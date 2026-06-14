package com.turizim.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import com.turizim.agency.AgencyRepository;
import com.turizim.domain.enums.SubscriptionPlanCode;
import com.turizim.domain.enums.SubscriptionStatus;
import com.turizim.domain.enums.TourStatus;
import com.turizim.tour.TourRepository;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

/**
 * Plan limitleri ve özellik erişim mantığı için birim testler.
 * HTTP / Spring context gerektirmez.
 */
@ExtendWith(MockitoExtension.class)
class AgencySubscriptionServiceTest {

    @Mock
    private AgencySubscriptionRepository subscriptionRepository;

    @Mock
    private AgencyRepository agencyRepository;

    @Mock
    private TourRepository tourRepository;

    @InjectMocks
    private AgencySubscriptionService service;

    private UUID agencyId;

    @BeforeEach
    void setup() {
        agencyId = UUID.randomUUID();
    }

    // ─── Tur limiti ───────────────────────────────────────────────────────

    @Test
    void freePlan_activeTourLimit_isOne() {
        when(subscriptionRepository.findByAgency_Id(agencyId)).thenReturn(Optional.empty());
        assertThat(service.getActiveTourLimit(agencyId)).isEqualTo(1);
    }

    @Test
    void agencyPro_activeTourLimit_isFive() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(activeSubscription(SubscriptionPlanCode.AGENCY_PRO)));
        assertThat(service.getActiveTourLimit(agencyId)).isEqualTo(5);
    }

    @Test
    void agencyGrowth_activeTourLimit_isTwenty() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(activeSubscription(SubscriptionPlanCode.AGENCY_GROWTH)));
        assertThat(service.getActiveTourLimit(agencyId)).isEqualTo(20);
    }

    @Test
    void pendingPro_tourLimit_isStillOne() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(pendingSubscription(SubscriptionPlanCode.AGENCY_PRO)));
        assertThat(service.getActiveTourLimit(agencyId)).isEqualTo(1);
    }

    // ─── canCreateAnotherTour ─────────────────────────────────────────────

    @Test
    void freePlan_canCreateTour_whenBelowLimit() {
        when(subscriptionRepository.findByAgency_Id(agencyId)).thenReturn(Optional.empty());
        when(tourRepository.countByAgencyIdAndStatus(agencyId, TourStatus.PUBLISHED))
                .thenReturn(0L);
        assertThat(service.canCreateAnotherTour(agencyId)).isTrue();
    }

    @Test
    void freePlan_cannotCreateTour_whenAtLimit() {
        when(subscriptionRepository.findByAgency_Id(agencyId)).thenReturn(Optional.empty());
        when(tourRepository.countByAgencyIdAndStatus(agencyId, TourStatus.PUBLISHED))
                .thenReturn(1L);
        assertThat(service.canCreateAnotherTour(agencyId)).isFalse();
    }

    @Test
    void proPlan_canCreateTour_whenBelowFiveLimit() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(activeSubscription(SubscriptionPlanCode.AGENCY_PRO)));
        when(tourRepository.countByAgencyIdAndStatus(agencyId, TourStatus.PUBLISHED))
                .thenReturn(4L);
        assertThat(service.canCreateAnotherTour(agencyId)).isTrue();
    }

    @Test
    void proPlan_cannotCreateTour_whenAtFiveLimit() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(activeSubscription(SubscriptionPlanCode.AGENCY_PRO)));
        when(tourRepository.countByAgencyIdAndStatus(agencyId, TourStatus.PUBLISHED))
                .thenReturn(5L);
        assertThat(service.canCreateAnotherTour(agencyId)).isFalse();
    }

    // ─── Özellik erişim ───────────────────────────────────────────────────

    @Test
    void freePlan_cannotUseAiMatch() {
        when(subscriptionRepository.findByAgency_Id(agencyId)).thenReturn(Optional.empty());
        assertThat(service.canUseAiMatch(agencyId)).isFalse();
    }

    @Test
    void activePro_canUseAiMatch() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(activeSubscription(SubscriptionPlanCode.AGENCY_PRO)));
        assertThat(service.canUseAiMatch(agencyId)).isTrue();
    }

    @Test
    void activeGrowth_canUseAiMatch() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(activeSubscription(SubscriptionPlanCode.AGENCY_GROWTH)));
        assertThat(service.canUseAiMatch(agencyId)).isTrue();
    }

    @Test
    void pendingPro_cannotUseAiMatch() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(pendingSubscription(SubscriptionPlanCode.AGENCY_PRO)));
        assertThat(service.canUseAiMatch(agencyId)).isFalse();
    }

    @Test
    void pastDuePro_cannotUseAiMatch() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(statusSubscription(SubscriptionPlanCode.AGENCY_PRO, SubscriptionStatus.PAST_DUE)));
        assertThat(service.canUseAiMatch(agencyId)).isFalse();
    }

    @Test
    void canceledPro_cannotUseAiMatch() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(statusSubscription(SubscriptionPlanCode.AGENCY_PRO, SubscriptionStatus.CANCELED)));
        assertThat(service.canUseAiMatch(agencyId)).isFalse();
    }

    @Test
    void activePro_canManageApplicants() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(activeSubscription(SubscriptionPlanCode.AGENCY_PRO)));
        assertThat(service.canManageApplicants(agencyId)).isTrue();
    }

    @Test
    void freePlan_cannotManageApplicants() {
        when(subscriptionRepository.findByAgency_Id(agencyId)).thenReturn(Optional.empty());
        assertThat(service.canManageApplicants(agencyId)).isFalse();
    }

    @Test
    void activePro_canSelectCreator() {
        when(subscriptionRepository.findByAgency_Id(agencyId))
                .thenReturn(Optional.of(activeSubscription(SubscriptionPlanCode.AGENCY_PRO)));
        assertThat(service.canSelectCreator(agencyId)).isTrue();
    }

    @Test
    void freePlan_cannotSelectCreator() {
        when(subscriptionRepository.findByAgency_Id(agencyId)).thenReturn(Optional.empty());
        assertThat(service.canSelectCreator(agencyId)).isFalse();
    }

    // ─── Yardımcılar ─────────────────────────────────────────────────────

    private AgencySubscription activeSubscription(SubscriptionPlanCode plan) {
        return statusSubscription(plan, SubscriptionStatus.ACTIVE);
    }

    private AgencySubscription pendingSubscription(SubscriptionPlanCode plan) {
        return statusSubscription(plan, SubscriptionStatus.PENDING);
    }

    private AgencySubscription statusSubscription(SubscriptionPlanCode plan, SubscriptionStatus status) {
        AgencySubscription sub = new AgencySubscription();
        sub.setPlanCode(plan);
        sub.setStatus(status);
        return sub;
    }
}
