package com.demo.mpmbackend.controller;

import com.demo.mpmbackend.dto.OrganisationUpdateRequest;
import com.demo.mpmbackend.entity.Organisation;
import com.demo.mpmbackend.exception.OrganisationNotFoundException;
import com.demo.mpmbackend.service.OrganisationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/organisations")
@RequiredArgsConstructor
public class OrganisationController {

    private final OrganisationService service;

    /**
     * GET /api/organisations
     * GET /api/organisations?searchField=orgId&query=GOO
     * GET /api/organisations?searchField=fullName&query=Google
     *
     * searchField=orgId   → partial, case-insensitive match on orgId OR shortName
     * searchField=fullName → partial, case-insensitive match on fullName
     * No params           → returns all organisations
     * Empty query         → returns all (Grails searched=true with blank query)
     */
    @GetMapping
    public ResponseEntity<List<Organisation>> search(
            @RequestParam(required = false) String searchField,
            @RequestParam(required = false) String query) {

        if (searchField == null && query == null) {
            return ResponseEntity.ok(service.findAll());
        }
        return ResponseEntity.ok(service.search(searchField, query));
    }

    /**
     * GET /api/organisations/{id}
     * Returns a single organisation by its DB primary key.
     */
    @GetMapping("/{id}")
    public ResponseEntity<Organisation> getById(@PathVariable Long id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new OrganisationNotFoundException(id));
    }

    /**
     * PUT /api/organisations/{id}
     * Updates an organisation with server-side role-based field filtering.
     *
     * Rule 1 (spec §8): admin-only fields are silently ignored for USER role.
     * Rule 2 (spec §8): orgId is immutable — never accepted on update.
     * Rule 3 (spec §8): parentOrgId cannot equal the org's own orgId.
     */
    @PutMapping("/{id}")
    public ResponseEntity<Organisation> update(
            @PathVariable Long id,
            @RequestBody OrganisationUpdateRequest request,
            Authentication authentication) {

        String role = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .map(a -> a.replace("ROLE_", ""))
                .findFirst()
                .orElse("USER");

        Organisation updated = service.update(id, request, role);
        return ResponseEntity.ok(updated);
    }
}
