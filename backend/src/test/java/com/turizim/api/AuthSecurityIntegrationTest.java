package com.turizim.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import com.turizim.agency.Agency;
import com.turizim.agency.AgencyRepository;
import com.turizim.creator.CreatorProfile;
import com.turizim.creator.CreatorProfileRepository;
import com.turizim.domain.enums.AgencyStatus;
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
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.transaction.annotation.Transactional;

/**
 * JWT + rol kuralları ({@code app.security.legacy-open-api=false}). MVP integration testleri
 * varsayılan olarak legacy modda kalır.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
@TestPropertySource(properties = "app.security.legacy-open-api=false")
class AuthSecurityIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private AgencyRepository agencyRepository;

    @Autowired
    private TourRepository tourRepository;

    @Autowired
    private CreatorProfileRepository creatorProfileRepository;

    @Test
    void registerCreator_returnsToken() throws Exception {
        mockMvc.perform(
                        post("/api/auth/register/creator")
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                {
                                  "fullName": "Auth Test Üretici",
                                  "email": "auth-creator-1@test.local",
                                  "password": "Secretpass1",
                                  "universityName": "Test Üniversitesi",
                                  "city": "İzmir",
                                  "passportType": "TURKISH_ORDINARY",
                                  "hasValidPassport": true,
                                  "hasSchengenVisa": false,
                                  "hasUsVisa": false,
                                  "hasUkVisa": false,
                                  "hasOtherValidVisa": false
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.role").value("CREATOR"));
    }

    @Test
    void registerAgency_defaultPendingApproval() throws Exception {
        mockMvc.perform(
                        post("/api/auth/register/agency")
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                {
                                  "name": "Bekleyen Acente",
                                  "contactEmail": "pending-agency@test.local",
                                  "password": "Secretpass1",
                                  "phone": "+90 216 1112233",
                                  "city": "İstanbul"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.role").value("AGENCY"))
                .andExpect(jsonPath("$.token").isNotEmpty());
        assertThat(agencyRepository.findAll())
                .anyMatch(
                        a -> "pending-agency@test.local".equalsIgnoreCase(a.getContactEmail())
                                && a.getStatus() == AgencyStatus.PENDING_APPROVAL);
    }

    @Test
    void loginSuccess_returnsToken() throws Exception {
        mockMvc.perform(
                        post("/api/auth/register/creator")
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                {
                                  "fullName": "Giriş Test",
                                  "email": "auth-login@test.local",
                                  "password": "CorrectPass1",
                                  "universityName": "Üniversite",
                                  "city": "Ankara",
                                  "passportType": "TURKISH_ORDINARY",
                                  "hasValidPassport": true
                                }
                                """))
                .andExpect(status().isOk());

        mockMvc.perform(
                        post("/api/auth/login")
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                { "email": "auth-login@test.local", "password": "CorrectPass1" }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty());
    }

    @Test
    void loginWrongPassword_returns401() throws Exception {
        mockMvc.perform(
                        post("/api/auth/register/creator")
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                {
                                  "fullName": "Yanlış Şifre Test",
                                  "email": "auth-badpass@test.local",
                                  "password": "RightPass1",
                                  "universityName": "Üniversite",
                                  "city": "Bursa",
                                  "passportType": "TURKISH_ORDINARY",
                                  "hasValidPassport": true
                                }
                                """))
                .andExpect(status().isOk());

        mockMvc.perform(
                        post("/api/auth/login")
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                { "email": "auth-badpass@test.local", "password": "WrongPass9" }
                                """))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void authMe_withoutToken_returns401() throws Exception {
        mockMvc.perform(get("/api/auth/me")).andExpect(status().isUnauthorized());
    }

    @Test
    void protectedApply_withoutToken_returns401() throws Exception {
        Tour tour = persistPublishedDomesticTour();
        CreatorProfile creator = persistBasicCreator();
        mockMvc.perform(
                        post("/api/tours/" + tour.getId() + "/applications")
                                .contentType(APPLICATION_JSON)
                                .content(applicationJson(creator.getId())))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void creatorCannotAccessAgencyTours_returns403() throws Exception {
        mockMvc.perform(
                        post("/api/auth/register/creator")
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                {
                                  "fullName": "Rol Test Üretici",
                                  "email": "auth-role@test.local",
                                  "password": "Secretpass1",
                                  "universityName": "Üniversite",
                                  "city": "Konya",
                                  "passportType": "TURKISH_ORDINARY",
                                  "hasValidPassport": true
                                }
                                """))
                .andExpect(status().isOk());

        MvcResult login = mockMvc.perform(
                        post("/api/auth/login")
                                .contentType(APPLICATION_JSON)
                                .content(
                                        """
                                { "email": "auth-role@test.local", "password": "Secretpass1" }
                                """))
                .andExpect(status().isOk())
                .andReturn();

        String token = JsonPath.read(login.getResponse().getContentAsString(), "$.token");
        Agency other = persistAgency();

        mockMvc.perform(
                        get("/api/agency/" + other.getId() + "/tours")
                                .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    private Agency persistAgency() {
        Agency agency = new Agency();
        agency.setName("Rol Test Acente");
        agency.setContactEmail("role-agency@test.local");
        agency.setCity("İstanbul");
        agency.setStatus(AgencyStatus.APPROVED);
        return agencyRepository.save(agency);
    }

    private Tour persistPublishedDomesticTour() {
        Agency agency = persistAgency();
        Tour tour = new Tour();
        tour.setAgency(agency);
        tour.setTitle("Auth test turu");
        tour.setDescription("—");
        tour.setDepartureCity("İstanbul");
        tour.setDestination("Kapadokya");
        tour.setStartDate(LocalDate.parse("2026-08-01"));
        tour.setEndDate(LocalDate.parse("2026-08-05"));
        tour.setNormalSalePrice(new BigDecimal("12000.00"));
        tour.setExpectedDepositAmount(new BigDecimal("800.00"));
        tour.setTourType(TourType.DOMESTIC);
        tour.setStatus(TourStatus.PUBLISHED);
        tour.setRequiresPassport(false);
        tour.setRequiresVisa(false);
        tour.setCapacity(25);
        tour.setAvailableCreatorSeats(3);
        return tourRepository.save(tour);
    }

    private CreatorProfile persistBasicCreator() {
        CreatorProfile c = new CreatorProfile();
        c.setFullName("Mock Üretici");
        c.setEmail("mock-creator-apply@test.local");
        c.setUniversityName("Üniversite");
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

    private static String applicationJson(UUID creatorId) {
        return """
                {
                  "creatorId": "%s",
                  "applicationNote": null,
                  "acceptedThirtyDayPublicationCommitment": true,
                  "acceptedAgencyContentUsageRights": true,
                  "acceptedEarlyRemovalFullFeeRule": true
                }
                """
                .formatted(creatorId);
    }
}
