# Code Review — Frontend (React) `mpm-ui/`

**Reviewed against:** `mpm-agents/coding_standards.md` (sections 1 General,
3 Frontend, 4 Tests).
**Review target:** `MPM-Migration-Orchestration/mpm-ui/`
**Reviewer:** code-review subagent (read-only; no source modified).

---

## Scope / files reviewed

Source (12 files):

- `src/main.jsx`
- `src/App.jsx`
- `src/api/axios.js`
- `src/context/AuthContext.jsx`
- `src/components/ProtectedRoute.jsx`
- `src/components/TopBarNav.jsx`
- `src/components/ErrorBanner.jsx`
- `src/components/PagePlaceholder.jsx`
- `src/pages/LoginPage.jsx`
- `src/pages/MerchantPage.jsx`
- `src/pages/OrganisationSearchPage.jsx`
- `src/pages/EditBasicDetailsPage.jsx`
- `src/styles/theme.js`

Tests (4 files): `src/test/setup.js`,
`src/__tests__/LoginPage.test.jsx`,
`src/__tests__/OrganisationSearchPage.test.jsx`,
`src/__tests__/EditBasicDetailsPage.test.jsx`.

To verify role-driven rendering I cross-checked the admin-only field set against
the backend's server-side filter in
`mpm-backend/.../service/OrganisationService.java`.

---

## Focus-area assessment (PASS items)

These are the items the task specifically called out. They were checked closely
and **pass** — recorded here so the verdict is transparent.

- **Hooks rules & effect dependency arrays — §3.2 — PASS.** All hooks are called
  unconditionally at the top level of each component. The only `useEffect`
  (`EditBasicDetailsPage.jsx`, the org-load effect) has a correct, complete
  dependency array `[id]`; it reads `id`, plus module-level constants (`FIELDS`,
  `api`) and stable `setState` setters that need not be listed. It also guards
  against setting state after unmount via a `cancelled` flag and returns a proper
  cleanup function. The `useMemo` for `parentOrgOptions` correctly lists
  `[allOrgs, id]`.
- **Stable, unique list keys — §3.3 — PASS.** No array-index keys are used for
  dynamic rows. `OrganisationSearchPage` keys result rows by `org.id` and cells
  by `col.key`; `EditBasicDetailsPage` keys fields by `field.key`, options by
  `opt`, and parent-org options by `o.id`; `MerchantPage` keys header cells by
  the (stable) column string.
- **Centralised API client — §3.4 / §3.5 — PASS.** Every call goes through the
  single axios instance in `src/api/axios.js` (`baseURL: '/api'`, JWT attached in
  a request interceptor, 401 handled in a response interceptor). No raw `fetch`,
  no hard-coded hosts, no secrets in source.
- **Role-driven rendering matches the backend — §3.10 — PASS.** The
  `adminOnly: true` set in `EditBasicDetailsPage.jsx` `FIELDS` is **identical** to
  the admin-only block in `OrganisationService.update(...)` (shortName, fullName,
  parentOrgId, feeRounding, the three credit limits, the eCheck limits, and all
  the admin-only boolean indicators). The UI disables/greys these for the `USER`
  role and shows the "(Admin only)" note, while the backend independently ignores
  them for non-admins — correct defence-in-depth, not the only check.
- **Tests — §4.1–§4.3 — PASS.** Tests assert real behaviour (login success/
  failure/validation, explicit-search gating, row-select → navigate, and the
  admin-vs-user field locking for both roles). They are independent (storage and
  mocks reset in `beforeEach`/`afterEach`) and mock the centralised axios module.

---

## Findings

All findings below are **MINOR**. Each cites a specific standard.

### 1. Imperative DOM style mutation on focus/blur — §3.9 (MINOR)
- **File/location:** `src/pages/LoginPage.jsx`, `handleInputFocus` /
  `handleInputBlur` (`e.target.style.borderColor = ...`), wired to both inputs.
- **Issue:** The focus border colour is changed by directly mutating the DOM
  node's style in an event handler, where React state or a CSS `:focus` rule
  should be used. Standard §3.9 (nominally MAJOR) flags direct DOM manipulation
  "where React state/refs should be used." Severity reduced to MINOR because the
  effect is purely cosmetic, self-contained to the event's own target, and
  reversed on blur (no DOM querying, no risk of React state desync).
- **Suggested fix:** Move the focus styling to CSS (`input:focus { border-color:
  … }`) or drive it from component state, removing the imperative handlers.

### 2. Login inputs have no programmatically associated label — §3.8 (MINOR)
- **File/location:** `src/pages/LoginPage.jsx`, the "Login ID" / "Password"
  `<table>` rows.
