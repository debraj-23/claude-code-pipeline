"""
sdk_runner.py
=============

Shared agent runtime for the MPM multi-agent migration system.

Every agent in this project (the Orchestrator and the three subagents -
figma_agent, spec_agent, test_agent) is built on top of the `AgentRunner`
class defined here. It wraps the official Anthropic Python SDK and provides:

  * A configured Anthropic client (model: claude-opus-4-8, adaptive thinking,
    streaming, effort control).
  * A reusable set of *client-side* tools (read/write/edit files, list dirs,
    make dirs, run shell commands) sandboxed to the base project directory.
  * A manual agentic loop that streams output, executes tool calls, and loops
    until the model is done.
  * A thread-safe `StatusTracker` so progress can be observed at the
    *subagent* level (queued -> running -> tool calls -> done/failed).
  * An `McpStdioBridge` that connects to a local stdio MCP server (used by
    figma_agent to talk to the Figma MCP server) and exposes its tools as
    ordinary Anthropic tools.
  * A MOCK mode (env MPM_AGENTS_MOCK=1) that skips the API entirely so the
    orchestrator -> subagent wiring can be validated without an API key.

Requires:  pip install "anthropic[mcp]"   (the [mcp] extra is only needed by
figma_agent; the other agents work with plain `anthropic`).

Author: Debraj Som
"""

from __future__ import annotations

import asyncio
import json
import os
import subprocess
import threading
import time
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional

# ---------------------------------------------------------------------------
# Paths & global configuration
# ---------------------------------------------------------------------------

# mpm-agents/ lives directly under the base project directory.
BASE_DIR = Path(__file__).resolve().parent.parent
AGENTS_DIR = Path(__file__).resolve().parent

# Output locations required by the use case. All agent-generated, migrated
# components live under MPM-Migration-Orchestration/ at the project root.
ORCH_OUTPUT_DIR = BASE_DIR / "MPM-Migration-Orchestration"
MPM_UI_DIR = ORCH_OUTPUT_DIR / "mpm-ui"
MPM_BACKEND_DIR = ORCH_OUTPUT_DIR / "mpm-backend"

# Relative paths (from the project root) used inside agent prompts/tasks so the
# client-side tools resolve them correctly.
UI_REL = "MPM-Migration-Orchestration/mpm-ui"
BACKEND_REL = "MPM-Migration-Orchestration/mpm-backend"

# Reference material the subagents are allowed to read.
SOURCE_APP_DIR = BASE_DIR / "grails-ui-demo"
MIGRATED_APP_DIR = BASE_DIR / "MPM-Migration"
DEFAULT_SPEC_FILE = SOURCE_APP_DIR / "specs.md"

# Coding standards the review_agent checks generated code against.
DEFAULT_STANDARDS_FILE = AGENTS_DIR / "coding_standards.md"
# Where the review_agent writes its review reports.
REVIEWS_REL = "MPM-Migration-Orchestration/reviews"

# Status file the orchestrator and any UI can poll.
STATUS_FILE = AGENTS_DIR / "agent_status.json"

MODEL = "claude-opus-4-8"
MAX_TOKENS = 64000          # streaming -> safe to give the model room
DEFAULT_EFFORT = "high"     # low | medium | high | xhigh | max
MAX_TURNS = 60              # hard ceiling on agentic loop iterations

MOCK = os.environ.get("MPM_AGENTS_MOCK", "") not in ("", "0", "false", "False")

# ---------------------------------------------------------------------------
# Authorship / watermark
# ---------------------------------------------------------------------------

AUTHOR = "Debraj Som"


def banner() -> str:
    """A small attribution banner printed by the orchestrator and each agent."""
    return (
        "\n"
        "============================================================\n"
        "  MPM Multi-Agent Migration System\n"
        f"  Developed by {AUTHOR}\n"
        "============================================================"
    )


def print_banner() -> None:
    print(banner())


