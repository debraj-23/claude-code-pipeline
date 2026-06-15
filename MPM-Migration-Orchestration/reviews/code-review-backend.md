# Code Review — Backend (Spring Boot)

**Target:** `MPM-Migration-Orchestration/mpm-backend/`
**Standards:** `mpm-agents/coding_standards.md` (General §1, Backend §2, Tests §4)
**Reviewer:** code-review subagent (read-only)

## Scope / files reviewed

Main source (13 files):
- `MpmBackendApplication.java`
- `config/SecurityConfig.java`
- `controller/AuthController.java`, `controller/OrganisationController.java`
- `dto/LoginRequest.java`, `dto/LoginResponse.java`, `dto/ErrorResponse.java`, `dto/OrganisationUpdateRequest.java`
- `entity/AppUser.java`, `entity/Organisation.java`
- `exception/GlobalExceptionHandler.java`, `exception/OrganisationNotFoundException.java`
- `init/DataInitializer.java`
- `repository/AppUserRepository.java`, `repository/OrganisationRepository.java`
- `security/JwtAuthFilter.java`, `security/JwtUtil.java`, `security/UserDetailsServiceImpl.java`
- `service/OrganisationService.java`
- `src/main/resources/application.yml`, `build.gradle`

Test source (4 files):
- `MpmBackendApplicationTests.java`
- `controller/AuthControllerTest.java`, `controller/OrganisationControllerTest.java`
- `service/OrganisationServiceTest.java`

---

## What passes (worth recording)

- **Backend §3 — Constructor injection.** All Spring components use Lombok
  `@RequiredArgsConstructor` over `private final` fields; no field `@Autowired`
  anywhere. PASS.
- **Backend §4 — BCrypt password hashing.** `SecurityConfig` exposes a
  `BCryptPasswordEncoder` bean; `DataInitializer.seedUsers()` stores
  `passwordEncoder.encode(...)`; no plaintext password is persisted or logged.
  PASS.
- **Backend §5 — Server-side role enforcement / orgId immutability.** Admin-only
  fields are gated behind an `isAdmin` check in `OrganisationService.update()`
  (lines ~78–101) and are silently ignored for non-admin roles regardless of the
  request body; `orgId` is not present on `OrganisationUpdateRequest` at all, so
  it can never be mutated on update. Enforcement is server-side, derived from the
  authenticated `Authentication` authorities. PASS.
- **Backend §10 — No raw/string-concatenated queries.** `OrganisationRepository`
  uses `@Query` JPQL with named parameters (`:query`) and `CONCAT`/`LOWER`; no
  string-built SQL/JPQL. SQL-injection safe. PASS.
- **Backend §8 — No `System.out.println`.** None present. PASS.
- **Tests §1–§3.** Tests assert real behaviour and cover the key role/permission
  rules (admin-only field filtering, orgId immutability, "cannot be own parent",
  401/400/404 paths). Tests use mocks and are independent. PASS.

---

## Findings

### 1. Controllers return JPA entities instead of DTOs — **MAJOR**
- **Rule:** Backend §2 — DTOs at the boundary; persistence model must not be
  leaked over the wire.
- **Location:** `controller/OrganisationController.java`
  - `search(...)` returns `ResponseEntity<List<Organisation>>` (line ~33)
  - `getById(...)` returns `ResponseEntity<Organisation>` (line ~46)
  - `update(...)` returns `ResponseEntity<Organisation>` (line ~62)
  - `OrganisationService` likewise returns the `Organisation` entity outward.
- **Why it matters:** The `Organisation` JPA entity is serialised directly to the
  client (and the entity is the persisted model, including the internal DB primary
  key `id`). This couples the API contract to the schema and leaks the persistence
  model. The codebase already establishes the DTO pattern for the auth flow
  (`LoginResponse`), so the read/update paths are inconsistent with it.
- **Suggested fix:** Introduce an `OrganisationResponse` DTO and map the entity to
  it in the service (or a mapper) before returning. Controllers should
  accept/return DTOs only.

### 2. `AuthController` builds ad-hoc error responses — **MAJOR**
- **Rule:** Backend §6 — Centralised error handling via `@ControllerAdvice`;
  controllers do not build ad-hoc error responses.
- **Location:** `controller/AuthController.java`, `login()` catch block (line ~33):
  `return ResponseEntity.status(401).body(Map.of("error", "Invalid username or password."));`
- **Why it matters:** The 401 error body is constructed inline in the controller
  with a raw `Map`, bypassing `GlobalExceptionHandler` and the `ErrorResponse`
  shape used everywhere else. The error contract is now inconsistent (`{"error":…}`
  here vs `{"status","error","message","timestamp"}` from the advice).
- **Suggested fix:** Let `BadCredentialsException` (or a custom
  `InvalidCredentialsException`) propagate and add an `@ExceptionHandler` in
  `GlobalExceptionHandler` returning `401` with `ErrorResponse`. Remove the inline
  try/catch and `Map.of` body.

