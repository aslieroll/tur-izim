package com.turizim.application;

import com.turizim.common.domain.BaseEntity;
import com.turizim.creator.CreatorProfile;
import com.turizim.domain.enums.ApplicationStatus;
import com.turizim.tour.Tour;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.math.BigDecimal;

@Entity
@Table(
        name = "tour_applications",
        uniqueConstraints = @UniqueConstraint(columnNames = {"tour_id", "creator_id"}))
public class TourApplication extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tour_id", nullable = false)
    private Tour tour;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "creator_id", nullable = false)
    private CreatorProfile creator;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    private ApplicationStatus status = ApplicationStatus.PENDING_REVIEW;

    @Column(name = "suitability_score", precision = 7, scale = 4)
    private BigDecimal suitabilityScore;

    @Column(name = "accepted_thirty_day_publication_commitment", nullable = false)
    private boolean acceptedThirtyDayPublicationCommitment;

    @Column(name = "accepted_agency_content_usage_rights", nullable = false)
    private boolean acceptedAgencyContentUsageRights;

    @Column(name = "accepted_early_removal_full_fee_rule", nullable = false)
    private boolean acceptedEarlyRemovalFullFeeRule;

    @Column(name = "application_note", columnDefinition = "TEXT")
    private String applicationNote;

    public Tour getTour() {
        return tour;
    }

    public void setTour(Tour tour) {
        this.tour = tour;
    }

    public CreatorProfile getCreator() {
        return creator;
    }

    public void setCreator(CreatorProfile creator) {
        this.creator = creator;
    }

    public ApplicationStatus getStatus() {
        return status;
    }

    public void setStatus(ApplicationStatus status) {
        this.status = status;
    }

    public BigDecimal getSuitabilityScore() {
        return suitabilityScore;
    }

    public void setSuitabilityScore(BigDecimal suitabilityScore) {
        this.suitabilityScore = suitabilityScore;
    }

    public boolean isAcceptedThirtyDayPublicationCommitment() {
        return acceptedThirtyDayPublicationCommitment;
    }

    public void setAcceptedThirtyDayPublicationCommitment(boolean acceptedThirtyDayPublicationCommitment) {
        this.acceptedThirtyDayPublicationCommitment = acceptedThirtyDayPublicationCommitment;
    }

    public boolean isAcceptedAgencyContentUsageRights() {
        return acceptedAgencyContentUsageRights;
    }

    public void setAcceptedAgencyContentUsageRights(boolean acceptedAgencyContentUsageRights) {
        this.acceptedAgencyContentUsageRights = acceptedAgencyContentUsageRights;
    }

    public boolean isAcceptedEarlyRemovalFullFeeRule() {
        return acceptedEarlyRemovalFullFeeRule;
    }

    public void setAcceptedEarlyRemovalFullFeeRule(boolean acceptedEarlyRemovalFullFeeRule) {
        this.acceptedEarlyRemovalFullFeeRule = acceptedEarlyRemovalFullFeeRule;
    }

    public String getApplicationNote() {
        return applicationNote;
    }

    public void setApplicationNote(String applicationNote) {
        this.applicationNote = applicationNote;
    }
}
