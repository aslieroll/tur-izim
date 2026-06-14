package com.turizim.billing.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ManualActivateRequest(@NotNull UUID agencyId) {}
