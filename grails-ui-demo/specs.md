# Application Specification: Merchant Profile Manager

> This document fully describes the application so that any AI tool or developer can recreate or migrate it to any tech stack with zero ambiguity.

---

## 1. Overview

**Application Name:** Merchant Profile Manager
**Purpose:** An internal tool for managing merchant organisations. Authenticated users can search for organisations and edit their basic details. Admin users have access to sensitive financial and configuration fields that regular users cannot modify.

**Current Stack:**
- Framework: Grails 7.0.9 (Apache Grails, Groovy-based, JVM)
- Language: Groovy
- Build tool: Gradle 9.1.0
- ORM: GORM (Grails Object Relational Mapping, built on Hibernate)
- Database: H2 in-memory (`create-drop` — schema and data reset on every restart)
- Views: GSP (Groovy Server Pages — server-side rendered HTML)
- Auth: Session-based (no JWT, no Spring Security — manual session map)
- Server port: 8080

**Migration Target Stack (recommended):**
- Backend: Java 17 + Spring Boot 3.x + Spring Security (JWT) + JPA/Hibernate
- Frontend: React 18 + Vite + React Router v6 + Axios
- Database: H2 for dev
- Auth: JWT tokens (Bearer header)

---

## 2. User Roles & Credentials

| Username | Password   | Role  | Full Name           |
|----------|------------|-------|---------------------|
| admin    | admin123   | ADMIN | System Administrator |
| debraj   | debraj123  | USER  | Debraj              |

### Role Behaviour
- **ADMIN**: Can view and edit ALL fields on the organisation edit form
- **USER**: Can view the edit form but admin-only fields are rendered grayed out (`disabled`/`readonly`) and are server-side ignored on save
- Both roles can log in, search organisations, and access the edit form

---

## 3. Authentication Flow

1. User visits `/` → redirected to login page (`GET /`)
2. User submits login form → `POST /login` with `username` + `password`
3. Server does a DB lookup: `SELECT * FROM app_user WHERE username=? AND password=?`
4. On match: stores user info in HTTP session: `session.user = {id, username, role, fullName}`
5. Redirect to `/home` (Merchant tab landing page)
6. On mismatch: re-render login page with error message "Invalid username or password."
7. `GET /logout` → invalidates session → redirect to login

**Auth Guard:** Every request (except `/` and `/login`) is intercepted by `AuthInterceptor`. If `session.user` is null → redirect to `/`. This is a simple session check, not Spring Security.

---

## 4. Data Model

### 4.1 AppUser

Represents a system user who can log in.

| Field    | Type   | Constraints              |
|----------|--------|--------------------------|
| id       | Long   | Auto-generated PK        |
| username | String | Unique, not blank        |
| password | String | Not blank (plain text — no hashing in current impl) |
| role     | String | Must be `'ADMIN'` or `'USER'` |
| fullName | String | Not blank                |

> **Migration note:** In the target stack, passwords must be hashed using BCrypt. The current implementation stores plain text passwords — this is intentional for the demo only.

---

### 4.2 Organisation

The primary entity. Represents a merchant organisation.

#### Identity Fields
| Field     | Type   | Constraints       | Admin Only |
|-----------|--------|-------------------|------------|
| id        | Long   | Auto PK           | —          |
| orgId     | String | Unique, not blank | No (read-only display) |
| shortName | String | Not blank         | **YES**    |
| fullName  | String | Not blank         | **YES**    |

#### Address Fields
| Field             | Type   | Nullable | Admin Only |
|-------------------|--------|----------|------------|
| corporateAddress  | String | Yes      | No         |
| corporateAddress2 | String | Yes      | No         |
| city              | String | Yes      | No         |
| country           | String | Yes      | No         |
| state             | String | Yes      | No         |
| postalCode        | String | Yes      | No         |

#### Classification Fields
| Field   | Type   | Nullable | Admin Only |
|---------|--------|----------|------------|
| type    | String | Yes      | No         |
| subType | String | Yes      | No         |

Valid values for `type`: `Merchant`, `ISO`, `Acquirer`, `Processor`
Valid values for `subType`: `Retail`, `Ecommerce`, `Hotel`, `Wholesale`

#### Amex Fields
| Field                      | Type    | Default | Admin Only |
|----------------------------|---------|---------|------------|
| amexPaymentServiceProvider | Boolean | false   | No         |
| amexMarketingIndicator     | Boolean | false   | No         |

