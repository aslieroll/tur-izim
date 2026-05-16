package com.turizim.admin;

import com.turizim.agency.Agency;
import com.turizim.common.domain.BaseEntity;
import com.turizim.domain.enums.ViolationStatus;
import com.turizim.publication.PublicationProof;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "violation_reports")
public class ViolationReport extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "publication_proof_id", nullable = false)
    private PublicationProof publicationProof;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "reported_by_agency_id", nullable = false)
    private Agency reportedByAgency;

    @Column(name = "reason", nullable = false, columnDefinition = "TEXT")
    private String reason;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    private ViolationStatus status = ViolationStatus.OPEN;

    @Column(name = "admin_note", columnDefinition = "TEXT")
    private String adminNote;

    @Column(name = "resolved_at")
    private Instant resolvedAt;

    public PublicationProof getPublicationProof() {
        return publicationProof;
    }

    public void setPublicationProof(PublicationProof publicationProof) {
        this.publicationProof = publicationProof;
    }

    public Agency getReportedByAgency() {
        return reportedByAgency;
    }

    public void setReportedByAgency(Agency reportedByAgency) {
        this.reportedByAgency = reportedByAgency;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public ViolationStatus getStatus() {
        return status;
    }

    public void setStatus(ViolationStatus status) {
        this.status = status;
    }

    public String getAdminNote() {
        return adminNote;
    }

    public void setAdminNote(String adminNote) {
        this.adminNote = adminNote;
    }

    public Instant getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Instant resolvedAt) {
        this.resolvedAt = resolvedAt;
    }
}
