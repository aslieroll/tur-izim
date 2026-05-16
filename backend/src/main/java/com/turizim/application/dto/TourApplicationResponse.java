package com.turizim.application.dto;

import com.turizim.domain.enums.ApplicationStatus;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record TourApplicationResponse(
        UUID id,
        UUID tourId,
        String tourTitle,
        UUID creatorId,
        String creatorName,
        ApplicationStatus status,
        BigDecimal suitabilityScore,
        boolean acceptedThirtyDayPublicationCommitment,
        boolean acceptedAgencyContentUsageRights,
        boolean acceptedEarlyRemovalFullFeeRule,
        String applicationNote,
        Instant createdAt) {
}