#### Contract & Hierarchy
| Field                 | Type   | Nullable | Admin Only |
|-----------------------|--------|----------|------------|
| acquiringContractOwner| String | Yes      | No         |
| parentOrgId           | String | Yes      | **YES**    |

Valid values for `acquiringContractOwner`: `Acquirer A`, `Chase Paymentech`, `Wells Fargo`, `Bank of America`, `Citi`, `US Bank`

#### Financial / Fee Fields (ALL Admin Only)
| Field                  | Type       | Nullable | Admin Only |
|------------------------|------------|----------|------------|
| feeRounding            | String     | Yes      | **YES**    |
| depositCreditLimit     | BigDecimal | Yes      | **YES**    |
| refundCreditLimit      | BigDecimal | Yes      | **YES**    |
| orphanRefundCreditLimit| BigDecimal | Yes      | **YES**    |

Valid values for `feeRounding`: `bankers_agg`, `ROUND_UP`, `ROUND_DOWN`, `ROUND_HALF`, `NONE`

#### Feature / Config Fields
| Field                          | Type       | Default   | Admin Only |
|--------------------------------|------------|-----------|------------|
| supportMastercardInterchange   | Boolean    | false     | **YES**    |
| supportQueryTransactions       | Boolean    | false     | **YES**    |
| salesforceId                   | String     | null      | No         |
| enableLogicalBackEndTying      | Boolean    | false     | **YES**    |
| startMultiSiteDay              | Integer    | null      | No         |
| maxCategoryNodes               | Integer    | 100       | No         |
| slaReportFrequency             | String     | `'None'`  | No         |
| enableEarlyReportGeneration    | Boolean    | false     | **YES**    |
| acquirerFeeLevel               | String     | `'Default'` | **YES** |
| pazienEnableIndicator          | Boolean    | false     | **YES**    |
| ssoPazien                      | Boolean    | false     | **YES**    |
| eightDigitBinSSR               | Boolean    | false     | **YES**    |
| netSettledSalesReportRemoveComma| Boolean   | false     | **YES**    |
| dailyECheckSalesVolumeLimit    | BigDecimal | null      | **YES**    |
| dailyECheckCreditVolumeLimit   | BigDecimal | null      | **YES**    |
| preferredCustomerReportIndicator| Boolean   | false     | **YES**    |
| embeddedFinanceEnabled         | Boolean    | false     | **YES**    |
| saferPaymentEnabled            | Boolean    | false     | **YES**    |
| active                         | Boolean    | true      | No         |

Valid values for `slaReportFrequency`: `None`, `Daily`, `Weekly`, `Monthly`
Valid values for `acquirerFeeLevel`: `Default`, `Level1`, `Level2`, `Level3`

---

## 5. Seed Data

### Users (seeded on startup)
```
admin   | admin123   | ADMIN | System Administrator
debraj  | debraj123  | USER  | Debraj
```

### Organisations (seeded on startup)
| orgId | shortName | fullName                  | City          | State | Country | Type     | SubType   | AcquiringContractOwner | ParentOrgId | FeeRounding  | DepositCreditLimit |
|-------|-----------|---------------------------|---------------|-------|---------|----------|-----------|------------------------|-------------|--------------|-------------------|
| 101   | GOOGLE    | Google LLC                | Mountain View | CA    | USA     | Merchant | Ecommerce | Chase Paymentech       | null        | bankers_agg  | 500000.00         |
| 102   | AMAZON    | Amazon.com Inc            | Seattle       | WA    | USA     | Merchant | Ecommerce | Wells Fargo            | null        | bankers_agg  | 750000.00         |
| 103   | NETFLIX   | Netflix Inc               | Los Gatos     | CA    | USA     | Merchant | Ecommerce | Bank of America        | null        | ROUND_UP     | 300000.00         |
| 104   | HULU      | Hulu LLC                  | Santa Monica  | CA    | USA     | Merchant | Ecommerce | Citi                   | 102         | ROUND_DOWN   | 150000.00         |
| 105   | DISNEY    | The Walt Disney Company   | Burbank       | CA    | USA     | Merchant | Retail    | US Bank                | null        | bankers_agg  | 1000000.00        |

---

## 6. URL Routes / API Map

| Method | URL                            | Action                          | Auth Required |
|--------|--------------------------------|---------------------------------|---------------|
| GET    | `/`                            | Show login page                 | No            |
| POST   | `/login`                       | Authenticate user               | No            |
| GET    | `/logout`                      | Clear session, redirect to login| Yes           |
| GET    | `/home`                        | Merchant tab landing page       | Yes           |
| GET    | `/organisations`               | Organisation search page        | Yes           |
| GET    | `/organisations?searched=true&query=X&searchField=Y` | Search results | Yes |
| GET    | `/organisations/{id}/edit`     | Edit Basic Details form         | Yes           |
| POST   | `/organisations/{id}/update`   | Save organisation changes       | Yes           |

