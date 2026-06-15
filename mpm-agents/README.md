# MPM Multi-Agent Migration System

**Author:** Debraj Som

Automates the migration of a legacy **Grails** app to **React + Spring Boot**.
A fully autonomous **Orchestrator agent** reads requirements from an Excel
workbook, decomposes them, and dispatches each to one of four specialist
subagents. Everything runs on the **Anthropic Python SDK** through one shared
runtime (`sdk_runner.py`).

```
                 requirements.xlsx
                        │
                        ▼
            ┌───────────────────────┐
            │   orchestrator.py     │  reads Excel, decomposes,
            │  (Orchestrator agent) │  routes, sequences, monitors
            └───────────┬───────────┘
            subagents exposed as tools
   ┌──────────────┬─────┴──────┬──────────────┐
   ▼              ▼            ▼              ▼
figma_agent   spec_agent   test_agent   review_agent
Figma→React   Spec→Spring   unit tests   code review vs.
              Boot          (run them)   coding_standards.md
   └──────────────┴─────┬──────┴──────────────┘
                  all on sdk_runner.py
                        │
                        ▼
          MPM-Migration-Orchestration/   (generated output)
            ├── mpm-backend/  (Spring Boot, port 8082)
            ├── mpm-ui/       (React, port 5174)
            └── reviews/      (code-review reports)
```

---

## Files

| File | Purpose |
|------|---------|
| `sdk_runner.py`   | Shared runtime: Anthropic client, client-side tools (read/write/edit/list/mkdir/run_command), agentic loop (streaming + adaptive thinking), `StatusTracker`, Figma MCP bridge, mock mode. |
| `orchestrator.py` | Autonomous orchestrator. Reads Excel, calls the subagents (as tools in LLM mode, or directly with `--no-llm`). |
| `figma_agent.py`  | Figma → React subagent. Writes React to `MPM-Migration-Orchestration/mpm-ui/`. |
| `spec_agent.py`   | Spec → Spring Boot subagent. Reads `grails-ui-demo/specs.md`, writes to `MPM-Migration-Orchestration/mpm-backend/`. |
| `test_agent.py`   | Writes **and runs** unit tests for the generated frontend / backend. |
| `review_agent.py` | Reviews generated code against `coding_standards.md`, writes a report to `reviews/`. Review-only (does not modify code). |
| `coding_standards.md` | The rules the review agent checks against. Edit this to change reviews — no code change needed. |
| `validate.py`     | Verifies the orchestrator → 4-subagents wiring with **no API key** (mock mode). |
| `requirements.txt`| Python dependencies. |

---

## Prerequisites

1. **Python 3.10+** (this project was run on 3.13). Verify: `python --version`.
2. **Node.js** — required for the Figma MCP server (`npx figma-developer-mcp`) and
   for running/building the React frontend. Verify: `node --version`.
3. **Local Gradle 8.14.2** — used to build/test the generated backend. This
   project intentionally uses a locally installed `gradle`, **not** the Gradle
   wrapper (`gradlew`) and **not** Gradle 9.x.
4. An **Anthropic API key** (from console.anthropic.com — this is a billed,
   programmatic key, separate from any Claude subscription).
5. A **Figma API key** (from Figma → Settings → Account → Personal access tokens)
   if you want the `figma_agent` to read real designs.

---

## Setup (first time)

From this folder (`mpm-agents/`):

```powershell
# 1. Install Python dependencies (installs the anthropic SDK + the mcp client + openpyxl)
pip install -U "anthropic[mcp]"
pip install -r requirements.txt

# 2. Set your Anthropic API key as an environment variable.
#    The SDK reads ANTHROPIC_API_KEY automatically — do NOT paste it into any file.
#    Persistent (survives reboots) — then OPEN A NEW TERMINAL afterwards:
setx ANTHROPIC_API_KEY "sk-ant-..."
#    (or, current session only:  $env:ANTHROPIC_API_KEY = "sk-ant-...")

# 3. Confirm the key is visible (in a fresh terminal):
python -c "import os; print('key set:', bool(os.environ.get('ANTHROPIC_API_KEY')))"
```

### Figma MCP config (`.mcp.json`)

The `figma_agent` connects to the Figma MCP server, configured in a `.mcp.json`
at the **project root** (one level above `mpm-agents/`). This file contains a
live Figma token, so it is **git-ignored** and not committed — create your own:

```json
{
  "mcpServers": {
    "figma": {
      "command": "C:\\Program Files\\nodejs\\npx.cmd",
      "args": ["-y", "figma-developer-mcp", "--figma-api-key=YOUR_FIGMA_TOKEN", "--stdio"]
    }
  }
}
```

