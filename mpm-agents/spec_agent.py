"""
spec_agent.py
=============

Specification -> Spring Boot converter subagent.

Author: Debraj Som

Reads a specification document (default: grails-ui-demo/specs.md) and generates
a Spring Boot backend implementing it, writing the code under the /mpm-backend
folder in the base project directory.

Public entry point:

    run_spec_agent(task, spec_path=None, status=None) -> dict

Standalone:

    python spec_agent.py --task "Implement the authentication and organisation APIs"
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Optional

from sdk_runner import (
    AgentRunner,
    StatusTracker,
    filesystem_tools,
    DEFAULT_SPEC_FILE,
    MPM_BACKEND_DIR,
    BACKEND_REL,
    print_banner,
)

AGENT_NAME = "spec_agent"

SYSTEM_PROMPT = f"""\
You are the Specification-to-Spring-Boot conversion subagent in an automated
migration pipeline.

## Your job
Read the provided specification and generate a Spring Boot backend that
implements it, writing all code under the `{BACKEND_REL}/` folder at the project root.

## Tools
You have filesystem tools (read_file, write_file, edit_file, list_dir, make_dir)
scoped to the project root. Start by reading the specification file whose path is
given in the task. ALWAYS write generated backend code under `{BACKEND_REL}/`.

## Target stack & conventions
- Java 21 + Spring Boot 3.2.x + Spring Security (JWT) + Spring Data JPA/Hibernate.
- Build tool: Gradle. Database: H2 for dev.
- Use this standard package layout under
  `{BACKEND_REL}/src/main/java/com/demo/mpmbackend`:
    config/      SecurityConfig and other @Configuration
    controller/  REST controllers
    dto/         request/response DTOs
    entity/      JPA entities
    exception/   custom exceptions + GlobalExceptionHandler
    init/        DataInitializer (seed data)
    repository/  Spring Data repositories
    security/    JwtUtil, JwtAuthFilter, UserDetailsServiceImpl
    service/     business logic
    <App>Application.java
- Use the base package `com.demo.mpmbackend` (or follow the spec if it names one).
- Hash passwords with BCrypt. Return JSON. Enforce role-based access (ADMIN/USER)
  exactly as the spec describes (admin-only fields ignored server-side for USER).
- Provide src/main/resources/application.yml and a build.gradle with the right deps.

## Build configuration & ports
Use these build patterns exactly (do not invent your own versions).
Gradle setup: Spring Boot 3.2.4 + io.spring.dependency-management,
Java 21, group com.demo, and the same dependencies (spring-boot-starter web /
security / data-jpa / validation, jjwt 0.11.5 api+impl+jackson, h2, postgresql,
lombok, spring-boot-starter-test + spring-security-test). In settings.gradle set
rootProject.name = 'mpm-backend'.

PORTS - the reference apps occupy 8080 (legacy Grails), 8081 (reference backend)
and 5173 (reference frontend). So this generated backend MUST run on a free
neighbour: set `server.port: 8082` in application.yml so it can run side-by-side
without a clash. Keep H2 in-memory + console at /h2-console and JPA
ddl-auto: create-drop. Configure CORS to allow the generated frontend origin
http://localhost:5174 (also allow http://localhost:5173).

Do NOT hardcode the JWT signing secret. Read it from `app.jwt.secret` with an
env-overridable dev default, e.g. `secret: ${{APP_JWT_SECRET:<dev-only-default>}}`,
and keep `app.jwt.expiration-ms`.

BUILD/TEST COMMANDS: this environment uses a locally installed Gradle 8.14.2 -
invoke `gradle ...` (NOT `gradlew`/`gradlew.bat`, and NOT Gradle 9.x).

## Workflow
1. read_file the specification (path given in the task). Extract: data model,
   API routes, auth flow, business rules, roles, seed data.
2. list_dir `{BACKEND_REL}/` to see what already exists; scaffold the Gradle project
   (build.gradle, settings.gradle, application.yml, Application.java) only if missing.
3. Generate entities -> repositories -> dtos -> security -> services -> controllers
   -> exception handling -> data initializer, in dependency order.
4. Keep each class in its own file under the correct package directory.
5. When done, summarise the endpoints implemented and any follow-ups.

Implement the spec faithfully and completely. No TODO placeholders in generated code.
"""


def build_spec_runner(status: Optional[StatusTracker] = None) -> AgentRunner:
    return AgentRunner(
        name=AGENT_NAME,
        system_prompt=SYSTEM_PROMPT,
        tools=filesystem_tools(include_shell=False),
        status=status,
        effort="high",
    )


def run_spec_agent(task: str,
                   spec_path: Optional[str] = None,
                   status: Optional[StatusTracker] = None) -> dict:
    """Run the Spec->Spring Boot subagent for one task."""
    spec = Path(spec_path) if spec_path else DEFAULT_SPEC_FILE
    # Express the spec path relative to the project root for the tools.
    try:
        spec_rel = spec.resolve().relative_to(DEFAULT_SPEC_FILE.parents[1])
    except (ValueError, IndexError):
        spec_rel = spec

    full_task = (
        f"Specification file to implement: {spec_rel}\n"
        f"(Read it first with read_file.)\n\n"
        f"Task: {task}\n\n"
        f"Output directory: {BACKEND_REL}/"
    )
    runner = build_spec_runner(status=status)
    return runner.run(full_task)


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Spec -> Spring Boot subagent")
    parser.add_argument("--task", default="Implement the full backend described by the specification.")
    parser.add_argument("--spec", default=None, help="Path to the spec file (defaults to grails-ui-demo/specs.md).")
    args = parser.parse_args()

    print_banner()
    MPM_BACKEND_DIR.mkdir(parents=True, exist_ok=True)
    result = run_spec_agent(args.task, spec_path=args.spec)
    print("\n=== spec_agent result ===")
    print(result)


if __name__ == "__main__":
    _cli()
