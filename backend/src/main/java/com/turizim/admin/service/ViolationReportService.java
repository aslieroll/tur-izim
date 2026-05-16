package com.turizim.admin.service;

import com.turizim.admin.ViolationReport;
import com.turizim.admin.ViolationReportRepository;
import com.turizim.admin.dto.ViolationCreateRequest;
import com.turizim.admin.dto.ViolationReportResponse;
import com.turizim.agency.Agency;
import com.turizim.agency.AgencyRepository;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.domain.enums.PublicationStatus;
import com.turizim.domain.enums.ViolationStatus;
import com.turizim.publication.PublicationProof;
import com.turizim.publication.PublicationProofRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class ViolationReportService {

    private final PublicationProofRepository publicationProofRepository;
    private final AgencyRepository agencyRepository;
    private final ViolationReportRepository violationReportRepository;

    public ViolationReportService(
            PublicationProofRepository publicationProofRepository,
            AgencyRepository agencyRepository,
            ViolationReportRepository violationReportRepository) {
        this.publicationProofRepository = publicationProofRepository;
        this.agencyRepository = agencyRepository;
        this.violationReportRepository = violationReportRepository;
    }

    @Transactional
    public ViolationReportResponse report(UUID proofId, ViolationCreateRequest request) {
        PublicationProof proof = publicationProofRepository
                .findById(proofId)
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Yayın kanıtı bulunamadı."));
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
}
