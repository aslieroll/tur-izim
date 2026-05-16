package com.turizim.tour.dto;

import com.turizim.domain.enums.TourStatus;
import com.turizim.domain.enums.TourType;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record TourSummaryResponse(
        UUID id,
        UUID agencyId,
        String agencyName,
        String title,
        String description,
        String departureCity,
        String destination,
        LocalDate startDate,
        LocalDate endDate,
        BigDecimal normalSalePrice,
        BigDecimal expectedDepositAmount,
        TourType tourType,
        TourStatus status,
        String passportVisaSummary,
        int availableCreatorSeats) {
}
