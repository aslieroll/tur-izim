package com.turizim.assignment;

import com.turizim.application.TourApplication;
import com.turizim.common.domain.BaseEntity;
import com.turizim.creator.CreatorProfile;
import com.turizim.domain.enums.AssignmentStatus;
import com.turizim.tour.Tour;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "assignments")
public class Assignment extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tour_id", nullable = false)
    private Tour tour;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "creator_id", nullable = false)
    private CreatorProfile creator;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "application_id", nullable = false, unique = true)
    private TourApplication application;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 40)
    private AssignmentStatus status = AssignmentStatus.PENDING_CREATOR_CONFIRMATION;

    @Column(name = "selected_at")
    private Instant selectedAt;

    @Column(name = "creator_confirmed_at")
    private Instant creatorConfirmedAt;

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

    public TourApplication getApplication() {
        return application;
    }

    public void setApplication(TourApplication application) {
        this.application = application;
    }

    public AssignmentStatus getStatus() {
        return status;
    }

    public void setStatus(AssignmentStatus status) {
        this.status = status;
    }

    public Instant getSelectedAt() {
        return selectedAt;
    }

    public void setSelectedAt(Instant selectedAt) {
        this.selectedAt = selectedAt;
    }

    public Instant getCreatorConfirmedAt() {
        return creatorConfirmedAt;
    }

    public void setCreatorConfirmedAt(Instant creatorConfirmedAt) {
        this.creatorConfirmedAt = creatorConfirmedAt;
    }
}