> If you only want the backend (`spec_agent`) or don't need real Figma data, the
> `figma_agent` falls back to building screens from `grails-ui-demo/specs.md`.

---

## How to run

```powershell
# 0. (optional) Validate the wiring WITHOUT an API key (mock mode)
python validate.py

# 1. (optional) Create / regenerate the requirements workbook.
#    A spec-derived requirements.xlsx is already included; this writes a fresh sample.
python orchestrator.py --init-sample

# 2. Run the full pipeline (autonomous, LLM-driven) — needs ANTHROPIC_API_KEY
python orchestrator.py
#    (defaults to requirements.xlsx; or pass --requirements path\to\file.xlsx)

# 2b. Deterministic routing instead of LLM (routes by the Type column)
python orchestrator.py --no-llm
```

Run any subagent on its own:

```powershell
python spec_agent.py   --task "Implement the backend from specs.md"
python figma_agent.py  --task "Build the login screen" --figma-url "https://www.figma.com/design/<key>/...?node-id=<id>"
python test_agent.py   --target backend  --task "Test the organisation service"
python review_agent.py --target backend  --task "Review the generated services"
```

### Monitoring progress

- The orchestrator prints a live status table and a final summary.
- `agent_status.json` is rewritten on every state change — watch it live:
  ```powershell
  Get-Content agent_status.json -Wait
  ```

---

## Requirements workbook format

Sheet 1, header row 1, one requirement per row:

| Column | Meaning |
|--------|---------|
| ID | Identifier, e.g. `R1`. |
| Requirement | What to do (free text). |
| Type | `spec`→spec_agent, `figma`→figma_agent, `test`→test_agent, `review`→review_agent, `auto`→inferred. |
| Target | `frontend` or `backend` (used by `test` and `review`). |
| Priority | High / Medium / Low (informational). |
| Notes | Free text; for `figma` rows put the Figma URL here. |

The orchestrator sequences generation (spec/figma) **before** tests and reviews.

---

## Output & running the generated apps

All generated code lands under `MPM-Migration-Orchestration/` at the project root:

```
MPM-Migration-Orchestration/
├── mpm-backend/   Spring Boot — runs on port 8082
├── mpm-ui/        React (Vite) — runs on port 5174 (proxies /api → 8082)
└── reviews/       code-review reports (read these)
```

> **Ports** are deliberately offset so the generated app runs side-by-side with
> the legacy Grails app (8080) and the hand-built reference (8081 / 5173) without
> clashing.

Start the generated apps in two terminals:

```powershell
# Backend  (http://localhost:8082)
cd ..\MPM-Migration-Orchestration\mpm-backend
gradle bootRun

# Frontend (http://localhost:5174)
cd ..\MPM-Migration-Orchestration\mpm-ui
npm install
npm run dev
```

Log in with the seeded credentials (from `specs.md`):
- **admin / admin123** — ADMIN, all fields editable
- **debraj / debraj123** — USER, admin-only fields disabled (and ignored server-side)

---

## How the orchestrator calls the subagents

In **LLM mode** the four subagents are registered as Anthropic *tools*
(`run_figma_agent`, `run_spec_agent`, `run_test_agent`, `run_review_agent`, plus
`get_subagent_status`). Claude reads the requirements and decides which tool to
call for each. In **`--no-llm` mode** the orchestrator routes each row by its
`Type` column and calls the same `run_*_agent()` functions directly. Either way
the call path is orchestrator → subagent, which `validate.py` checks.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `key set: False` | Key not in this shell. Re-run `setx ...` and open a **new** terminal. |
| `ModuleNotFoundError: anthropic` / `mcp` | `pip install -U "anthropic[mcp]"`. |
| `TypeError` about `thinking` / `effort` params | SDK too old: `pip install -U anthropic`. |
| Figma agent can't connect | Check `.mcp.json` exists at the project root with a valid Figma token and Node is installed. |
| Backend build fails / wants to download Gradle | Use local **gradle 8.14.2** (`gradle`, not `gradlew`); no network to Gradle servers is needed. |
| Port already in use | Something else is on 8082/5174 — stop it, or change the port in `application.yml` / `vite.config.js`. |

---

## Notes

- Model: `claude-opus-4-8`, adaptive thinking, `effort="high"`. Tune
  `DEFAULT_EFFORT` / `MODEL` in `sdk_runner.py` for cheaper/faster runs.
- The review agent's rules live in `coding_standards.md` — edit there to change
  what reviews enforce, without touching any code.
- A real run makes billed API calls and can take a while; run a single subagent
  first for a cheaper smoke test.
