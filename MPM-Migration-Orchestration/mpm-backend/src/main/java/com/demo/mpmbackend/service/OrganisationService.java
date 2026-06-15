package com.demo.mpmbackend.service;

import com.demo.mpmbackend.dto.OrganisationUpdateRequest;
import com.demo.mpmbackend.entity.Organisation;
import com.demo.mpmbackend.exception.OrganisationNotFoundException;
import com.demo.mpmbackend.repository.OrganisationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class OrganisationService {

    private final OrganisationRepository repository;

    /**
     * Explicit search (spec §8 rule 5).
     * searchField=fullName → partial, case-insensitive match on fullName.
     * searchField=orgId (default) → partial, case-insensitive match on orgId OR shortName.
     * Empty/blank query → matches everything (equivalent to Grails searched=true with blank query).
     */
    public List<Organisation> search(String searchField, String query) {
        String q = (query == null) ? "" : query;
        if ("fullName".equals(searchField)) {
            return repository.searchByFullName(q);
        }
        return repository.searchByOrgIdOrShortName(q);
    }

    public Optional<Organisation> findById(Long id) {
        return repository.findById(id);
    }

    public List<Organisation> findAll() {
        return repository.findAll();
    }

    /**
     * Update an organisation with server-side role-based field filtering.
     *
     * Rule 1 (spec §8): admin-only fields are silently ignored for USER role,
     *                   even if the client tampers and submits them.
     * Rule 2 (spec §8): orgId is immutable — it is not on the request DTO and never changed here.
     * Rule 3 (spec §8): parentOrgId cannot reference the org's own orgId.
     */
    @Transactional
    public Organisation update(Long id, OrganisationUpdateRequest req, String role) {
        Organisation org = repository.findById(id)
                .orElseThrow(() -> new OrganisationNotFoundException(id));

        boolean isAdmin = "ADMIN".equals(role);

        // Rule 3: an organisation cannot be its own parent (only relevant when admin can set it)
        if (isAdmin && req.getParentOrgId() != null && req.getParentOrgId().equals(org.getOrgId())) {
            throw new IllegalArgumentException("An organisation cannot be its own parent.");
        }

        // Non-admin fields — applied for any authenticated role
        if (req.getCorporateAddress() != null)           org.setCorporateAddress(req.getCorporateAddress());
        if (req.getCorporateAddress2() != null)          org.setCorporateAddress2(req.getCorporateAddress2());
        if (req.getCity() != null)                       org.setCity(req.getCity());
        if (req.getCountry() != null)                    org.setCountry(req.getCountry());
        if (req.getState() != null)                      org.setState(req.getState());
        if (req.getPostalCode() != null)                 org.setPostalCode(req.getPostalCode());
        if (req.getType() != null)                       org.setType(req.getType());
        if (req.getSubType() != null)                    org.setSubType(req.getSubType());
        if (req.getAmexPaymentServiceProvider() != null) org.setAmexPaymentServiceProvider(req.getAmexPaymentServiceProvider());
        if (req.getAmexMarketingIndicator() != null)     org.setAmexMarketingIndicator(req.getAmexMarketingIndicator());
        if (req.getAcquiringContractOwner() != null)     org.setAcquiringContractOwner(req.getAcquiringContractOwner());
        if (req.getSalesforceId() != null)               org.setSalesforceId(req.getSalesforceId());
        if (req.getStartMultiSiteDay() != null)          org.setStartMultiSiteDay(req.getStartMultiSiteDay());
        if (req.getMaxCategoryNodes() != null)           org.setMaxCategoryNodes(req.getMaxCategoryNodes());
        if (req.getSlaReportFrequency() != null)         org.setSlaReportFrequency(req.getSlaReportFrequency());
        if (req.getActive() != null)                     org.setActive(req.getActive());

        // Admin-only fields — Rule 1: silently ignored for USER role even if submitted
        if (isAdmin) {
            if (req.getShortName() != null)                        org.setShortName(req.getShortName());
            if (req.getFullName() != null)                         org.setFullName(req.getFullName());
            if (req.getParentOrgId() != null)                      org.setParentOrgId(req.getParentOrgId());
            if (req.getFeeRounding() != null)                      org.setFeeRounding(req.getFeeRounding());
            if (req.getDepositCreditLimit() != null)               org.setDepositCreditLimit(req.getDepositCreditLimit());
            if (req.getRefundCreditLimit() != null)                org.setRefundCreditLimit(req.getRefundCreditLimit());
            if (req.getOrphanRefundCreditLimit() != null)          org.setOrphanRefundCreditLimit(req.getOrphanRefundCreditLimit());
            if (req.getSupportMastercardInterchange() != null)     org.setSupportMastercardInterchange(req.getSupportMastercardInterchange());
            if (req.getSupportQueryTransactions() != null)         org.setSupportQueryTransactions(req.getSupportQueryTransactions());
            if (req.getEnableLogicalBackEndTying() != null)        org.setEnableLogicalBackEndTying(req.getEnableLogicalBackEndTying());
            if (req.getEnableEarlyReportGeneration() != null)      org.setEnableEarlyReportGeneration(req.getEnableEarlyReportGeneration());
            if (req.getAcquirerFeeLevel() != null)                 org.setAcquirerFeeLevel(req.getAcquirerFeeLevel());
            if (req.getPazienEnableIndicator() != null)            org.setPazienEnableIndicator(req.getPazienEnableIndicator());
            if (req.getSsoPazien() != null)                        org.setSsoPazien(req.getSsoPazien());
            if (req.getEightDigitBinSSR() != null)                 org.setEightDigitBinSSR(req.getEightDigitBinSSR());
            if (req.getNetSettledSalesReportRemoveComma() != null) org.setNetSettledSalesReportRemoveComma(req.getNetSettledSalesReportRemoveComma());
            if (req.getDailyECheckSalesVolumeLimit() != null)      org.setDailyECheckSalesVolumeLimit(req.getDailyECheckSalesVolumeLimit());
            if (req.getDailyECheckCreditVolumeLimit() != null)     org.setDailyECheckCreditVolumeLimit(req.getDailyECheckCreditVolumeLimit());
            if (req.getPreferredCustomerReportIndicator() != null) org.setPreferredCustomerReportIndicator(req.getPreferredCustomerReportIndicator());
            if (req.getEmbeddedFinanceEnabled() != null)           org.setEmbeddedFinanceEnabled(req.getEmbeddedFinanceEnabled());
            if (req.getSaferPaymentEnabled() != null)              org.setSaferPaymentEnabled(req.getSaferPaymentEnabled());
        }

        return repository.save(org);
    }
}
