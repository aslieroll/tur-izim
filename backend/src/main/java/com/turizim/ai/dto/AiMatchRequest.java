package com.turizim.ai.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

/** Not: projedeki tüm kimlikler UUID'dir; sayısal id kullanılmaz. */
public record AiMatchRequest(@NotNull UUID tourId, @NotNull UUID creatorId) {}
