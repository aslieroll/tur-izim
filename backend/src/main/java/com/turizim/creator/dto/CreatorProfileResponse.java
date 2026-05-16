package com.turizim.creator.dto;

import com.turizim.domain.enums.PassportType;
import java.util.UUID;

public record CreatorProfileResponse(
        UUID id,
        String fullName,
        String email,
        String universityName,
        String city,
        PassportType passportType,
        boolean hasValidPassport,
        boolean hasSchengenVisa,
        boolean hasUsVisa,
        boolean hasUkVisa,
        boolean hasOtherValidVisa,
        boolean active) {
}
