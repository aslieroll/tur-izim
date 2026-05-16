package com.turizim.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record ViolationCreateRequest(@NotNull UUID agencyId, @NotBlank String reason) {}
