package com.demo.mpmbackend.dto;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Update payload for an organisation.
 *
 * Note: orgId is intentionally NOT present here — it is immutable (spec §8 rule 2)
 * and must never be accepted on update.
 */
@Getter @Setter
public class OrganisationUpdateRequest {

    // Non-admin fields (any authenticated user can update)
    private String corporateAddress;
    private String corporateAddress2;
    private String city;
    private String country;
    private String state;
    private String postalCode;
    private String type;
    private String subType;
    private Boolean amexPaymentServiceProvider;
    private Boolean amexMarketingIndicator;
    private String acquiringContractOwner;
    private String salesforceId;
    private Integer startMultiSiteDay;
    private Integer maxCategoryNodes;
    private String slaReportFrequency;
    private Boolean active;

    // Admin-only fields
    private String shortName;
    private String fullName;
    private String parentOrgId;
    private String feeRounding;
    private BigDecimal depositCreditLimit;
    private BigDecimal refundCreditLimit;
    private BigDecimal orphanRefundCreditLimit;
    private Boolean supportMastercardInterchange;
    private Boolean supportQueryTransactions;
    private Boolean enableLogicalBackEndTying;
    private Boolean enableEarlyReportGeneration;
    private String acquirerFeeLevel;
    private Boolean pazienEnableIndicator;
    private Boolean ssoPazien;
    private Boolean eightDigitBinSSR;
    private Boolean netSettledSalesReportRemoveComma;
    private BigDecimal dailyECheckSalesVolumeLimit;
    private BigDecimal dailyECheckCreditVolumeLimit;
    private Boolean preferredCustomerReportIndicator;
    private Boolean embeddedFinanceEnabled;
    private Boolean saferPaymentEnabled;
}
