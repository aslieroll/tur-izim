package com.turizim.domain.service;

import com.turizim.creator.CreatorProfile;
import com.turizim.domain.enums.TourType;
import com.turizim.tour.Tour;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.stereotype.Component;

/** MVP: basit, deterministik AUE yerine tutarı — ileride suitability-score.md ile değiştirilir. */
@Component
public class SimpleSuitabilityCalculator {

    public BigDecimal score(Tour tour, CreatorProfile creator) {
        int base = 58;
        if (creator.isActive()) {
            base += 12;
        }
        if (tour.getTourType() == TourType.INTERNATIONAL && creator.isHasValidPassport()) {
            base += 10;
        }
        if (creator.isHasSchengenVisa() || creator.isHasUsVisa() || creator.isHasUkVisa()) {
            base += 8;
        }
        int jitter = Math.floorMod(creator.getId().hashCode() ^ tour.getId().hashCode(), 15);
        int total = Math.min(100, base + jitter);
        return BigDecimal.valueOf(total).setScale(2, RoundingMode.HALF_UP);
    }
}
