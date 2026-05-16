package com.turizim.assignment.dto;

import com.turizim.domain.enums.AssignmentStatus;
import java.time.Instant;
import java.util.UUID;

public record AssignmentDetailResponse(
        UUID id,
        UUID tourId,
        String tourTitle,
        UUID agencyId,
        String agencyName,
        UUID creatorId,
        String creatorName,
        UUID applicationId,
        AssignmentStatus status,
        Instant selectedAt,
        Instant creatorConfirmedAt,
        MockDepositResponse deposit) {}
