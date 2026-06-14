package com.turizim.billing.web;

import com.turizim.billing.AgencySubscriptionService;
import com.turizim.billing.dto.AgencyPlanResponse;
import com.turizim.billing.dto.CheckoutRequest;
import com.turizim.billing.dto.CheckoutResponse;
import com.turizim.billing.dto.SubscriptionStatusResponse;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.domain.enums.SubscriptionPlanCode;
import com.turizim.domain.enums.SubscriptionStatus;
import com.turizim.security.SecurityContextSupport;
import com.turizim.security.TurIzimPrincipal;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Acente abonelik durumu ve ödeme API'si.
 *
 * <p>Güvenlik notu: {@code APP_LEGACY_OPEN_API=true} iken uçlar anonime açıktır.
 * Üretimde {@code false} yapıldığında SecurityConfig'deki AGENCY/ADMIN rolleri devreye girer.
 */
@RestController
@RequestMapping("/api/billing/agency")
public class BillingController {

    private final AgencySubscriptionService subscriptionService;

    @Value("${app.billing.agency-pro-payment-link:}")
    private String agencyProPaymentLink;

    @Value("${app.billing.agency-growth-payment-link:}")
    private String agencyGrowthPaymentLink;

    public BillingController(AgencySubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    /**
     * Geçerli acentenin abonelik durumunu ve plan özelliklerini döner.
     * JWT yoksa (legacy mod) FREE / NONE döner.
     */
    @GetMapping("/subscription")
    public SubscriptionStatusResponse getSubscription() {
        UUID agencyId = SecurityContextSupport.currentUser()
                .map(TurIzimPrincipal::getAgencyId)
                .orElse(null);

        if (agencyId == null) {
            return new SubscriptionStatusResponse(
                    SubscriptionPlanCode.FREE.name(),
                    SubscriptionStatus.NONE.name(),
                    1, false, false, false, null, null);
        }

        return subscriptionService.buildSubscriptionStatusResponse(agencyId);
    }

    /**
     * Mevcut plan tanımlarını döner (Free / Pro / Growth kart verileri).
     * Herkes erişebilir; checkout linkinin mevcut olup olmadığını raporlar.
     */
    @GetMapping("/plans")
    public List<AgencyPlanResponse> getPlans() {
        boolean proAvailable = agencyProPaymentLink != null && !agencyProPaymentLink.isBlank();
        boolean growthAvailable = agencyGrowthPaymentLink != null && !agencyGrowthPaymentLink.isBlank();

        return List.of(
                new AgencyPlanResponse(
                        SubscriptionPlanCode.FREE.name(),
                        "Ücretsiz",
                        0, 1,
                        false, false, false, false, false),
                new AgencyPlanResponse(
                        SubscriptionPlanCode.AGENCY_PRO.name(),
                        "Agency Pro",
                        499, 5,
                        true, true, true, false, proAvailable),
                new AgencyPlanResponse(
                        SubscriptionPlanCode.AGENCY_GROWTH.name(),
                        "Agency Growth",
                        999, 20,
                        true, true, true, true, growthAvailable));
    }

    /**
     * Verilen plan için harici checkout URL'si döner.
     * FREE plan seçilemez. Link eksikse HTTP 422 döner.
     *
     * <p>Frontend bu URL'yi tarayıcıda açar; uygulama içinde kart işleme yapılmaz.
     */
    @PostMapping("/checkout")
    public CheckoutResponse checkout(@Valid @RequestBody CheckoutRequest req) {
        SubscriptionPlanCode plan;
        try {
            plan = SubscriptionPlanCode.valueOf(req.planCode().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new BusinessRuleException(400, "Geçersiz plan kodu: " + req.planCode());
        }

        if (plan == SubscriptionPlanCode.FREE) {
            throw new BusinessRuleException(400, "Ücretsiz plan için ödeme gerekmez.");
        }

        String link = switch (plan) {
            case AGENCY_PRO -> agencyProPaymentLink;
            case AGENCY_GROWTH -> agencyGrowthPaymentLink;
            default -> null;
        };

        if (link == null || link.isBlank()) {
            throw new BusinessRuleException(422,
                    "Bu abonelik planı için ödeme linki henüz tanımlanmadı.");
        }

        SecurityContextSupport.currentUser().ifPresent(p -> {
            if (p.getAgencyId() != null) {
                subscriptionService.initPendingSubscription(p.getAgencyId(), plan);
            }
        });

        return new CheckoutResponse(link, plan.name());
    }
}
