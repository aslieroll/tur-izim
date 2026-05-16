package com.turizim.tour.dto;

import com.turizim.domain.enums.PassportType;
import com.turizim.domain.enums.TourType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreateTourRequest(
        @NotNull UUID agencyId,
        @NotBlank String title,
        String description,
        @NotBlank String departureCity,
        @NotBlank String destination,
        @NotNull LocalDate startDate,
        @NotNull LocalDate endDate,
        @NotNull BigDecimal normalSalePrice,
        @NotNull BigDecimal expectedDepositAmount,
        @NotNull TourType tourType,
        boolean requiresPassport,
        PassportType requiredPassportType,
        boolean requiresVisa,
        String requiredVisaDescription,
        @NotNull @Min(1) Integer capacity,
        @NotNull @Min(0) Integer availableCreatorSeats) {
}
