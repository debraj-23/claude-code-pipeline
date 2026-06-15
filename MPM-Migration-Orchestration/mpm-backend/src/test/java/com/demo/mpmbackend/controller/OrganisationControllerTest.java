package com.demo.mpmbackend.controller;

import com.demo.mpmbackend.dto.OrganisationUpdateRequest;
import com.demo.mpmbackend.entity.Organisation;
import com.demo.mpmbackend.exception.OrganisationNotFoundException;
import com.demo.mpmbackend.security.JwtUtil;
import com.demo.mpmbackend.service.OrganisationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(OrganisationController.class)
@AutoConfigureMockMvc(addFilters = false)
class OrganisationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private OrganisationService service;

    // Required because @WebMvcTest registers Filter beans (incl. the security
    // JwtAuthFilter), whose JwtUtil dependency must be satisfied.
    @MockBean
    private JwtUtil jwtUtil;

    private Organisation sample() {
        Organisation o = new Organisation();
        o.setId(1L);
        o.setOrgId("101");
        o.setShortName("GOOGLE");
        o.setFullName("Google LLC");
        o.setCity("Mountain View");
        return o;
    }

    /** Builds an Authentication carrying the given ROLE_* authority. */
    private Authentication authWithRole(String username, String role) {
        return new UsernamePasswordAuthenticationToken(
                username, "n/a", List.of(new SimpleGrantedAuthority("ROLE_" + role)));
    }

    // ---------- GET (search / findAll) ----------

    @Test
    void getAll_withNoParams_returnsFindAll() throws Exception {
        when(service.findAll()).thenReturn(List.of(sample()));

        mockMvc.perform(get("/api/organisations"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].orgId").value("101"))
                .andExpect(jsonPath("$[0].shortName").value("GOOGLE"));

        verify(service).findAll();
    }

    @Test
    void search_withParams_delegatesToServiceSearch() throws Exception {
        when(service.search("fullName", "goo")).thenReturn(List.of(sample()));

        mockMvc.perform(get("/api/organisations")
                        .param("searchField", "fullName")
                        .param("query", "goo"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].fullName").value("Google LLC"));

        verify(service).search("fullName", "goo");
    }

    // ---------- GET by id ----------

    @Test
    void getById_returnsOrganisation() throws Exception {
        when(service.findById(1L)).thenReturn(Optional.of(sample()));

        mockMvc.perform(get("/api/organisations/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.orgId").value("101"));
    }

    @Test
    void getById_whenMissing_returns404() throws Exception {
        when(service.findById(99L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/organisations/99"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    // ---------- PUT update: role propagation ----------

    @Test
    void update_asAdmin_passesAdminRoleToService() throws Exception {
        when(service.update(eq(1L), any(OrganisationUpdateRequest.class), eq("ADMIN")))
                .thenReturn(sample());

        OrganisationUpdateRequest req = new OrganisationUpdateRequest();
        req.setShortName("GOOG");

        mockMvc.perform(put("/api/organisations/1")
                        .principal(authWithRole("admin", "ADMIN"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk());

        verify(service).update(eq(1L), any(OrganisationUpdateRequest.class), eq("ADMIN"));
    }

    @Test
    void update_asUser_passesUserRoleToService() throws Exception {
        when(service.update(eq(1L), any(OrganisationUpdateRequest.class), eq("USER")))
                .thenReturn(sample());

        OrganisationUpdateRequest req = new OrganisationUpdateRequest();
        req.setCity("Palo Alto");

        mockMvc.perform(put("/api/organisations/1")
                        .principal(authWithRole("debraj", "USER"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk());

        verify(service).update(eq(1L), any(OrganisationUpdateRequest.class), eq("USER"));
    }

    @Test
    void update_whenServiceThrowsIllegalArgument_returns400() throws Exception {
        when(service.update(eq(1L), any(OrganisationUpdateRequest.class), eq("ADMIN")))
                .thenThrow(new IllegalArgumentException("An organisation cannot be its own parent."));

        OrganisationUpdateRequest req = new OrganisationUpdateRequest();
        req.setParentOrgId("101");

        mockMvc.perform(put("/api/organisations/1")
                        .principal(authWithRole("admin", "ADMIN"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400));
    }

    @Test
    void update_whenNotFound_returns404() throws Exception {
        when(service.update(eq(99L), any(OrganisationUpdateRequest.class), eq("ADMIN")))
                .thenThrow(new OrganisationNotFoundException(99L));

        mockMvc.perform(put("/api/organisations/99")
                        .principal(authWithRole("admin", "ADMIN"))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new OrganisationUpdateRequest())))
                .andExpect(status().isNotFound());
    }
}
