package com.turizim.config;

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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Yerel geliştirme için örnek veri. Üretimde kapalı; yalnız boş veritabanında çalışır.
 */
@Component
@Order
@Profile("!test")
@ConditionalOnProperty(name = "app.dev-seed", havingValue = "true", matchIfMissing = true)
public class DevDataLoader implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DevDataLoader.class);

    private final AgencyRepository agencyRepository;
    private final CreatorProfileRepository creatorProfileRepository;
    private final TourRepository tourRepository;

    public DevDataLoader(
            AgencyRepository agencyRepository,
            CreatorProfileRepository creatorProfileRepository,
            TourRepository tourRepository) {
        this.agencyRepository = agencyRepository;
        this.creatorProfileRepository = creatorProfileRepository;
        this.tourRepository = tourRepository;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (agencyRepository.count() > 0) {
            return;
        }
        log.warn("DEV DEMO: Veritabanı boş — örnek acente, üretici ve tur kayıtları yükleniyor.");

        Agency agency = new Agency();
        agency.setName("Demo Gezi Acentesi A.Ş. (DEV)");
        agency.setContactEmail("demo-acenta@turizim.local");
        agency.setPhone("+90 322 000 00 00");
        agency.setCity("Adana");
        agency.setStatus(AgencyStatus.APPROVED);
        agency = agencyRepository.save(agency);

        CreatorProfile c1 = new CreatorProfile();
        c1.setFullName("Demo Öğrenci Ayşe (yerel uygun)");
        c1.setEmail("dev-creator-yerel@turizim.local");
        c1.setUniversityName("Çukurova Üniversitesi");
        c1.setCity("Adana");
        c1.setPassportType(PassportType.TURKISH_ORDINARY);
        c1.setHasValidPassport(true);
        c1.setHasSchengenVisa(false);
        c1.setHasUsVisa(false);
        c1.setHasUkVisa(false);
        c1.setHasOtherValidVisa(false);
        c1 = creatorProfileRepository.save(c1);

        CreatorProfile c2 = new CreatorProfile();
        c2.setFullName("Demo Öğrenci Can (Schengen beyanlı)");
        c2.setEmail("dev-creator-schengen@turizim.local");
        c2.setUniversityName("Mersin Üniversitesi");
        c2.setCity("Mersin");
        c2.setPassportType(PassportType.TURKISH_ORDINARY);
        c2.setHasValidPassport(true);
        c2.setHasSchengenVisa(true);
        c2.setHasUsVisa(false);
        c2.setHasUkVisa(false);
        c2.setHasOtherValidVisa(false);
        c2 = creatorProfileRepository.save(c2);

        Tour t1 = buildTour(
                agency,
                "Kapadokya — Ulaşım dahil hafta sonu (DEV)",
                "Örnek yurt içi tur ilanı.",
                "Adana",
                "Nevşehir",
                LocalDate.now().plusWeeks(2),
                LocalDate.now().plusWeeks(2).plusDays(2),
                new BigDecimal("18499.00"),
                new BigDecimal("2200.00"),
                TourType.DOMESTIC,
                false,
                null,
                false,
                null,
                40,
                5);

        Tour t2 = buildTour(
                agency,
                "Akdeniz kıyı rotası (DEV)",
                "Örnek yurt içi ikinci tur.",
                "Mersin",
                "Antalya çevresi",
                LocalDate.now().plusWeeks(4),
                LocalDate.now().plusWeeks(4).plusDays(3),
                new BigDecimal("12499.00"),
                new BigDecimal("1800.00"),
                TourType.DOMESTIC,
                false,
                null,
                false,
                null,
                32,
                4);

        Tour t3 = buildTour(
                agency,
                "Selanik çıkışlı tur — yurt dışı örnek (DEV)",
                "Örnek yurt dışı tur; pasaport ve Schengen vizesi beyanı şart.",
                "İstanbul",
                "Selanik",
                LocalDate.now().plusMonths(1),
                LocalDate.now().plusMonths(1).plusDays(4),
                new BigDecimal("38999.00"),
                new BigDecimal("4800.00"),
                TourType.INTERNATIONAL,
                true,
                PassportType.TURKISH_ORDINARY,
                true,
                "Geçerli Schengen vizesi veya eşdeğeri beyanı (MVP manuel doğrulama).",
                28,
                3);

        tourRepository.save(t1);
        tourRepository.save(t2);
        tourRepository.save(t3);

        log.warn("DEV DEMO yükleme tamam — acenteId={} creatorId1={} creatorId2={}", agency.getId(), c1.getId(), c2.getId());
    }

    private static Tour buildTour(
            Agency agency,
            String title,
            String description,
            String departure,
            String destination,
            LocalDate start,
            LocalDate end,
            BigDecimal price,
            BigDecimal deposit,
            TourType type,
            boolean reqPass,
            PassportType reqPassType,
            boolean reqVisa,
            String visaDesc,
            int cap,
            int seats) {
        Tour t = new Tour();
        t.setAgency(agency);
        t.setTitle(title);
        t.setDescription(description);
        t.setDepartureCity(departure);
        t.setDestination(destination);
        t.setStartDate(start);
        t.setEndDate(end);
        t.setNormalSalePrice(price);
        t.setExpectedDepositAmount(deposit);
        t.setTourType(type);
        t.setStatus(TourStatus.PUBLISHED);
        t.setRequiresPassport(reqPass);
        t.setRequiredPassportType(reqPassType);
        t.setRequiresVisa(reqVisa);
        t.setRequiredVisaDescription(visaDesc);
        t.setCapacity(cap);
        t.setAvailableCreatorSeats(seats);
        return t;
    }
}
