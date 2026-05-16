package com.turizim.tour.service;

import com.turizim.agency.Agency;
import com.turizim.agency.AgencyRepository;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.domain.enums.TourStatus;
import com.turizim.domain.enums.UserRole;
import com.turizim.domain.service.TourCreatorEligibilityService;
import com.turizim.security.SecurityContextSupport;
import com.turizim.security.TurIzimPrincipal;
import com.turizim.tour.Tour;
import com.turizim.tour.TourRepository;
import com.turizim.tour.dto.CreateTourRequest;
import com.turizim.tour.dto.TourSummaryResponse;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TourService {

    private final TourRepository tourRepository;
    private final AgencyRepository agencyRepository;
    private final TourCreatorEligibilityService tourCreatorEligibilityService;

    public TourService(
            TourRepository tourRepository,
            AgencyRepository agencyRepository,
            TourCreatorEligibilityService tourCreatorEligibilityService) {
        this.tourRepository = tourRepository;
        this.agencyRepository = agencyRepository;
        this.tourCreatorEligibilityService = tourCreatorEligibilityService;
    }

    @Transactional(readOnly = true)
    public List<TourSummaryResponse> listPublished() {
        return tourRepository.findPublishedWithAgency(TourStatus.PUBLISHED).stream()
                .map(this::toSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public TourSummaryResponse getById(UUID id) {
        Tour tour = tourRepository
                .findOneByIdWithAgency(id)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Tur bulunamadı."));
        if (tour.getStatus() != TourStatus.PUBLISHED) {
            throw new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Tur yayımlanmamış veya kapalı.");
        }
        return toSummary(tour);
    }

    @Transactional
    public TourSummaryResponse create(CreateTourRequest request) {
        SecurityContextSupport.currentUser()
                .ifPresent(actor -> enforceAgencyMatchesCreateRequest(actor, request.agencyId()));
        Agency agency = agencyRepository
                .findById(request.agencyId())
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Acente bulunamadı."));
        if (agency.getStatus() != com.turizim.domain.enums.AgencyStatus.APPROVED) {
            throw new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Acente onaylı değilken tur oluşturulamaz.");
        }
        validateDates(request.startDate(), request.endDate());
        if (request.availableCreatorSeats() > request.capacity()) {
            throw new BusinessRuleException(
                    HttpStatus.BAD_REQUEST.value(), "Müsait creator kotası kapasiteyi aşamaz.");
        }
        Tour tour = new Tour();
        tour.setAgency(agency);
        tour.setTitle(request.title().trim());
        tour.setDescription(request.description());
        tour.setDepartureCity(request.departureCity().trim());
        tour.setDestination(request.destination().trim());
        tour.setStartDate(request.startDate());
        tour.setEndDate(request.endDate());
        tour.setNormalSalePrice(request.normalSalePrice());
        tour.setExpectedDepositAmount(request.expectedDepositAmount());
        tour.setTourType(request.tourType());
        tour.setRequiresPassport(request.requiresPassport());
        tour.setRequiredPassportType(request.requiredPassportType());
        tour.setRequiresVisa(request.requiresVisa());
        tour.setRequiredVisaDescription(request.requiredVisaDescription());
        tour.setCapacity(request.capacity());
        tour.setAvailableCreatorSeats(request.availableCreatorSeats());
        tour.setStatus(TourStatus.PUBLISHED);
        tourCreatorEligibilityService.validateInternationalTourDefinition(tour);
        tour = tourRepository.save(tour);
        return toSummary(tourRepository.findOneByIdWithAgency(tour.getId()).orElse(tour));
    }

    @Transactional(readOnly = true)
    public List<TourSummaryResponse> listByAgency(UUID agencyId) {
        if (!agencyRepository.existsById(agencyId)) {
            throw new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Acente bulunamadı.");
        }
        SecurityContextSupport.currentUser().ifPresent(actor -> enforceAgencyPath(actor, agencyId));
        return tourRepository.findByAgencyIdWithAgency(agencyId).stream()
                .map(this::toSummary)
                .toList();
    }

    private static void enforceAgencyMatchesCreateRequest(TurIzimPrincipal actor, UUID agencyIdInBody) {
        if (actor.getRole() != UserRole.AGENCY) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Tur oluşturma yalnız acente hesabıyla yapılabilir.");
        }
        if (actor.getAgencyId() == null || !actor.getAgencyId().equals(agencyIdInBody)) {
            throw new BusinessRuleException(
                    HttpStatus.FORBIDDEN.value(), "İstek gövdesindeki acente kimliği oturumla eşleşmiyor.");
        }
    }

    private static void enforceAgencyPath(TurIzimPrincipal actor, UUID agencyIdInPath) {
        if (actor.getRole() == UserRole.CREATOR) {
            throw new BusinessRuleException(
                    HttpStatus.FORBIDDEN.value(), "Acente turları yalnız acente hesabıyla listelenebilir.");
        }
        if (actor.getRole() != UserRole.AGENCY) {
            return;
        }
        if (actor.getAgencyId() == null || !actor.getAgencyId().equals(agencyIdInPath)) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Bu acenteye ait turları listeleyemezsiniz.");
        }
    }

    private void validateDates(LocalDate start, LocalDate end) {
        if (end.isBefore(start)) {
            throw new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Bitiş tarihi başlangıçtan önce olamaz.");
        }
    }

    private TourSummaryResponse toSummary(Tour t) {
        Agency ag = t.getAgency();
        return new TourSummaryResponse(
                t.getId(),
                ag.getId(),
                ag.getName(),
                t.getTitle(),
                t.getDescription(),
                t.getDepartureCity(),
                t.getDestination(),
                t.getStartDate(),
                t.getEndDate(),
                t.getNormalSalePrice(),
                t.getExpectedDepositAmount(),
                t.getTourType(),
                t.getStatus(),
                passportVisaSummary(t),
                t.getAvailableCreatorSeats());
    }

    private String passportVisaSummary(Tour t) {
        StringBuilder sb = new StringBuilder();
        if (t.isRequiresPassport()) {
            sb.append("Pasaport gerekli");
            if (t.getRequiredPassportType() != null) {
                sb.append(" (min: ").append(t.getRequiredPassportType()).append(")");
            }
        }
        if (t.isRequiresVisa()) {
            if (!sb.isEmpty()) {
                sb.append("; ");
            }
            sb.append("Vize gerekli");
            if (t.getRequiredVisaDescription() != null && !t.getRequiredVisaDescription().isBlank()) {
                sb.append(": ").append(t.getRequiredVisaDescription().trim());
            }
        }
        if (sb.isEmpty()) {
            return "Pasaport/vize şartı yok (yurt içi veya beyan yok).";
        }
        return sb.toString();
    }
}
