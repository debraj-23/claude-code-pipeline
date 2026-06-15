"""
review_agent.py
===============

Code-review subagent. Reviews newly generated frontend or backend code against
the project's coding standards and writes a structured review report.

Author: Debraj Som

  * target="frontend" -> reviews React code under MPM-Migration-Orchestration/mpm-ui/
  * target="backend"  -> reviews Spring Boot code under MPM-Migration-Orchestration/mpm-backend/

The standards it checks against live in mpm-agents/coding_standards.md
(DEFAULT_STANDARDS_FILE). A different standards file can be supplied per task.

The agent is review-only: it reads the standards + the generated code and writes
a markdown report under MPM-Migration-Orchestration/reviews/. It does NOT modify
the code it is reviewing (fixing is the generating agent's job).

Public entry point:

    run_review_agent(task, target="backend", standards_path=None, status=None) -> dict

Standalone:

    python review_agent.py --target backend --task "Review the generated services"
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Optional

from sdk_runner import (
    AgentRunner,
    StatusTracker,
    filesystem_tools,
    DEFAULT_STANDARDS_FILE,
    BASE_DIR,
    UI_REL,
    BACKEND_REL,
    REVIEWS_REL,
    print_banner,
)

AGENT_NAME = "review_agent"

_FRONTEND_GUIDE = f"""\
Target: FRONTEND (React) under `{UI_REL}/`.
- Focus on the "General", "Frontend (React / JavaScript)", and "Tests" sections
  of the coding standards.
- Pay special attention to: hooks rules and effect dependency arrays, list keys,
  centralised API calls, loading/error handling, and role-driven rendering that
  matches the backend permission rules.
"""

_BACKEND_GUIDE = f"""\
Target: BACKEND (Spring Boot) under `{BACKEND_REL}/`.
- Focus on the "General", "Backend (Java / Spring Boot)", and "Tests" sections
  of the coding standards.
- Pay special attention to: controller -> service -> repository layering, DTOs at
  the boundary, constructor injection, BCrypt password hashing, server-side
  role enforcement, centralised exception handling, and SQL-injection safety.
"""

SYSTEM_PROMPT_TEMPLATE = """\
You are the code-review subagent in an automated migration pipeline. You review
code another subagent just generated against the project's coding standards, then
write a structured review report. You do NOT modify the code under review.

## Tools
You have filesystem tools (read_file, write_file, edit_file, list_dir, make_dir)
scoped to the project root. Use read_file/list_dir to inspect the standards and
the generated code, and write_file ONLY to write your review report under
`{reviews_rel}/`.

{guide}

## Workflow
1. read_file the coding standards file (its path is given in the task). Treat it
   as the source of truth for what to check and how to assign severity.
2. list_dir / read_file the target source tree to understand what was generated.
   If the target directory is empty or missing, write a short report saying there
   is nothing to review and stop.
3. Review the code file by file against the standards. For every finding record:
   the rule id + one-line description, severity (BLOCKER / MAJOR / MINOR), the
   file and approximate location, and a concrete suggested fix.
4. Be specific and fair: cite the exact file and code. Do not invent issues; if
   the code follows a rule, do not report it. Do not fix the code yourself.
5. Write the report to `{reviews_rel}/code-review-{target}.md` using write_file,
   following the "Review output contract" in the standards, and end with a verdict:
   APPROVED, APPROVED WITH COMMENTS, or CHANGES REQUESTED.
6. In your final message, summarise: files reviewed, counts by severity, and the
   overall verdict.

Report findings faithfully and tie every one back to a specific standard.
"""


def build_review_runner(target: str, status: Optional[StatusTracker] = None) -> AgentRunner:
    guide = _FRONTEND_GUIDE if target == "frontend" else _BACKEND_GUIDE
    prompt = SYSTEM_PROMPT_TEMPLATE.format(
        guide=guide, reviews_rel=REVIEWS_REL, target=target
    )
    return AgentRunner(
        name=AGENT_NAME,
        system_prompt=prompt,
        # Review-only: filesystem tools, no shell. write_file is used only for
        # the report (the prompt forbids editing the reviewed code).
        tools=filesystem_tools(include_shell=False),
        status=status,
        effort="high",
    )


def run_review_agent(task: str,
                     target: str = "backend",
                     standards_path: Optional[str] = None,
                     status: Optional[StatusTracker] = None) -> dict:
    """Run the code-review subagent. `target` is 'frontend' or 'backend'."""
    target = (target or "backend").strip().lower()
    if target not in ("frontend", "backend"):
        target = "backend"

    standards = Path(standards_path) if standards_path else DEFAULT_STANDARDS_FILE
    # Express the standards path relative to the project root for the tools.
    try:
        standards_rel = standards.resolve().relative_to(BASE_DIR)
    except (ValueError, IndexError):
        standards_rel = standards

    out_dir = f"{UI_REL}/" if target == "frontend" else f"{BACKEND_REL}/"
    full_task = (
        f"Coding standards file: {standards_rel}\n"
        f"(Read it first with read_file.)\n\n"
        f"Review target: {target} ({out_dir})\n\n"
        f"Task: {task}\n\n"
        f"Write the review report under {REVIEWS_REL}/."
    )
    runner = build_review_runner(target, status=status)
    return runner.run(full_task)


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Code-review subagent")
    parser.add_argument("--target", choices=["frontend", "backend"], default="backend")
    parser.add_argument("--task", default="Review the generated code against the coding standards.")
    parser.add_argument("--standards", default=None,
                        help="Path to the coding standards file (defaults to mpm-agents/coding_standards.md).")
    args = parser.parse_args()

    print_banner()
    result = run_review_agent(args.task, target=args.target, standards_path=args.standards)
    print("\n=== review_agent result ===")
    print(result)


if __name__ == "__main__":
    _cli()
