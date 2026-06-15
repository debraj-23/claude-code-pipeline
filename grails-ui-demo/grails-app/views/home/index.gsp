<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Merchant – Merchant Profile Manager</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, Helvetica, sans-serif; font-size: 12px; background: #fff; color: #444; }

        /* ── Top bar ── */
        .top-bar { display: flex; align-items: center; padding: 4px 10px; border-bottom: 1px solid #ccc; }
        .user-area { display: flex; align-items: center; gap: 16px; font-size: 12px; margin-left: auto; }
        .user-area .username { color: #5a9e32; font-weight: bold; }
        .user-area a { color: #5a9e32; text-decoration: none; font-weight: bold; }
        .user-area a:hover { text-decoration: underline; }

        /* ── Nav tabs ── */
        .nav-tabs { display: flex; border-bottom: 1px solid #bbb; background: #e8e8e8; padding: 0 4px; }
        .nav-tabs a, .nav-tabs span {
            padding: 6px 14px; font-size: 12px; color: #444; cursor: pointer;
            border: 1px solid transparent; border-bottom: none; margin-bottom: -1px;
            background: #e8e8e8; text-decoration: none; display: inline-block;
        }
        .nav-tabs a:hover, .nav-tabs span:hover { background: #d8d8d8; }
        .nav-tabs a.active {
            background: #ffffff; border-color: #bbb; color: #333; font-weight: bold;
        }

        /* ── Toolbar ── */
        .toolbar {
            display: flex; align-items: center; flex-wrap: wrap;
            padding: 4px 6px; border-bottom: 1px solid #ccc; background: #f9f9f9;
        }
        .toolbar .search-group { display: flex; align-items: center; margin-right: 8px; }
        .toolbar select {
            padding: 2px 4px; border: 1px solid #aaa; font-size: 12px;
            background: #fff; height: 22px; cursor: pointer;
        }
        .toolbar input[type=text] {
            padding: 2px 6px; border: 1px solid #aaa; border-left: none;
            font-size: 12px; height: 22px; width: 160px; outline: none;
        }
        .toolbar .btn-search {
            padding: 2px 12px; border: 1px solid #aaa; border-left: none;
            background: #e8e8e8; font-size: 12px; height: 22px; cursor: pointer; color: #333;
        }
        .toolbar .btn-search:hover { background: #d8d8d8; }
        .toolbar .actions-bar { display: flex; align-items: center; flex-wrap: wrap; }
        .toolbar .actions-bar .sep { color: #bbb; padding: 0 4px; font-size: 13px; }
        .toolbar .actions-bar span {
            font-size: 12px; color: #bbb; padding: 2px 4px; white-space: nowrap;
        }

        /* ── Grid ── */
        .grid-wrapper { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 12px; }
        thead tr { background: #f2f2f2; border-bottom: 2px solid #ccc; }
        thead th {
            padding: 5px 8px; text-align: left; font-weight: bold; color: #444;
            white-space: nowrap; border-right: 1px solid #ddd;
        }
        thead th:last-child { border-right: none; }
        .no-data { padding: 20px; text-align: center; color: #888; font-size: 12px; }

        /* ── Pagination ── */
        .pagination-bar {
            display: flex; align-items: center; justify-content: space-between;
            padding: 4px 8px; border-top: 1px solid #ccc; background: #f9f9f9;
            font-size: 12px; color: #555;
        }
        .pagination-bar .pager { display: flex; align-items: center; gap: 4px; }
        .pagination-bar .pager button {
            background: none; border: 1px solid #bbb; width: 20px; height: 18px;
            font-size: 10px; cursor: pointer; color: #555; padding: 0;
        }
        .pagination-bar .pager button:disabled { color: #ccc; cursor: default; }
        .pagination-bar .pager input {
            width: 36px; text-align: center; border: 1px solid #bbb;
            height: 18px; font-size: 12px; padding: 0 2px;
        }
    </style>
</head>
<body>

<!-- Top Bar -->
<div class="top-bar">
    <div class="user-area">
        <span class="username">Username: ${session.user?.username}</span>
        <a href="${createLink(uri: '/logout')}">Logout</a>
    </div>
</div>

<!-- Navigation Tabs — Merchant is active by default -->
<div class="nav-tabs">
    <a href="${createLink(uri: '/home')}" class="active">Merchant</a>
    <a href="${createLink(uri: '/organisations')}">Organization</a>
</div>

<!-- Toolbar -->
<div class="toolbar">
    <div class="search-group">
        <select>
            <option>Merchant ID/Org ID</option>
        </select>
        <input type="text" placeholder=""/>
        <button class="btn-search">Search</button>
    </div>
    <div class="actions-bar">
        <span class="sep">|</span>
        <span>Edit Basic Details</span>
    </div>
</div>

<!-- Data Grid — empty on load -->
<div class="grid-wrapper">
    <table>
        <thead>
            <tr>
                <th>Merchant ID <span style="color:#888;font-size:10px;">&#8597;</span></th>
                <th>Merchant Name</th>
                <th>External MID</th>
                <th>Status</th>
                <th>Processing Group ID</th>
                <th>Organization ID</th>
                <th>Organization Name</th>
                <th>Organization Type</th>
                <th>Customer Experience Manager</th>
                <th>Payment Service Provider ID</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td colspan="10" class="no-data">No data to display</td>
            </tr>
        </tbody>
    </table>
</div>

<!-- Pagination Bar -->
<div class="pagination-bar">
    <div class="pager">
        <button disabled>&#124;&#9664;</button>
        <button disabled>&#9664;</button>
        &nbsp; Page <input type="text" value="0"/> of 0 &nbsp;
        <button disabled>&#9654;</button>
        <button disabled>&#9654;&#124;</button>
    </div>
    <div>No data to display</div>
</div>

</body>
</html>
