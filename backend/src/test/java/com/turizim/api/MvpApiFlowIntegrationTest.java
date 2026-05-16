package com.turizim.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.turizim.agency.Agency;
import com.turizim.agency.AgencyRepository;
import com.turizim.application.TourApplication;
import com.turizim.application.TourApplicationRepository;
import com.turizim.assignment.AssignmentRepository;
import com.turizim.creator.CreatorProfile;
import com.turizim.creator.CreatorProfileRepository;
import com.turizim.deposit.MockDepositRepository;
import com.turizim.domain.enums.AgencyStatus;
import com.turizim.domain.enums.ApplicationStatus;
import com.turizim.domain.enums.AssignmentStatus;
import com.turizim.domain.enums.DepositStatus;
import com.turizim.domain.enums.PassportType;
import com.turizim.domain.enums.TourStatus;
import com.turizim.domain.enums.TourType;
import com.turizim.tour.Tour;
import com.turizim.tour.TourRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

/**
 * Full-stack (H2 + MockMvc) checks for MVP tour/application/assignment rules.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class MvpApiFlowIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private AgencyRepository agencyRepository;

    @Autowired
    private TourRepository tourRepository;

    @Autowired
    private CreatorProfileRepository creatorProfileRepository;

    @Autowired
    private TourApplicationRepository tourApplicationRepository;

    @Autowired
    private AssignmentRepository assignmentRepository;

    @Autowired
    private MockDepositRepository mockDepositRepository;

    @Test
    void listPublishedTours_returnsSeededInTestData() throws Exception {
        Tour tour = persistPublishedDomesticTour("MVP test turu");
        mockMvc
                .perform(get("/api/tours"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.id == '%s')]".formatted(tour.getId())).exists());
    }

    @Test
    void apply_rejectsWhenCheckboxNotAccepted() throws Exception {
        Tour tour = persistPublishedDomesticTour("Kutu testi");
        CreatorProfile creator = persistBasicCreator("Kutu Creator");
        String body = """
                {
                  "creatorId": "%s",
                  "applicationNote": "n",
                  "acceptedThirtyDayPublicationCommitment": false,
                  "acceptedAgencyContentUsageRights": true,
                  "acceptedEarlyRemovalFullFeeRule": true
                }
                """
                .formatted(creator.getId());

        mockMvc
                .perform(post("/api/tours/%s/applications".formatted(tour.getId()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("BUSINESS_RULE"))
                .andExpect(jsonPath("$.message").value(containsString("onay")));
    }

    @Test
    void apply_internationalTourBlocksCreatorWithoutVisa() throws Exception {
        Tour tour = persistInternationalTourRequiringVisa();
        CreatorProfile creator = persistCreatorWithoutVisa("Yurtdışısız");
        String body = applicationJson(creator.getId(), true, true, true);

        mockMvc
                .perform(post("/api/tours/%s/applications".formatted(tour.getId()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("BUSINESS_RULE"))
                .andExpect(jsonPath("$.message").value(containsString("vize")));
    }

    @Test
    void selectApplication_createsAssignmentAndPendingMockDeposit() throws Exception {
        Tour tour = persistPublishedDomesticTour("Seçim turu");
        assertThat(tour.getAvailableCreatorSeats()).isEqualTo(2);
        CreatorProfile creator = persistBasicCreator("Seçilen üretici");
        TourApplication app = new TourApplication();
        app.setTour(tour);
        app.setCreator(creator);
        app.setStatus(ApplicationStatus.PENDING_REVIEW);
        app.setSuitabilityScore(new BigDecimal("50.0000"));
        app.setAcceptedThirtyDayPublicationCommitment(true);
        app.setAcceptedAgencyContentUsageRights(true);
        app.setAcceptedEarlyRemovalFullFeeRule(true);
        app.setApplicationNote("x");
        app = tourApplicationRepository.save(app);

        mockMvc
                .perform(post("/api/applications/%s/select".formatted(app.getId())))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PENDING_CREATOR_CONFIRMATION"));

        assertThat(tourApplicationRepository.findById(app.getId()))
                .isPresent()
                .get()
                .extracting(TourApplication::getStatus)
                .isEqualTo(ApplicationStatus.SELECTED);

        assertThat(assignmentRepository.findByApplication_Id(app.getId()))
                .isPresent()
                .get()
                .satisfies(a -> {
                    assertThat(a.getStatus()).isEqualTo(AssignmentStatus.PENDING_CREATOR_CONFIRMATION);
                    assertThat(mockDepositRepository.findByAssignment_Id(a.getId()))
                            .isPresent()
                            .get()
                            .satisfies(d -> {
                                assertThat(d.getStatus()).isEqualTo(DepositStatus.PENDING);
                                assertThat(d.getAmount()).isEqualByComparingTo(tour.getExpectedDepositAmount());
                            });
                });

        Tour reloaded = tourRepository.findById(tour.getId()).orElseThrow();
        assertThat(reloaded.getAvailableCreatorSeats()).isEqualTo(1);
    }

    private String applicationJson(UUID creatorId, boolean a1, boolean a2, boolean a3) {
        return """
                {
                  "creatorId": "%s",
                  "applicationNote": "note",
                  "acceptedThirtyDayPublicationCommitment": %s,
                  "acceptedAgencyContentUsageRights": %s,
                  "acceptedEarlyRemovalFullFeeRule": %s
                }
                """
                .formatted(creatorId, a1, a2, a3);
    }

    private Agency persistAgency() {
        Agency agency = new Agency();
        agency.setName("Test Acente");
        agency.setContactEmail("agency@test.local");
        agency.setCity("İstanbul");
        agency.setStatus(AgencyStatus.APPROVED);
        return agencyRepository.save(agency);
    }

    private Tour persistPublishedDomesticTour(String title) {
        Agency agency = persistAgency();
        Tour tour = new Tour();
        tour.setAgency(agency);
        tour.setTitle(title);
        tour.setDescription("Açıklama");
        tour.setDepartureCity("İstanbul");
        tour.setDestination("Kapadokya");
        tour.setStartDate(LocalDate.parse("2026-06-01"));
        tour.setEndDate(LocalDate.parse("2026-06-05"));
        tour.setNormalSalePrice(new BigDecimal("15000.00"));
        tour.setExpectedDepositAmount(new BigDecimal("500.00"));
        tour.setTourType(TourType.DOMESTIC);
        tour.setStatus(TourStatus.PUBLISHED);
        tour.setRequiresPassport(false);
        tour.setRequiresVisa(false);
        tour.setCapacity(20);
        tour.setAvailableCreatorSeats(2);
        return tourRepository.save(tour);
    }

    private Tour persistInternationalTourRequiringVisa() {
        Agency agency = persistAgency();
        Tour tour = new Tour();
        tour.setAgency(agency);
        tour.setTitle("Schengen demo");
        tour.setDescription("Yurt dışı demo");
        tour.setDepartureCity("İstanbul");
        tour.setDestination("Barselona");
        tour.setStartDate(LocalDate.parse("2026-07-01"));
        tour.setEndDate(LocalDate.parse("2026-07-08"));
        tour.setNormalSalePrice(new BigDecimal("45000.00"));
        tour.setExpectedDepositAmount(new BigDecimal("1200.00"));
        tour.setTourType(TourType.INTERNATIONAL);
        tour.setStatus(TourStatus.PUBLISHED);
        tour.setRequiresPassport(false);
        tour.setRequiresVisa(true);
        tour.setRequiredVisaDescription("Geçerli Schengen vizesi gerekir.");
        tour.setCapacity(10);
        tour.setAvailableCreatorSeats(3);
        return tourRepository.save(tour);
    }

    private CreatorProfile persistBasicCreator(String name) {
        CreatorProfile c = new CreatorProfile();
        c.setFullName(name);
        c.setEmail(name.replace(' ', '.').toLowerCase() + "@univ.edu.tr");
        c.setUniversityName("Demo Üniversitesi");
        c.setCity("Ankara");
        c.setPassportType(PassportType.TURKISH_ORDINARY);
        c.setHasValidPassport(true);
        c.setHasSchengenVisa(false);
        c.setHasUsVisa(false);
        c.setHasUkVisa(false);
        c.setHasOtherValidVisa(false);
        c.setActive(true);
        return creatorProfileRepository.save(c);
    }

    private CreatorProfile persistCreatorWithoutVisa(String name) {
        CreatorProfile c = persistBasicCreator(name);
        c.setHasValidPassport(false);
        c.setPassportType(PassportType.NONE);
        return creatorProfileRepository.save(c);
    }
}
