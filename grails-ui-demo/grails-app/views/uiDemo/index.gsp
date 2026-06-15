<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Grails UI Components Demo</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 13px;
            background: #e8e8e8;
            color: #222;
        }

        .page-wrap { background: #f0f0f0; min-height: 100vh; }

        /* Green top bar */
        .top-bar { height: 4px; background: #3dba4e; }

        /* Flash message */
        .flash-msg {
            margin: 8px 16px;
            padding: 7px 12px;
            background: #dff0d8;
            border: 1px solid #a5d6a7;
            color: #2e7d32;
            font-size: 13px;
        }

        /* Form table */
        .form-table { width: 100%; border-collapse: collapse; }
        .form-table tr { border-bottom: 1px solid #ddd; }
        .form-table tr:last-child { border-bottom: none; }
        .form-table td { padding: 5px 10px 5px 16px; vertical-align: middle; }

        /* Label cell */
        .form-table td.lbl {
            width: 38%;
            font-weight: bold;
            color: #222;
            white-space: nowrap;
            padding-right: 12px;
        }

        /* Control cell */
        .form-table td.ctrl { width: 62%; }

        /* Read-only */
        .readonly-val { font-size: 13px; color: #222; }

        /* Text inputs */
        input[type="text"] {
            height: 24px; padding: 2px 5px;
            border: 1px solid #aaa; background: #fff;
            font-size: 13px; font-family: Arial, Helvetica, sans-serif;
            color: #222; outline: none;
        }
        input[type="text"]:focus { border-color: #5a9fd4; box-shadow: inset 0 1px 3px rgba(0,0,0,.15); }

        input.w80  { width: 80px; }
        input.w120 { width: 120px; }
        input.w160 { width: 160px; }
        input.w300 { width: 300px; }
        input.w400 { width: 400px; }

        /* Select */
        select {
            height: 24px; padding: 2px 4px;
            border: 1px solid #aaa; background: #fff;
            font-size: 13px; font-family: Arial, Helvetica, sans-serif;
            color: #222; outline: none;
        }
        select:focus { border-color: #5a9fd4; }
        select.w90  { width: 90px; }
        select.w170 { width: 170px; }
        select.w420 { width: 420px; }

        /* Checkbox */
        input[type="checkbox"] {
            width: 14px; height: 14px;
            cursor: pointer; vertical-align: middle;
            margin: 0; accent-color: #1a6fc4;
        }

        /* Dollar prefix */
        .dollar-wrap { display: inline-flex; align-items: center; }
        .dollar-prefix {
            display: inline-block; height: 24px; line-height: 24px;
            padding: 0 5px; background: #e8e8e8;
            border: 1px solid #aaa; border-right: none;
            font-size: 13px; color: #444;
        }
        .dollar-wrap input { border-left: none; width: 130px; }

        /* Info icon */
        .info-icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 16px; height: 16px; background: #4a90d9; color: #fff;
            border-radius: 50%; font-size: 10px; font-weight: bold; font-style: normal;
            cursor: default; margin-left: 5px; vertical-align: middle;
            user-select: none; position: relative; flex-shrink: 0;
        }
        .info-icon:hover::after {
            content: attr(data-tip);
            position: absolute; left: 22px; top: 50%; transform: translateY(-50%);
            background: #333; color: #fff; padding: 4px 8px; border-radius: 4px;
            font-size: 11px; white-space: nowrap; z-index: 99; pointer-events: none;
        }
        .lbl-wrap { display: flex; align-items: center; }

        /* Action buttons */
        .action-row {
            padding: 12px 16px; border-top: 1px solid #ccc;
            background: #f0f0f0; display: flex; gap: 6px;
        }
        .btn {
            height: 26px; padding: 0 14px; font-size: 13px;
            font-family: Arial, Helvetica, sans-serif; cursor: pointer;
            border: 1px solid; outline: none;
        }
        .btn-default { background: #f5f5f5; border-color: #aaa; color: #333; }
        .btn-default:hover { background: #e8e8e8; }
        .btn-success { background: #5cb85c; border-color: #4cae4c; color: #fff; }
        .btn-success:hover { background: #4cae4c; }
    </style>
</head>
<body>
<div class="page-wrap">

    <div class="top-bar"></div>

    <g:if test="${flash.message}">
        <div class="flash-msg">&#10003; ${flash.message}</div>
    </g:if>

    <g:form controller="uiDemo" action="submit" method="post">
    <table class="form-table">

        <tr>
            <td class="lbl">Organization ID</td>
            <td class="ctrl"><span class="readonly-val">100</span></td>
        </tr>

        <tr>
            <td class="lbl">Short Name</td>
            <td class="ctrl">
                <g:textField name="shortName" class="w120" value="${params.shortName ?: 'PTITEST'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Full Name</td>
            <td class="ctrl">
                <g:textField name="fullName" class="w300" value="${params.fullName ?: 'PTI Test Merchant'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Corporate Street Address</td>
            <td class="ctrl">
                <g:textField name="streetAddr1" class="w400" value="${params.streetAddr1 ?: ''}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Corporate Street Address 2</td>
            <td class="ctrl">
                <g:textField name="streetAddr2" class="w400" value="${params.streetAddr2 ?: ''}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Corporate City</td>
            <td class="ctrl">
                <g:textField name="city" class="w160" value="${params.city ?: ''}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Corporate Country</td>
            <td class="ctrl">
                <g:select name="country" class="w170"
                          from="${['Select One...','Australia','Brazil','Canada','France','Germany','India','Japan','Mexico','United Kingdom','United States']}"
                          value="${params.country ?: 'Select One...'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Corporate State</td>
            <td class="ctrl">
                <g:select name="state" class="w90"
                          from="${['','AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY']}"
                          value="${params.state ?: ''}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Corporate Postal Code</td>
            <td class="ctrl">
                <g:textField name="postalCode" class="w80" value="${params.postalCode ?: ''}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Type</td>
            <td class="ctrl">
                <g:select name="type" class="w170"
                          from="${['Merchant','Partner','Acquirer','Processor']}"
                          value="${params.type ?: 'Merchant'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Sub Type</td>
            <td class="ctrl">
                <g:select name="subType" class="w170"
                          from="${['No SubType','Type A','Type B','Type C']}"
                          value="${params.subType ?: 'No SubType'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Amex Payment Service Provider</td>
            <td class="ctrl">
                <g:checkBox name="amexPSP" value="on" checked="${params.amexPSP == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Amex Marketing Indicator</td>
            <td class="ctrl">
                <g:checkBox name="amexMarketing" value="on" checked="${params.amexMarketing != 'false'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Acquiring Contract Owner</td>
            <td class="ctrl">
                <g:select name="contractOwner" class="w170"
                          from="${['Acquirer A','Acquirer B','Acquirer C','Acquirer D']}"
                          value="${params.contractOwner ?: 'Acquirer A'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Parent Organization ID</td>
            <td class="ctrl">
                <g:select name="parentOrgId" class="w170"
                          from="${['Select One...','100','200','300','400']}"
                          value="${params.parentOrgId ?: 'Select One...'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Fee Rounding</td>
            <td class="ctrl">
                <g:select name="feeRounding" class="w420"
                          from="${['bankers_agg - round half even at journal entry level','standard - round half up','truncate - always round down','ceiling - always round up']}"
                          value="${params.feeRounding ?: 'bankers_agg - round half even at journal entry level'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Deposit Credit Limit (in USD including foreign currency)</td>
            <td class="ctrl">
                <span class="dollar-wrap">
                    <span class="dollar-prefix">$</span>
                    <g:textField name="depositLimit" value="${params.depositLimit ?: ''}"/>
                </span>
            </td>
        </tr>

        <tr>
            <td class="lbl">Refund Credit Limit (in USD including foreign currency)</td>
            <td class="ctrl">
                <span class="dollar-wrap">
                    <span class="dollar-prefix">$</span>
                    <g:textField name="refundLimit" value="${params.refundLimit ?: ''}"/>
                </span>
            </td>
        </tr>

        <tr>
            <td class="lbl">Orphan Refund Credit Limit (in USD including foreign currency)</td>
            <td class="ctrl">
                <span class="dollar-wrap">
                    <span class="dollar-prefix">$</span>
                    <g:textField name="orphanLimit" value="${params.orphanLimit ?: ''}"/>
                </span>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Support MasterCard Business Service Arrangement Interchange Rates
                    <i class="info-icon" data-tip="Enable MasterCard BSA interchange rates">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="mcBsa" value="on" checked="${params.mcBsa == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Support Query Transactions
                    <i class="info-icon" data-tip="Allow query transaction types">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="queryTxn" value="on" checked="${params.queryTxn == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Salesforce Id</td>
            <td class="ctrl">
                <g:textField name="salesforceId" class="w160" value="${params.salesforceId ?: ''}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Enable Logical Back End Tying
                    <i class="info-icon" data-tip="Enables logical back-end tying for this org">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="logicalTying" value="on" checked="${params.logicalTying != 'false'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Start Multi Site Day
                    <i class="info-icon" data-tip="Day of month the multi-site period starts">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:textField name="multiSiteDay" class="w80" value="${params.multiSiteDay ?: ''}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Maximum No. of Category Nodes</td>
            <td class="ctrl">
                <g:textField name="categoryNodes" class="w120" value="${params.categoryNodes ?: '100'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">SLA Report Frequency</td>
            <td class="ctrl">
                <g:select name="slaFrequency" class="w170"
                          from="${['None','Daily','Weekly','Monthly']}"
                          value="${params.slaFrequency ?: 'None'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Enable Early Report Generation
                    <i class="info-icon" data-tip="Generate reports before end of day">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="earlyReport" value="on" checked="${params.earlyReport == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">Acquirer Fee Level</td>
            <td class="ctrl">
                <g:select name="acquirerFeeLevel" class="w170"
                          from="${['Default','Level 1','Level 2','Level 3']}"
                          value="${params.acquirerFeeLevel ?: 'Default'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Pazien Enable Indicator
                    <i class="info-icon" data-tip="Enable Pazien integration for this org">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="pazienEnable" value="on" checked="${params.pazienEnable == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">SSO Pazien
                    <i class="info-icon" data-tip="Use SSO for Pazien authentication">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="ssoPazien" value="on" checked="${params.ssoPazien == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">8 Digit Bin SSR
                    <i class="info-icon" data-tip="Enable 8-digit BIN for SSR processing">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="eightDigitBin" value="on" checked="${params.eightDigitBin == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Net Settled Sales Report Remove Comma
                    <i class="info-icon" data-tip="Strip commas from net settled sales report">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="removeComma" value="on" checked="${params.removeComma == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Daily eCheck Sales Volume Limit
                    <i class="info-icon" data-tip="Maximum daily eCheck sales volume">i</i>
                </span>
            </td>
            <td class="ctrl">
                <span class="dollar-wrap">
                    <span class="dollar-prefix">$</span>
                    <g:textField name="echeckSales" value="${params.echeckSales ?: ''}"/>
                </span>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Daily eCheck Credit Volume Limit
                    <i class="info-icon" data-tip="Maximum daily eCheck credit volume">i</i>
                </span>
            </td>
            <td class="ctrl">
                <span class="dollar-wrap">
                    <span class="dollar-prefix">$</span>
                    <g:textField name="echeckCredit" value="${params.echeckCredit ?: ''}"/>
                </span>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Preferred Customer Report Indicator
                    <i class="info-icon" data-tip="Flag this org as a preferred customer">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="preferredCustomer" value="on" checked="${params.preferredCustomer == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">Embedded Finance Enabled
                    <i class="info-icon" data-tip="Enable embedded finance features">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="embeddedFinance" value="on" checked="${params.embeddedFinance == 'on'}"/>
            </td>
        </tr>

        <tr>
            <td class="lbl">
                <span class="lbl-wrap">SaferPayment Enabled
                    <i class="info-icon" data-tip="Enable SaferPayment fraud screening">i</i>
                </span>
            </td>
            <td class="ctrl">
                <g:checkBox name="saferPayment" value="on" checked="${params.saferPayment == 'on'}"/>
            </td>
        </tr>

    </table>

    <!-- Action Buttons -->
    <div class="action-row">
        <button type="button" class="btn btn-default"
                onclick="alert('Checking multi-site compatibility…')">Check Multi-Site Compatible</button>
        <g:link controller="uiDemo" action="index"
                class="btn btn-default" style="line-height:24px; text-decoration:none;">Cancel</g:link>
        <g:submitButton name="save" value="Save" class="btn btn-success"/>
    </div>

    </g:form>
</div>
</body>
</html>
