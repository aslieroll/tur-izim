package com.turizim.auth.dto;

import com.turizim.domain.enums.PassportType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record RegisterCreatorRequest(
        @NotBlank @Size(max = 200) String fullName,
        @NotBlank @Email @Size(max = 320) String email,
        @NotBlank @Size(min = 8, max = 128) String password,
        @NotBlank @Size(max = 200) String universityName,
        @NotBlank @Size(max = 120) String city,
        @NotNull PassportType passportType,
        @NotNull Boolean hasValidPassport,
        Boolean hasSchengenVisa,
        Boolean hasUsVisa,
        Boolean hasUkVisa,
        Boolean hasOtherValidVisa) {}
