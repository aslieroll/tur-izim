package com.turizim.ai.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.turizim.ai.client.OpenRouterClient;
import com.turizim.ai.dto.AiMatchRequest;
import com.turizim.ai.dto.AiMatchResponse;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.creator.CreatorProfile;
import com.turizim.creator.CreatorProfileRepository;
import com.turizim.domain.enums.PassportType;
import com.turizim.domain.enums.RiskLevel;
import com.turizim.domain.enums.TourType;
import com.turizim.tour.Tour;
import com.turizim.tour.TourRepository;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class AiMatchServiceTest {

    private TourRepository tourRepository;
    private CreatorProfileRepository creatorProfileRepository;
    private OpenRouterClient openRouterClient;
    private AiMatchService service;

    private final UUID tourId = UUID.randomUUID();
    private final UUID creatorId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        tourRepository = mock(TourRepository.class);
        creatorProfileRepository = mock(CreatorProfileRepository.class);
        openRouterClient = mock(OpenRouterClient.class);
        service = new AiMatchService(tourRepository, creatorProfileRepository, openRouterClient);
    }

    private Tour domesticTour() {
        Tour tour = new Tour();
        tour.setId(tourId);
        tour.setTitle("Kapadokya Turu");
        tour.setDepartureCity("Adana");
        tour.setDestination("Kapadokya");
        tour.setTourType(TourType.DOMESTIC);
        return tour;
    }

    private CreatorProfile activeCreator() {
        CreatorProfile creator = new CreatorProfile();
        creator.setId(creatorId);
        creator.setFullName("Test Creator");
        creator.setCity("Adana");
        creator.setActive(true);
        return creator;
    }

    @Test
    void domesticTourWithActiveSameCityCreatorScoresFullAndLowRisk() {
        when(tourRepository.findById(tourId)).thenReturn(Optional.of(domesticTour()));
        when(creatorProfileRepository.findById(creatorId)).thenReturn(Optional.of(activeCreator()));
        when(openRouterClient.summarizeMatch(anyString())).thenReturn("Uygun aday.");

        AiMatchResponse response = service.evaluate(new AiMatchRequest(tourId, creatorId));

        // 30 (aktif) + 50 (yurt içi uygunluk) + 20 (şehir uyumu) = 100
        assertThat(response.fitnessScore()).isEqualTo(100);
        assertThat(response.riskLevel()).isEqualTo(RiskLevel.LOW);
        assertThat(response.aiSummary()).isEqualTo("Uygun aday.");
        assertThat(response.fallbackUsed()).isFalse();
    }

    @Test
    void sameInputAlwaysProducesSameScore() {
        Tour tour = domesticTour();
        CreatorProfile creator = activeCreator();
        int first = service.calculateFitnessScore(tour, creator);
        int second = service.calculateFitnessScore(tour, creator);
        assertThat(first).isEqualTo(second);
    }

    @Test
    void internationalTourWithoutPassportScoresLowAndHighRisk() {
        Tour tour = domesticTour();
        tour.setTourType(TourType.INTERNATIONAL);
        tour.setRequiresPassport(true);
        tour.setRequiredPassportType(PassportType.TURKISH_ORDINARY);
        tour.setRequiresVisa(true);
        CreatorProfile creator = activeCreator();
        creator.setCity("Mersin"); // şehir uyumu yok
        creator.setHasValidPassport(false);
        creator.setPassportType(PassportType.NONE); // istenen türü karşılamaz

        int score = service.calculateFitnessScore(tour, creator);

        // Yalnızca aktiflik puanı: 30 → HIGH risk
        assertThat(score).isEqualTo(30);
        assertThat(RiskLevel.fromScore(score)).isEqualTo(RiskLevel.HIGH);
    }

    @Test
    void riskLevelBoundaries() {
        assertThat(RiskLevel.fromScore(75)).isEqualTo(RiskLevel.LOW);
        assertThat(RiskLevel.fromScore(74)).isEqualTo(RiskLevel.MEDIUM);
        assertThat(RiskLevel.fromScore(50)).isEqualTo(RiskLevel.MEDIUM);
        assertThat(RiskLevel.fromScore(49)).isEqualTo(RiskLevel.HIGH);
        assertThat(RiskLevel.fromScore(0)).isEqualTo(RiskLevel.HIGH);
    }

    @Test
    void fallbackSummaryUsedWhenLlmUnavailable() {
        when(tourRepository.findById(tourId)).thenReturn(Optional.of(domesticTour()));
        when(creatorProfileRepository.findById(creatorId)).thenReturn(Optional.of(activeCreator()));
        when(openRouterClient.summarizeMatch(anyString())).thenReturn(null);

        AiMatchResponse response = service.evaluate(new AiMatchRequest(tourId, creatorId));

        assertThat(response.fallbackUsed()).isTrue();
        assertThat(response.aiSummary()).contains("AI açıklaması şu anda kullanılamıyor");
        assertThat(response.fitnessScore()).isEqualTo(100);
    }

    @Test
    void missingTourReturns404() {
        when(tourRepository.findById(tourId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.evaluate(new AiMatchRequest(tourId, creatorId)))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getStatus()).isEqualTo(404));
    }

    @Test
    void missingCreatorReturns404() {
        when(tourRepository.findById(tourId)).thenReturn(Optional.of(domesticTour()));
        when(creatorProfileRepository.findById(creatorId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.evaluate(new AiMatchRequest(tourId, creatorId)))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getStatus()).isEqualTo(404));
    }
}
