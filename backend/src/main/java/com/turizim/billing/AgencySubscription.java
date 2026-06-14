package com.turizim.billing;

import com.turizim.agency.Agency;
import com.turizim.common.domain.BaseEntity;
import com.turizim.domain.enums.SubscriptionPlanCode;
import com.turizim.domain.enums.SubscriptionStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;

/**
 * Acente abonelik kaydı. Her acentenin en fazla bir kaydı olur (OneToOne).
 *
 * <p>Kayıt yoksa FREE plan varsayılır; ücretli özellikler kapalıdır.
 * Gerçek ödeme gateway webhook'u MVP sonrasıdır.
 */
@Entity
@Table(name = "agency_subscriptions")
public class AgencySubscription extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agency_id", unique = true, nullable = false)
    private Agency agency;

    @Enumerated(EnumType.STRING)
    @Column(name = "plan_code", nullable = false, length = 32)
    private SubscriptionPlanCode planCode = SubscriptionPlanCode.AGENCY_PRO;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    private SubscriptionStatus status = SubscriptionStatus.NONE;

    @Column(name = "provider", length = 64)
    private String provider;

    @Column(name = "provider_subscription_id")
    private String providerSubscriptionId;

    @Column(name = "current_period_start")
    private Instant currentPeriodStart;

    @Column(name = "current_period_end")
    private Instant currentPeriodEnd;

    public Agency getAgency() { return agency; }
    public void setAgency(Agency agency) { this.agency = agency; }

    public SubscriptionPlanCode getPlanCode() { return planCode; }
    public void setPlanCode(SubscriptionPlanCode planCode) { this.planCode = planCode; }

    public SubscriptionStatus getStatus() { return status; }
    public void setStatus(SubscriptionStatus status) { this.status = status; }

    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }

    public String getProviderSubscriptionId() { return providerSubscriptionId; }
    public void setProviderSubscriptionId(String id) { this.providerSubscriptionId = id; }

    public Instant getCurrentPeriodStart() { return currentPeriodStart; }
    public void setCurrentPeriodStart(Instant t) { this.currentPeriodStart = t; }

    public Instant getCurrentPeriodEnd() { return currentPeriodEnd; }
    public void setCurrentPeriodEnd(Instant t) { this.currentPeriodEnd = t; }
}
