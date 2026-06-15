# MPM Migration — Coding Standards

This document is the **source of truth** the `review_agent` checks generated code
against. The orchestrator points the review subagent at this file by default. Keep
it concise and rule-shaped: every item should be something a reviewer can mark as
PASS / FAIL / N/A against a concrete piece of code.

Severity legend used in review reports:
- **BLOCKER** — must be fixed before the code can be considered done.
- **MAJOR** — should be fixed; risks correctness, security, or maintainability.
- **MINOR** — style / polish; fix when convenient.

---

## 1. General (all code)

1. **No dead or placeholder code.** No `TODO`, `FIXME`, commented-out blocks, or
   stubbed methods that throw "not implemented" in delivered code. (BLOCKER)
2. **No secrets in source.** No hard-coded passwords, API keys, tokens, or
   connection strings. Use config/env. (BLOCKER)
3. **Meaningful names.** Classes are nouns, methods/functions are verbs; no
   single-letter names except loop indices. (MINOR)
4. **Single responsibility.** A function does one thing; split functions longer
   than ~50 lines or with more than ~3 levels of nesting. (MAJOR)
5. **No magic numbers/strings.** Extract to named constants or config. (MINOR)
6. **Errors are handled, not swallowed.** No empty catch blocks; never catch a
   broad exception only to ignore it. Log or rethrow with context. (MAJOR)
7. **Input is validated at the boundary** (controllers, API handlers, form
   submit) before it reaches business logic. (MAJOR)
8. **Consistent formatting** within a file (indentation, brace style, import
   order). Match the surrounding code. (MINOR)
9. **No unused** imports, variables, parameters, or files. (MINOR)
10. **Comments explain *why*, not *what*.** The code should be self-explanatory;
    comments cover intent, edge cases, and non-obvious decisions. (MINOR)

## 2. Backend (Java / Spring Boot)

1. **Layering is respected:** controller → service → repository. Controllers
   contain no business logic; repositories are not called directly from
   controllers. (MAJOR)
2. **DTOs at the boundary.** Controllers accept/return DTOs, never JPA entities,
   so the persistence model is not leaked over the wire. (MAJOR)
3. **Constructor injection** for dependencies (no field `@Autowired`). Fields are
   `private final`. (MAJOR)
4. **Passwords are BCrypt-hashed**; never stored or logged in plaintext. (BLOCKER)
5. **Role-based access enforced server-side** (`@PreAuthorize` / security config).
   Admin-only fields must be ignored server-side for non-admin users, regardless
   of what the client sends. (BLOCKER)
6. **Centralised error handling** via `@ControllerAdvice` /
   `GlobalExceptionHandler`; controllers do not build ad-hoc error responses.
   Return correct HTTP status codes (400/401/403/404/409). (MAJOR)
7. **Validation annotations** (`@Valid`, `@NotNull`, `@Size`, …) on request DTOs.
   (MAJOR)
8. **No `System.out.println`** — use a logger (SLF4J). (MINOR)
9. **Transactions:** write service methods are `@Transactional`; read-only ones
   are `@Transactional(readOnly = true)` where it matters. (MINOR)
10. **No raw/unparameterised queries** built from string concatenation — use JPA
    or parameterised queries (SQL-injection safe). (BLOCKER)

## 3. Frontend (React / JavaScript)

1. **Function components + hooks only** (no class components). (MINOR)
2. **Hooks rules:** called unconditionally at the top level; `useEffect` has a
   correct, complete dependency array. (MAJOR)
3. **Keys on list items** are stable and unique (not the array index when the
   list can reorder). (MAJOR)
4. **No secrets or full API URLs hard-coded** in components; use a config/env or a
   central API client. (MAJOR)
5. **API calls are centralised** (e.g. an axios instance / service module), not
   scattered raw `fetch` calls in every component. (MINOR)
6. **Loading and error states are handled** for every async call — no UI that
   silently hangs or crashes on failure. (MAJOR)
7. **Controlled inputs** for forms; validate before submit. (MINOR)
8. **Accessibility basics:** form inputs have labels, buttons have accessible
   text, images have `alt`. (MINOR)
9. **No direct DOM manipulation** (`document.querySelector`, manual `innerHTML`)
   where React state/refs should be used. (MAJOR)
10. **Role/permission-driven rendering** matches the backend rules — the UI must
    not expose admin-only actions to non-admin users (defence in depth, not the
    only check). (MAJOR)

## 4. Tests

1. Tests assert real behaviour, not trivial truths (`assertTrue(true)`). (MAJOR)
2. Core business logic and role/permission rules are covered. (MAJOR)
3. Tests are independent and repeatable (no reliance on execution order or shared
   mutable state). (MINOR)

---

## Review output contract

The review agent must produce a report with, for each file/area reviewed:
- the rule id (e.g. `Backend §3`) and a one-line description,
- severity (BLOCKER / MAJOR / MINOR),
- the file and approximate location,
- a concrete suggested fix.

End with a verdict: **APPROVED** (no BLOCKERs/MAJORs), **APPROVED WITH COMMENTS**
(MINORs only), or **CHANGES REQUESTED** (one or more BLOCKER/MAJOR).
