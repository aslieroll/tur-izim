package com.turizim.tour;

import com.turizim.agency.Agency;
import com.turizim.common.domain.BaseEntity;
import com.turizim.domain.enums.PassportType;
import com.turizim.domain.enums.TourStatus;
import com.turizim.domain.enums.TourType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "tours")
public class Tour extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "agency_id", nullable = false)
    private Agency agency;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "departure_city", nullable = false)
    private String departureCity;

    @Column(name = "destination", nullable = false)
    private String destination;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Column(name = "normal_sale_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal normalSalePrice;

    @Column(name = "expected_deposit_amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal expectedDepositAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "tour_type", nullable = false, length = 32)
    private TourType tourType = TourType.DOMESTIC;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    private TourStatus status = TourStatus.DRAFT;

    @Column(name = "requires_passport", nullable = false)
    private boolean requiresPassport;

    @Enumerated(EnumType.STRING)
    @Column(name = "required_passport_type", length = 40)
    private PassportType requiredPassportType;

    @Column(name = "requires_visa", nullable = false)
    private boolean requiresVisa;

    @Column(name = "required_visa_description", columnDefinition = "TEXT")
    private String requiredVisaDescription;

    @Column(name = "capacity", nullable = false)
    private int capacity;

    @Column(name = "available_creator_seats", nullable = false)
    private int availableCreatorSeats;

    public Agency getAgency() {
        return agency;
    }

    public void setAgency(Agency agency) {
        this.agency = agency;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDepartureCity() {
        return departureCity;
    }

    public void setDepartureCity(String departureCity) {
        this.departureCity = departureCity;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public BigDecimal getNormalSalePrice() {
        return normalSalePrice;
    }

    public void setNormalSalePrice(BigDecimal normalSalePrice) {
        this.normalSalePrice = normalSalePrice;
    }

    public BigDecimal getExpectedDepositAmount() {
        return expectedDepositAmount;
    }

    public void setExpectedDepositAmount(BigDecimal expectedDepositAmount) {
        this.expectedDepositAmount = expectedDepositAmount;
    }

    public TourType getTourType() {
        return tourType;
    }

    public void setTourType(TourType tourType) {
        this.tourType = tourType;
    }

    public TourStatus getStatus() {
        return status;
    }

    public void setStatus(TourStatus status) {
        this.status = status;
    }

    public boolean isRequiresPassport() {
        return requiresPassport;
    }

    public void setRequiresPassport(boolean requiresPassport) {
        this.requiresPassport = requiresPassport;
    }

    public PassportType getRequiredPassportType() {
        return requiredPassportType;
    }

    public void setRequiredPassportType(PassportType requiredPassportType) {
        this.requiredPassportType = requiredPassportType;
    }

    public boolean isRequiresVisa() {
        return requiresVisa;
    }

    public void setRequiresVisa(boolean requiresVisa) {
        this.requiresVisa = requiresVisa;
    }

    public String getRequiredVisaDescription() {
        return requiredVisaDescription;
    }

    public void setRequiredVisaDescription(String requiredVisaDescription) {
        this.requiredVisaDescription = requiredVisaDescription;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public int getAvailableCreatorSeats() {
        return availableCreatorSeats;
    }

    public void setAvailableCreatorSeats(int availableCreatorSeats) {
        this.availableCreatorSeats = availableCreatorSeats;
    }
}
