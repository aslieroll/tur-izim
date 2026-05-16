package com.turizim.admin.dto;

import com.turizim.domain.enums.ViolationStatus;
import java.time.Instant;
import java.util.UUID;

public record ViolationReportResponse(
        UUID id,
        UUID publicationProofId,
        UUID reportedByAgencyId,
        String reason,
        ViolationStatus status,
        Instant createdAt) {}
