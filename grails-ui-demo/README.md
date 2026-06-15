# Grails UI Components Demo

A single-page Groovy & Grails web application showcasing all common UI components via GSP (Groovy Server Pages).

## Components Included

| Component | Grails GSP Tag | Notes |
|---|---|---|
| Labels | `<label>` | Uppercase, styled |
| Text Input | `<g:textField>` | Name, Email, Password, Phone, URL |
| Date Picker | `<g:field type="date">` | HTML5 date input |
| Textarea | `<g:textArea>` | Bio, Notes |
| Select / Dropdown | `<g:select>` | Country, Timezone, Experience |
| Radio Buttons | `<g:radio>` / `<input type="radio">` | Gender, Plan, Frequency |
| Checkboxes | `<g:checkBox>` | Interests, Languages |
| Range Sliders | `<input type="range">` | Rating, Volume, Budget |
| Toggle Switch | Custom CSS+checkbox | Dark mode, alerts |
| Color Picker | `<input type="color">` | Live hex preview |
| Number Stepper | Custom JS+number | Quantity |
| File Upload | `<input type="file">` | Drag-and-drop style |
| Star Rating | Radio + CSS flip | 1-5 stars |
| Buttons | `<g:submitButton>` / `<button>` | Primary, Outline, Success, Danger |
| Tooltip | Pure CSS | Hover-reveal |
| Modal Dialog | JS toggle | Backdrop click to close |
| Toast Notification | JS | Auto-dismiss |

---

## Quick Preview (No Grails needed)

Open **`preview.html`** directly in your browser — it is a fully self-contained, static HTML replica of the Grails GSP.

---

## Running as a Grails Application

### Prerequisites
- Java 17+
- Internet access (Gradle downloads itself on first run)

### Step 1 — Download the Gradle wrapper JAR

**Windows:**
```bat
setup.bat
```

**Linux / macOS:**
```bash
chmod +x setup.sh && ./setup.sh
```

### Step 2 — Run the app

**Windows:**
```bat
gradlew.bat bootRun
```

**Linux / macOS:**
```bash
./gradlew bootRun
```

### Step 3 — Open in browser

```
http://localhost:8080
```

The app starts on port **8080** by default and shows the UI demo page.

---

## Project Structure

```
grails-ui-demo/
├── grails-app/
│   ├── controllers/demo/
│   │   └── UiDemoController.groovy     # Handles index + submit + result
│   ├── views/uiDemo/
│   │   ├── index.gsp                   # Main UI demo page (all components)
│   │   └── result.gsp                  # Shows submitted form data
│   ├── init/demo/
│   │   ├── Application.groovy          # Spring Boot entry point
│   │   └── BootStrap.groovy            # App startup hook
│   └── conf/
│       ├── application.yml             # Grails/Spring Boot configuration
│       ├── UrlMappings.groovy          # URL routing
│       └── logback.groovy              # Logging config
├── gradle/wrapper/
│   └── gradle-wrapper.properties
├── build.gradle                        # Grails 6.1.1 + Gradle 8.5
├── gradle.properties
├── settings.gradle
├── gradlew / gradlew.bat
├── setup.sh / setup.bat                # Bootstrap helpers
└── preview.html                        # Instant browser preview (no Grails needed)
```

---

## How the Form Submit Works

1. User fills the form and clicks **Submit**
2. `POST /uiDemo/submit` is routed to `UiDemoController.submit()`
3. The controller reads `params` (and `params.list('interests')` for checkboxes)
4. It redirects to `result` action passing a `formData` map
5. `result.gsp` iterates the map and displays each field/value pair

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Groovy 4.x |
| Framework | Grails 6.1.1 |
| Runtime | Spring Boot 3.x |
| View | GSP (Groovy Server Pages) |
| Build | Gradle 8.5 |
| Java | 17+ |
| Styling | Pure CSS (no external dependencies) |
