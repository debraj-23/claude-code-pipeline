package demo

class OrganisationController {

    OrganisationService organisationService

    // Fields that ONLY admins can modify
    static final List ADMIN_ONLY_FIELDS = [
        'feeRounding', 'depositCreditLimit', 'refundCreditLimit', 'orphanRefundCreditLimit',
        'parentOrgId', 'acquirerFeeLevel', 'supportMastercardInterchange',
        'supportQueryTransactions', 'enableLogicalBackEndTying', 'enableEarlyReportGeneration',
        'pazienEnableIndicator', 'ssoPazien', 'eightDigitBinSSR',
        'netSettledSalesReportRemoveComma', 'dailyECheckSalesVolumeLimit',
        'dailyECheckCreditVolumeLimit', 'preferredCustomerReportIndicator',
        'embeddedFinanceEnabled', 'saferPaymentEnabled'
    ]

    /**
     * GET /organisations  → show search form; results only after explicit search
     */
    def index() {
        if (!params.containsKey('searched')) {
            return [organisations: null, query: '', searchField: 'orgId', searched: false]
        }
        def query       = params.query?.trim()
        def searchField = params.searchField ?: 'orgId'
        def organisations = organisationService.search(query, searchField)
        [organisations: organisations, query: query, searchField: searchField, searched: true]
    }

    /**
     * GET /organisations/${id}/show  → view org details (all roles)
     */
    def show() {
        def org = organisationService.findById(params.long('id'))
        if (!org) {
            flash.error = 'Organisation not found.'
            redirect action: 'index'
            return
        }
        [org: org]
    }

    /**
     * GET /organisations/${id}/edit  → edit form (all logged-in roles can view;
     *                                   admin-only fields are rendered readonly for USER)
     */
    def edit() {
        def org = organisationService.findById(params.long('id'))
        if (!org) {
            flash.error = 'Organisation not found.'
            redirect action: 'index'
            return
        }
        def allOrgs = organisationService.listAll()
        [org: org, allOrgs: allOrgs, isAdmin: isAdmin()]
    }

    /**
     * POST /organisations/${id}/update  → save changes
     *   - Admin  : can update ALL fields
     *   - USER   : can only update non-admin fields; admin-only fields are ignored
     */
    def update() {
        def org = organisationService.findById(params.long('id'))
        if (!org) {
            flash.error = 'Organisation not found.'
            redirect action: 'index'
            return
        }

        // ── Fields editable by ALL roles ─────────────────────────────────────
        org.corporateAddress       = params.corporateAddress
        org.corporateAddress2      = params.corporateAddress2
        org.city                   = params.city
        org.country                = params.country
        org.state                  = params.state
        org.postalCode             = params.postalCode
        org.type                   = params.type
        org.subType                = params.subType
        org.amexPaymentServiceProvider = params.boolean('amexPaymentServiceProvider') ?: false
        org.amexMarketingIndicator     = params.boolean('amexMarketingIndicator')     ?: false
        org.acquiringContractOwner = params.acquiringContractOwner
        org.salesforceId           = params.salesforceId
        org.startMultiSiteDay      = params.startMultiSiteDay ? params.int('startMultiSiteDay') : null
        org.maxCategoryNodes       = params.maxCategoryNodes  ? params.int('maxCategoryNodes')  : 100
        org.slaReportFrequency     = params.slaReportFrequency

        // ── Admin-only fields ────────────────────────────────────────────────
        if (isAdmin()) {
            org.shortName                    = params.shortName
            org.fullName                     = params.fullName
            org.parentOrgId                  = (params.parentOrgId && params.parentOrgId != 'none') ? params.parentOrgId : null
            org.feeRounding                  = params.feeRounding
            org.depositCreditLimit           = toBigDecimal(params.depositCreditLimit)
            org.refundCreditLimit            = toBigDecimal(params.refundCreditLimit)
            org.orphanRefundCreditLimit      = toBigDecimal(params.orphanRefundCreditLimit)
            org.supportMastercardInterchange     = params.boolean('supportMastercardInterchange')     ?: false
            org.supportQueryTransactions         = params.boolean('supportQueryTransactions')         ?: false
            org.enableLogicalBackEndTying        = params.boolean('enableLogicalBackEndTying')        ?: false
            org.enableEarlyReportGeneration      = params.boolean('enableEarlyReportGeneration')      ?: false
            org.acquirerFeeLevel                 = params.acquirerFeeLevel
            org.pazienEnableIndicator            = params.boolean('pazienEnableIndicator')            ?: false
            org.ssoPazien                        = params.boolean('ssoPazien')                        ?: false
            org.eightDigitBinSSR                 = params.boolean('eightDigitBinSSR')                 ?: false
            org.netSettledSalesReportRemoveComma = params.boolean('netSettledSalesReportRemoveComma') ?: false
            org.dailyECheckSalesVolumeLimit      = toBigDecimal(params.dailyECheckSalesVolumeLimit)
            org.dailyECheckCreditVolumeLimit     = toBigDecimal(params.dailyECheckCreditVolumeLimit)
            org.preferredCustomerReportIndicator = params.boolean('preferredCustomerReportIndicator') ?: false
            org.embeddedFinanceEnabled           = params.boolean('embeddedFinanceEnabled')           ?: false
            org.saferPaymentEnabled              = params.boolean('saferPaymentEnabled')              ?: false
        }

        if (org.validate()) {
            organisationService.save(org)
            redirect action: 'index'
        } else {
            flash.error = 'Failed to update organisation. Please check the highlighted fields.'
            def allOrgs = organisationService.listAll()
            render view: 'edit', model: [org: org, allOrgs: allOrgs, isAdmin: isAdmin()]
        }
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private boolean isAdmin() {
        session.user?.role == 'ADMIN'
    }

    private BigDecimal toBigDecimal(String val) {
        (val?.trim()) ? new BigDecimal(val.trim()) : null
    }
}
