<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <title>${org.shortName} – View Details</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: Arial, Helvetica, sans-serif; background: #f0f2f5; }
        .topbar { background: #1a3b6e; color: #fff; padding: 10px 24px; display: flex; align-items: center; justify-content: space-between; }
        .topbar h1 { font-size: 16px; font-weight: bold; }
        .topbar .user-info { font-size: 12px; display: flex; align-items: center; gap: 16px; }
        .topbar .role-badge { background: #e8a917; color: #1a3b6e; padding: 2px 8px; border-radius: 10px; font-weight: bold; font-size: 11px; }
        .topbar a.logout { color: #fff; text-decoration: none; font-size: 12px; border: 1px solid rgba(255,255,255,0.5); padding: 4px 10px; border-radius: 3px; }
        .content { padding: 24px; max-width: 900px; margin: 0 auto; }
        .breadcrumb { font-size: 12px; color: #666; margin-bottom: 16px; }
        .breadcrumb a { color: #1a3b6e; text-decoration: none; }
        .card { background: #fff; border: 1px solid #ddd; border-radius: 4px; padding: 24px; }
        .card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 2px solid #1a3b6e; }
        .card-header h2 { font-size: 16px; color: #1a3b6e; }
        .detail-table { width: 100%; border-collapse: collapse; }
        .detail-table tr td { padding: 8px 12px; font-size: 13px; border-bottom: 1px solid #f0f0f0; }
        .detail-table tr td:first-child { font-weight: bold; color: #555; width: 200px; }
        .type-badge { background: #e8f0fe; color: #1a3b6e; padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: bold; }
        .btn { padding: 7px 18px; border-radius: 4px; font-size: 13px; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-primary { background: #1a3b6e; color: #fff; border: none; }
        .btn-secondary { background: #fff; color: #333; border: 1px solid #ccc; }
        .btn:hover { opacity: 0.85; }
        .section-title { font-size: 13px; font-weight: bold; color: #1a3b6e; margin: 16px 0 8px; padding-bottom: 4px; border-bottom: 1px solid #eee; }
        .bool-yes { color: #28a745; font-weight: bold; }
        .bool-no  { color: #dc3545; }
    </style>
</head>
<body>
<div class="topbar">
    <h1>Organisation Management System</h1>
    <div class="user-info">
        <span>Welcome, <strong>${session.user?.fullName}</strong></span>
        <span class="role-badge">${session.user?.role}</span>
        <a href="${createLink(uri: '/logout')}" class="logout">Sign Out</a>
    </div>
</div>

<div class="content">
    <div class="breadcrumb">
        <a href="${createLink(uri: '/organisations')}">Organisations</a> &rsaquo; ${org.shortName}
    </div>

    <div class="card">
        <div class="card-header">
            <h2>${org.orgId} &mdash; ${org.fullName}</h2>
            <div style="display:flex;gap:8px;">
                <g:if test="${session.user?.role == 'ADMIN'}">
                    <a href="${createLink(controller: 'organisation', action: 'edit', id: org.id)}" class="btn btn-primary">Edit</a>
                </g:if>
                <a href="${createLink(uri: '/organisations')}" class="btn btn-secondary">Back to List</a>
            </div>
        </div>

        <div class="section-title">Identity</div>
        <table class="detail-table">
            <tr><td>Organisation ID</td><td>${org.orgId}</td></tr>
            <tr><td>Short Name</td><td>${org.shortName}</td></tr>
            <tr><td>Full Name</td><td>${org.fullName}</td></tr>
        </table>

        <div class="section-title">Address</div>
        <table class="detail-table">
            <tr><td>Corporate Address</td><td>${org.corporateAddress ?: '-'}</td></tr>
            <tr><td>City</td><td>${org.city ?: '-'}</td></tr>
            <tr><td>Country</td><td>${org.country ?: '-'}</td></tr>
            <tr><td>State</td><td>${org.state ?: '-'}</td></tr>
            <tr><td>Postal Code</td><td>${org.postalCode ?: '-'}</td></tr>
        </table>

        <div class="section-title">Classification</div>
        <table class="detail-table">
            <tr><td>Type</td><td><span class="type-badge">${org.type ?: '-'}</span></td></tr>
            <tr><td>Sub Type</td><td>${org.subType ?: '-'}</td></tr>
        </table>

        <div class="section-title">Contract &amp; Hierarchy</div>
        <table class="detail-table">
            <tr><td>Acquiring Contract Owner</td><td>${org.acquiringContractOwner ?: '-'}</td></tr>
            <tr><td>Parent Org ID</td><td>${org.parentOrgId ?: '-'}</td></tr>
        </table>

        <div class="section-title">Financial</div>
        <table class="detail-table">
            <tr><td>Fee Rounding</td><td>${org.feeRounding ?: '-'}</td></tr>
            <tr><td>Dollar Credit Limit</td><td>${org.dollarCreditLimit != null ? "\$${org.dollarCreditLimit}" : '-'}</td></tr>
        </table>

        <div class="section-title">Amex</div>
        <table class="detail-table">
            <tr><td>Amex SV</td><td><span class="${org.amexSV ? 'bool-yes' : 'bool-no'}">${org.amexSV ? 'Yes' : 'No'}</span></td></tr>
            <tr><td>Amex Opt</td><td><span class="${org.amexOpt ? 'bool-yes' : 'bool-no'}">${org.amexOpt ? 'Yes' : 'No'}</span></td></tr>
        </table>

        <div class="section-title">Feature Flags</div>
        <table class="detail-table">
            <tr><td>Feature Flag 1</td><td><span class="${org.featureFlag1 ? 'bool-yes' : 'bool-no'}">${org.featureFlag1 ? 'Enabled' : 'Disabled'}</span></td></tr>
            <tr><td>Feature Flag 2</td><td><span class="${org.featureFlag2 ? 'bool-yes' : 'bool-no'}">${org.featureFlag2 ? 'Enabled' : 'Disabled'}</span></td></tr>
            <tr><td>Feature Flag 3</td><td><span class="${org.featureFlag3 ? 'bool-yes' : 'bool-no'}">${org.featureFlag3 ? 'Enabled' : 'Disabled'}</span></td></tr>
        </table>
    </div>
</div>
</body>
</html>
