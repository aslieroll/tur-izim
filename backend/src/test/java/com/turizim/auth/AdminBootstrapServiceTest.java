package com.turizim.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.turizim.domain.enums.UserRole;
import com.turizim.user.UserAccount;
import com.turizim.user.UserAccountRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AdminBootstrapServiceTest {

    private static final String ADMIN_EMAIL = "admin@turizim.local";
    private static final String ADMIN_PASSWORD = "StrongPass1!";
    private static final String ENCODED_HASH = "$2a$10$encodedhashvalue";

    @Mock
    private UserAccountRepository userAccountRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AdminBootstrapService service;

    @BeforeEach
    void setup() {
        lenient().when(passwordEncoder.encode(eq(ADMIN_PASSWORD))).thenReturn(ENCODED_HASH);
    }

    @Test
    void bootstrapDisabled_createsNoAdmin() {
        AdminBootstrapService.BootstrapOutcome outcome =
                service.bootstrap(false, ADMIN_EMAIL, ADMIN_PASSWORD);

        assertThat(outcome).isEqualTo(AdminBootstrapService.BootstrapOutcome.SKIPPED_DISABLED);
        verify(userAccountRepository, never()).save(any());
    }

    @Test
    void bootstrapEnabledWithValidConfig_createsExactlyOneAdmin() {
        when(userAccountRepository.existsByRole(UserRole.ADMIN)).thenReturn(false);
        when(userAccountRepository.existsByEmailIgnoreCase(ADMIN_EMAIL)).thenReturn(false);

        AdminBootstrapService.BootstrapOutcome outcome =
                service.bootstrap(true, ADMIN_EMAIL, ADMIN_PASSWORD);

        assertThat(outcome).isEqualTo(AdminBootstrapService.BootstrapOutcome.CREATED);

        ArgumentCaptor<UserAccount> captor = ArgumentCaptor.forClass(UserAccount.class);
        verify(userAccountRepository).save(captor.capture());

        UserAccount saved = captor.getValue();
        assertThat(saved.getEmail()).isEqualTo(ADMIN_EMAIL);
        assertThat(saved.getRole()).isEqualTo(UserRole.ADMIN);
        assertThat(saved.isActive()).isTrue();
        assertThat(saved.getPasswordHash()).isEqualTo(ENCODED_HASH);
        assertThat(saved.getPasswordHash()).isNotEqualTo(ADMIN_PASSWORD);
        verify(passwordEncoder).encode(ADMIN_PASSWORD);
    }

    @Test
    void bootstrapRunTwice_doesNotCreateDuplicateAdmin() {
        when(userAccountRepository.existsByRole(UserRole.ADMIN)).thenReturn(true);

        AdminBootstrapService.BootstrapOutcome outcome =
                service.bootstrap(true, ADMIN_EMAIL, ADMIN_PASSWORD);

        assertThat(outcome).isEqualTo(AdminBootstrapService.BootstrapOutcome.SKIPPED_ADMIN_EXISTS);
        verify(userAccountRepository, never()).save(any());
    }

    @Test
    void bootstrapEnabledMissingEmail_createsNoAdmin() {
        AdminBootstrapService.BootstrapOutcome outcome =
                service.bootstrap(true, "  ", ADMIN_PASSWORD);

        assertThat(outcome).isEqualTo(AdminBootstrapService.BootstrapOutcome.SKIPPED_MISSING_CONFIG);
        verify(userAccountRepository, never()).save(any());
    }

    @Test
    void bootstrapEnabledMissingPassword_createsNoAdmin() {
        AdminBootstrapService.BootstrapOutcome outcome =
                service.bootstrap(true, ADMIN_EMAIL, "");

        assertThat(outcome).isEqualTo(AdminBootstrapService.BootstrapOutcome.SKIPPED_MISSING_CONFIG);
        verify(userAccountRepository, never()).save(any());
    }

    @Test
    void bootstrapEnabledEmailAlreadyTaken_doesNotOverwriteExistingUser() {
        when(userAccountRepository.existsByRole(UserRole.ADMIN)).thenReturn(false);
        when(userAccountRepository.existsByEmailIgnoreCase(ADMIN_EMAIL)).thenReturn(true);

        AdminBootstrapService.BootstrapOutcome outcome =
                service.bootstrap(true, ADMIN_EMAIL, ADMIN_PASSWORD);

        assertThat(outcome).isEqualTo(AdminBootstrapService.BootstrapOutcome.SKIPPED_EMAIL_EXISTS);
        verify(userAccountRepository, never()).save(any());
        verify(passwordEncoder, never()).encode(any());
    }

    @Test
    void bootstrapNormalizesEmailToLowercase() {
        when(userAccountRepository.existsByRole(UserRole.ADMIN)).thenReturn(false);
        when(userAccountRepository.existsByEmailIgnoreCase("admin@turizim.local")).thenReturn(false);

        service.bootstrap(true, "  Admin@Turizim.Local  ", ADMIN_PASSWORD);

        ArgumentCaptor<UserAccount> captor = ArgumentCaptor.forClass(UserAccount.class);
        verify(userAccountRepository).save(captor.capture());
        assertThat(captor.getValue().getEmail()).isEqualTo("admin@turizim.local");
    }
}
