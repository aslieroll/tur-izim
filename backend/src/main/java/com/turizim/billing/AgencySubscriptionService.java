package com.turizim.billing;

import com.turizim.agency.Agency;
import com.turizim.agency.AgencyRepository;
import com.turizim.billing.dto.SubscriptionStatusResponse;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.domain.enums.SubscriptionPlanCode;
import com.turizim.domain.enums.SubscriptionStatus;
import com.turizim.domain.enums.TourStatus;
import com.turizim.domain.enums.UserRole;
import com.turizim.security.SecurityContextSupport;
import com.turizim.security.TurIzimPrincipal;
import com.turizim.tour.TourRepository;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Acente abonelik ve plan sınırı iş mantığı.
 *
 * <p><b>Gating kuralı:</b> JWT yoksa (legacy-open-api=true veya anonim)
 * geçişe izin verilir; demo akışı ve mevcut testler bozulmaz.
 * Gerçek üretimde {@code APP_LEGACY_OPEN_API=false} + JWT zorunludur.
 *
 * <p><b>Plan hiyerarşisi:</b> FREE (varsayılan) &lt; AGENCY_PRO &lt; AGENCY_GROWTH.
 * Yalnızca ACTIVE durumundaki AGENCY_PRO veya AGENCY_GROWTH ücretli özellikleri açar.
 */
@Service
public class AgencySubscriptionService {

    private static final String PAID_REQUIRED_MSG =
            "Bu özellik Turİzim Agency Pro veya Growth aboneliği gerektirir.";

    private final AgencySubscriptionRepository subscriptionRepository;
    private final AgencyRepository agencyRepository;
    private final TourRepository tourRepository;

    public AgencySubscriptionService(
            AgencySubscriptionRepository subscriptionRepository,
            AgencyRepository agencyRepository,
            TourRepository tourRepository) {
        this.subscriptionRepository = subscriptionRepository;
        this.agencyRepository = agencyRepository;
        this.tourRepository = tourRepository;
    }

    // ──────────────────────────────────────────────────────────────────────
    // Plan sorgulama
    // ──────────────────────────────────────────────────────────────────────

    /**
     * Acentenin aktif plan kodunu döner.
     * ACTIVE olmayan kayıtlar FREE olarak değerlendirilir.
     */
    @Transactional(readOnly = true)
    public SubscriptionPlanCode getCurrentPlanForAgency(UUID agencyId) {
        return subscriptionRepository.findByAgency_Id(agencyId)
                .filter(s -> s.getStatus() == SubscriptionStatus.ACTIVE)
                .map(AgencySubscription::getPlanCode)
                .filter(p -> p != SubscriptionPlanCode.FREE)
                .orElse(SubscriptionPlanCode.FREE);
    }

    @Transactional(readOnly = true)
    public Optional<AgencySubscription> getCurrentSubscriptionForAgency(UUID agencyId) {
        return subscriptionRepository.findByAgency_Id(agencyId);
    }

    @Transactional(readOnly = true)
    public boolean hasActivePaidSubscription(UUID agencyId) {
        SubscriptionPlanCode plan = getCurrentPlanForAgency(agencyId);
        return plan == SubscriptionPlanCode.AGENCY_PRO
                || plan == SubscriptionPlanCode.AGENCY_GROWTH;
    }

    // ──────────────────────────────────────────────────────────────────────
    // Özellik erişim kontrolleri
    // ──────────────────────────────────────────────────────────────────────

    public boolean canUseAiMatch(UUID agencyId) {
        return hasActivePaidSubscription(agencyId);
    }

    public boolean canManageApplicants(UUID agencyId) {
        return hasActivePaidSubscription(agencyId);
    }

    public boolean canSelectCreator(UUID agencyId) {
        return hasActivePaidSubscription(agencyId);
    }

    // ──────────────────────────────────────────────────────────────────────
    // Tur kotası
    // ──────────────────────────────────────────────────────────────────────

    public int getActiveTourLimit(UUID agencyId) {
        return switch (getCurrentPlanForAgency(agencyId)) {
            case AGENCY_PRO -> 5;
            case AGENCY_GROWTH -> 20;
            default -> 1;
        };
    }

    @Transactional(readOnly = true)
    public boolean canCreateAnotherTour(UUID agencyId) {
        long current = tourRepository.countByAgencyIdAndStatus(agencyId, TourStatus.PUBLISHED);
        return current < getActiveTourLimit(agencyId);
    }

