package com.turizim.billing;

import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
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
 * Billing endpoint güvenlik testleri ({@code legacy-open-api=false} modu).
 *
 * <p>Ücretsiz uç (/api/billing/agency/plans) ile korumalı uçların (subscription, checkout,
 * admin/manual-activate) farklı davrandığını doğrular.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
@TestPropertySource(properties = "app.security.legacy-open-api=false")
class BillingSecurityIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    // ─── Herkese açık plan listesi ────────────────────────────────────────

    @Test
    void plans_noToken_returns200() throws Exception {
        mockMvc.perform(get("/api/billing/agency/plans"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].planCode").value("FREE"))
                .andExpect(jsonPath("$[1].planCode").value("AGENCY_PRO"))
                .andExpect(jsonPath("$[2].planCode").value("AGENCY_GROWTH"));
    }

    // ─── Admin manual-activate: public erişim yoktur ─────────────────────

    @Test
    void manualActivate_withoutToken_returns401() throws Exception {
        mockMvc.perform(
                        post("/api/billing/admin/subscriptions/manual-activate")
                                .contentType(APPLICATION_JSON)
                                .content("{\"agencyId\":\"%s\",\"planCode\":\"AGENCY_PRO\"}"
                                        .formatted(UUID.randomUUID())))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void manualActivate_withCreatorToken_returns403() throws Exception {
        // Creator kaydı + giriş
        mockMvc.perform(
                        post("/api/auth/register/creator")
                                .contentType(APPLICATION_JSON)
                                .content(creatorJson("billing-sec-creator@test.local", "Pass123!")))
                .andExpect(status().isOk());

        MvcResult login = mockMvc.perform(
                        post("/api/auth/login")
                                .contentType(APPLICATION_JSON)
                                .content("{\"email\":\"billing-sec-creator@test.local\",\"password\":\"Pass123!\"}"))
                .andExpect(status().isOk())
                .andReturn();

        String token = JsonPath.read(login.getResponse().getContentAsString(), "$.token");

        // Creator manual-activate → 403
        mockMvc.perform(
                        post("/api/billing/admin/subscriptions/manual-activate")
                                .header("Authorization", "Bearer " + token)
                                .contentType(APPLICATION_JSON)
                                .content("{\"agencyId\":\"%s\",\"planCode\":\"AGENCY_PRO\"}"
                                        .formatted(UUID.randomUUID())))
                .andExpect(status().isForbidden());
    }

    // ─── Abonelik ucu: token gerektirir ──────────────────────────────────

    @Test
    void subscription_withoutToken_returns401() throws Exception {
        mockMvc.perform(get("/api/billing/agency/subscription"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void subscription_withCreatorToken_returns403() throws Exception {
        mockMvc.perform(
                        post("/api/auth/register/creator")
                                .contentType(APPLICATION_JSON)
                                .content(creatorJson("billing-sec-sub@test.local", "Pass123!")))
                .andExpect(status().isOk());

        MvcResult login = mockMvc.perform(
                        post("/api/auth/login")
                                .contentType(APPLICATION_JSON)
                                .content("{\"email\":\"billing-sec-sub@test.local\",\"password\":\"Pass123!\"}"))
                .andExpect(status().isOk())
                .andReturn();

        String token = JsonPath.read(login.getResponse().getContentAsString(), "$.token");

        mockMvc.perform(
                        get("/api/billing/agency/subscription")
                                .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    // ─── AI match-score: token gerektirir ────────────────────────────────

    @Test
    void aiMatchScore_withoutToken_returns401() throws Exception {
        mockMvc.perform(
                        post("/api/ai/match-score")
                                .contentType(APPLICATION_JSON)
                                .content("{\"tourId\":\"%s\",\"creatorId\":\"%s\"}"
                                        .formatted(UUID.randomUUID(), UUID.randomUUID())))
                .andExpect(status().isUnauthorized());
    }

    // ─── Yardımcılar ─────────────────────────────────────────────────────

    private static String creatorJson(String email, String password) {
        return """
                {
                  "fullName": "Billing Sec Test",
                  "email": "%s",
                  "password": "%s",
                  "universityName": "Test Üniversitesi",
                  "city": "İstanbul",
                  "passportType": "TURKISH_ORDINARY",
                  "hasValidPassport": true,
                  "hasSchengenVisa": false,
                  "hasUsVisa": false,
                  "hasUkVisa": false,
                  "hasOtherValidVisa": false
                }
                """.formatted(email, password);
    }
}
