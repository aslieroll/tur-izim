package com.turizim.assignment.dto;

import com.turizim.domain.enums.DepositStatus;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record MockDepositResponse(
        UUID id, BigDecimal amount, DepositStatus status, Instant heldAt, Instant releasedAt) {}
