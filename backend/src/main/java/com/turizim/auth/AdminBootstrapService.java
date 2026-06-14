package com.turizim.auth;

import com.turizim.domain.enums.UserRole;
import com.turizim.user.UserAccount;
import com.turizim.user.UserAccountRepository;
import java.util.Locale;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * İlk üretim/beta ADMIN hesabını güvenli şekilde oluşturur.
 *
 * <p>Genel API veya kayıt ucu yoktur; yalnızca ortam değişkenleri ile tetiklenir.
 * Şifre asla loglanmaz; mevcut kullanıcıların üzerine yazılmaz.
 */
@Service
public class AdminBootstrapService {

    private static final Logger log = LoggerFactory.getLogger(AdminBootstrapService.class);

    public enum BootstrapOutcome {
        SKIPPED_DISABLED,
        SKIPPED_MISSING_CONFIG,
        SKIPPED_ADMIN_EXISTS,
        SKIPPED_EMAIL_EXISTS,
        CREATED
    }

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminBootstrapService(
            UserAccountRepository userAccountRepository, PasswordEncoder passwordEncoder) {
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Bootstrap koşullarını değerlendirir ve gerekirse tek bir ADMIN hesabı oluşturur.
     *
     * @param enabled bootstrap açık mı ({@code APP_ADMIN_BOOTSTRAP_ENABLED})
     * @param email admin e-postası ({@code APP_ADMIN_EMAIL})
     * @param password düz metin şifre ({@code APP_ADMIN_PASSWORD}); loglanmaz
     */
    @Transactional
    public BootstrapOutcome bootstrap(boolean enabled, String email, String password) {
        if (!enabled) {
            return BootstrapOutcome.SKIPPED_DISABLED;
        }

        String normalizedEmail = normalizeEmail(email);
        if (normalizedEmail.isEmpty() || password == null || password.isBlank()) {
            log.warn(
                    "Admin bootstrap etkin ancak APP_ADMIN_EMAIL veya APP_ADMIN_PASSWORD eksik;"
                            + " ADMIN hesabı oluşturulmadı.");
            return BootstrapOutcome.SKIPPED_MISSING_CONFIG;
        }

        if (userAccountRepository.existsByRole(UserRole.ADMIN)) {
            log.info("Admin bootstrap atlandı: sistemde zaten bir ADMIN hesabı var.");
            return BootstrapOutcome.SKIPPED_ADMIN_EXISTS;
        }

        if (userAccountRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            log.warn(
                    "Admin bootstrap atlandı: {} e-postası zaten kayıtlı; mevcut kullanıcı değiştirilmedi.",
                    normalizedEmail);
            return BootstrapOutcome.SKIPPED_EMAIL_EXISTS;
        }

        UserAccount admin = new UserAccount();
        admin.setFullName("Turİzim Admin");
        admin.setEmail(normalizedEmail);
        admin.setPasswordHash(passwordEncoder.encode(password));
        admin.setRole(UserRole.ADMIN);
        admin.setActive(true);
        userAccountRepository.save(admin);

        log.info("Admin bootstrap tamamlandı: ilk ADMIN hesabı oluşturuldu ({}).", normalizedEmail);
        return BootstrapOutcome.CREATED;
    }

    private static String normalizeEmail(String email) {
        if (email == null) {
            return "";
        }
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