# ---------------------------------------------------------------------------
# Status tracking (observable at the subagent level)
# ---------------------------------------------------------------------------

@dataclass
class AgentStatus:
    name: str
    state: str = "queued"           # queued | running | completed | failed
    task: str = ""
    activity: str = ""              # human-readable current activity
    tool_calls: int = 0
    turns: int = 0
    started_at: Optional[float] = None
    finished_at: Optional[float] = None
    files_written: List[str] = field(default_factory=list)
    error: Optional[str] = None
    result_summary: str = ""

    def elapsed(self) -> float:
        if self.started_at is None:
            return 0.0
        end = self.finished_at or time.time()
        return round(end - self.started_at, 1)


class StatusTracker:
    """Thread-safe registry of per-agent status, persisted to STATUS_FILE.

    Shared by the orchestrator across all subagents so the user can monitor
    progress at the subagent level (in-process via `snapshot()` or out of
    process by reading agent_status.json).
    """

    def __init__(self, status_file: Path = STATUS_FILE):
        self._agents: Dict[str, AgentStatus] = {}
        self._lock = threading.RLock()
        self._status_file = status_file

    # -- registration / lookup --------------------------------------------
    def register(self, name: str, task: str = "") -> AgentStatus:
        with self._lock:
            st = self._agents.get(name) or AgentStatus(name=name)
            st.task = task or st.task
            st.state = "queued"
            self._agents[name] = st
            self._flush()
            return st

    def get(self, name: str) -> Optional[AgentStatus]:
        with self._lock:
            return self._agents.get(name)

    # -- mutations ---------------------------------------------------------
    def update(self, name: str, **fields: Any) -> None:
        with self._lock:
            st = self._agents.get(name)
            if st is None:
                st = AgentStatus(name=name)
                self._agents[name] = st
            for k, v in fields.items():
                setattr(st, k, v)
            self._flush()

    def mark_running(self, name: str, activity: str = "") -> None:
        with self._lock:
            st = self._agents.setdefault(name, AgentStatus(name=name))
            st.state = "running"
            st.activity = activity
            if st.started_at is None:
                st.started_at = time.time()
            self._flush()

    def bump_turn(self, name: str, activity: str = "") -> None:
        with self._lock:
            st = self._agents.setdefault(name, AgentStatus(name=name))
            st.turns += 1
            if activity:
                st.activity = activity
            self._flush()

    def record_tool_call(self, name: str, tool: str, file_written: Optional[str] = None) -> None:
        with self._lock:
            st = self._agents.setdefault(name, AgentStatus(name=name))
            st.tool_calls += 1
            st.activity = f"tool: {tool}"
            if file_written and file_written not in st.files_written:
                st.files_written.append(file_written)
            self._flush()

    def mark_done(self, name: str, summary: str = "") -> None:
        with self._lock:
            st = self._agents.setdefault(name, AgentStatus(name=name))
            st.state = "completed"
            st.activity = "done"
            st.result_summary = summary
            st.finished_at = time.time()
            self._flush()

    def mark_failed(self, name: str, error: str) -> None:
        with self._lock:
            st = self._agents.setdefault(name, AgentStatus(name=name))
            st.state = "failed"
            st.activity = "failed"
            st.error = error
            st.finished_at = time.time()
            self._flush()

    # -- views -------------------------------------------------------------
    def snapshot(self) -> Dict[str, dict]:
        with self._lock:
            return {name: asdict(st) for name, st in self._agents.items()}

    def render_table(self) -> str:
        with self._lock:
            rows = ["", "  AGENT                STATE       TURNS  TOOLS  ELAPSED  ACTIVITY",
                    "  " + "-" * 78]
            for st in self._agents.values():
                rows.append(
                    f"  {st.name:<20} {st.state:<11} {st.turns:<6} "
                    f"{st.tool_calls:<6} {st.elapsed():<8} {st.activity[:24]}"
                )
            rows.append("  " + "-" * 78)
            rows.append(f"  MPM Multi-Agent Migration System · developed by {AUTHOR}")
            return "\n".join(rows)

    def _flush(self) -> None:
        try:
            data = {name: asdict(st) for name, st in self._agents.items()}
            self._status_file.write_text(json.dumps(data, indent=2), encoding="utf-8")
        except Exception:
            # Status persistence is best-effort; never let it crash an agent.
            pass


