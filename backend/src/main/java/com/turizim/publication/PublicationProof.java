package com.turizim.publication;

import com.turizim.assignment.Assignment;
import com.turizim.common.domain.BaseEntity;
import com.turizim.domain.enums.PublicationStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "publication_proofs")
public class PublicationProof extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "assignment_id", nullable = false, unique = true)
    private Assignment assignment;

    @Column(name = "post_url", length = 2048)
    private String postUrl;

    @Column(name = "cloud_content_url", length = 2048)
    private String cloudContentUrl;

    @Column(name = "submitted_at")
    private Instant submittedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 40)
    private PublicationStatus status = PublicationStatus.NOT_SUBMITTED;

    @Column(name = "publication_deadline")
    private Instant publicationDeadline;

    @Column(name = "must_stay_public_until")
    private Instant mustStayPublicUntil;

    public Assignment getAssignment() {
        return assignment;
    }

    public void setAssignment(Assignment assignment) {
        this.assignment = assignment;
    }

    public String getPostUrl() {
        return postUrl;
    }

    public void setPostUrl(String postUrl) {
        this.postUrl = postUrl;
    }

    public String getCloudContentUrl() {
        return cloudContentUrl;
    }

    public void setCloudContentUrl(String cloudContentUrl) {
        this.cloudContentUrl = cloudContentUrl;
    }

    public Instant getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Instant submittedAt) {
        this.submittedAt = submittedAt;
    }

    public PublicationStatus getStatus() {
        return status;
    }

    public void setStatus(PublicationStatus status) {
        this.status = status;
    }

    public Instant getPublicationDeadline() {
        return publicationDeadline;
    }

    public void setPublicationDeadline(Instant publicationDeadline) {
        this.publicationDeadline = publicationDeadline;
    }

    public Instant getMustStayPublicUntil() {
        return mustStayPublicUntil;
    }

    public void setMustStayPublicUntil(Instant mustStayPublicUntil) {
        this.mustStayPublicUntil = mustStayPublicUntil;
    }
}
