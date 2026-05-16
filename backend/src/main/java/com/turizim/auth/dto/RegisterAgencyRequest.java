package com.turizim.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterAgencyRequest(
        @NotBlank @Size(max = 200) String name,
        @NotBlank @Email @Size(max = 320) String contactEmail,
        @NotBlank @Size(min = 8, max = 128) String password,
        @NotBlank @Size(max = 40) String phone,
        @NotBlank @Size(max = 120) String city) {}
