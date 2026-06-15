package demo

import grails.gorm.transactions.Transactional

@Transactional
class OrganisationService {

    /**
     * Search organisations with optional field-specific filtering.
     * @param query       the search term
     * @param searchField 'orgId' → search by Org ID | 'fullName' → search by Full Name | anything else → search all
     * @param max         max results to return
     */
    @Transactional(readOnly = true)
    List<Organisation> search(String query, String searchField = 'orgId', int max = 100) {
        if (!query?.trim()) {
            // No query → return all (so user sees results when they hit Search with empty box)
            return Organisation.list(max: max, sort: 'orgId', order: 'asc')
        }

        def q = "%${query.trim()}%"

        return Organisation.createCriteria().list(max: max) {
            switch (searchField) {
                case 'fullName':
                    ilike('fullName', q)
                    break
                default: // 'orgId' or anything else → search orgId + shortName
                    or {
                        ilike('orgId',      q)
                        ilike('shortName',  q)
                    }
                    break
            }
            order('orgId', 'asc')
        }
    }

    /**
     * Find an organisation by its database id
     */
    @Transactional(readOnly = true)
    Organisation findById(Long id) {
        Organisation.get(id)
    }

    /**
     * Return all organisations sorted by orgId (for dropdowns etc.)
     */
    @Transactional(readOnly = true)
    List<Organisation> listAll() {
        Organisation.list(sort: 'orgId', order: 'asc')
    }

    /**
     * Save or update an organisation
     */
    Organisation save(Organisation org) {
        org.save(flush: true, failOnError: true)
    }
}
