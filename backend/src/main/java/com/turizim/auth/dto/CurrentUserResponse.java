package com.turizim.auth.dto;

import com.turizim.domain.enums.UserRole;
import java.util.UUID;

public record CurrentUserResponse(
        UUID userId,
        UserRole role,
        String email,
        String fullName,
        UUID creatorProfileId,
        UUID agencyId) {}
