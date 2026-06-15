package com.demo.mpmbackend.service;

import com.demo.mpmbackend.dto.OrganisationUpdateRequest;
import com.demo.mpmbackend.entity.Organisation;
import com.demo.mpmbackend.exception.OrganisationNotFoundException;
import com.demo.mpmbackend.repository.OrganisationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OrganisationServiceTest {

    @Mock
    private OrganisationRepository repository;

    @InjectMocks
    private OrganisationService service;

    private Organisation existing;

    @BeforeEach
    void setUp() {
        existing = new Organisation();
        existing.setId(1L);
        existing.setOrgId("101");
        existing.setShortName("GOOGLE");
        existing.setFullName("Google LLC");
        existing.setCity("Mountain View");
        existing.setState("CA");
        existing.setCountry("USA");
        existing.setActive(true);
        existing.setDepositCreditLimit(new BigDecimal("500000.00"));
    }

    // ---------- search ----------

    @Test
    void search_withFullNameField_delegatesToFullNameQuery() {
        when(repository.searchByFullName("goo")).thenReturn(List.of(existing));

        List<Organisation> result = service.search("fullName", "goo");

        assertThat(result).containsExactly(existing);
        verify(repository).searchByFullName("goo");
        verify(repository, never()).searchByOrgIdOrShortName(any());
    }

    @Test
    void search_withOrgIdField_delegatesToOrgIdOrShortNameQuery() {
        when(repository.searchByOrgIdOrShortName("10")).thenReturn(List.of(existing));

        List<Organisation> result = service.search("orgId", "10");

        assertThat(result).containsExactly(existing);
        verify(repository).searchByOrgIdOrShortName("10");
        verify(repository, never()).searchByFullName(any());
    }

    @Test
    void search_withUnknownField_defaultsToOrgIdOrShortNameQuery() {
        when(repository.searchByOrgIdOrShortName("x")).thenReturn(List.of());

        service.search("somethingElse", "x");

        verify(repository).searchByOrgIdOrShortName("x");
    }

    @Test
    void search_withNullQuery_passesEmptyStringToRepository() {
        when(repository.searchByOrgIdOrShortName("")).thenReturn(List.of(existing));

        List<Organisation> result = service.search("orgId", null);

        assertThat(result).containsExactly(existing);
        verify(repository).searchByOrgIdOrShortName("");
    }

    // ---------- findById ----------

    @Test
    void findById_returnsOrganisationWhenPresent() {
        when(repository.findById(1L)).thenReturn(Optional.of(existing));

        Optional<Organisation> result = service.findById(1L);

        assertThat(result).contains(existing);
    }

    @Test
    void findById_returnsEmptyWhenMissing() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        assertThat(service.findById(99L)).isEmpty();
    }

    // ---------- update: not found ----------

    @Test
    void update_throwsWhenOrganisationNotFound() {
        when(repository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.update(99L, new OrganisationUpdateRequest(), "ADMIN"))
                .isInstanceOf(OrganisationNotFoundException.class)
                .hasMessageContaining("99");
        verify(repository, never()).save(any());
    }

    // ---------- update: non-admin fields applied for any role ----------

    @Test
    void update_appliesNonAdminFieldsForUserRole() {
        when(repository.findById(1L)).thenReturn(Optional.of(existing));
        when(repository.save(any(Organisation.class))).thenAnswer(inv -> inv.getArgument(0));

        OrganisationUpdateRequest req = new OrganisationUpdateRequest();
        req.setCity("San Francisco");
        req.setState("CA");
        req.setActive(false);

        Organisation result = service.update(1L, req, "USER");

        assertThat(result.getCity()).isEqualTo("San Francisco");
        assertThat(result.getActive()).isFalse();
    }

    // ---------- Rule 1: admin-only fields silently ignored for USER ----------

    @Test
    void update_userRole_doesNotChangeAdminOnlyFields() {
        when(repository.findById(1L)).thenReturn(Optional.of(existing));
        when(repository.save(any(Organisation.class))).thenAnswer(inv -> inv.getArgument(0));

        OrganisationUpdateRequest req = new OrganisationUpdateRequest();
        // non-admin field that should change
        req.setCity("Palo Alto");
        // admin-only fields the USER tampered with — must be ignored
        req.setShortName("HACKED");
        req.setFullName("Tampered Name");
        req.setParentOrgId("999");
        req.setDepositCreditLimit(new BigDecimal("1.00"));
        req.setSaferPaymentEnabled(true);

        Organisation result = service.update(1L, req, "USER");

        // non-admin change applied
        assertThat(result.getCity()).isEqualTo("Palo Alto");
        // admin-only fields untouched
        assertThat(result.getShortName()).isEqualTo("GOOGLE");
        assertThat(result.getFullName()).isEqualTo("Google LLC");
        assertThat(result.getParentOrgId()).isNull();
        assertThat(result.getDepositCreditLimit()).isEqualByComparingTo("500000.00");
        // saferPaymentEnabled defaults to false on the entity; USER tampering must not flip it to true
        assertThat(result.getSaferPaymentEnabled()).isFalse();
    }

    // ---------- Admin: admin-only fields applied ----------

    @Test
    void update_adminRole_updatesAdminOnlyFields() {
        when(repository.findById(1L)).thenReturn(Optional.of(existing));
        when(repository.save(any(Organisation.class))).thenAnswer(inv -> inv.getArgument(0));

        OrganisationUpdateRequest req = new OrganisationUpdateRequest();
        req.setShortName("GOOG");
        req.setFullName("Alphabet Inc");
        req.setParentOrgId("200");
        req.setDepositCreditLimit(new BigDecimal("999999.00"));
        req.setSaferPaymentEnabled(true);
        req.setCity("New York"); // non-admin field too

        Organisation result = service.update(1L, req, "ADMIN");

        assertThat(result.getShortName()).isEqualTo("GOOG");
        assertThat(result.getFullName()).isEqualTo("Alphabet Inc");
        assertThat(result.getParentOrgId()).isEqualTo("200");
        assertThat(result.getDepositCreditLimit()).isEqualByComparingTo("999999.00");
        assertThat(result.getSaferPaymentEnabled()).isTrue();
        assertThat(result.getCity()).isEqualTo("New York");
    }

    // ---------- Rule 2: orgId immutable for both roles ----------

    @Test
    void update_orgIdIsImmutableForAdmin() {
        when(repository.findById(1L)).thenReturn(Optional.of(existing));
        when(repository.save(any(Organisation.class))).thenAnswer(inv -> inv.getArgument(0));

        // DTO has no orgId setter at all (immutable by design); verify it never changes
        Organisation result = service.update(1L, new OrganisationUpdateRequest(), "ADMIN");

        assertThat(result.getOrgId()).isEqualTo("101");
    }

    @Test
    void update_orgIdIsImmutableForUser() {
        when(repository.findById(1L)).thenReturn(Optional.of(existing));
        when(repository.save(any(Organisation.class))).thenAnswer(inv -> inv.getArgument(0));

        Organisation result = service.update(1L, new OrganisationUpdateRequest(), "USER");

        assertThat(result.getOrgId()).isEqualTo("101");
    }

    // ---------- Rule 3: org cannot be its own parent (admin) ----------

    @Test
    void update_adminCannotSetParentToOwnOrgId() {
        when(repository.findById(1L)).thenReturn(Optional.of(existing));

        OrganisationUpdateRequest req = new OrganisationUpdateRequest();
        req.setParentOrgId("101"); // same as org's own orgId

        assertThatThrownBy(() -> service.update(1L, req, "ADMIN"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("its own parent");
        verify(repository, never()).save(any());
    }

    @Test
    void update_savesUpdatedEntity() {
        when(repository.findById(1L)).thenReturn(Optional.of(existing));
        when(repository.save(any(Organisation.class))).thenAnswer(inv -> inv.getArgument(0));

        OrganisationUpdateRequest req = new OrganisationUpdateRequest();
        req.setCity("Austin");

        service.update(1L, req, "ADMIN");

        ArgumentCaptor<Organisation> captor = ArgumentCaptor.forClass(Organisation.class);
        verify(repository).save(captor.capture());
        assertThat(captor.getValue().getCity()).isEqualTo("Austin");
    }
}
