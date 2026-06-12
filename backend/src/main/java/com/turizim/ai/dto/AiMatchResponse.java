package com.turizim.ai.dto;

import com.turizim.domain.enums.RiskLevel;
import java.util.UUID;

public record AiMatchResponse(
        UUID tourId,
        UUID creatorId,
        int fitnessScore,
        RiskLevel riskLevel,
        String aiSummary,
        boolean fallbackUsed) {}
