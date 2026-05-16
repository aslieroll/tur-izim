package com.turizim.assignment.service;

import com.turizim.application.TourApplication;
import com.turizim.application.TourApplicationRepository;
import com.turizim.assignment.Assignment;
import com.turizim.assignment.AssignmentRepository;
import com.turizim.assignment.dto.AssignmentDetailResponse;
import com.turizim.assignment.dto.MockDepositResponse;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.deposit.MockDeposit;
import com.turizim.deposit.MockDepositRepository;
import com.turizim.domain.enums.ApplicationStatus;
import com.turizim.domain.enums.AssignmentStatus;
import com.turizim.domain.enums.DepositStatus;
import com.turizim.tour.Tour;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AssignmentWorkflowService {

    private final TourApplicationRepository tourApplicationRepository;
    private final AssignmentRepository assignmentRepository;
    private final MockDepositRepository mockDepositRepository;

    public AssignmentWorkflowService(
            TourApplicationRepository tourApplicationRepository,
            AssignmentRepository assignmentRepository,
            MockDepositRepository mockDepositRepository) {
        this.tourApplicationRepository = tourApplicationRepository;
        this.assignmentRepository = assignmentRepository;
        this.mockDepositRepository = mockDepositRepository;
    }

    @Transactional
    public AssignmentDetailResponse selectApplication(UUID applicationId) {
        TourApplication app = tourApplicationRepository
                .findFetchedById(applicationId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Başvuru bulunamadı."));
        if (app.getStatus() != ApplicationStatus.PENDING_REVIEW) {
            throw new BusinessRuleException(
                    HttpStatus.BAD_REQUEST.value(), "Yalnız PENDING_REVIEW başvurular seçilebilir.");
        }
        if (assignmentRepository.findByApplication_Id(app.getId()).isPresent()) {
            throw new BusinessRuleException(HttpStatus.CONFLICT.value(), "Bu başvuru için atama zaten var.");
        }
        Tour tour = app.getTour();
        if (tour.getAvailableCreatorSeats() <= 0) {
            throw new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Turda müsait creator kotası kalmadı.");
        }
        app.setStatus(ApplicationStatus.SELECTED);
        Assignment assignment = new Assignment();
        assignment.setTour(tour);
        assignment.setCreator(app.getCreator());
        assignment.setApplication(app);
        assignment.setStatus(AssignmentStatus.PENDING_CREATOR_CONFIRMATION);
        assignment.setSelectedAt(Instant.now());
        assignment = assignmentRepository.save(assignment);
        MockDeposit deposit = new MockDeposit();
        deposit.setAssignment(assignment);
        deposit.setAmount(tour.getExpectedDepositAmount());
        deposit.setStatus(DepositStatus.PENDING);
        mockDepositRepository.save(deposit);
        tour.setAvailableCreatorSeats(tour.getAvailableCreatorSeats() - 1);
        return toDetail(assignment.getId());
    }

    @Transactional(readOnly = true)
    public AssignmentDetailResponse getDetail(UUID assignmentId) {
        return toDetail(assignmentId);
    }

    @Transactional(readOnly = true)
    public List<AssignmentDetailResponse> listForCreator(UUID creatorId) {
        return assignmentRepository.findDetailByCreatorId(creatorId).stream()
                .map(a -> toDetail(a.getId()))
                .toList();
    }

    @Transactional
    public AssignmentDetailResponse confirmCreator(UUID assignmentId) {
        Assignment assignment = assignmentRepository
                .findDetailById(assignmentId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Atama bulunamadı."));
        if (assignment.getStatus() != AssignmentStatus.PENDING_CREATOR_CONFIRMATION) {
            throw new BusinessRuleException(
                    HttpStatus.BAD_REQUEST.value(), "Atama üretici onayı beklenmiyor.");
        }
        assignment.setStatus(AssignmentStatus.CONFIRMED);
        assignment.setCreatorConfirmedAt(Instant.now());
        MockDeposit deposit = mockDepositRepository
                .findByAssignment_Id(assignment.getId())
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Mock depozito bulunamadı."));
        deposit.setStatus(DepositStatus.HELD);
        deposit.setHeldAt(Instant.now());
        return toDetail(assignmentId);
    }

    public Assignment requireAssignmentEntity(UUID id) {
        return assignmentRepository
                .findById(id)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Atama bulunamadı."));
    }

    @Transactional(readOnly = true)
    public MockDepositResponse getDeposit(UUID assignmentId) {
        if (!assignmentRepository.existsById(assignmentId)) {
            throw new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Atama bulunamadı.");
        }
        MockDeposit d = mockDepositRepository
                .findByAssignment_Id(assignmentId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Mock depozito bulunamadı."));
        return new MockDepositResponse(d.getId(), d.getAmount(), d.getStatus(), d.getHeldAt(), d.getReleasedAt());
    }

    private AssignmentDetailResponse toDetail(UUID assignmentId) {
        Assignment a = assignmentRepository
                .findDetailById(assignmentId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Atama bulunamadı."));
        MockDeposit d = mockDepositRepository
                .findByAssignment_Id(a.getId())
                .orElse(null);
        MockDepositResponse dr = d == null
                ? null
                : new MockDepositResponse(d.getId(), d.getAmount(), d.getStatus(), d.getHeldAt(), d.getReleasedAt());
        return new AssignmentDetailResponse(
                a.getId(),
                a.getTour().getId(),
                a.getTour().getTitle(),
                a.getTour().getAgency().getId(),
                a.getTour().getAgency().getName(),
                a.getCreator().getId(),
                a.getCreator().getFullName(),
                a.getApplication().getId(),
                a.getStatus(),
                a.getSelectedAt(),
                a.getCreatorConfirmedAt(),
                dr);
    }
}
