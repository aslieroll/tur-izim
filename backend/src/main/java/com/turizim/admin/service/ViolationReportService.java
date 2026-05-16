package com.turizim.admin.service;

import com.turizim.admin.ViolationReport;
import com.turizim.admin.ViolationReportRepository;
import com.turizim.admin.dto.ViolationCreateRequest;
import com.turizim.admin.dto.ViolationReportResponse;
import com.turizim.agency.Agency;
import com.turizim.agency.AgencyRepository;
import com.turizim.assignment.Assignment;
import com.turizim.assignment.AssignmentRepository;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.domain.enums.PublicationStatus;
import com.turizim.domain.enums.UserRole;
import com.turizim.domain.enums.ViolationStatus;
import com.turizim.publication.PublicationProof;
import com.turizim.publication.PublicationProofRepository;
import com.turizim.security.SecurityContextSupport;
import com.turizim.security.TurIzimPrincipal;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class ViolationReportService {

    private final PublicationProofRepository publicationProofRepository;
    private final AgencyRepository agencyRepository;
    private final ViolationReportRepository violationReportRepository;
    private final AssignmentRepository assignmentRepository;

    public ViolationReportService(
            PublicationProofRepository publicationProofRepository,
            AgencyRepository agencyRepository,
            ViolationReportRepository violationReportRepository,
            AssignmentRepository assignmentRepository) {
        this.publicationProofRepository = publicationProofRepository;
        this.agencyRepository = agencyRepository;
        this.violationReportRepository = violationReportRepository;
        this.assignmentRepository = assignmentRepository;
    }

    @Transactional
    public ViolationReportResponse report(UUID proofId, ViolationCreateRequest request) {
        SecurityContextSupport.currentUser()
                .ifPresent(actor -> enforceReportingAgency(actor, request.agencyId()));
        PublicationProof proof = publicationProofRepository
                .findById(proofId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Yayın kanıtı bulunamadı."));
        Assignment assignment = assignmentRepository
                .findDetailById(proof.getAssignment().getId())
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Atama bulunamadı."));
        UUID owningAgencyId = assignment.getTour().getAgency().getId();
        if (!owningAgencyId.equals(request.agencyId())) {
            throw new BusinessRuleException(
                    HttpStatus.FORBIDDEN.value(),
                    "İhlal bildirimi yalnız turu yayımlayan acente adına yapılabilir.");
        }
        Agency agency = agencyRepository
                .findById(request.agencyId())
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.BAD_REQUEST.value(), "Acente bulunamadı."));
        ViolationReport report = new ViolationReport();
        report.setPublicationProof(proof);
        report.setReportedByAgency(agency);
        report.setReason(request.reason().trim());
        report.setStatus(ViolationStatus.OPEN);
        report = violationReportRepository.save(report);
        proof.setStatus(PublicationStatus.VIOLATION_REPORTED);
        return new ViolationReportResponse(
                report.getId(), proof.getId(), agency.getId(), report.getReason(), report.getStatus(), report.getCreatedAt());
    }

    private static void enforceReportingAgency(TurIzimPrincipal actor, UUID agencyIdInBody) {
        if (actor.getRole() != UserRole.AGENCY) {
            throw new BusinessRuleException(HttpStatus.FORBIDDEN.value(), "İhlal bildirimi yalnız acente hesabıyla yapılabilir.");
        }
        if (actor.getAgencyId() == null || !actor.getAgencyId().equals(agencyIdInBody)) {
            throw new BusinessRuleException(
                    HttpStatus.FORBIDDEN.value(), "İstek gövdesindeki acente kimliği oturumla eşleşmiyor.");
        }
    }
}
