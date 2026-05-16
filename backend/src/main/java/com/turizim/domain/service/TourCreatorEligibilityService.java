package com.turizim.domain.service;

import com.turizim.common.exception.BusinessRuleException;
import com.turizim.creator.CreatorProfile;
import com.turizim.domain.enums.PassportType;
import com.turizim.domain.enums.TourType;
import com.turizim.tour.Tour;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

@Component
public class TourCreatorEligibilityService {

    public void validateEligibleForApplication(Tour tour, CreatorProfile creator) {
        if (!creator.isActive()) {
            throw new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Üretici profili aktif değil.");
        }
        if (tour.getTourType() == TourType.INTERNATIONAL) {
            if (!tour.isRequiresPassport() && !tour.isRequiresVisa()) {
                throw new BusinessRuleException(
                        HttpStatus.BAD_REQUEST.value(),
                        "Yurt dışı turda pasaport veya vize şartından en az biri tanımlanmalıdır.");
            }
            if (tour.isRequiresPassport()) {
                if (!creator.isHasValidPassport() || creator.getPassportType() == PassportType.NONE) {
                    throw new BusinessRuleException(
                            HttpStatus.BAD_REQUEST.value(), "Bu tur için geçerli pasaport gereklidir.");
                }
                PassportType required = tour.getRequiredPassportType();
                if (required != null && required != PassportType.NONE) {
                    if (!creator.getPassportType().satisfiesMinimum(required)) {
                        throw new BusinessRuleException(
                                HttpStatus.BAD_REQUEST.value(),
                                "Üreticinin pasaport türü tur şartını karşılamıyor.");
                    }
                }
            }
            if (tour.isRequiresVisa()) {
                if (!creator.isHasSchengenVisa()
                        && !creator.isHasUsVisa()
                        && !creator.isHasUkVisa()
                        && !creator.isHasOtherValidVisa()) {
                    throw new BusinessRuleException(
                            HttpStatus.BAD_REQUEST.value(),
                            "Bu tur için beyan edilen vize şartı karşılanmıyor.");
                }
            }
        }
    }

    public void validateInternationalTourDefinition(Tour tour) {
        if (tour.getTourType() != TourType.INTERNATIONAL) {
            return;
        }
        if (!tour.isRequiresPassport() && !tour.isRequiresVisa()) {
            throw new BusinessRuleException(
                    HttpStatus.BAD_REQUEST.value(),
                    "Yurt dışı turda pasaport veya vize gereksiniminden en az biri işaretlenmelidir.");
        }
        if (tour.isRequiresVisa()) {
            if (tour.getRequiredVisaDescription() == null || tour.getRequiredVisaDescription().isBlank()) {
                throw new BusinessRuleException(
                        HttpStatus.BAD_REQUEST.value(), "Vize gerekliyse açıklama metni zorunludur.");
            }
        }
    }
}
