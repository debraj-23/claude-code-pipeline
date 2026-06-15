<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${org.fullName} (${org.orgId}): Organization Basic Details</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 12px;
            background: #e0e0e0;
            color: #333;
        }

        /* ── Top bar ── */
        .top-bar {
            display: flex;
            align-items: center;
            padding: 4px 10px;
            background: #fff;
            border-bottom: 1px solid #ccc;
        }
        .user-area {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 12px;
            margin-left: auto;
        }
        .user-area .username { color: #5a9e32; font-weight: bold; }
        .user-area a { color: #5a9e32; text-decoration: none; font-weight: bold; }
        .user-area a:hover { text-decoration: underline; }

        /* ── Green separator ── */
        .green-line { height: 3px; background: #5a9e32; }

        /* ── Page title ── */
        .page-title {
            padding: 6px 10px;
            font-size: 13px;
            font-weight: bold;
            color: #333;
            background: #fff;
            border-bottom: 1px solid #ccc;
        }

        /* ── Flash ── */
        .flash-error {
            background: #fdecea; color: #721c24;
            padding: 6px 10px; font-size: 12px; border-bottom: 1px solid #f5c6cb;
        }

        /* ── Form ── */
        .form-wrap { padding: 10px 10px 20px; }

        table.form-tbl { border-collapse: collapse; }
        table.form-tbl tr td { padding: 4px 6px; vertical-align: middle; font-size: 12px; }

        /* Label column */
        table.form-tbl td.lbl {
            font-weight: bold;
            color: #333;
            width: 310px;
            white-space: nowrap;
            padding-right: 10px;
        }

        /* Read-only value */
        td.val-readonly { color: #333; }

        /* Admin-only field locked indicator */
        .admin-only-field { background: #f5f5f5 !important; color: #888 !important; cursor: not-allowed !important; }
        .admin-lock-note { font-size: 11px; color: #e08000; margin-left: 6px; font-style: italic; }

        /* Text inputs */
        table.form-tbl input[type=text],
        table.form-tbl input[type=number] {
            padding: 2px 4px;
            border: 1px solid #aaa;
            background: #fff;
            font-size: 12px;
            height: 20px;
            outline: none;
        }
        table.form-tbl input[type=text]:focus,
        table.form-tbl input[type=number]:focus { border-color: #5a9e32; }

        /* Short inputs */
        .inp-sm  { width: 80px;  }
        .inp-md  { width: 160px; }
        .inp-lg  { width: 260px; }
        .inp-xl  { width: 370px; }

        /* Select / dropdown */
        table.form-tbl select {
            padding: 1px 4px;
            border: 1px solid #aaa;
            background: #fff;
            font-size: 12px;
            height: 20px;
            cursor: pointer;
        }
        .sel-sm  { width: 120px; }
        .sel-md  { width: 200px; }
        .sel-lg  { width: 370px; }

        /* Dollar prefix field */
        .dollar-wrap { display: inline-flex; align-items: center; }
        .dollar-wrap .dollar-sign {
            padding: 1px 4px;
            border: 1px solid #aaa;
            border-right: none;
            background: #f5f5f5;
            font-size: 12px;
            height: 20px;
            line-height: 18px;
        }
        .dollar-wrap input {
            border-left: none !important;
            width: 140px;
        }

        /* Checkbox */
        table.form-tbl input[type=checkbox] {
            width: 13px; height: 13px; cursor: pointer; vertical-align: middle;
        }

        /* Info icon */
        .info-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 14px; height: 14px;
            background: #5b9bd5;
            color: #fff;
            border-radius: 50%;
            font-size: 9px;
            font-weight: bold;
            margin-left: 4px;
            cursor: default;
            vertical-align: middle;
        }

        /* ── Buttons ── */
        .btn-row { padding: 10px 10px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .btn {
            padding: 3px 14px;
            border: 1px solid #aaa;
            background: #e8e8e8;
            font-size: 12px;
            cursor: pointer;
            color: #333;
        }
        .btn:hover { background: #d4d4d4; }
        .btn-multisite { margin-right: 20px; }
    </style>
</head>
<body>

<!-- Top bar -->
<div class="top-bar">
    <div class="user-area">
        <span class="username">Username: ${session.user?.username}</span>
        <a href="${createLink(uri: '/logout')}">Logout</a>
    </div>
</div>

<!-- Green separator -->
<div class="green-line"></div>

<!-- Page title -->
<div class="page-title">
    ${org.fullName} (${org.orgId}): Organization Basic Details
</div>

<g:if test="${flash.error}">
    <div class="flash-error">${flash.error}</div>
</g:if>

<g:form url="[uri: '/organisations/' + org.id + '/update']" method="POST">
<div class="form-wrap">
<table class="form-tbl">

    <!-- Organization ID (read-only) -->
    <tr>
        <td class="lbl">Organization ID</td>
        <td class="val-readonly">${org.orgId}</td>
    </tr>

    <!-- Short Name -->
    <tr>
        <td class="lbl">Short Name <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td><input type="text" name="shortName" value="${org.shortName}" class="inp-md ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'readonly' : ''}/></td>
    </tr>

    <!-- Full Name -->
    <tr>
        <td class="lbl">Full Name <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td><input type="text" name="fullName" value="${org.fullName}" class="inp-xl ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'readonly' : ''}/></td>
    </tr>

    <!-- Corporate Street Address -->
    <tr>
        <td class="lbl">Corporate Street Address</td>
        <td><input type="text" name="corporateAddress" value="${org.corporateAddress ?: ''}" class="inp-xl"/></td>
    </tr>

    <!-- Corporate Street Address 2 -->
    <tr>
        <td class="lbl">Corporate Street Address 2</td>
        <td><input type="text" name="corporateAddress2" value="${org.corporateAddress2 ?: ''}" class="inp-xl"/></td>
    </tr>

    <!-- Corporate City -->
    <tr>
        <td class="lbl">Corporate City</td>
        <td><input type="text" name="city" value="${org.city ?: ''}" class="inp-md"/></td>
    </tr>

    <!-- Corporate Country -->
    <tr>
        <td class="lbl">Corporate Country</td>
        <td>
            <select name="country" class="sel-md">
                <option value="">Select One...</option>
                <option value="USA" ${org.country == 'USA' ? 'selected' : ''}>United States</option>
                <option value="CAN" ${org.country == 'CAN' ? 'selected' : ''}>Canada</option>
                <option value="GBR" ${org.country == 'GBR' ? 'selected' : ''}>United Kingdom</option>
                <option value="AUS" ${org.country == 'AUS' ? 'selected' : ''}>Australia</option>
                <option value="IND" ${org.country == 'IND' ? 'selected' : ''}>India</option>
            </select>
        </td>
    </tr>

    <!-- Corporate State -->
    <tr>
        <td class="lbl">Corporate State</td>
        <td>
            <select name="state" class="sel-sm">
                <option value="">--</option>
                <option value="AL" ${org.state=='AL'?'selected':''}>AL</option>
                <option value="CA" ${org.state=='CA'?'selected':''}>CA</option>
                <option value="FL" ${org.state=='FL'?'selected':''}>FL</option>
                <option value="GA" ${org.state=='GA'?'selected':''}>GA</option>
                <option value="IL" ${org.state=='IL'?'selected':''}>IL</option>
                <option value="MA" ${org.state=='MA'?'selected':''}>MA</option>
                <option value="NJ" ${org.state=='NJ'?'selected':''}>NJ</option>
                <option value="NY" ${org.state=='NY'?'selected':''}>NY</option>
                <option value="TX" ${org.state=='TX'?'selected':''}>TX</option>
                <option value="WA" ${org.state=='WA'?'selected':''}>WA</option>
            </select>
        </td>
    </tr>

    <!-- Corporate Postal Code -->
    <tr>
        <td class="lbl">Corporate Postal Code</td>
        <td><input type="text" name="postalCode" value="${org.postalCode ?: ''}" class="inp-sm"/></td>
    </tr>

    <!-- Type -->
    <tr>
        <td class="lbl">Type</td>
        <td>
            <select name="type" class="sel-md" id="typeSelect" onchange="updateSubType()">
                <option value="">Select One...</option>
                <option value="Merchant"  ${org.type == 'Merchant'  ? 'selected' : ''}>Merchant</option>
                <option value="ISO"       ${org.type == 'ISO'       ? 'selected' : ''}>ISO</option>
                <option value="Acquirer"  ${org.type == 'Acquirer'  ? 'selected' : ''}>Acquirer</option>
                <option value="Processor" ${org.type == 'Processor' ? 'selected' : ''}>Processor</option>
            </select>
        </td>
    </tr>

    <!-- Sub Type -->
    <tr>
        <td class="lbl">Sub Type</td>
        <td>
            <select name="subType" class="sel-md" id="subTypeSelect">
                <option value="">No SubType</option>
                <option value="Retail"     ${org.subType == 'Retail'     ? 'selected' : ''}>Retail</option>
                <option value="Ecommerce"  ${org.subType == 'Ecommerce'  ? 'selected' : ''}>Ecommerce</option>
                <option value="Hotel"      ${org.subType == 'Hotel'      ? 'selected' : ''}>Hotel</option>
                <option value="Wholesale"  ${org.subType == 'Wholesale'  ? 'selected' : ''}>Wholesale</option>
            </select>
        </td>
    </tr>

    <!-- Amex Payment Service Provider -->
    <tr>
        <td class="lbl">Amex Payment Service Provider</td>
        <td><input type="checkbox" name="amexPaymentServiceProvider" ${org.amexPaymentServiceProvider ? 'checked' : ''}/></td>
    </tr>

    <!-- Amex Marketing Indicator -->
    <tr>
        <td class="lbl">Amex Marketing Indicator</td>
        <td><input type="checkbox" name="amexMarketingIndicator" ${org.amexMarketingIndicator ? 'checked' : ''}/></td>
    </tr>

    <!-- Acquiring Contract Owner -->
    <tr>
        <td class="lbl">Acquiring Contract Owner</td>
        <td>
            <select name="acquiringContractOwner" class="sel-md">
                <option value="">Select One...</option>
                <option value="Acquirer A"       ${org.acquiringContractOwner == 'Acquirer A'      ? 'selected' : ''}>Acquirer A</option>
                <option value="Chase Paymentech" ${org.acquiringContractOwner == 'Chase Paymentech'? 'selected' : ''}>Chase Paymentech</option>
                <option value="Wells Fargo"      ${org.acquiringContractOwner == 'Wells Fargo'     ? 'selected' : ''}>Wells Fargo</option>
                <option value="Bank of America"  ${org.acquiringContractOwner == 'Bank of America' ? 'selected' : ''}>Bank of America</option>
                <option value="Citi"             ${org.acquiringContractOwner == 'Citi'            ? 'selected' : ''}>Citi</option>
                <option value="US Bank"          ${org.acquiringContractOwner == 'US Bank'         ? 'selected' : ''}>US Bank</option>
            </select>
        </td>
    </tr>

    <!-- Parent Organization ID -->
    <tr>
        <td class="lbl">Parent Organization ID <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <select name="parentOrgId" class="sel-md ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'disabled' : ''}>
                <option value="none">Select One...</option>
                <g:each in="${allOrgs}" var="o">
                    <g:if test="${o.id != org.id}">
                        <option value="${o.orgId}" ${org.parentOrgId == o.orgId ? 'selected' : ''}>${o.orgId} – ${o.shortName}</option>
                    </g:if>
                </g:each>
            </select>
        </td>
    </tr>

    <!-- Fee Rounding -->
    <tr>
        <td class="lbl">Fee Rounding <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <select name="feeRounding" class="sel-lg ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'disabled' : ''}>
                <option value="">Select One...</option>
                <option value="bankers_agg" ${org.feeRounding == 'bankers_agg' ? 'selected' : ''}>bankers_agg - round half even at journal entry level</option>
                <option value="ROUND_UP"    ${org.feeRounding == 'ROUND_UP'    ? 'selected' : ''}>round_up - always round up</option>
                <option value="ROUND_DOWN"  ${org.feeRounding == 'ROUND_DOWN'  ? 'selected' : ''}>round_down - always round down</option>
                <option value="ROUND_HALF"  ${org.feeRounding == 'ROUND_HALF'  ? 'selected' : ''}>round_half - round half up</option>
                <option value="NONE"        ${org.feeRounding == 'NONE'        ? 'selected' : ''}>none - no rounding</option>
            </select>
        </td>
    </tr>

    <!-- Deposit Credit Limit -->
    <tr>
        <td class="lbl">Deposit Credit Limit (in USD including foreign currency) <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <div class="dollar-wrap">
                <span class="dollar-sign">$</span>
                <input type="text" name="depositCreditLimit" value="${org.depositCreditLimit ?: ''}" class="inp-md ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'readonly' : ''}/>
            </div>
        </td>
    </tr>

    <!-- Refund Credit Limit -->
    <tr>
        <td class="lbl">Refund Credit Limit (in USD including foreign currency) <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <div class="dollar-wrap">
                <span class="dollar-sign">$</span>
                <input type="text" name="refundCreditLimit" value="${org.refundCreditLimit ?: ''}" class="inp-md ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'readonly' : ''}/>
            </div>
        </td>
    </tr>

    <!-- Orphan Refund Credit Limit -->
    <tr>
        <td class="lbl">Orphan Refund Credit Limit (in USD including foreign currency) <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <div class="dollar-wrap">
                <span class="dollar-sign">$</span>
                <input type="text" name="orphanRefundCreditLimit" value="${org.orphanRefundCreditLimit ?: ''}" class="inp-md ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'readonly' : ''}/>
            </div>
        </td>
    </tr>

    <!-- Support MasterCard BSAIR -->
    <tr>
        <td class="lbl">Support MasterCard Business Service Arrangement Interchange Rates <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="supportMastercardInterchange" ${org.supportMastercardInterchange ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Enables MasterCard BSAIR support">i</span>
        </td>
    </tr>

    <!-- Support Query Transactions -->
    <tr>
        <td class="lbl">Support Query Transactions <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="supportQueryTransactions" ${org.supportQueryTransactions ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Allow query transaction type">i</span>
        </td>
    </tr>

    <!-- Salesforce Id -->
    <tr>
        <td class="lbl">Salesforce Id</td>
        <td><input type="text" name="salesforceId" value="${org.salesforceId ?: ''}" class="inp-lg"/></td>
    </tr>

    <!-- Enable Logical Back End Tying -->
    <tr>
        <td class="lbl">Enable Logical Back End Tying <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="enableLogicalBackEndTying" ${org.enableLogicalBackEndTying ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Enable logical back end tying">i</span>
        </td>
    </tr>

    <!-- Start Multi Site Day -->
    <tr>
        <td class="lbl">Start Multi Site Day</td>
        <td>
            <input type="text" name="startMultiSiteDay" value="${org.startMultiSiteDay ?: ''}" class="inp-sm"/>
            <span class="info-icon" title="Day of month multi-site processing starts">i</span>
        </td>
    </tr>

    <!-- Maximum No. of Category Nodes -->
    <tr>
        <td class="lbl">Maximum No. of Category Nodes</td>
        <td><input type="text" name="maxCategoryNodes" value="${org.maxCategoryNodes ?: 100}" class="inp-sm"/></td>
    </tr>

    <!-- SLA Report Frequency -->
    <tr>
        <td class="lbl">SLA Report Frequency</td>
        <td>
            <select name="slaReportFrequency" class="sel-sm">
                <option value="None"    ${(org.slaReportFrequency ?: 'None') == 'None'    ? 'selected' : ''}>None</option>
                <option value="Daily"   ${org.slaReportFrequency == 'Daily'   ? 'selected' : ''}>Daily</option>
                <option value="Weekly"  ${org.slaReportFrequency == 'Weekly'  ? 'selected' : ''}>Weekly</option>
                <option value="Monthly" ${org.slaReportFrequency == 'Monthly' ? 'selected' : ''}>Monthly</option>
            </select>
        </td>
    </tr>

    <!-- Enable Early Report Generation -->
    <tr>
        <td class="lbl">Enable Early Report Generation <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="enableEarlyReportGeneration" ${org.enableEarlyReportGeneration ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Generate reports earlier in processing cycle">i</span>
        </td>
    </tr>

    <!-- Acquirer Fee Level -->
    <tr>
        <td class="lbl">Acquirer Fee Level <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <select name="acquirerFeeLevel" class="sel-sm ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'disabled' : ''}>
                <option value="Default"  ${(org.acquirerFeeLevel ?: 'Default') == 'Default'  ? 'selected' : ''}>Default</option>
                <option value="Level1"   ${org.acquirerFeeLevel == 'Level1'   ? 'selected' : ''}>Level 1</option>
                <option value="Level2"   ${org.acquirerFeeLevel == 'Level2'   ? 'selected' : ''}>Level 2</option>
                <option value="Level3"   ${org.acquirerFeeLevel == 'Level3'   ? 'selected' : ''}>Level 3</option>
            </select>
        </td>
    </tr>

    <!-- Pazien Enable Indicator -->
    <tr>
        <td class="lbl">Pazien Enable Indicator <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="pazienEnableIndicator" ${org.pazienEnableIndicator ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Enable Pazien analytics integration">i</span>
        </td>
    </tr>

    <!-- SSO Pazien -->
    <tr>
        <td class="lbl">SSO Pazien <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="ssoPazien" ${org.ssoPazien ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Enable Single Sign-On for Pazien">i</span>
        </td>
    </tr>

    <!-- 8 Digit Bin SSR -->
    <tr>
        <td class="lbl">8 Digit Bin SSR <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="eightDigitBinSSR" ${org.eightDigitBinSSR ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Support 8-digit BIN in SSR reports">i</span>
        </td>
    </tr>

    <!-- Net Settled Sales Report Remove Comma -->
    <tr>
        <td class="lbl">Net Settled Sales Report Remove Comma <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="netSettledSalesReportRemoveComma" ${org.netSettledSalesReportRemoveComma ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Remove comma separator from net settled sales report">i</span>
        </td>
    </tr>

    <!-- Daily eCheck Sales Volume Limit -->
    <tr>
        <td class="lbl">Daily eCheck Sales Volume Limit <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <div class="dollar-wrap">
                <span class="dollar-sign">$</span>
                <input type="text" name="dailyECheckSalesVolumeLimit" value="${org.dailyECheckSalesVolumeLimit ?: ''}" class="inp-md ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'readonly' : ''}/>
            </div>
            <span class="info-icon" title="Maximum daily eCheck sales volume">i</span>
        </td>
    </tr>

    <!-- Daily eCheck Credit Volume Limit -->
    <tr>
        <td class="lbl">Daily eCheck Credit Volume Limit <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <div class="dollar-wrap">
                <span class="dollar-sign">$</span>
                <input type="text" name="dailyECheckCreditVolumeLimit" value="${org.dailyECheckCreditVolumeLimit ?: ''}" class="inp-md ${!isAdmin ? 'admin-only-field' : ''}" ${!isAdmin ? 'readonly' : ''}/>
            </div>
            <span class="info-icon" title="Maximum daily eCheck credit volume">i</span>
        </td>
    </tr>

    <!-- Preferred Customer Report Indicator -->
    <tr>
        <td class="lbl">Preferred Customer Report Indicator <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="preferredCustomerReportIndicator" ${org.preferredCustomerReportIndicator ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Mark as preferred customer for reporting">i</span>
        </td>
    </tr>

    <!-- Embedded Finance Enabled -->
    <tr>
        <td class="lbl">Embedded Finance Enabled <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="embeddedFinanceEnabled" ${org.embeddedFinanceEnabled ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Enable embedded finance features">i</span>
        </td>
    </tr>

    <!-- SaferPayment Enabled -->
    <tr>
        <td class="lbl">SaferPayment Enabled <g:if test="${!isAdmin}"><span class="admin-lock-note">(Admin only)</span></g:if></td>
        <td>
            <input type="checkbox" name="saferPaymentEnabled" ${org.saferPaymentEnabled ? 'checked' : ''} ${!isAdmin ? 'disabled' : ''}/>
            <span class="info-icon" title="Enable SaferPayment fraud detection">i</span>
        </td>
    </tr>

</table>
</div>

<!-- Button row -->
<div class="btn-row">
    <button type="button" class="btn btn-multisite">Check Multi-Site Compatible</button>
    <a href="${createLink(uri: '/organisations')}" class="btn">Cancel</a>
    <button type="submit" class="btn">Save</button>
</div>

</g:form>

<script>
    function updateSubType() {
        // Sub type stays enabled — just a placeholder for future logic
    }
</script>

</body>
</html>