### Search Parameters
- `searchField`: `orgId` (searches orgId and shortName) or `fullName` (searches fullName)
- `query`: the search string (partial match, case-insensitive)
- `searched`: must be present (even as empty string) to trigger search; if absent, shows empty search page

### Migration REST API equivalent
```
POST   /api/auth/login           → returns JWT token
POST   /api/auth/logout          → invalidates token
GET    /api/organisations?query=X&searchField=Y  → search results
GET    /api/organisations/{id}   → get single org
PUT    /api/organisations/{id}   → update org (role-based field filtering on server)
```

---

## 7. Pages & UI Screens

### 7.1 Login Page (`/`)

**Layout:**
- White background, centered card with green border
- Title: "Merchant Profile Manager" in green (`#5a9e32`)
- Two fields: "Login ID" (text) + "Password" (password)
- "Login" button (green background, white text)
- No logo, no help links, no footer

**Behaviour:**
- On success → redirect to `/home`
- On failure → re-render with red error message: "Invalid username or password."
- If already logged in → redirect to `/home`

---

### 7.2 Merchant Tab (`/home`) — Landing Page After Login

**Layout:**
- Top bar: white background, "Username: {name}" + "Logout" link at extreme right in green
- Green separator line (3px, `#5a9e32`) below top bar
- Navigation tabs: **Merchant** (active) | **Organization**
- Toolbar: `[Merchant ID/Org ID ▼][text input][Search]` | `Edit Basic Details`
- Data grid below toolbar (always empty — no merchant data in this app)
- Grid columns: Merchant ID, Merchant Name, External MID, Status, Processing Group ID, Organization ID, Organization Name, Organization Type, Customer Experience Manager, Payment Service Provider ID
- Pagination row at bottom: `|< < Page [0] of 0 > >|` + "No data to display" on right
- Body: "No data to display" centered in grid

**Notes:**
- This page has no search functionality wired up — it is a static placeholder
- The Edit Basic Details button in the toolbar is not functional on this page

---

### 7.3 Organisation Search Page (`/organisations`)

**Layout:**
- Same top bar as Merchant page
- Navigation tabs: **Merchant** | **Organization** (active)
- Toolbar: `[Org ID ▼][text input][Search button]` | `Edit Basic Details`
- Search field dropdown options: "Org ID" and "Full Name"
- Results grid (shown only after search is submitted)
- Grid columns: Org ID, Short Name, Full Name, Type, Sub Type, Fee Rounding, Active

**Behaviour:**
1. Page loads → shows empty search form, no grid
2. User selects search field, types query, clicks Search → page reloads with `?searched=true&query=X&searchField=Y`
3. Results appear in grid (partial match, case-insensitive)
4. User clicks a row → row highlights in green, "Edit Basic Details" button becomes active (enabled)
5. User clicks "Edit Basic Details" → navigates to `/organisations/{id}/edit`
6. If no row selected and Edit Basic Details clicked → alert: "Please select an organisation first."

**Search Logic:**
- `searchField = orgId` → matches on `orgId` OR `shortName` (LIKE %query%)
- `searchField = fullName` → matches on `fullName` (LIKE %query%)
- Empty query with `searched=true` → returns all organisations

---

### 7.4 Edit Basic Details Form (`/organisations/{id}/edit`)

**Layout:**
- Same top bar (no nav tabs on this page)
- Green separator line
- Page title bar (white background): `{fullName} ({orgId}): Organization Basic Details`
- Gray page body (`#e0e0e0`)
- Two-column table form: bold label (left, ~310px wide) | control (right)
- No table borders — clean label/input layout
- Button row at bottom: `[Check Multi-Site Compatible]` `[Cancel]` `[Save]`
- Cancel → navigates back to `/organisations`

**Form Fields (in order):**

