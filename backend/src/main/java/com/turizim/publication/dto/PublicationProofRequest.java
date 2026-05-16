package com.turizim.publication.dto;

import com.turizim.domain.enums.PublicationStatus;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.util.UUID;

public record PublicationProofRequest(@NotBlank String postUrl, String cloudContentUrl) {}