# ---------------------------------------------------------------------------
# Client-side tools (sandboxed to BASE_DIR)
# ---------------------------------------------------------------------------

def _resolve(path: str) -> Path:
    """Resolve a tool-supplied path against BASE_DIR and keep it inside the sandbox."""
    p = Path(path)
    if not p.is_absolute():
        p = BASE_DIR / p
    p = p.resolve()
    if BASE_DIR not in p.parents and p != BASE_DIR:
        raise ValueError(f"Path '{path}' is outside the allowed project directory.")
    return p


def _tool_read_file(path: str, **_: Any) -> str:
    p = _resolve(path)
    if not p.exists():
        return f"ERROR: file not found: {path}"
    if p.is_dir():
        return f"ERROR: '{path}' is a directory; use list_dir."
    try:
        text = p.read_text(encoding="utf-8", errors="replace")
    except Exception as e:  # noqa: BLE001
        return f"ERROR reading {path}: {e}"
    # Guard against dumping huge files into context.
    if len(text) > 200_000:
        text = text[:200_000] + "\n...[truncated]..."
    return text


def _tool_write_file(path: str, content: str, **_: Any) -> str:
    p = _resolve(path)
    try:
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content, encoding="utf-8")
    except Exception as e:  # noqa: BLE001
        return f"ERROR writing {path}: {e}"
    return f"WROTE {p.relative_to(BASE_DIR)} ({len(content)} bytes)"


def _tool_edit_file(path: str, old_string: str, new_string: str, **_: Any) -> str:
    p = _resolve(path)
    if not p.exists():
        return f"ERROR: file not found: {path}"
    try:
        text = p.read_text(encoding="utf-8")
    except Exception as e:  # noqa: BLE001
        return f"ERROR reading {path}: {e}"
    count = text.count(old_string)
    if count == 0:
        return "ERROR: old_string not found in file."
    if count > 1:
        return f"ERROR: old_string is not unique ({count} matches); add more context."
    p.write_text(text.replace(old_string, new_string), encoding="utf-8")
    return f"EDITED {p.relative_to(BASE_DIR)}"


def _tool_list_dir(path: str = ".", **_: Any) -> str:
    p = _resolve(path)
    if not p.exists():
        return f"ERROR: not found: {path}"
    if p.is_file():
        return f"FILE {path}"
    entries = []
    for child in sorted(p.iterdir()):
        if child.name in (".git", "node_modules", "build", ".gradle", "target", "dist"):
            entries.append(f"  {child.name}/ (skipped)")
            continue
        entries.append(f"  {child.name}/" if child.is_dir() else f"  {child.name}")
    return f"{p.relative_to(BASE_DIR) if p != BASE_DIR else '.'}:\n" + "\n".join(entries)


def _tool_make_dir(path: str, **_: Any) -> str:
    p = _resolve(path)
    p.mkdir(parents=True, exist_ok=True)
    return f"CREATED dir {p.relative_to(BASE_DIR)}"


