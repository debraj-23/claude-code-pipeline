<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Login – Merchant Profile Manager</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 12px;
            background: #ffffff;
            color: #555;
        }

        /* ── Top header bar ── */
        .top-header {
            display: flex;
            align-items: center;
            padding: 6px 10px;
            border-bottom: 2px solid #ccc;
            gap: 10px;
        }


        .header-title {
            font-size: 13px;
            color: #666;
        }

        /* ── Page body ── */
        .page-body {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding-top: 60px;
        }

        /* ── Login card ── */
        .login-card {
            border: 1px solid #5a9e32;
            background: #f0f0f0;
            padding: 24px 32px 20px;
            width: 320px;
        }
        .login-card h2 {
            text-align: center;
            color: #5a9e32;
            font-size: 15px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .form-row {
            display: flex;
            align-items: center;
            margin-bottom: 12px;
        }
        .form-row label {
            width: 90px;
            color: #5a9e32;
            font-size: 12px;
            font-weight: bold;
            flex-shrink: 0;
        }
        .form-row input {
            flex: 1;
            padding: 3px 5px;
            border: 1px solid #aaa;
            background: #fff;
            font-size: 12px;
            outline: none;
        }
        .form-row input:focus { border-color: #5a9e32; }

        .btn-login-wrap {
            text-align: center;
            margin-top: 16px;
        }
        .btn-login {
            padding: 4px 22px;
            background: #e8e8e8;
            border: 1px solid #aaa;
            font-size: 12px;
            cursor: pointer;
            color: #333;
        }
        .btn-login:hover { background: #d8d8d8; }

        .alert-error {
            background: #fdecea;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 6px 10px;
            font-size: 12px;
            margin-bottom: 12px;
            text-align: center;
        }

        /* ── Links below card ── */
        .help-links {
            margin-top: 24px;
            text-align: center;
            font-size: 12px;
            color: #666;
            line-height: 2;
        }
        .help-links a {
            color: #5a9e32;
            text-decoration: none;
            font-weight: bold;
        }
        .help-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>

<!-- Top header -->
<div class="top-header">
    <span class="header-title">Login to Merchant Profile Manager</span>
</div>

<!-- Page body -->
<div class="page-body">
    <div class="login-card">
        <h2>Merchant Profile Manager</h2>

        <g:if test="${flash.error}">
            <div class="alert-error">${flash.error}</div>
        </g:if>

        <g:form url="[uri: '/login']" method="POST">
            <div class="form-row">
                <label for="username">Login ID</label>
                <input type="text" id="username" name="username"
                       value="${params.username ?: ''}" autofocus/>
            </div>
            <div class="form-row">
                <label for="password">Password</label>
                <input type="password" id="password" name="password"/>
            </div>
            <div class="btn-login-wrap">
                <button type="submit" class="btn-login">Login</button>
            </div>
        </g:form>
    </div>

</div>

</body>
</html>
