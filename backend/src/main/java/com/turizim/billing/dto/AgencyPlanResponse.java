package com.turizim.billing.dto;

public record AgencyPlanResponse(
        String planCode,
        String displayName,
        int priceMonthlyTl,
        int activeTourLimit,
        boolean canUseAiMatch,
        boolean canManageApplicants,
        boolean canSelectCreator,
        boolean prioritySupport,
        boolean checkoutAvailable) {}
