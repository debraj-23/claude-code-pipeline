package demo

class BootStrap {

    def init = { servletContext ->
        log.info "Bootstrapping application data..."

        AppUser.withTransaction {

            // ── Seed Users ────────────────────────────────────────────────────
            if (!AppUser.count()) {
                new AppUser(username: 'admin', password: 'admin123', role: 'ADMIN', fullName: 'System Administrator').save(flush: true, failOnError: true)
                new AppUser(username: 'debraj', password: 'debraj123', role: 'USER', fullName: 'Debraj').save(flush: true, failOnError: true)
                log.info "Created 2 users: admin (ADMIN), debraj (USER)"
            }

            // ── Seed Organisations ─────────────────────────────────────────────
            if (!Organisation.count()) {
                def orgs = [
                    [orgId: '101', shortName: 'GOOGLE',  fullName: 'Google LLC',
                     corporateAddress: '1600 Amphitheatre Parkway', city: 'Mountain View', country: 'USA', state: 'CA', postalCode: '94043',
                     type: 'Merchant', subType: 'Ecommerce', acquiringContractOwner: 'Chase Paymentech', parentOrgId: null,
                     feeRounding: 'bankers_agg', depositCreditLimit: 500000.00,
                     amexPaymentServiceProvider: true, amexMarketingIndicator: true,
                     maxCategoryNodes: 100, slaReportFrequency: 'None', acquirerFeeLevel: 'Default'],

                    [orgId: '102', shortName: 'AMAZON',  fullName: 'Amazon.com Inc',
                     corporateAddress: '410 Terry Avenue North',    city: 'Seattle',       country: 'USA', state: 'WA', postalCode: '98109',
                     type: 'Merchant', subType: 'Ecommerce', acquiringContractOwner: 'Wells Fargo',      parentOrgId: null,
                     feeRounding: 'bankers_agg', depositCreditLimit: 750000.00,
                     amexPaymentServiceProvider: true, amexMarketingIndicator: false,
                     maxCategoryNodes: 100, slaReportFrequency: 'None', acquirerFeeLevel: 'Default'],

                    [orgId: '103', shortName: 'NETFLIX', fullName: 'Netflix Inc',
                     corporateAddress: '100 Winchester Circle',     city: 'Los Gatos',     country: 'USA', state: 'CA', postalCode: '95032',
                     type: 'Merchant', subType: 'Ecommerce', acquiringContractOwner: 'Bank of America',  parentOrgId: null,
                     feeRounding: 'ROUND_UP', depositCreditLimit: 300000.00,
                     amexPaymentServiceProvider: false, amexMarketingIndicator: true,
                     maxCategoryNodes: 100, slaReportFrequency: 'None', acquirerFeeLevel: 'Default'],

                    [orgId: '104', shortName: 'HULU',    fullName: 'Hulu LLC',
                     corporateAddress: '2500 Broadway',             city: 'Santa Monica',  country: 'USA', state: 'CA', postalCode: '90404',
                     type: 'Merchant', subType: 'Ecommerce', acquiringContractOwner: 'Citi',             parentOrgId: '102',
                     feeRounding: 'ROUND_DOWN', depositCreditLimit: 150000.00,
                     amexPaymentServiceProvider: false, amexMarketingIndicator: false,
                     maxCategoryNodes: 100, slaReportFrequency: 'None', acquirerFeeLevel: 'Default'],

                    [orgId: '105', shortName: 'DISNEY',  fullName: 'The Walt Disney Company',
                     corporateAddress: '500 South Buena Vista Street', city: 'Burbank',    country: 'USA', state: 'CA', postalCode: '91521',
                     type: 'Merchant', subType: 'Retail',    acquiringContractOwner: 'US Bank',          parentOrgId: null,
                     feeRounding: 'bankers_agg', depositCreditLimit: 1000000.00,
                     amexPaymentServiceProvider: true, amexMarketingIndicator: true,
                     maxCategoryNodes: 100, slaReportFrequency: 'None', acquirerFeeLevel: 'Default'],
                ]
                orgs.each { data -> new Organisation(data).save(flush: true, failOnError: true) }
                log.info "Created ${orgs.size()} sample organisations."
            }
        }
        log.info "Bootstrap complete. App is ready at http://localhost:8080"
    }

    def destroy = {}
}
