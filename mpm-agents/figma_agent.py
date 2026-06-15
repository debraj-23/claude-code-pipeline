"""
figma_agent.py
==============

Figma -> React converter subagent.

Author: Debraj Som

Connects to the Figma MCP server (configured in the repo's .mcp.json) and turns
a Figma design into React 18 + Vite components, writing the generated code under
the /mpm-ui folder in the base project directory.

Public entry point:

    run_figma_agent(task, figma_url=None, status=None) -> dict

The orchestrator calls this directly (see orchestrator.py). It can also be run
standalone:

    python figma_agent.py --figma-url "https://www.figma.com/design/<key>/...?node-id=<id>"
"""

from __future__ import annotations

import argparse
from typing import Optional

from sdk_runner import (
    AgentRunner,
    StatusTracker,
    McpStdioBridge,
    filesystem_tools,
    load_figma_mcp_bridge,
    MPM_UI_DIR,
    UI_REL,
    BASE_DIR,
    MOCK,
    print_banner,
)

AGENT_NAME = "figma_agent"

SYSTEM_PROMPT = f"""\
You are the Figma-to-React conversion subagent in an automated migration pipeline.

## Your job
Convert a Figma design into production-quality React components and write them
under the `{UI_REL}/` folder at the project root.

## Tools
- You have a Figma MCP toolset (tools prefixed `figma__`). Use `figma__get_figma_data`
  to read the design's structure, layout, styles, text and component tree, and
  `figma__download_figma_images` to export any image/icon assets you need.
- You have filesystem tools (read_file, write_file, edit_file, list_dir, make_dir)
  scoped to the project root. ALWAYS write generated frontend code under `{UI_REL}/`.

## Target stack & conventions
- React 18 + Vite + React Router v6 + Axios (functional components, hooks).
- Use this standard structure under `{UI_REL}/src`:
    src/pages/        page-level components
    src/components/   reusable presentational components
    src/context/      React context (e.g. AuthContext)
    src/api/axios.js  configured axios instance
    src/styles/       theme / shared style tokens
    src/App.jsx, src/main.jsx
- Keep styling faithful to the Figma design (colors, spacing, typography, layout).
- No TypeScript unless explicitly asked; use `.jsx`.

## Build configuration & ports
When you scaffold the project, use these build patterns exactly (do not invent
your own versions).
Use these deps (react 18.3.1, react-dom 18.3.1, react-router-dom 6.23.1,
axios 1.6.8) and devDeps (@vitejs/plugin-react 4.3.0, vite 5.x), "type": "module",
and the dev/build/preview scripts.

PORTS - the reference apps occupy 8080 (legacy Grails), 8081 (reference backend)
and 5173 (reference frontend). So this generated frontend MUST run on a free
neighbour: in vite.config.js set `server.port: 5174` and proxy `/api` to
`http://localhost:8082` (the generated backend's port). Point the axios baseURL
at `/api` so the dev proxy handles it.

## Parsing a Figma URL
A frame URL looks like:
  https://www.figma.com/design/<FILE_KEY>/<name>?node-id=<NODE_ID>&...
- FILE_KEY is the path segment right after `/design/`
  (e.g. `e2RQMTHDbU2eSIKrTFXoAf`).
- NODE_ID is the `node-id` query param, but the API wants COLONS not dashes:
  `node-id=24-8` -> nodeId `24:8`. If a call errors on the format, retry with the
  original dash form (`24-8`).
Call `figma__get_figma_data` with `fileKey` and `nodeId` extracted this way.

## Workflow
1. If a Figma URL/file key/node id is provided, parse it as above and call
   `figma__get_figma_data` to fetch the design (and `figma__download_figma_images`
   for any icon/image assets, saving them under the React assets folder).
   If NO Figma design is provided, fall back to the written spec: read
   `grails-ui-demo/specs.md` and build the screens from its "Pages & UI Screens"
   and "UI Style Guide" sections, staying consistent with any existing
   `{UI_REL}/` code.
2. Inspect `{UI_REL}/` (list_dir) to see what already exists; create the scaffold
   (package.json, vite.config.js, index.html, src/main.jsx, src/App.jsx) only if
   it does not exist yet.
3. Generate or update the React components that realise the requested screen(s).
4. Keep components small and composable. Extract repeated UI into components/.
5. When done, summarise the files you created/changed and any follow-ups.

Be precise and complete. Do not leave TODO placeholders in generated code.
"""


def build_figma_runner(status: Optional[StatusTracker] = None,
                       bridge: Optional[McpStdioBridge] = None) -> tuple[AgentRunner, Optional[McpStdioBridge]]:
    """Construct the figma AgentRunner. Returns (runner, bridge_to_close)."""
    tools = filesystem_tools(include_shell=False)
    owns_bridge = False
    if not MOCK:
        if bridge is None:
            bridge = load_figma_mcp_bridge()
            owns_bridge = True
        tools = tools + bridge.tools()
    runner = AgentRunner(
        name=AGENT_NAME,
        system_prompt=SYSTEM_PROMPT,
        tools=tools,
        status=status,
        effort="high",
    )
    return runner, (bridge if owns_bridge else None)


def run_figma_agent(task: str,
                    figma_url: Optional[str] = None,
                    status: Optional[StatusTracker] = None,
                    bridge: Optional[McpStdioBridge] = None) -> dict:
    """Run the Figma->React subagent for one task.

    `bridge` may be supplied by the orchestrator to reuse a single Figma MCP
    connection across multiple tasks; otherwise one is created and closed here.
    """
    full_task = task
    if figma_url:
        full_task = (
            f"Figma design source: {figma_url}\n\n"
            f"Task: {task}\n\n"
            f"Output directory: {UI_REL}/"
        )
    else:
        full_task = f"Task: {task}\n\nOutput directory: {UI_REL}/"

    runner, owned_bridge = build_figma_runner(status=status, bridge=bridge)
    try:
        return runner.run(full_task)
    finally:
        if owned_bridge is not None:
            owned_bridge.stop()


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Figma -> React subagent")
    parser.add_argument("--task", default="Convert the organisation home screen design into React components.")
    parser.add_argument("--figma-url", default=None, help="Figma design URL (with node-id).")
    args = parser.parse_args()

    print_banner()
    MPM_UI_DIR.mkdir(parents=True, exist_ok=True)
    result = run_figma_agent(args.task, figma_url=args.figma_url)
    print("\n=== figma_agent result ===")
    print(result)


if __name__ == "__main__":
    _cli()
