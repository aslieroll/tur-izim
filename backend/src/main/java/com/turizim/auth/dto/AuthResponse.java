package com.turizim.auth.dto;

import com.turizim.domain.enums.UserRole;
import java.util.UUID;

public record AuthResponse(
        String token,
        UUID userId,
        UserRole role,
        String email,
        String fullName,
        UUID creatorProfileId,
        UUID agencyId) {}