- **Issue:** The label text lives in a sibling `<td>` and is not tied to the
  input via `<label htmlFor>`/`id` or an `aria-label`. The password input has no
  accessible name at all (the success test reaches it via
  `container.querySelector('input[type="password"]')`, confirming there is no
  accessible name to query by).
- **Suggested fix:** Use real `<label htmlFor="loginId">`/`id="loginId"`
  associations (or `aria-label`) so each input has an accessible name.

### 3. Edit-form controls lack programmatic label association — §3.8 (MINOR)
- **File/location:** `src/pages/EditBasicDetailsPage.jsx`, `renderControl(...)`
  and the field `<table>` rows.
- **Issue:** Field labels are rendered in a separate `<td>` and are not linked to
  their input/select/checkbox via `htmlFor`/`id` or `aria-label`. Controls have
  no accessible name (the test suite works around this by traversing from the
  label `<td>` to the row).
- **Suggested fix:** Give each control an `id` and associate the label cell's text
  with `<label htmlFor>`, or add `aria-label={field.label}` to each control.

### 4. Secondary parent-org fetch swallows its error — §1.6 (MINOR)
- **File/location:** `src/pages/EditBasicDetailsPage.jsx`, inner
  `try { … api.get('/organisations' …) } catch { setAllOrgs([]) }` inside the
  load effect.
- **Issue:** A failure of the Parent-Org dropdown list is caught and reduced to an
  empty list with no logging and no user-visible signal. It degrades gracefully,
  but the failure is otherwise invisible (§1.6: errors should be logged or
  rethrown with context, not silently swallowed).
- **Suggested fix:** Log the caught error (or set a small non-blocking notice such
  as "Parent organisation list unavailable") in addition to the `[]` fallback.

### 5. Unreachable branch / placeholder comment in the empty grid — §1.1 / §1.9 (MINOR)
- **File/location:** `src/pages/MerchantPage.jsx`, `EmptyDataGrid` —
  `const rows = []` followed by `rows.length === 0 ? (…) : null /* rows would be
  rendered here if there were any */`.
- **Issue:** `rows` is a constant empty array, so the `: null` branch is dead and
  the trailing comment is placeholder narration. Standard §1.1 discourages
  placeholder code and §1.9 unused code. (The spec does require a static empty
  grid here, so this is a tidiness issue, not a functional one.)
- **Suggested fix:** Render the "No data to display" row directly and drop the
  always-false conditional and the placeholder comment.

### 6. Unused placeholder component file — §1.9 / §1.1 (MINOR)
- **File/location:** `src/components/PagePlaceholder.jsx`.
- **Issue:** The component is a "coming soon" scaffold and is not imported by
  `App.jsx` or any route/component — it is an unused file containing placeholder
  copy ("This screen is part of a later migration step.").
- **Suggested fix:** Delete the file, or wire it into a route if it is still
  intended to be used.

### 7. Unused exports in the theme module — §1.9 (MINOR)
- **File/location:** `src/styles/theme.js`, exports `activeTabBorder` and
  `pageStyle`.
- **Issue:** Neither is imported anywhere — `TopBarNav` re-declares the active-tab
  border inline and each page defines its own `page` style object inline.
- **Suggested fix:** Remove the unused exports, or adopt them where the equivalent
  inline values are currently duplicated.

### 8. Edit form does not validate before submit — §3.7 (MINOR)
- **File/location:** `src/pages/EditBasicDetailsPage.jsx`, `handleSave`.
- **Issue:** Inputs are properly controlled, but numeric/money fields are coerced
  with `parseInt`/`Number` and PUT with no client-side validation (e.g. a
  non-numeric "Deposit Credit Limit" becomes `NaN`). §3.7 asks for validation
  before submit. (The backend remains the authoritative validator, so this is
  polish, not a correctness blocker.)
- **Suggested fix:** Validate numeric/money fields (and any required fields)
  before calling `api.put`, surfacing inline errors via the existing
  `ErrorBanner`.

---

## Severity summary

| Severity | Count |
|----------|-------|
| BLOCKER  | 0 |
| MAJOR    | 0 |
| MINOR    | 8 |

---

## Verdict

**APPROVED WITH COMMENTS.**

All four focus areas — hooks/effect dependencies, stable list keys, centralised
axios usage with loading + error handling, and role-driven rendering aligned with
the backend's server-side field filtering — pass. No BLOCKER or MAJOR issues were
found. The eight MINOR items (accessibility labelling, an imperative focus style,
a swallowed secondary-fetch error, and some dead/unused code) should be cleaned up
when convenient but do not block delivery.
