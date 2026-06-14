package com.turizim.config;

import com.turizim.auth.AdminBootstrapService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Uygulama başlangıcında ilk ADMIN hesabını ortam değişkenleriyle oluşturur.
 *
 * <p>Üretim/beta ilk dağıtımında {@code APP_ADMIN_BOOTSTRAP_ENABLED=true} ile bir kez
 * çalıştırılır; giriş doğrulandıktan sonra {@code false} yapılmalıdır.
 *
 * <p>Genel kayıt API'si yoktur; {@code SecurityConfig} değiştirilmez.
 */
@Component
@Order(0)
@Profile("!test")
public class InitialAdminBootstrap implements ApplicationRunner {

    private final AdminBootstrapService adminBootstrapService;

    @Value("${app.admin-bootstrap.enabled:false}")
    private boolean bootstrapEnabled;

    @Value("${app.admin-bootstrap.email:}")
    private String adminEmail;

    @Value("${app.admin-bootstrap.password:}")
    private String adminPassword;

    public InitialAdminBootstrap(AdminBootstrapService adminBootstrapService) {
        this.adminBootstrapService = adminBootstrapService;
    }

    @Override
    public void run(ApplicationArguments args) {
        adminBootstrapService.bootstrap(bootstrapEnabled, adminEmail, adminPassword);
    }
}
