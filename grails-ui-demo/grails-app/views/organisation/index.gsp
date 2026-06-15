<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Organisation – Merchant Profile Manager</title>
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
        .nav-tabs a:hover { background: #d8d8d8; }
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
        .toolbar input[type=text]:focus { border-color: #5a9e32; }
        .toolbar .btn-search {
            padding: 2px 12px; border: 1px solid #aaa; border-left: none;
            background: #e8e8e8; font-size: 12px; height: 22px; cursor: pointer; color: #333;
        }
        .toolbar .btn-search:hover { background: #d8d8d8; }

        /* pipe-separated action links */
        .actions-bar { display: flex; align-items: center; flex-wrap: wrap; }
        .actions-bar .sep { color: #bbb; padding: 0 4px; font-size: 13px; }
        .actions-bar a, .actions-bar span {
            font-size: 12px; color: #444; padding: 2px 4px;
            text-decoration: none; white-space: nowrap; cursor: pointer;
        }
        .actions-bar a:hover { color: #5a9e32; text-decoration: underline; }
        .actions-bar .disabled { color: #bbb; cursor: default; pointer-events: none; }
        .actions-bar a.edit-btn { color: #333; }
        .actions-bar a.edit-btn.inactive { color: #bbb; pointer-events: none; cursor: default; }

        /* ── Flash ── */
        .flash-msg { padding: 5px 10px; font-size: 12px; border-bottom: 1px solid #ccc; }
        .flash-success { background: #dff0d8; color: #3c763d; }
        .flash-error   { background: #fdecea; color: #721c24; }

        /* ── Grid ── */
        .grid-wrapper { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 12px; }
        thead tr { background: #f2f2f2; border-bottom: 2px solid #ccc; }
        thead th {
            padding: 5px 8px; text-align: left; font-weight: bold; color: #444;
            white-space: nowrap; border-right: 1px solid #ddd; cursor: pointer; user-select: none;
        }
        thead th:last-child { border-right: none; }
        tbody tr { border-bottom: 1px solid #eee; cursor: pointer; }
        tbody tr:hover { background: #eef5e8; }
        tbody tr.selected { background: #c8e6c9 !important; }
        tbody td { padding: 4px 8px; color: #333; border-right: 1px solid #eee; white-space: nowrap; }
        tbody td:last-child { border-right: none; }
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
        .pagination-bar .refresh-btn {
            background: none; border: 1px solid #bbb; padding: 1px 6px; cursor: pointer; font-size: 12px;
        }
        .pagination-bar .refresh-btn:hover { background: #e8e8e8; }
    </style>
</head>
<body>

<!-- ── Top Bar ── -->
<div class="top-bar">
    <div class="user-area">
        <span class="username">Username: ${session.user?.username}</span>
        <a href="${createLink(uri: '/logout')}">Logout</a>
    </div>
</div>

<!-- ── Navigation Tabs — Organization is active ── -->
<div class="nav-tabs">
    <a href="${createLink(uri: '/home')}">Merchant</a>
    <a href="${createLink(uri: '/organisations')}" class="active">Organization</a>
</div>

<!-- ── Flash Messages (errors only) ── -->
<g:if test="${flash.error}">
    <div class="flash-msg flash-error">${flash.error}</div>
</g:if>

<!-- ── Toolbar ── -->
<g:form url="[uri: '/organisations']" method="GET" id="searchForm">
    <!-- Hidden flag so controller knows search was submitted -->
    <input type="hidden" name="searched" value="true"/>
    <div class="toolbar">
        <div class="search-group">
            <select name="searchField" id="searchField">
                <option value="orgId"    ${searchField == 'orgId'    || !searchField ? 'selected' : ''}>Organization ID</option>
                <option value="fullName" ${searchField == 'fullName' ? 'selected' : ''}>Full Name</option>
            </select>
            <input type="text" name="query" id="queryInput" value="${query ?: ''}" autofocus/>
            <button type="submit" class="btn-search">Search</button>
        </div>

        <div class="actions-bar">
            <span class="sep">|</span>
            <a href="#" id="editBasicDetailsBtn" class="edit-btn inactive" onclick="editSelected(event)">Edit Basic Details</a>
        </div>
    </div>
</g:form>

<!-- ── Data Grid ── -->
<div class="grid-wrapper">
    <table id="orgTable">
        <thead>
            <tr>
                <th>Organization ID &#8597;</th>
                <th>Short Name</th>
                <th>Full Name</th>
                <th>Type</th>
                <th>Amex Payment Service Provider</th>
                <th>Acquiring Contract Owner</th>
                <th>Parent Organization ID</th>
                <th>Fee Rounding</th>
                <th>Deposit Credit Limit</th>
            </tr>
        </thead>
        <tbody>
            <g:if test="${searched && organisations}">
                <g:each in="${organisations}" var="org">
                    <tr data-id="${org.id}"
                        data-edit="${createLink(controller: 'organisation', action: 'edit', id: org.id)}"
                        onclick="selectRow(this)">
                        <td>${org.orgId}</td>
                        <td>${org.shortName}</td>
                        <td>${org.fullName}</td>
                        <td>${org.type ?: ''}</td>
                        <td>${org.amexPaymentServiceProvider ? 'true' : 'false'}</td>
                        <td>${org.acquiringContractOwner ?: ''}</td>
                        <td>${org.parentOrgId ?: ''}</td>
                        <td>${org.feeRounding ?: ''}</td>
                        <td>${org.depositCreditLimit != null ? org.depositCreditLimit : ''}</td>
                    </tr>
                </g:each>
            </g:if>
            <g:elseif test="${searched && !organisations}">
                <tr><td colspan="9" class="no-data">No data to display</td></tr>
            </g:elseif>
            <g:else>
                <!-- Not yet searched — show empty grid -->
                <tr><td colspan="9" class="no-data">No data to display</td></tr>
            </g:else>
        </tbody>
    </table>
</div>

<!-- ── Pagination Bar ── -->
<div class="pagination-bar">
    <div class="pager">
        <button disabled>&#124;&#9664;</button>
        <button disabled>&#9664;</button>
        &nbsp; Page <input type="text" value="${(searched && organisations) ? 1 : 0}"/>
        of ${(searched && organisations) ? 1 : 0} &nbsp;
        <button disabled>&#9654;</button>
        <button disabled>&#9654;&#124;</button>
        &nbsp;
        <button class="refresh-btn" onclick="window.location.href='${createLink(uri: '/organisations')}'" title="Refresh">&#8635;</button>
    </div>
    <div>
        <g:if test="${searched && organisations}">
            Showing ${organisations.size()} record(s)
        </g:if>
        <g:else>
            No data to display
        </g:else>
    </div>
</div>

<script>
    var selectedRow = null;
    var selectedEditUrl = null;

    function selectRow(row) {
        if (selectedRow) selectedRow.classList.remove('selected');
        if (selectedRow === row) {
            selectedRow = null;
            selectedEditUrl = null;
            setEditActive(false);
        } else {
            row.classList.add('selected');
            selectedRow = row;
            selectedEditUrl = row.getAttribute('data-edit');
            setEditActive(true);
        }
    }

    function setEditActive(active) {
        var btn = document.getElementById('editBasicDetailsBtn');
        if (!btn) return;
        if (active) {
            btn.classList.remove('inactive');
        } else {
            btn.classList.add('inactive');
        }
    }

    function editSelected(e) {
        e.preventDefault();
        if (selectedEditUrl) window.location.href = selectedEditUrl;
    }
</script>

</body>
</html>