def _tool_run_command(command: str, cwd: str = ".", timeout: int = 600, **_: Any) -> str:
    work = _resolve(cwd)
    if not work.exists():
        return f"ERROR: cwd not found: {cwd}"
    try:
        proc = subprocess.run(
            command,
            cwd=str(work),
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        return f"ERROR: command timed out after {timeout}s: {command}"
    except Exception as e:  # noqa: BLE001
        return f"ERROR running command: {e}"
    out = (proc.stdout or "")[-15000:]
    err = (proc.stderr or "")[-8000:]
    return (
        f"exit_code={proc.returncode}\n"
        f"--- stdout ---\n{out}\n"
        f"--- stderr ---\n{err}"
    )


@dataclass
class Tool:
    """A client-side tool: an Anthropic tool schema + a python handler."""
    name: str
    description: str
    input_schema: dict
    handler: Callable[..., str]
    writes_files: bool = False

    def to_anthropic(self) -> dict:
        return {
            "name": self.name,
            "description": self.description,
            "input_schema": self.input_schema,
        }


def filesystem_tools(include_shell: bool = False) -> List[Tool]:
    """Standard toolbox. `include_shell` adds run_command (needed by test_agent)."""
    tools = [
        Tool(
            name="read_file",
            description="Read a UTF-8 text file. Path is relative to the project root.",
            input_schema={
                "type": "object",
                "properties": {"path": {"type": "string", "description": "File path relative to project root."}},
                "required": ["path"],
            },
            handler=_tool_read_file,
        ),
        Tool(
            name="write_file",
            description="Create or overwrite a text file with the given content. Creates parent dirs.",
            input_schema={
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "File path relative to project root."},
                    "content": {"type": "string", "description": "Full file content."},
                },
                "required": ["path", "content"],
            },
            handler=_tool_write_file,
            writes_files=True,
        ),
        Tool(
            name="edit_file",
            description="Replace a unique old_string with new_string in an existing file.",
            input_schema={
                "type": "object",
                "properties": {
                    "path": {"type": "string"},
                    "old_string": {"type": "string"},
                    "new_string": {"type": "string"},
                },
                "required": ["path", "old_string", "new_string"],
            },
            handler=_tool_edit_file,
            writes_files=True,
        ),
        Tool(
            name="list_dir",
            description="List the contents of a directory (relative to project root).",
            input_schema={
                "type": "object",
                "properties": {"path": {"type": "string", "default": "."}},
                "required": [],
            },
            handler=_tool_list_dir,
        ),
        Tool(
            name="make_dir",
            description="Create a directory (and parents) relative to project root.",
            input_schema={
                "type": "object",
                "properties": {"path": {"type": "string"}},
                "required": ["path"],
            },
            handler=_tool_make_dir,
        ),
    ]
    if include_shell:
        tools.append(
            Tool(
                name="run_command",
                description=(
                    "Run a shell command (e.g. 'npm test', 'gradlew.bat test'). "
                    "Use for installing deps and running test suites. Returns exit code, stdout, stderr."
                ),
                input_schema={
                    "type": "object",
                    "properties": {
                        "command": {"type": "string"},
                        "cwd": {"type": "string", "default": "."},
                        "timeout": {"type": "integer", "default": 600},
                    },
                    "required": ["command"],
                },
                handler=_tool_run_command,
            )
        )
    return tools


# ---------------------------------------------------------------------------
# MCP stdio bridge (used by figma_agent for the Figma MCP server)
# ---------------------------------------------------------------------------

