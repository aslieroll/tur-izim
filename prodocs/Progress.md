# İlerleme durumu

Bu dosya **ürün / mühendislik ilerlemesinin** kısa özetidir. Tarihçe için commit mesajları ve iş kayıtları tam kaynak olabilir.

**Son güncelleme:** 2026-05-16 (Acente operasyon özeti ↔ `GET /api/agency/{id}/tours`, demo agencyId tek kaynak)

---

## Tamamlanan / istikrarlı

| Alan | Not |
|------|-----|
| Ürün dokümantasyonu | `prodocs/` altında PRD, iş kuralları, akışlar, şema, API taslağı, AUE, tasarım sistemi bileşenleri |
| Flutter | Shell; `flutter analyze` / `test`; router–session–repository arayüz slice (Aşama 2.1) |
| Flutter ↔ API (Aşama 1) | `core/api` (`HttpTurIzimApiClient`, `ApiConfig` `API_BASE_URL` dart-define, `ApiException`); `ApiTour` / `ApiApplications` / `ApiAssignments` / `ApiPublications` / `ApiCreatorDashboard` / **`ApiAgencyDashboardRepository`** (`GET /api/agency/{agencyId}/tours`, tur başına `GET /api/agency/tours/{tourId}/applications` ile bekleyen başvuru sayımı); **mock repository’ler duruyor**; bağlantı / ağ / 5xx’te otomatik mock’a düşen sarmalayıcılar; **acente operasyon özeti** hata + «Yeniden dene»; demo kimlik sırası: dart-define `DEMO_AGENCY_ID` / `DEMO_CREATOR_ID` → karşılama sonrası API’den ilk tur + ilk creator → mock sabitler; backend `TourSummaryResponse` **agencyId + agencyName** içerir; yerel tam akış için **Spring Boot `http://localhost:8080`** (seed’li Postgres); `go_router`’a depozito / yayın bildirimi rotaları eklendi |
| Backend temel | Spring Boot; `GET /api/health`; PostgreSQL ortam değişkenleri; Maven Wrapper |
| Backend domain | Ortak `BaseEntity`; enum’lar; `Agency`, `CreatorProfile`, `Tour`, `TourApplication`, `Assignment`, `MockDeposit`, `PublicationProof`, `ViolationReport` JPA + Spring Data |
| Backend MVP API | Tur listesi/detay; acente tur oluşturma ve acente turları; creator listesi/profil; başvuru (3 onay kutusu, yurt dışı uygunluk, AUE skoru); başvuru seçimi → Assignment + **mock** MockDeposit; üretici onayı; depozito ve yayın kanıtı uçları; ihlal bildirimi MVP; DTO + servis + ince controller; CORS (yerel Flutter/web); `GlobalExceptionHandler` + iş kuralı doğrulamaları |
| Yerel ortam seed | `app.dev-seed` (varsayılan açık): veritabanı boşsa demo acente, 2 creator, 3 tur (iç/dış karışık); **test profilinde seed kapalı** |
| Yerel veritabanı | Kök `docker-compose.yml` ile PostgreSQL 16 servisi |
| Backend testler | Context load; health; JPA repository kaydı; persistence smoke; MockMvc ile tur listesi, başvuru onay kutusu, yurt dışı blok, seçim → atama + mock depozito |

## Devam eden veya sıradaki (MVP’ye göre)

| Alan | Not |
|------|-----|
| Backend veri şeması | Flyway/Liquibase migrasyonları; üretim `ddl-auto` yerine sürümlü şema |
| Kimlik doğrulama | **Bu aşamada yok**; JWT/oturum sonraki dilim |
| Ödeme | **Yalnız mock depozito**; gerçek tahsilat entegrasyonu yok |
| Flutter ↔ API | Kalan mocklar: admin/acenta dashboard özeti, deliveries, violations, bazı çoklu-acente uçları; JWT auth; üretim base URL politikası |

## Son kararlar

- Ürün ve teknik **kaynak gerçeği** `prodocs/` klasöründedir; teslim dosya adları: `PRD.md`, `DesignSystem.md`, `tech-stack.md`, `Plan.md`, `Progress.md`.
- `Match` dili kullanılmaz; **Assignment** kullanılır.
- **Otomatik eşleştirme / otomatik atama yok**; acenta başvuruyu manuel seçer.
- Bu backend diliminde **kimlik doğrulama yok** (ör. `agencyId` / `creatorId` gövde veya path ile MVP).

## Nasıl güncellenir?

Önemli kilometre taşları eklendiğinde bu dosyaya kısa bir not ekleyin.
