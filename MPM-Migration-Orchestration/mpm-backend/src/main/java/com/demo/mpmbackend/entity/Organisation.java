package com.demo.mpmbackend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "organisation")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class Organisation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Identity
    @NotBlank
    @Column(unique = true, nullable = false)
    private String orgId;

    @NotBlank
    @Column(nullable = false)
    private String shortName;   // ADMIN ONLY

    @NotBlank
    @Column(nullable = false)
    private String fullName;    // ADMIN ONLY

    // Address
    private String corporateAddress;
    private String corporateAddress2;
    private String city;
    private String country;
    private String state;
    private String postalCode;

    // Classification
    private String type;
    private String subType;

    // Amex
    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean amexPaymentServiceProvider = false;

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean amexMarketingIndicator = false;

    // Contract & Hierarchy
    private String acquiringContractOwner;

    private String parentOrgId;  // ADMIN ONLY

    // Financial / Fee (ALL ADMIN ONLY)
    private String feeRounding;
    private BigDecimal depositCreditLimit;
    private BigDecimal refundCreditLimit;
    private BigDecimal orphanRefundCreditLimit;

    // Feature / Config
    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean supportMastercardInterchange = false;  // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean supportQueryTransactions = false;      // ADMIN ONLY

    private String salesforceId;

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean enableLogicalBackEndTying = false;     // ADMIN ONLY

    private Integer startMultiSiteDay;

    @Column(nullable = false)
    private Integer maxCategoryNodes = 100;

    @Column(nullable = false)
    private String slaReportFrequency = "None";

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean enableEarlyReportGeneration = false;   // ADMIN ONLY

    @Column(nullable = false)
    private String acquirerFeeLevel = "Default";           // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean pazienEnableIndicator = false;         // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean ssoPazien = false;                     // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean eightDigitBinSSR = false;              // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean netSettledSalesReportRemoveComma = false;  // ADMIN ONLY

    private BigDecimal dailyECheckSalesVolumeLimit;        // ADMIN ONLY
    private BigDecimal dailyECheckCreditVolumeLimit;       // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean preferredCustomerReportIndicator = false;  // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean embeddedFinanceEnabled = false;        // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default false")
    private Boolean saferPaymentEnabled = false;           // ADMIN ONLY

    @Column(nullable = false, columnDefinition = "boolean default true")
    private Boolean active = true;
}