class McpStdioBridge:
    """Connect to a local stdio MCP server and expose its tools synchronously.

    Runs an asyncio event loop in a background thread so the rest of the runner
    can stay synchronous. Tool names are prefixed (e.g. 'figma__get_figma_data')
    to avoid collisions with the local filesystem tools.
    """

    def __init__(self, command: str, args: List[str], prefix: str = "mcp"):
        self.command = command
        self.args = args
        self.prefix = prefix
        self._loop: Optional[asyncio.AbstractEventLoop] = None
        self._thread: Optional[threading.Thread] = None
        self._session = None
        self._stdio_ctx = None
        self._session_ctx = None
        self._ready = threading.Event()
        self._mcp_tools: List[dict] = []   # raw MCP tool dicts: {name, description, inputSchema}

    # -- lifecycle ---------------------------------------------------------
    def start(self) -> None:
        self._thread = threading.Thread(target=self._run_loop, daemon=True)
        self._thread.start()
        if not self._ready.wait(timeout=60):
            raise RuntimeError("Timed out connecting to MCP server.")

    def _run_loop(self) -> None:
        self._loop = asyncio.new_event_loop()
        asyncio.set_event_loop(self._loop)
        self._loop.run_until_complete(self._connect())
        self._loop.run_forever()

    async def _connect(self) -> None:
        from mcp import ClientSession, StdioServerParameters
        from mcp.client.stdio import stdio_client

        params = StdioServerParameters(command=self.command, args=self.args)
        self._stdio_ctx = stdio_client(params)
        read, write = await self._stdio_ctx.__aenter__()
        self._session_ctx = ClientSession(read, write)
        self._session = await self._session_ctx.__aenter__()
        await self._session.initialize()
        listed = await self._session.list_tools()
        self._mcp_tools = [
            {"name": t.name, "description": t.description or "", "inputSchema": t.inputSchema}
            for t in listed.tools
        ]
        self._ready.set()

    # -- tool exposure -----------------------------------------------------
    def tools(self) -> List[Tool]:
        out: List[Tool] = []
        for t in self._mcp_tools:
            mcp_name = t["name"]
            exposed = f"{self.prefix}__{mcp_name}"
            out.append(
                Tool(
                    name=exposed,
                    description=t["description"],
                    input_schema=t.get("inputSchema") or {"type": "object", "properties": {}},
                    handler=self._make_handler(mcp_name),
                )
            )
        return out

    def _make_handler(self, mcp_name: str) -> Callable[..., str]:
        def handler(**kwargs: Any) -> str:
            return self.call(mcp_name, kwargs)
        return handler

    def call(self, mcp_name: str, arguments: dict) -> str:
        if self._loop is None or self._session is None:
            return "ERROR: MCP session not ready."
        fut = asyncio.run_coroutine_threadsafe(
            self._session.call_tool(mcp_name, arguments), self._loop
        )
        try:
            result = fut.result(timeout=180)
        except Exception as e:  # noqa: BLE001
            return f"ERROR calling MCP tool {mcp_name}: {e}"
        # Flatten the MCP content blocks into text.
        parts: List[str] = []
        for block in getattr(result, "content", []) or []:
            text = getattr(block, "text", None)
            if text is not None:
                parts.append(text)
            else:
                parts.append(str(block))
        return "\n".join(parts) if parts else "(no content returned)"

    def stop(self) -> None:
        if self._loop is None:
            return
        async def _close() -> None:
            try:
                if self._session_ctx is not None:
                    await self._session_ctx.__aexit__(None, None, None)
                if self._stdio_ctx is not None:
                    await self._stdio_ctx.__aexit__(None, None, None)
            except Exception:
                pass
        try:
            asyncio.run_coroutine_threadsafe(_close(), self._loop).result(timeout=15)
        except Exception:
            pass
        self._loop.call_soon_threadsafe(self._loop.stop)


def load_figma_mcp_bridge() -> McpStdioBridge:
    """Build an McpStdioBridge for the Figma server from the repo's .mcp.json."""
    mcp_config_path = BASE_DIR / ".mcp.json"
    cfg = json.loads(mcp_config_path.read_text(encoding="utf-8"))
    figma = cfg["mcpServers"]["figma"]
    bridge = McpStdioBridge(command=figma["command"], args=figma["args"], prefix="figma")
    bridge.start()
    return bridge


# ---------------------------------------------------------------------------
# The agent runner (manual agentic loop on the Messages API)
# ---------------------------------------------------------------------------

def _get_client():
    import anthropic
    return anthropic.Anthropic()


