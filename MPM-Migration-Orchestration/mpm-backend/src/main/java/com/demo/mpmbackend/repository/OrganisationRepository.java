package com.demo.mpmbackend.repository;

import com.demo.mpmbackend.entity.Organisation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrganisationRepository extends JpaRepository<Organisation, Long> {

    // searchField=orgId: partial, case-insensitive match on orgId OR shortName
    @Query("SELECT o FROM Organisation o WHERE " +
           "LOWER(o.orgId) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(o.shortName) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Organisation> searchByOrgIdOrShortName(@Param("query") String query);

    // searchField=fullName: partial, case-insensitive match on fullName
    @Query("SELECT o FROM Organisation o WHERE " +
           "LOWER(o.fullName) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Organisation> searchByFullName(@Param("query") String query);
}
