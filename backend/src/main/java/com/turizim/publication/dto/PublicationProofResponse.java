package com.turizim.publication.dto;

import com.turizim.domain.enums.PublicationStatus;
import java.time.Instant;
import java.util.UUID;

public record PublicationProofResponse(
        UUID id,
        UUID assignmentId,
        String postUrl,
        String cloudContentUrl,
        PublicationStatus status,
        Instant submittedAt,
        Instant publicationDeadline,
        Instant mustStayPublicUntil) {}