    // ──────────────────────────────────────────────────────────────────────
    // Gating (endpoint koruma)
    // ──────────────────────────────────────────────────────────────────────

    /**
     * Ücretli özelliklere erişim gerektirir.
     *
     * <p>JWT yoksa (anonim / legacy-open-api) atlanır.
     * ADMIN her zaman geçer.
     * AGENCY rolüyle aktif ücretli plan yoksa HTTP 402 fırlatır.
     */
    public void requireActivePaidSubscription() {
        Optional<TurIzimPrincipal> principalOpt = SecurityContextSupport.currentUser();
        if (principalOpt.isEmpty()) {
            return;
        }

        TurIzimPrincipal principal = principalOpt.get();
        if (principal.getRole() == UserRole.ADMIN) {
            return;
        }
        if (principal.getRole() != UserRole.AGENCY) {
            return;
        }

        UUID agencyId = principal.getAgencyId();
        if (agencyId == null) {
            return;
        }

        if (!hasActivePaidSubscription(agencyId)) {
            throw new BusinessRuleException(402, PAID_REQUIRED_MSG);
        }
    }

    // ──────────────────────────────────────────────────────────────────────
    // DTO oluşturma
    // ──────────────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public SubscriptionStatusResponse buildSubscriptionStatusResponse(UUID agencyId) {
        SubscriptionPlanCode plan = getCurrentPlanForAgency(agencyId);
        Optional<AgencySubscription> sub = subscriptionRepository.findByAgency_Id(agencyId);

        return new SubscriptionStatusResponse(
                plan.name(),
                sub.map(s -> s.getStatus().name()).orElse(SubscriptionStatus.NONE.name()),
                getActiveTourLimit(agencyId),
                canUseAiMatch(agencyId),
                canManageApplicants(agencyId),
                canSelectCreator(agencyId),
                sub.map(AgencySubscription::getCurrentPeriodStart).orElse(null),
                sub.map(AgencySubscription::getCurrentPeriodEnd).orElse(null));
    }

    // ──────────────────────────────────────────────────────────────────────
    // Abonelik yönetimi
    // ──────────────────────────────────────────────────────────────────────

    /**
     * Checkout başlangıcında aboneliği PENDING yap (idempotent).
     * ACTIVE veya PENDING ise planı güncelle ama durumu değiştirme.
     */
    @Transactional
    public void initPendingSubscription(UUID agencyId, SubscriptionPlanCode plan) {
        subscriptionRepository.findByAgency_Id(agencyId).ifPresentOrElse(
                existing -> {
                    existing.setPlanCode(plan);
                    if (existing.getStatus() == SubscriptionStatus.NONE
                            || existing.getStatus() == SubscriptionStatus.CANCELED) {
                        existing.setStatus(SubscriptionStatus.PENDING);
                    }
                    subscriptionRepository.save(existing);
                },
                () -> {
                    Agency agency = agencyRepository.findById(agencyId).orElse(null);
                    if (agency == null) return;
                    AgencySubscription sub = new AgencySubscription();
                    sub.setAgency(agency);
                    sub.setPlanCode(plan);
                    sub.setStatus(SubscriptionStatus.PENDING);
                    subscriptionRepository.save(sub);
                });
    }

    /**
     * Kontrollü beta / admin aktivasyonu.
     * Gerçek webhook gelince bu yerine provider callback kullanılır.
     */
    @Transactional
    public void manualActivate(UUID agencyId, SubscriptionPlanCode plan, String providerSubId) {
        Agency agency = agencyRepository.findById(agencyId)
                .orElseThrow(() -> new BusinessRuleException(404, "Acente bulunamadı: " + agencyId));

        AgencySubscription sub = subscriptionRepository.findByAgency_Id(agencyId)
                .orElseGet(() -> {
                    AgencySubscription newSub = new AgencySubscription();
                    newSub.setAgency(agency);
                    return newSub;
                });

        sub.setPlanCode(plan);
        sub.setStatus(SubscriptionStatus.ACTIVE);
        if (providerSubId != null && !providerSubId.isBlank()) {
            sub.setProviderSubscriptionId(providerSubId);
        }
        subscriptionRepository.save(sub);
    }
}
