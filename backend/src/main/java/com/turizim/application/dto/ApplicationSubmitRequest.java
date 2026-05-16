package com.turizim.application.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ApplicationSubmitRequest(
        @NotNull UUID creatorId,
        String applicationNote,
        @NotNull Boolean acceptedThirtyDayPublicationCommitment,
        @NotNull Boolean acceptedAgencyContentUsageRights,
        @NotNull Boolean acceptedEarlyRemovalFullFeeRule) {
}
