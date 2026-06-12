package com.turizim.ai.service;

import com.turizim.ai.client.OpenRouterClient;
import com.turizim.ai.dto.AiMatchRequest;
import com.turizim.ai.dto.AiMatchResponse;
import com.turizim.common.exception.BusinessRuleException;
import com.turizim.creator.CreatorProfile;
import com.turizim.creator.CreatorProfileRepository;
import com.turizim.domain.enums.RiskLevel;
import com.turizim.domain.enums.TourType;
import com.turizim.tour.Tour;
import com.turizim.tour.TourRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * AI Match Assistant: deterministik uygunluk skoru + LLM açıklaması.
 *
 * <p>Skor karar desteğidir; acente seçimi her zaman manueldir. Rastgelelik içermez:
 * aynı tur + creator çifti her zaman aynı skoru üretir.
 */
@Service
public class AiMatchService {

    private final TourRepository tourRepository;
    private final CreatorProfileRepository creatorProfileRepository;
    private final OpenRouterClient openRouterClient;

    public AiMatchService(
            TourRepository tourRepository,
            CreatorProfileRepository creatorProfileRepository,
            OpenRouterClient openRouterClient) {
        this.tourRepository = tourRepository;
        this.creatorProfileRepository = creatorProfileRepository;
        this.openRouterClient = openRouterClient;
    }

    @Transactional(readOnly = true)
    public AiMatchResponse evaluate(AiMatchRequest request) {
        Tour tour = tourRepository
                .findById(request.tourId())
                .orElseThrow(() -> new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "Tur bulunamadı."));
        CreatorProfile creator = creatorProfileRepository
                .findById(request.creatorId())
                .orElseThrow(() ->
                        new BusinessRuleException(HttpStatus.NOT_FOUND.value(), "İçerik üreticisi bulunamadı."));

        int fitnessScore = calculateFitnessScore(tour, creator);
        RiskLevel riskLevel = RiskLevel.fromScore(fitnessScore);

        String aiSummary = openRouterClient.summarizeMatch(buildMatchContext(tour, creator, fitnessScore, riskLevel));
        boolean fallbackUsed = aiSummary == null || aiSummary.isBlank();
        if (fallbackUsed) {
            aiSummary = fallbackSummary(fitnessScore, riskLevel);
        }

        return new AiMatchResponse(
                tour.getId(), creator.getId(), fitnessScore, riskLevel, aiSummary, fallbackUsed);
    }

    /**
     * Deterministik uygunluk skoru (0–100). Mevcut entity alanlarıyla çalışır.
     *
     * <p>TODO: equipment quality, content category ve previous delivery score alanları MVP
     * şemasında yok; eklendiklerinde bu skor formülü genişletilmelidir (yeni DB alanı bu
     * görevde icat edilmez).
     */
    int calculateFitnessScore(Tour tour, CreatorProfile creator) {
        int score = 0;

        // Aktif (doğrulanmış) creator profili: güvenilir teslim profili göstergesi.
        if (creator.isActive()) {
            score += 30;
        }

        if (tour.getTourType() == TourType.INTERNATIONAL) {
            // Yurt dışı tur: pasaport/vize uygunluğu skoru belirler.
            if (creator.isHasValidPassport()) {
                score += 25;
            }
            if (passportRequirementSatisfied(tour, creator)) {
                score += 10;
            }
            if (!tour.isRequiresVisa() || hasAnyValidVisa(creator)) {
                score += 15;
            }
        } else {
            // Yurt içi tur: pasaport/vize engeli yok; uygunluk puanı tam verilir.
            score += 50;
        }

        // Şehir uyumu: creator şehri kalkış şehri ile aynıysa lojistik uyum yüksek.
        if (sameCity(tour.getDepartureCity(), creator.getCity())) {
            score += 20;
        }

        return Math.max(0, Math.min(100, score));
    }

    private static boolean passportRequirementSatisfied(Tour tour, CreatorProfile creator) {
        if (!tour.isRequiresPassport()) {
            return true;
        }
        if (creator.getPassportType() == null) {
            return false;
        }
        // Mevcut domain kuralı: PassportType.satisfiesMinimum tür hiyerarşisini kıyaslar.
        return creator.getPassportType().satisfiesMinimum(tour.getRequiredPassportType());
    }

    private static boolean hasAnyValidVisa(CreatorProfile creator) {
        return creator.isHasSchengenVisa()
                || creator.isHasUsVisa()
                || creator.isHasUkVisa()
                || creator.isHasOtherValidVisa();
    }

    private static boolean sameCity(String tourCity, String creatorCity) {
        if (tourCity == null || creatorCity == null) {
            return false;
        }
        return tourCity.trim().equalsIgnoreCase(creatorCity.trim());
    }

    private static String buildMatchContext(
            Tour tour, CreatorProfile creator, int fitnessScore, RiskLevel riskLevel) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tour: ").append(tour.getTitle());
        sb.append(" | Departure city: ").append(tour.getDepartureCity());
        sb.append(" | Destination: ").append(tour.getDestination());
        sb.append(" | Tour type: ").append(tour.getTourType());
        sb.append(" | Requires passport: ").append(tour.isRequiresPassport());
        sb.append(" | Requires visa: ").append(tour.isRequiresVisa());
        sb.append(" || Creator city: ").append(creator.getCity());
        sb.append(" | Creator active/verified: ").append(creator.isActive());
        sb.append(" | Has valid passport: ").append(creator.isHasValidPassport());
        sb.append(" | Has any valid visa: ").append(hasAnyValidVisa(creator));
        sb.append(" || Deterministic fitness score (0-100): ").append(fitnessScore);
        sb.append(" | Risk level: ").append(riskLevel);
        return sb.toString();
    }

    private static String fallbackSummary(int fitnessScore, RiskLevel riskLevel) {
        String fit = switch (riskLevel) {
            case LOW -> "güçlü bir aday";
            case MEDIUM -> "kısmen uygun bir aday";
            case HIGH -> "düşük uyumlu bir aday";
        };
        return "AI açıklaması şu anda kullanılamıyor. Deterministik skora göre (" + fitnessScore
                + "/100) bu içerik üreticisi tur için " + fit + ".";
    }
}
