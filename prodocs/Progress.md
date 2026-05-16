# İlerleme durumu

Bu dosya **ürün / mühendislik ilerlemesinin** kısa özetidir. Tarihçe için commit mesajları ve iş kayıtları tam kaynak olabilir.

**Son güncelleme:** 2026-05-16 (Backend JWT / rol tabanlı güvenlik; `app.security.legacy-open-api` ile Flutter uyumu)

---

## Tamamlanan / istikrarlı

| Alan | Not |
|------|-----|
| Ürün dokümantasyonu | `prodocs/` altında PRD, iş kuralları, akışlar, şema, API taslağı, AUE, tasarım sistemi bileşenleri |
| Flutter | Shell; `flutter analyze` / `test`; router–session–repository arayüz slice (Aşama 2.1) |
| Flutter ↔ API (Aşama 1) | `core/api` (`HttpTurIzimApiClient`, `ApiConfig` `API_BASE_URL` dart-define, `ApiException`); `ApiTour` / `ApiApplications` / `ApiAssignments` / `ApiPublications` / `ApiCreatorDashboard` / **`ApiAgencyDashboardRepository`** (`GET /api/agency/{agencyId}/tours`, tur başına `GET /api/agency/tours/{tourId}/applications` ile bekleyen başvuru sayımı); **mock repository’ler duruyor**; bağlantı / ağ / 5xx’te otomatik mock’a düşen sarmalayıcılar; **acente operasyon özeti** hata + «Yeniden dene»; demo kimlik sırası: dart-define `DEMO_AGENCY_ID` / `DEMO_CREATOR_ID` → karşılama sonrası API’den ilk tur + ilk creator → mock sabitler; backend `TourSummaryResponse` **agencyId + agencyName** içerir; yerel tam akış için **Spring Boot `http://localhost:8080`** (seed’li Postgres); `go_router`’a depozito / yayın bildirimi rotaları eklendi |
| Backend temel | Spring Boot; `GET /api/health`; PostgreSQL ortam değişkenleri; Maven Wrapper |
| Backend domain | Ortak `BaseEntity`; enum’lar; **`UserAccount`** (BCrypt şifre özeti, rol, `CreatorProfile` / `Agency` üzerinde `user_account_id`); diğer varlıklar: `Agency`, `CreatorProfile`, `Tour`, `TourApplication`, `Assignment`, `MockDeposit`, `PublicationProof`, `ViolationReport` |
| Backend MVP API | Açık: `GET /api/health`, `POST /api/auth/register|login`, yayımlı `GET /api/tours` (+ detay), `GET /api/creators` listesi/profil; korumalı: başvuru/atama/acenta portalı/ihlal uçları — JWT + rol; **`app.security.legacy-open-api=true`** (varsayılan) ile mevcut Flutter demo token gerektirmez; `false` iken `Authorization: Bearer` gerekir; CORS; iş kuralı hataları `GlobalExceptionHandler` |
| Yerel ortam seed | `app.dev-seed` (varsayılan açık): boş DB’de demo acente (onaylı) + 2 creator + 3 tur; bağlı `UserAccount` ve yerel şifre **`Demo123!`** (log’da); **test profilinde seed kapalı** |
| Yerel veritabanı | Kök `docker-compose.yml` ile PostgreSQL 16 servisi |
| Backend testler | Context load; health; JPA; persistence; MVP MockMvc akışı; **`AuthSecurityIntegrationTest`** (`legacy-open-api=false`: kayıt, giriş, 401/403) |

## Devam eden veya sıradaki (MVP’ye göre)

| Alan | Not |
|------|-----|
| Backend veri şeması | Flyway/Liquibase migrasyonları; üretim `ddl-auto` yerine sürümlü şema |
| Kimlik doğrulama | Backend **JWT + BCrypt** tamam; Flutter’da kalıcı token/login UI henüz tam entegre değil (TODO) |
| Ödeme | **Yalnız mock depozito**; gerçek tahsilat entegrasyonu yok |
| Flutter ↔ API | JWT header ile korumalı mod; `legacy-open-api` kapatılınca token zorunlu; admin/diğer mock alanlar kademeli |

## Son kararlar

- Ürün ve teknik **kaynak gerçeği** `prodocs/` klasöründedir; teslim dosya adları: `PRD.md`, `DesignSystem.md`, `tech-stack.md`, `Plan.md`, `Progress.md`.
- `Match` dili kullanılmaz; **Assignment** kullanılır.
- **Otomatik eşleştirme / otomatik atama yok**; acenta başvuruyu manuel seçer.
- Kimlik: **JWT** ile `CREATOR` / `AGENCY` / `ADMIN` rolleri; üretici ve acente kayıtları e-posta+şifre; acente kaydı varsayılan **PENDING_APPROVAL**; yerel **`APP_LEGACY_OPEN_API`** / `app.security.legacy-open-api` ile geçiş modu.

## Nasıl güncellenir?

Önemli kilometre taşları eklendiğinde bu dosyaya kısa bir not ekleyin.