class AgentRunner:
    """Runs a single agent: a system prompt + a tool set + an agentic loop."""

    def __init__(
        self,
        name: str,
        system_prompt: str,
        tools: Optional[List[Tool]] = None,
        status: Optional[StatusTracker] = None,
        effort: str = DEFAULT_EFFORT,
        max_turns: int = MAX_TURNS,
        stream_to_console: bool = True,
    ):
        self.name = name
        self.system_prompt = system_prompt
        self.tools: List[Tool] = tools or filesystem_tools()
        self._tool_map = {t.name: t for t in self.tools}
        self.status = status or StatusTracker()
        self.effort = effort
        self.max_turns = max_turns
        self.stream_to_console = stream_to_console

    def run(self, task: str) -> dict:
        """Run the agent to completion. Returns a result dict."""
        self.status.register(self.name, task=task)
        self.status.mark_running(self.name, activity="starting")

        if MOCK:
            return self._run_mock(task)

        try:
            return self._run_real(task)
        except Exception as e:  # noqa: BLE001
            self.status.mark_failed(self.name, error=str(e))
            return {"agent": self.name, "ok": False, "error": str(e)}

    # -- real loop ---------------------------------------------------------
    def _run_real(self, task: str) -> dict:
        client = _get_client()
        anthropic_tools = [t.to_anthropic() for t in self.tools]
        messages: List[dict] = [{"role": "user", "content": task}]
        final_text = ""

        for _turn in range(self.max_turns):
            self.status.bump_turn(self.name, activity="thinking")
            with client.messages.stream(
                model=MODEL,
                max_tokens=MAX_TOKENS,
                system=self.system_prompt,
                thinking={"type": "adaptive"},
                output_config={"effort": self.effort},
                tools=anthropic_tools,
                messages=messages,
            ) as stream:
                if self.stream_to_console:
                    for text in stream.text_stream:
                        print(text, end="", flush=True)
                response = stream.get_final_message()

            if self.stream_to_console:
                print()

            messages.append({"role": "assistant", "content": response.content})

            if response.stop_reason != "tool_use":
                final_text = "".join(b.text for b in response.content if b.type == "text")
                break

            tool_results = []
            for block in response.content:
                if block.type != "tool_use":
                    continue
                result_str = self._execute_tool(block.name, block.input)
                tool_results.append(
                    {"type": "tool_result", "tool_use_id": block.id, "content": result_str}
                )
            messages.append({"role": "user", "content": tool_results})
        else:
            self.status.mark_failed(self.name, error=f"hit max_turns ({self.max_turns})")
            return {"agent": self.name, "ok": False, "error": "max_turns reached"}

        st = self.status.get(self.name)
        self.status.mark_done(self.name, summary=final_text[:500])
        return {
            "agent": self.name,
            "ok": True,
            "summary": final_text,
            "files_written": list(st.files_written) if st else [],
            "tool_calls": st.tool_calls if st else 0,
        }

    def _execute_tool(self, tool_name: str, tool_input: dict) -> str:
        tool = self._tool_map.get(tool_name)
        if tool is None:
            return f"ERROR: unknown tool '{tool_name}'."
        file_written = tool_input.get("path") if tool.writes_files else None
        self.status.record_tool_call(self.name, tool_name, file_written=file_written)
        try:
            return tool.handler(**tool_input)
        except TypeError as e:
            return f"ERROR: bad arguments for {tool_name}: {e}"
        except Exception as e:  # noqa: BLE001
            return f"ERROR in {tool_name}: {e}"

    # -- mock loop (no API) ------------------------------------------------
    def _run_mock(self, task: str) -> dict:
        """Simulate a short run so orchestrator->subagent wiring can be tested."""
        self.status.bump_turn(self.name, activity="mock")
        self.status.record_tool_call(self.name, "write_file", file_written=f"mock/{self.name}.txt")
        summary = f"[MOCK] {self.name} handled task: {task[:120]}"
        self.status.mark_done(self.name, summary=summary)
        if self.stream_to_console:
            print(summary)
        return {"agent": self.name, "ok": True, "summary": summary,
                "files_written": [f"mock/{self.name}.txt"], "tool_calls": 1, "mock": True}
