package com.turizim.billing.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ManualActivateAdminRequest(
        @NotNull UUID agencyId,
        @NotBlank String planCode,
        String providerSubscriptionId) {}
