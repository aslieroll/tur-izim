package com.turizim.publication.service;

import com.turizim.assignment.Assignment;
import com.turizim.assignment.AssignmentRepository;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.domain.enums.AssignmentStatus;
import com.turizim.domain.enums.PublicationStatus;
import com.turizim.domain.enums.UserRole;
import com.turizim.security.SecurityContextSupport;
import com.turizim.security.TurIzimPrincipal;
import com.turizim.publication.PublicationProof;
import com.turizim.publication.PublicationProofRepository;
import com.turizim.publication.dto.PublicationProofRequest;
import com.turizim.publication.dto.PublicationProofResponse;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PublicationWorkflowService {

    private final AssignmentRepository assignmentRepository;
    private final PublicationProofRepository publicationProofRepository;

    public PublicationWorkflowService(
            AssignmentRepository assignmentRepository, PublicationProofRepository publicationProofRepository) {
        this.assignmentRepository = assignmentRepository;
        this.publicationProofRepository = publicationProofRepository;
    }

    @Transactional
    public PublicationProofResponse upsert(UUID assignmentId, PublicationProofRequest request) {
        Assignment assignment = assignmentRepository
                .findDetailById(assignmentId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Atama bulunamadı."));
        SecurityContextSupport.currentUser()
                .ifPresent(actor -> enforceCreatorPublisher(actor, assignment));
        if (assignment.getStatus() != AssignmentStatus.CONFIRMED) {
            throw new BusinessRuleException(
                    HttpStatus.BAD_REQUEST.value(), "Yayın kanıtı yalnız onaylanmış atamalarda gönderilir.");
        }
        PublicationProof proof = publicationProofRepository
                .findByAssignment_Id(assignmentId)
                .orElseGet(() -> {
                    PublicationProof p = new PublicationProof();
                    p.setAssignment(assignment);
                    return p;
                });
        proof.setPostUrl(request.postUrl().trim());
        proof.setCloudContentUrl(
                request.cloudContentUrl() == null || request.cloudContentUrl().isBlank()
                        ? null
                        : request.cloudContentUrl().trim());
        Instant now = Instant.now();
        proof.setSubmittedAt(now);
        proof.setStatus(PublicationStatus.SUBMITTED);
        proof.setPublicationDeadline(now.plus(14, ChronoUnit.DAYS));
        proof.setMustStayPublicUntil(now.plus(30, ChronoUnit.DAYS));
        proof = publicationProofRepository.save(proof);
        return toResponse(proof);
    }

    @Transactional(readOnly = true)
    public PublicationProofResponse get(UUID assignmentId) {
        PublicationProof proof = publicationProofRepository
                .findByAssignment_Id(assignmentId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Yayın kanıtı yok."));
        Assignment a = assignmentRepository
                .findDetailById(assignmentId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Atama bulunamadı."));
        SecurityContextSupport.currentUser().ifPresent(actor -> enforcePublicationViewer(actor, a));
        return toResponse(proof);
    }

    private static void enforceCreatorPublisher(TurIzimPrincipal actor, Assignment assignment) {
        if (actor.getRole() != UserRole.CREATOR) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Yayın kanıtı yalnız üretici tarafından gönderilebilir.");
        }
        if (actor.getCreatorProfileId() == null
                || !actor.getCreatorProfileId().equals(assignment.getCreator().getId())) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Bu atama için yayın kanıtı gönderemezsiniz.");
        }
    }

    private void enforcePublicationViewer(TurIzimPrincipal actor, Assignment a) {
        if (actor.getRole() == UserRole.CREATOR) {
            if (actor.getCreatorProfileId() == null
                    || !actor.getCreatorProfileId().equals(a.getCreator().getId())) {
                throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Bu yayın kanıtını görüntüleme yetkiniz yok.");
            }
        } else if (actor.getRole() == UserRole.AGENCY) {
            if (actor.getAgencyId() == null || !actor.getAgencyId().equals(a.getTour().getAgency().getId())) {
                throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "Bu yayın kanıtını görüntüleme yetkiniz yok.");
            }
        }
    }

    private PublicationProofResponse toResponse(PublicationProof p) {
        return new PublicationProofResponse(
                p.getId(),
                p.getAssignment().getId(),
                p.getPostUrl(),
                p.getCloudContentUrl(),
                p.getStatus(),
                p.getSubmittedAt(),
                p.getPublicationDeadline(),
                p.getMustStayPublicUntil());
    }
}
