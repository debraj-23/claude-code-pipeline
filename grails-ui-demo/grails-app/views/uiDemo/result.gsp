<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Form Submitted — Grails UI Demo</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --primary: #4f46e5; --success: #10b981; --bg: #f1f5f9;
            --surface: #fff; --border: #e2e8f0; --text: #1e293b; --muted: #64748b;
        }
        body { font-family: 'Segoe UI', system-ui, sans-serif; background: var(--bg); color: var(--text); }
        .app-header {
            background: linear-gradient(135deg, var(--primary) 0%, #7c3aed 100%);
            color: #fff; padding: 24px 40px; display: flex; align-items: center; gap: 16px;
        }
        .container { max-width: 720px; margin: 40px auto; padding: 0 24px 60px; }
        .card { background: var(--surface); border-radius: 10px; box-shadow: 0 2px 12px rgba(0,0,0,.08); padding: 28px 32px; }
        .success-banner {
            background: #d1fae5; border: 1px solid #6ee7b7; border-radius: 10px;
            padding: 20px 24px; margin-bottom: 24px; display: flex; align-items: center; gap: 16px;
        }
        .success-icon { font-size: 36px; }
        h2 { font-size: 20px; color: #065f46; }
        .result-row { display: flex; padding: 10px 0; border-bottom: 1px solid var(--border); gap: 16px; }
        .result-row:last-child { border-bottom: none; }
        .result-key { font-size: 13px; font-weight: 700; color: var(--muted); min-width: 160px; text-transform: uppercase; letter-spacing: .4px; }
        .result-val { font-size: 14px; color: var(--text); }
        .btn {
            display: inline-block; margin-top: 20px;
            padding: 10px 24px; background: var(--primary); color: #fff;
            border-radius: 8px; text-decoration: none; font-size: 14px; font-weight: 600;
        }
        .btn:hover { opacity: .9; }
    </style>
</head>
<body>
<header class="app-header">
    <div style="width:48px;height:48px;background:rgba(255,255,255,.2);border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:24px;font-weight:700;">G</div>
    <div>
        <h1 style="font-size:22px;font-weight:700;">Grails UI Demo — Submission Result</h1>
        <p style="font-size:13px;opacity:.75;">Groovy &amp; Grails GSP Form</p>
    </div>
</header>

<div class="container">
    <div class="success-banner">
        <span class="success-icon">&#9989;</span>
        <div>
            <h2>Form Submitted Successfully!</h2>
            <p style="font-size:13px;color:#065f46;margin-top:4px;">Here is the data received by the Grails controller.</p>
        </div>
    </div>

    <div class="card">
        <g:each in="${formData}" var="entry">
            <div class="result-row">
                <span class="result-key">${entry.key}</span>
                <span class="result-val">
                    <g:if test="${entry.value instanceof List}">
                        ${entry.value.join(', ') ?: '(none selected)'}
                    </g:if>
                    <g:elseif test="${entry.value instanceof Boolean}">
                        ${entry.value ? 'Yes ✓' : 'No ✗'}
                    </g:elseif>
                    <g:else>
                        ${entry.value ?: '(empty)'}
                    </g:else>
                </span>
            </div>
        </g:each>
    </div>

    <a href="${createLink(controller: 'uiDemo', action: 'index')}" class="btn">
        &#8592; Back to Form
    </a>
</div>
</body>
</html>
