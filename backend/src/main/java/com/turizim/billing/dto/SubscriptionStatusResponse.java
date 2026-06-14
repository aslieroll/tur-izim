package com.turizim.billing.dto;

import java.time.Instant;

public record SubscriptionStatusResponse(
        String planCode,
        String status,
        int activeTourLimit,
        boolean canUseAiMatch,
        boolean canManageApplicants,
        boolean canSelectCreator,
        Instant currentPeriodStart,
        Instant currentPeriodEnd) {}