| # | Label | Control Type | Width | Admin Only |
|---|-------|--------------|-------|------------|
| 1 | Organization ID | Read-only text (no input) | — | — |
| 2 | Short Name | Text input | 160px | YES |
| 3 | Full Name | Text input | 370px | YES |
| 4 | Corporate Street Address | Text input | 370px | No |
| 5 | Corporate Street Address 2 | Text input | 370px | No |
| 6 | Corporate City | Text input | 160px | No |
| 7 | Corporate Country | Dropdown | 200px | No |
| 8 | Corporate State | Dropdown | 120px | No |
| 9 | Corporate Postal Code | Text input | 80px | No |
| 10 | Type | Dropdown | 200px | No |
| 11 | Sub Type | Dropdown | 200px | No |
| 12 | Amex Payment Service Provider | Checkbox | — | No |
| 13 | Amex Marketing Indicator | Checkbox | — | No |
| 14 | Acquiring Contract Owner | Dropdown | 200px | No |
| 15 | Parent Organization ID | Dropdown (list of other orgs) | 200px | YES |
| 16 | Fee Rounding | Dropdown | 370px | YES |
| 17 | Deposit Credit Limit (in USD including foreign currency) | `$` prefix + text input | 140px | YES |
| 18 | Refund Credit Limit (in USD including foreign currency) | `$` prefix + text input | 140px | YES |
| 19 | Orphan Refund Credit Limit (in USD including foreign currency) | `$` prefix + text input | 140px | YES |
| 20 | Support MasterCard Business Service Arrangement Interchange Rates | Checkbox + ⓘ icon | — | YES |
| 21 | Support Query Transactions | Checkbox + ⓘ icon | — | YES |
| 22 | Salesforce Id | Text input | 260px | No |
| 23 | Enable Logical Back End Tying | Checkbox + ⓘ icon | — | YES |
| 24 | Start Multi Site Day | Text input + ⓘ icon | 80px | No |
| 25 | Maximum No. of Category Nodes | Text input | 80px | No |
| 26 | SLA Report Frequency | Dropdown | 120px | No |
| 27 | Enable Early Report Generation | Checkbox + ⓘ icon | — | YES |
| 28 | Acquirer Fee Level | Dropdown | 120px | YES |
| 29 | Pazien Enable Indicator | Checkbox + ⓘ icon | — | YES |
| 30 | SSO Pazien | Checkbox + ⓘ icon | — | YES |
| 31 | 8 Digit Bin SSR | Checkbox + ⓘ icon | — | YES |
| 32 | Net Settled Sales Report Remove Comma | Checkbox + ⓘ icon | — | YES |
| 33 | Daily eCheck Sales Volume Limit | `$` prefix + text input + ⓘ icon | 140px | YES |
| 34 | Daily eCheck Credit Volume Limit | `$` prefix + text input + ⓘ icon | 140px | YES |
| 35 | Preferred Customer Report Indicator | Checkbox + ⓘ icon | — | YES |
| 36 | Embedded Finance Enabled | Checkbox + ⓘ icon | — | YES |
| 37 | SaferPayment Enabled | Checkbox + ⓘ icon | — | YES |

**Admin-Only Field Rendering for USER role:**
- Text inputs → add `readonly` attribute + gray background (`#f5f5f5`) + gray text (`#888`) + `cursor: not-allowed`
- Dropdowns → add `disabled` attribute + same gray styling
- Checkboxes → add `disabled` attribute
- Label gets an inline note: `(Admin only)` in orange (`#e08000`), italic, 11px

**On Save (POST /organisations/{id}/update):**
- All roles: basic fields are saved
- ADMIN only: admin-only fields are saved; for USER role, these params are ignored server-side even if tampered with
- On success: no flash message — silently redirect to `/organisations`
- On validation error: re-render form with red error message at top

---

## 8. Business Logic Rules

1. **Admin-only field enforcement is server-side.** Even if a USER manipulates the HTML and submits admin-only fields, the server ignores them.
2. **orgId is immutable** — it is displayed as plain text, never in an input field, and never accepted as a POST param.
3. **Parent Org dropdown** excludes the org being edited (an org cannot be its own parent).
4. **Parent Org stored as String** (`parentOrgId` stores the orgId string value, not a FK reference).
5. **Search is always explicit** — the org search page shows no results until the user clicks Search.
6. **No success flash messages** — saving an org silently redirects back to the search page.
7. **Error flash messages** are shown at the top of the edit form on validation failure.
8. **Merchant tab is a placeholder** — it shows an empty grid and has no real data or search functionality.
9. **H2 create-drop** — all data is reset on every app restart. Seed data is re-inserted from BootStrap.

---

## 9. UI Style Guide

