# MPM Migration — Multi-Agent Automation

Automates the migration of a legacy **Grails** application to a modern
**React + Spring Boot** stack, using a **multi-agent system** built on the
**Anthropic Python SDK**.

**Author:** Debraj Som

This repository contains three parts: the **base app** (the legacy Grails
source), the **agents** that automate the migration, and the **agentic-migrated
app** (the React + Spring Boot output the agents produced).

---

## What's in this repo

| Path | What it is |
|------|------------|
| [`grails-ui-demo/`](grails-ui-demo/) | **Base app** — the legacy Grails application being migrated. Contains the source and the `specs.md` specification. |
| [`mpm-agents/`](mpm-agents/) | **The agents** — an autonomous Orchestrator + four specialist subagents (Figma→React, Spec→Spring Boot, test, code-review) on the Anthropic Python SDK. See [`mpm-agents/README.md`](mpm-agents/README.md). |
| [`MPM-Migration-Orchestration/`](MPM-Migration-Orchestration/) | **Agentic-migrated app** — the React + Spring Boot app the agents produced: `mpm-backend/` (Spring Boot, port 8082) + `mpm-ui/` (React, port 5174) + `reviews/` (code-review reports). |

> Build artifacts (`build/`, `node_modules/`, `.gradle/`, `__pycache__/`) and
> large archives are excluded via `.gitignore`; the agent-generated **source**
> under `MPM-Migration-Orchestration/` is committed.

---

## The migration pipeline

```
                              requirements.xlsx
                                     │
                                     ▼
                         ┌───────────────────────────┐
   grails-ui-demo/  ───► │       orchestrator.py      │  reads Excel, decomposes,
   (specs.md, base app)  │     (Orchestrator agent)   │  routes, sequences, monitors
                         └─────────────┬──────────────┘
                       subagents exposed as TOOLS (LLM mode)
                       or called directly  (--no-llm mode)
           ┌────────────────┬──────────┴──────────┬─────────────────┐
           ▼                ▼                      ▼                 ▼
     figma_agent.py    spec_agent.py        test_agent.py     review_agent.py
     Figma → React     Spec → Spring Boot   unit tests for    reviews code vs.
                       (reads specs.md)     ui / backend      coding_standards.md
           │                │                      │                 │
           │                │   build patterns + ports pinned in agent prompts
           │                │                      │                 │
           └────────────────┴──────────┬───────────┴─────────────────┘
                                        ▼
                                  sdk_runner.py
              (Anthropic client · client-side tools · agentic loop ·
               StatusTracker · Figma MCP bridge · mock mode)
                                        │
                                        ▼
                          MPM-Migration-Orchestration/   (generated output)
                            ├── mpm-ui/        (React)
                            ├── mpm-backend/   (Spring Boot)
                            └── reviews/       (code-review reports)
```

**In one sentence:** the Orchestrator is itself a Claude agent whose "tools" are
the four subagents; it reads requirements from Excel and dispatches each to the
right subagent until the migration is done, while a shared `StatusTracker`
records progress at the subagent level.

### The agents

| Agent | Does |
|-------|------|
| **Orchestrator** | Reads `requirements.xlsx`, decomposes/routes each requirement, sequences generation before test/review, and summarises. LLM-driven (autonomous) or deterministic (`--no-llm`). |
| **Figma agent** | Converts a Figma design into React 18 + Vite components (via the Figma MCP server). |
| **Spec agent** | Reads `grails-ui-demo/specs.md` and generates a Spring Boot backend. |
| **Test agent** | Writes **and runs** unit tests for the generated frontend (Vitest + RTL) or backend (JUnit + MockMvc). |
| **Review agent** | Reviews generated code against `mpm-agents/coding_standards.md` and writes a verdict report. Review-only — does not modify code. |

---

## Quick start

> Prerequisites: **Python 3.10+**, **Node.js** (Figma MCP server + frontend
> tests), and an `ANTHROPIC_API_KEY`.

```powershell
cd mpm-agents
pip install -r requirements.txt

# 1. create a sample requirements workbook
python orchestrator.py --init-sample

# 2. validate the orchestrator -> subagents wiring WITHOUT an API key (mock mode)
python validate.py

# 3. run the full pipeline (autonomous, LLM-driven) — needs ANTHROPIC_API_KEY
$env:ANTHROPIC_API_KEY = "sk-ant-..."
python orchestrator.py --requirements requirements.xlsx
```

Full agent documentation: [`mpm-agents/README.md`](mpm-agents/README.md).

---

## Tech stack

- **Base app:** Grails / Groovy / Gradle
- **Target stack:** React 18 + Vite, Spring Boot 3.2 (Java 21) + Spring Security (JWT) + JPA
- **Agents:** Python 3.10+, Anthropic Python SDK (`claude-opus-4-8`), Model Context Protocol (Figma MCP server)
