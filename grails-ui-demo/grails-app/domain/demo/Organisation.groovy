package demo

class Organisation {

    // Identity
    String orgId
    String shortName
    String fullName

    // Address
    String corporateAddress
    String corporateAddress2
    String city
    String country
    String state
    String postalCode

    // Classification
    String type
    String subType

    // Amex
    Boolean amexPaymentServiceProvider = false
    Boolean amexMarketingIndicator     = false

    // Contract & Hierarchy
    String acquiringContractOwner
    String parentOrgId

    // Financial / Fee
    String     feeRounding
    BigDecimal depositCreditLimit
    BigDecimal refundCreditLimit
    BigDecimal orphanRefundCreditLimit

    // Feature flags with info icons
    Boolean supportMastercardInterchange    = false
    Boolean supportQueryTransactions        = false
    String  salesforceId
    Boolean enableLogicalBackEndTying       = false
    Integer startMultiSiteDay
    Integer maxCategoryNodes               = 100
    String  slaReportFrequency             = 'None'
    Boolean enableEarlyReportGeneration    = false
    String  acquirerFeeLevel               = 'Default'
    Boolean pazienEnableIndicator          = false
    Boolean ssoPazien                      = false
    Boolean eightDigitBinSSR               = false
    Boolean netSettledSalesReportRemoveComma = false
    BigDecimal dailyECheckSalesVolumeLimit
    BigDecimal dailyECheckCreditVolumeLimit
    Boolean preferredCustomerReportIndicator = false
    Boolean embeddedFinanceEnabled           = false
    Boolean saferPaymentEnabled              = false

    Boolean active = true

    static constraints = {
        orgId          unique: true, blank: false
        shortName      blank: false
        fullName       blank: false
        corporateAddress        nullable: true
        corporateAddress2       nullable: true
        city                    nullable: true
        country                 nullable: true
        state                   nullable: true
        postalCode              nullable: true
        type                    nullable: true
        subType                 nullable: true
        acquiringContractOwner  nullable: true
        parentOrgId             nullable: true
        feeRounding             nullable: true
        depositCreditLimit      nullable: true
        refundCreditLimit       nullable: true
        orphanRefundCreditLimit nullable: true
        amexPaymentServiceProvider nullable: true
        amexMarketingIndicator     nullable: true
        supportMastercardInterchange    nullable: true
        supportQueryTransactions        nullable: true
        salesforceId                    nullable: true
        enableLogicalBackEndTying       nullable: true
        startMultiSiteDay               nullable: true
        maxCategoryNodes                nullable: true
        slaReportFrequency              nullable: true
        enableEarlyReportGeneration     nullable: true
        acquirerFeeLevel                nullable: true
        pazienEnableIndicator           nullable: true
        ssoPazien                       nullable: true
        eightDigitBinSSR                nullable: true
        netSettledSalesReportRemoveComma nullable: true
        dailyECheckSalesVolumeLimit     nullable: true
        dailyECheckCreditVolumeLimit    nullable: true
        preferredCustomerReportIndicator nullable: true
        embeddedFinanceEnabled           nullable: true
        saferPaymentEnabled              nullable: true
    }

    String toString() { "$orgId - $shortName" }
}
