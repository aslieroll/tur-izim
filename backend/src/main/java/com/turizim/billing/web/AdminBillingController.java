package com.turizim.billing.web;

import com.turizim.billing.AgencySubscriptionService;
import com.turizim.billing.dto.ManualActivateAdminRequest;
import com.turizim.billing.dto.SubscriptionStatusResponse;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.domain.enums.SubscriptionPlanCode;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Kontrollü beta için admin aktivasyon ucu.
 *
 * <p><b>Güvenlik:</b> {@code APP_LEGACY_OPEN_API=false} iken SecurityConfig'de
 * ADMIN rolü zorunlu kılınmıştır.
 * {@code APP_LEGACY_OPEN_API=true} (yerel/demo) iken anonim erişime açıktır —
 * üretimde ASLA true kullanılmamalıdır.
 *
 * <p>Gerçek ödeme sağlayıcısı webhook'u gelince bu uç kaldırılacak veya
 * webhook doğrulaması eklenerek korunacaktır.
 */
@RestController
@RequestMapping("/api/billing/admin/subscriptions")
public class AdminBillingController {

    private final AgencySubscriptionService subscriptionService;

    public AdminBillingController(AgencySubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    /**
     * Acenteye belirtilen ücretli planı ACTIVE yapar.
     * FREE plan aktivasyon girişimi reddedilir.
     */
    @PostMapping("/manual-activate")
    public SubscriptionStatusResponse manualActivate(
            @Valid @RequestBody ManualActivateAdminRequest req) {
        SubscriptionPlanCode plan;
        try {
            plan = SubscriptionPlanCode.valueOf(req.planCode().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new BusinessRuleException(400, "Geçersiz plan kodu: " + req.planCode());
        }

        if (plan == SubscriptionPlanCode.FREE) {
            throw new BusinessRuleException(400,
                    "FREE planı manuel aktivasyon gerektirmez.");
        }

        subscriptionService.manualActivate(req.agencyId(), plan, req.providerSubscriptionId());
        return subscriptionService.buildSubscriptionStatusResponse(req.agencyId());
    }
}
