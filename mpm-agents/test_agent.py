"""
test_agent.py
=============

Unit-test subagent. Generates and runs unit tests for newly generated frontend
or backend code.

Author: Debraj Som

  * target="frontend" -> tests for React code under MPM-Migration-Orchestration/mpm-ui/
    (Vitest + React Testing Library).
  * target="backend"  -> tests for Spring Boot code under MPM-Migration-Orchestration/mpm-backend/
    (JUnit 5 + Spring Boot Test + Mockito).

Public entry point:

    run_test_agent(task, target="backend", status=None) -> dict

Standalone:

    python test_agent.py --target frontend --task "Write tests for the login page"
"""

from __future__ import annotations

import argparse
from typing import Optional

from sdk_runner import (
    AgentRunner,
    StatusTracker,
    filesystem_tools,
    MPM_UI_DIR,
    MPM_BACKEND_DIR,
    UI_REL,
    BACKEND_REL,
    print_banner,
)

AGENT_NAME = "test_agent"

_FRONTEND_GUIDE = f"""\
Target: FRONTEND (React) under `{UI_REL}/`.
- Use Vitest + @testing-library/react + jsdom. Add them to devDependencies and
  add a "test" script (e.g. "vitest run") to package.json if missing.
- Place tests next to components or under `src/__tests__/`, named `*.test.jsx`.
- Test rendering, user interaction, conditional rendering by role, and API
  calls (mock axios).
- Run the suite with run_command: `npm install` then `npm test` (cwd: {UI_REL}).
"""

_BACKEND_GUIDE = f"""\
Target: BACKEND (Spring Boot) under `{BACKEND_REL}/`.
- Use JUnit 5 + Spring Boot Test + Mockito (spring-boot-starter-test is enough).
- Place tests under `src/test/java/...` mirroring the main package layout.
- Write unit tests for services (mocked repositories) and slice/web tests for
  controllers (@WebMvcTest or MockMvc), covering auth, role rules, and validation.
- Run the suite with run_command using the locally installed Gradle 8.14.2:
  `gradle test` (cwd: {BACKEND_REL}). Do NOT use `gradlew`/`gradlew.bat` or
  Gradle 9.x - this environment has no network access to the Gradle servers.
"""

SYSTEM_PROMPT_TEMPLATE = """\
You are the unit-test subagent in an automated migration pipeline. You write and
run unit tests for code another subagent just generated, then report the results.

## Tools
You have filesystem tools (read_file, write_file, edit_file, list_dir, make_dir)
and a run_command tool for installing deps and running test suites, all scoped to
the project root.

{guide}

## Workflow
1. list_dir / read_file the target source tree to understand what exists. If the
   target directory is empty or missing, report that there is nothing to test and
   stop.
2. Write focused, meaningful unit tests (not trivial assertions). Cover the core
   business logic and the role/permission rules.
3. Run the test suite with run_command and read the output.
4. If tests fail because of test bugs, fix the tests and re-run. If they reveal a
   real bug in the source, report it clearly in your summary rather than masking it.
5. Summarise: how many tests, pass/fail counts, and anything that needs attention.

Report results faithfully. If tests fail, say so and include the relevant output.
"""


def build_test_runner(target: str, status: Optional[StatusTracker] = None) -> AgentRunner:
    guide = _FRONTEND_GUIDE if target == "frontend" else _BACKEND_GUIDE
    return AgentRunner(
        name=AGENT_NAME,
        system_prompt=SYSTEM_PROMPT_TEMPLATE.format(guide=guide),
        tools=filesystem_tools(include_shell=True),
        status=status,
        effort="high",
    )


def run_test_agent(task: str,
                   target: str = "backend",
                   status: Optional[StatusTracker] = None) -> dict:
    """Run the test subagent. `target` is 'frontend' or 'backend'."""
    target = (target or "backend").strip().lower()
    if target not in ("frontend", "backend"):
        target = "backend"
    out_dir = f"{UI_REL}/" if target == "frontend" else f"{BACKEND_REL}/"
    full_task = f"Test target: {target} ({out_dir})\n\nTask: {task}"
    runner = build_test_runner(target, status=status)
    return runner.run(full_task)


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Unit-test subagent")
    parser.add_argument("--target", choices=["frontend", "backend"], default="backend")
    parser.add_argument("--task", default="Write and run unit tests for the generated code.")
    args = parser.parse_args()

    print_banner()
    result = run_test_agent(args.task, target=args.target)
    print("\n=== test_agent result ===")
    print(result)


if __name__ == "__main__":
    _cli()
