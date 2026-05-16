package com.turizim.domain;

import static org.assertj.core.api.Assertions.assertThat;

import com.turizim.admin.ViolationReport;
import com.turizim.admin.ViolationReportRepository;
import com.turizim.agency.Agency;
import com.turizim.agency.AgencyRepository;
import com.turizim.application.TourApplication;
import com.turizim.application.TourApplicationRepository;
import com.turizim.assignment.Assignment;
import com.turizim.assignment.AssignmentRepository;
import com.turizim.creator.CreatorProfile;
import com.turizim.creator.CreatorProfileRepository;
import com.turizim.deposit.MockDeposit;
import com.turizim.deposit.MockDepositRepository;
import com.turizim.domain.enums.AgencyStatus;
import com.turizim.domain.enums.ApplicationStatus;
import com.turizim.domain.enums.AssignmentStatus;
import com.turizim.domain.enums.DepositStatus;
import com.turizim.domain.enums.PassportType;
import com.turizim.domain.enums.PublicationStatus;
import com.turizim.domain.enums.TourStatus;
import com.turizim.domain.enums.TourType;
import com.turizim.domain.enums.ViolationStatus;
import com.turizim.publication.PublicationProof;
import com.turizim.publication.PublicationProofRepository;
import com.turizim.tour.Tour;
import com.turizim.tour.TourRepository;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

@DataJpaTest
@ActiveProfiles("test")
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class DomainPersistenceTest {

    @Autowired
    private AgencyRepository agencyRepository;
    @Autowired
    private CreatorProfileRepository creatorProfileRepository;
    @Autowired
    private TourRepository tourRepository;
    @Autowired
    private TourApplicationRepository tourApplicationRepository;
    @Autowired
    private AssignmentRepository assignmentRepository;
    @Autowired
    private MockDepositRepository mockDepositRepository;
    @Autowired
    private PublicationProofRepository publicationProofRepository;
    @Autowired
    private ViolationReportRepository violationReportRepository;

    @Test
    @Transactional
    void persistsCoreGraphAndReadsBackRelations() {
        Agency agency = new Agency();
        agency.setName("Test Acente");
        agency.setContactEmail("acenta@test.local");
        agency.setPhone("+90 555 000 0000");
        agency.setCity("Adana");
        agency.setStatus(AgencyStatus.APPROVED);
        agency = agencyRepository.saveAndFlush(agency);

        CreatorProfile creator = new CreatorProfile();
        creator.setFullName("Test Öğrenci");
        creator.setEmail("ogrenci@test.local");
        creator.setUniversityName("Örnek Üniversite");
        creator.setCity("Mersin");
        creator.setPassportType(PassportType.TURKISH_ORDINARY);
        creator.setHasValidPassport(true);
        creator = creatorProfileRepository.saveAndFlush(creator);

        Tour tour = new Tour();
        tour.setAgency(agency);
        tour.setTitle("Kapadokya");
        tour.setDescription("Test turu");
        tour.setDepartureCity("Adana");
        tour.setDestination("Nevşehir");
        tour.setStartDate(LocalDate.of(2026, 6, 1));
        tour.setEndDate(LocalDate.of(2026, 6, 4));
        tour.setNormalSalePrice(new BigDecimal("24999.00"));
        tour.setExpectedDepositAmount(new BigDecimal("2500.00"));
        tour.setTourType(TourType.DOMESTIC);
        tour.setStatus(TourStatus.PUBLISHED);
        tour.setRequiresPassport(false);
        tour.setRequiresVisa(false);
        tour.setCapacity(40);
        tour.setAvailableCreatorSeats(3);
        tour = tourRepository.saveAndFlush(tour);

        TourApplication application = new TourApplication();
        application.setTour(tour);
        application.setCreator(creator);
        application.setStatus(ApplicationStatus.PENDING_REVIEW);
        application.setSuitabilityScore(new BigDecimal("87.5000"));
        application.setAcceptedThirtyDayPublicationCommitment(true);
        application.setAcceptedAgencyContentUsageRights(true);
        application.setAcceptedEarlyRemovalFullFeeRule(true);
        application = tourApplicationRepository.saveAndFlush(application);

        Assignment assignment = new Assignment();
        assignment.setTour(tour);
        assignment.setCreator(creator);
        assignment.setApplication(application);
        assignment.setStatus(AssignmentStatus.PENDING_CREATOR_CONFIRMATION);
        assignment.setSelectedAt(Instant.now());
        assignment = assignmentRepository.saveAndFlush(assignment);

        MockDeposit deposit = new MockDeposit();
        deposit.setAssignment(assignment);
        deposit.setAmount(new BigDecimal("2500.00"));
        deposit.setStatus(DepositStatus.PENDING);
        deposit = mockDepositRepository.saveAndFlush(deposit);

        PublicationProof proof = new PublicationProof();
        proof.setAssignment(assignment);
        proof.setStatus(PublicationStatus.NOT_SUBMITTED);
        proof.setPublicationDeadline(Instant.now().plus(14, ChronoUnit.DAYS));
        proof = publicationProofRepository.saveAndFlush(proof);

        ViolationReport report = new ViolationReport();
        report.setPublicationProof(proof);
        report.setReportedByAgency(agency);
        report.setReason("Yayın erken kaldırıldı (test)");
        report.setStatus(ViolationStatus.OPEN);
        violationReportRepository.saveAndFlush(report);

        Assignment loaded = assignmentRepository.findById(assignment.getId()).orElseThrow();
        assertThat(loaded.getTour().getId()).isEqualTo(tour.getId());
        assertThat(loaded.getApplication().getId()).isEqualTo(application.getId());
        assertThat(mockDepositRepository.findAll()).hasSize(1);
        assertThat(publicationProofRepository.findAll()).hasSize(1);
        assertThat(violationReportRepository.findAll()).hasSize(1);
    }
}
