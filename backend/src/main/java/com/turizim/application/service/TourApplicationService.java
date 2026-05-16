package com.turizim.application.service;

import com.turizim.application.TourApplication;
import com.turizim.application.TourApplicationRepository;
import com.turizim.application.dto.ApplicationSubmitRequest;
import com.turizim.application.dto.TourApplicationResponse;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.creator.CreatorProfile;
import com.turizim.domain.enums.ApplicationStatus;
import com.turizim.domain.enums.TourStatus;
import com.turizim.domain.enums.UserRole;
import com.turizim.domain.service.SimpleSuitabilityCalculator;
import com.turizim.domain.service.TourCreatorEligibilityService;
import com.turizim.security.SecurityContextSupport;
import com.turizim.security.TurIzimPrincipal;
import com.turizim.tour.Tour;
import com.turizim.tour.TourRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TourApplicationService {

    private final TourRepository tourRepository;
    private final TourApplicationRepository tourApplicationRepository;
    private final TourCreatorEligibilityService tourCreatorEligibilityService;
    private final SimpleSuitabilityCalculator suitabilityCalculator;
    private final com.turizim.creator.service.CreatorProfileService creatorProfileService;

    public TourApplicationService(
            TourRepository tourRepository,
            TourApplicationRepository tourApplicationRepository,
            TourCreatorEligibilityService tourCreatorEligibilityService,
            SimpleSuitabilityCalculator suitabilityCalculator,
            com.turizim.creator.service.CreatorProfileService creatorProfileService) {
        this.tourRepository = tourRepository;
        this.tourApplicationRepository = tourApplicationRepository;
        this.tourCreatorEligibilityService = tourCreatorEligibilityService;
        this.suitabilityCalculator = suitabilityCalculator;
        this.creatorProfileService = creatorProfileService;
    }

    @Transactional
    public TourApplicationResponse submit(UUID tourId, ApplicationSubmitRequest request) {
        if (!Boolean.TRUE.equals(request.acceptedThirtyDayPublicationCommitment())
                || !Boolean.TRUE.equals(request.acceptedAgencyContentUsageRights())
                || !Boolean.TRUE.equals(request.acceptedEarlyRemovalFullFeeRule())) {
            throw new BusinessRuleException(
                    HttpStatus.BAD_REQUEST.value(), "Başvuru için üç onay kutusu da işaretlenmelidir.");
        }
        SecurityContextSupport.currentUser()
                .ifPresent(actor -> enforceCreatorMatchesBody(actor, request.creatorId()));
        Tour tour = tourRepository
                .findById(tourId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Tur bulunamadı."));
        if (tour.getStatus() != TourStatus.PUBLISHED) {
            throw new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Yalnız yayımlanmış turlara başvurulabilir.");
        }
        CreatorProfile creator = creatorProfileService.requireCreator(request.creatorId());
        if (tourApplicationRepository.existsByTourAndCreator(tour, creator)) {
            throw new BusinessRuleException(HttpStatus.CONFLICT.value(), "Bu üretici bu tura zaten başvurmuş.");
        }
        tourCreatorEligibilityService.validateEligibleForApplication(tour, creator);
        TourApplication app = new TourApplication();
        app.setTour(tour);
        app.setCreator(creator);
        app.setStatus(ApplicationStatus.PENDING_REVIEW);
        app.setSuitabilityScore(suitabilityCalculator.score(tour, creator));
        app.setAcceptedThirtyDayPublicationCommitment(true);
        app.setAcceptedAgencyContentUsageRights(true);
        app.setAcceptedEarlyRemovalFullFeeRule(true);
        app.setApplicationNote(request.applicationNote());
        app = tourApplicationRepository.save(app);
        return toResponse(app);
    }

    @Transactional(readOnly = true)
    public List<TourApplicationResponse> listForCreator(UUID creatorId) {
        SecurityContextSupport.currentUser()
                .ifPresent(actor -> enforceCreatorOwnResource(actor, creatorId, "Başvurular yalnız kendi hesabınıza ait olabilir."));
        creatorProfileService.getById(creatorId);
        return tourApplicationRepository.findByCreator_IdOrderByCreatedAtDesc(creatorId).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<TourApplicationResponse> listForTour(UUID tourId) {
        Tour tour = tourRepository
                .findById(tourId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Tur bulunamadı."));
        SecurityContextSupport.currentUser()
                .ifPresent(actor -> enforceAgencyTourApplicantsAccess(actor, tour));
        return tourApplicationRepository.findByTour_IdOrderByCreatedAtDesc(tourId).stream()
                .map(this::toResponse)
                .toList();
    }

    private static void enforceAgencyTourApplicantsAccess(TurIzimPrincipal actor, Tour tour) {
        if (actor.getRole() == UserRole.CREATOR) {
            throw new BusinessRuleException(
                    HttpStatus.FORBIDDEN.value(), "Başvuru listesi yalnız acente hesabıyla görüntülenebilir.");
        }
        if (actor.getRole() != UserRole.AGENCY) {
            return;
        }
        if (actor.getAgencyId() == null || !actor.getAgencyId().equals(tour.getAgency().getId())) {
            throw new BusinessRuleException(
                    HttpStatus.FORBIDDEN.value(), "Bu tura ait başvuruları görüntüleme yetkiniz yok.");
        }
    }

    private static void enforceCreatorMatchesBody(TurIzimPrincipal actor, UUID creatorId) {
        if (actor.getRole() != UserRole.CREATOR) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Başvuru yalnız üretici hesabıyla yapılabilir.");
        }
        if (actor.getCreatorProfileId() == null || !actor.getCreatorProfileId().equals(creatorId)) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Başvuru gövdesindeki üretici, oturumla eşleşmiyor.");
        }
    }

    private static void enforceCreatorOwnResource(TurIzimPrincipal actor, UUID creatorId, String message) {
        if (actor.getRole() != UserRole.CREATOR) {
            return;
        }
        if (actor.getCreatorProfileId() == null || !actor.getCreatorProfileId().equals(creatorId)) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), message);
        }
    }

    @Transactional(readOnly = true)
    public TourApplication requireById(UUID id) {
        return tourApplicationRepository
                .findById(id)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Başvuru bulunamadı."));
    }

    private TourApplicationResponse toResponse(TourApplication a) {
        return new TourApplicationResponse(
                a.getId(),
                a.getTour().getId(),
                a.getTour().getTitle(),
                a.getCreator().getId(),
                a.getCreator().getFullName(),
                a.getStatus(),
                a.getSuitabilityScore(),
                a.isAcceptedThirtyDayPublicationCommitment(),
                a.isAcceptedAgencyContentUsageRights(),
                a.isAcceptedEarlyRemovalFullFeeRule(),
                a.getApplicationNote(),
                a.getCreatedAt());
    }
}
