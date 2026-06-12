# İlerleme durumu

Bu dosya **ürün / mühendislik ilerlemesinin** kısa özetidir. Tarihçe için commit mesajları ve iş kayıtları tam kaynak olabilir.

**Son güncelleme:** 2026-06-12 (Final teslim depo yapısı hazırlandı; dokümantasyon tamamlandı)

---

## 2026-06-12 — Final Teslim Depo Yapısı

- Depo yapısı final teslim için hazırlandı: `/frontend`, `/backend`, `/prodocs`, `.gitignore`, `README.md`, `.env.example` doğrulandı.
- `README.md` yeniden yazıldı (çözümsüz git merge conflict giderildi); proje tanımı, kurulum adımları, ortam değişkenleri ve dağıtım notları eklendi.
- `.gitignore` genişletildi: `target/`, `build/`, `.dart_tool/`, `.idea/`, `.vscode/`, `node_modules/`, `.DS_Store`, `*.env` eklendi.
- `.env.example` güncellendi: `DATABASE_URL`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `OPENROUTER_API_KEY`, `OPENROUTER_MODEL`, `FRONTEND_API_BASE_URL`, `JWT_SECRET` şablonları eklendi.
- `prodocs/PRD.md` başlık metadata bloğu güncellendi (versiyon, marka adı, tarih).
- `prodocs/tech-stack.md` yeniden yazıldı: AI servisi (OpenRouter) bölümü, teknoloji seçim gerekçeleri ve "AI kullanımı" bölümleri eklendi.
- `prodocs/Plan.md` yeniden yazıldı: kullanıcı hikayeleri ve teknik görevler Faz 0–3 dilimlerine ayrıldı; kapsam dışı liste güncellendi.
- `prodocs/DesignSystem.md` güncellendi: "0. Marka Kimliği" bölümü eklendi; HEX renk değerleri (Royal Indigo, Deep Navy, Soft Coral, vb.) ve tipografi tablosu tanımlandı.
- MVP kapsam kilidi onaylandı; aşağıdaki özellikler açıkça reddedildi:
  - Sosyal medya feed'i
  - Uygulama içi chat / mesajlaşma
  - Otel rezervasyonu
  - Uçak bileti rezervasyonu
  - Gerçek ödeme entegrasyonu
  - Otomatik creator eşleştirmesi
  - Video upload / streaming
  - Otomatik sosyal medya izleme

---

## Tamamlanan / istikrarlı

| Alan | Not |
|------|-----|
| Ürün dokümantasyonu | `prodocs/` altında PRD, iş kuralları, akışlar, şema, API taslağı, AUE, tasarım sistemi bileşenleri |
| Flutter | Shell; `flutter analyze` / `test`; router–session–repository arayüz slice (Aşama 2.1) |
| Flutter ↔ API (Aşama 1) | `core/api` (`HttpTurIzimApiClient`, isteğe bağlı **`Authorization: Bearer`**, `ApiConfig` `API_BASE_URL` dart-define, `ApiException`); `ApiTour` / `ApiApplications` / `ApiAssignments` / `ApiPublications` / `ApiCreatorDashboard` / **`ApiAgencyDashboardRepository`** (`GET /api/agency/{agencyId}/tours`, tur başına `GET /api/agency/tours/{tourId}/applications` ile bekleyen başvuru sayımı); **mock repository’ler duruyor**; bağlantı / ağ / 5xx’te otomatik mock’a düşen sarmalayıcılar; **acente operasyon özeti** hata + «Yeniden dene»; **Kimlik (birincil):** `SharedPreferences` JWT + `/api/auth/me` ile oturum; **kimlik önceliği:** `DEMO_*` dart-define → **JWT** `creatorProfileId` / `agencyId` → karşılama **demo** akışında `primeDemoIdentityFromApi` → mock sabitler; demo rol düğmeleri JWT’yi temizler (legacy API uyumu); backend `TourSummaryResponse` **agencyId + agencyName** içerir; yerel tam akış için **Spring Boot `http://localhost:8080`** (seed’li Postgres); `go_router` depozito / yayın / **login & register** rotaları |
| Flutter auth UI | `/login`, `/register/creator`, `/register/agency`; karşılamada metin bağlantıları; acente kaydında **onay bekliyor** snackbar (PENDING_APPROVAL); uygulama açılışında kısa yükleme → JWT doğrulama |
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
| Admin / üretim kimlik | Admin için yerel **demo girişi** (JWT’siz) hâlâ mümkün; gerçek `ADMIN` JWT için backend’de kullanıcı tanımı gerekir |
| Ödeme | **Yalnız mock depozito**; gerçek tahsilat entegrasyonu yok |
| Flutter ↔ API | `legacy-open-api=false` iken korumalı uçlara **Bearer zorunlu** (oturum açıkça taşınır); admin ekranı / bazı veriler mock’ta kalabilir |

## Son kararlar

- Ürün ve teknik **kaynak gerçeği** `prodocs/` klasöründedir; teslim dosya adları: `PRD.md`, `DesignSystem.md`, `tech-stack.md`, `Plan.md`, `Progress.md`.
- `Match` dili kullanılmaz; **Assignment** kullanılır.
- **Otomatik eşleştirme / otomatik atama yok**; acenta başvuruyu manuel seçer.
- Kimlik: **JWT** ile `CREATOR` / `AGENCY` / `ADMIN` rolleri; üretici ve acente kayıtları e-posta+şifre; acente kaydı varsayılan **PENDING_APPROVAL**; yerel **`APP_LEGACY_OPEN_API`** / `app.security.legacy-open-api` ile geçiş modu.

## Nasıl güncellenir?

Önemli kilometre taşları eklendiğinde bu dosyaya kısa bir not ekleyin.