### 3. Update request DTO has no validation and controller omits `@Valid` — **MAJOR**
- **Rule:** Backend §7 — validation annotations on request DTOs; General §1.7 —
  input validated at the boundary before reaching business logic.
- **Location:** `dto/OrganisationUpdateRequest.java` (no constraint annotations on
  any field) and `controller/OrganisationController.update(...)` (line ~60):
  `@RequestBody OrganisationUpdateRequest request` — note the missing `@Valid`.
- **Why it matters:** Unlike `LoginRequest` (which uses `@NotBlank`), the update
  payload is not validated at the boundary. Free-text fields and bounded fields
  (e.g. `slaReportFrequency`, `acquirerFeeLevel`, numeric limits, `*Day` /
  `maxCategoryNodes`) are accepted unchecked; `@Column(nullable=false)` columns
  would only fail at the DB layer (500) rather than returning a clean 400.
- **Suggested fix:** Add appropriate constraints (`@Size`, `@Min`/`@Max`,
  `@Pattern`/enum for the bounded string fields) to `OrganisationUpdateRequest`
  and annotate the controller parameter with `@Valid`. `MethodArgumentNotValidException`
  is already handled by the advice.

### 4. `userRepository.findByUsername(...).orElseThrow()` produces an unhandled 500 path — **MINOR**
- **Rule:** Backend §6 — return correct HTTP status codes; General §1.6 — errors
  handled with context.
- **Location:** `controller/AuthController.login()` (line ~37):
  `.orElseThrow()` throws a bare `NoSuchElementException`.
- **Why it matters:** If authentication succeeds but the user lookup fails (e.g. a
  race or data inconsistency), the bare `NoSuchElementException` is not handled by
  `GlobalExceptionHandler` and surfaces as an opaque 500 with no context.
- **Suggested fix:** Throw a descriptive exception
  (`orElseThrow(() -> new IllegalStateException("Authenticated user not found: " + username))`)
  and/or add a fallback `@ExceptionHandler` for unexpected exceptions returning a
  generic 500 `ErrorResponse`.

### 5. Read-only service methods are not `@Transactional(readOnly = true)` — **MINOR**
- **Rule:** Backend §9 — read-only methods should be
  `@Transactional(readOnly = true)` where it matters.
- **Location:** `service/OrganisationService.java` — `findAll()`, `findById()`,
  `search(...)` carry no transactional annotation (only `update()` is
  `@Transactional`).
- **Suggested fix:** Annotate the read methods with
  `@Transactional(readOnly = true)` (or the class with a sensible default).

### 6. Hard-coded seed credentials in source — **MINOR (note)**
- **Rule:** General §1.2 — no hard-coded passwords in source.
- **Location:** `init/DataInitializer.seedUsers()` — `"admin123"`, `"debraj123"`.
- **Why it matters / nuance:** These are demo seed credentials for an in-memory H2
  database, encoded with BCrypt before storage, and are clearly intended as
  fixture data rather than production secrets (the JWT secret is correctly
  externalised via `${APP_JWT_SECRET:...}` and the DB uses the default H2 `sa`).
  Reported as MINOR rather than BLOCKER given the demo-seed context, but they
  should not be reused in any non-demo profile.
- **Suggested fix:** Move seed credentials to a dev-only configuration/profile or
  an env-driven property, and ensure the seeder only runs under a `dev`/`h2`
  profile.

### 7. H2 console exposed and CSRF disabled — **MINOR (note)**
- **Rule:** General §1.2 / Backend §5 (defence in depth).
- **Location:** `config/SecurityConfig.filterChain` — `/h2-console/**` is
  `permitAll()` with `frameOptions(sameOrigin)` and `csrf disabled`.
- **Why it matters:** Acceptable for a local/dev H2 demo, but the H2 console should
  not be reachable in any deployed/non-dev profile.
- **Suggested fix:** Guard the H2 console mapping (and its `permitAll`) behind a
  dev profile.

---

## Severity summary

| Severity | Count | Items |
|----------|-------|-------|
| BLOCKER  | 0     | — |
| MAJOR    | 3     | #1 entity returned over the wire, #2 ad-hoc auth error response, #3 missing DTO validation/`@Valid` |
| MINOR    | 4     | #4 unhandled `orElseThrow` 500, #5 read-only tx, #6 seed credentials, #7 H2 console |

---

## Verdict

**CHANGES REQUESTED**

The security-critical standards (BCrypt hashing, server-side role enforcement,
orgId immutability, parameterised queries, constructor injection, centralised
advice existence) are met — there are no BLOCKERs. However, three MAJOR issues
must be addressed before sign-off: (1) controllers/service expose the JPA
`Organisation` entity instead of a DTO at the API boundary, (2) `AuthController`
builds an ad-hoc 401 error body that bypasses the centralised handler, and (3) the
update request DTO has no validation and the controller omits `@Valid`. Resolving
these (plus the MINOR items) will bring the backend in line with Backend §2, §6
and §7.