### Colors
| Usage | Value |
|-------|-------|
| Primary green (tabs, separator, links, title) | `#5a9e32` |
| Page background (edit form) | `#e0e0e0` |
| Top bar / toolbar background | `#ffffff` |
| Nav tab background | `#e8e8e8` |
| Active nav tab background | `#ffffff` |
| Active nav tab border-bottom | 2px solid `#5a9e32` |
| Admin-only locked field background | `#f5f5f5` |
| Admin-only locked field text | `#888` |
| Admin-only label note text | `#e08000` |
| Error message background | `#fdecea` |
| Error message text | `#721c24` |
| Info icon background (ⓘ) | `#5b9bd5` |
| Info icon text | `#ffffff` |
| Separator line between actions | `#bbb` |
| Button background | `#e8e8e8` |
| Button border | `#aaa` |
| Input border (normal) | `#aaa` |
| Input border (focused) | `#5a9e32` |

### Typography
- Font family: `Arial, Helvetica, sans-serif`
- Base font size: `12px`
- Bold labels in forms
- Page title: `13px`, bold

### Layout Conventions
- Top bar: flex, items vertically centered, username+logout at `margin-left: auto` (extreme right)
- Nav tabs: flex row, horizontal, no wrapping
- Toolbar: flex row with search group left + actions bar right
- Form: `<table>` layout, label column 310px wide, no cell borders
- Dollar fields: `$` prefix div + borderless-left input (inline-flex)
- Button row: flex, gap 8px, Cancel is `<a>` styled as button, others are `<button>`

---

## 10. Project File Structure

```
grails-ui-demo/
├── grails-app/
│   ├── controllers/demo/
│   │   ├── AuthController.groovy       # Login / logout
│   │   ├── AuthInterceptor.groovy      # Session guard (blocks unauthenticated)
│   │   ├── HomeController.groovy       # Merchant tab
│   │   ├── OrganisationController.groovy # Org search + edit + update
│   │   └── UrlMappings.groovy          # URL → controller mappings
│   ├── domain/demo/
│   │   ├── AppUser.groovy              # User entity
│   │   └── Organisation.groovy         # Organisation entity
│   ├── services/demo/
│   │   └── OrganisationService.groovy  # @Transactional DB operations
│   ├── views/
│   │   ├── auth/index.gsp              # Login page
│   │   ├── home/index.gsp              # Merchant tab landing
│   │   ├── organisation/
│   │   │   ├── index.gsp               # Org search + results
│   │   │   └── edit.gsp                # Edit Basic Details form
│   │   ├── error.gsp                   # 500 error page
│   │   └── notFound.gsp                # 404 page
│   ├── init/demo/
│   │   ├── Application.groovy          # App entry point
│   │   └── BootStrap.groovy            # Seed data on startup
│   └── conf/
│       └── application.yml             # DB config, server settings
├── build.gradle                        # Grails 7.0.9 + dependencies
├── gradle.properties                   # Version pins
└── settings.gradle                     # Project name: grails-ui-demo
```

---

## 11. Migration Checklist (Grails → React + Spring Boot)

### Backend (Spring Boot)
- [ ] Create Spring Boot 3.x project (Web, JPA, H2, Spring Security, Lombok)
- [ ] Create `AppUser.java` entity with BCrypt password encoding
- [ ] Create `Organisation.java` entity (mirror all fields above)
- [ ] Create `DataInitializer.java` `@PostConstruct` to seed users and orgs
- [ ] Create `AuthController.java` → `POST /api/auth/login` returns JWT, `POST /api/auth/logout`
- [ ] Create `OrganisationController.java` → `GET /api/organisations`, `GET /api/organisations/{id}`, `PUT /api/organisations/{id}`
- [ ] Implement role-based field filtering in update endpoint (ignore admin-only fields for USER role)
- [ ] Configure Spring Security to protect all `/api/**` except `/api/auth/**`
- [ ] Configure H2 console for dev, CORS for React dev server (localhost:5173)

### Frontend (React)
- [ ] Create Vite + React 18 project
- [ ] Set up React Router v6 with `ProtectedRoute` (checks JWT in localStorage)
- [ ] `LoginPage.jsx` — matches login page spec above
- [ ] `MerchantPage.jsx` — static empty grid, matches Merchant tab spec
- [ ] `OrganisationSearchPage.jsx` — search + results grid + row selection + Edit button
- [ ] `EditBasicDetailsPage.jsx` — full form with role-based field disabling
- [ ] `AuthContext.jsx` — stores JWT + user role, provides login/logout actions
- [ ] Axios instance with JWT Bearer header interceptor
- [ ] Match UI style guide (colors, fonts, layout) from Section 9 above

---

*Generated: 2026-04-06 | Source: grails-ui-demo Grails application*
