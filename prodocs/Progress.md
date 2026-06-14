# İlerleme durumu

Bu dosya **ürün / mühendislik ilerlemesinin** kısa özetidir. Tarihçe için commit mesajları ve iş kayıtları tam kaynak olabilir.

**Son güncelleme:** 2026-06-12 (Canlı dağıtım hazırlığı tamamlandı: Railway + Vercel yapılandırması)

---

## 2026-06-14 — Initial Admin Bootstrap

- **`AdminBootstrapService` eklendi:** `APP_ADMIN_BOOTSTRAP_ENABLED=true` + `APP_ADMIN_EMAIL` + `APP_ADMIN_PASSWORD` ile startup'ta tek ADMIN oluşturur; şifre BCrypt hash; şifre loglanmaz.
- **`InitialAdminBootstrap` (`ApplicationRunner`):** `@Profile("!test")`, `@Order(0)`; genel kayıt API'si yok.
- **`UserAccountRepository.existsByRole(ADMIN)`** sorgusu eklendi; çift admin ve mevcut e-posta üzerine yazma engellendi.
- **Üretim blocker çözüldü:** `POST /api/billing/admin/subscriptions/manual-activate` artık bootstrap ile oluşturulan ADMIN JWT ile çalıştırılabilir.
- **Testler:** `AdminBootstrapServiceTest` — disabled, create one, no duplicate, missing config, encoded password (7 test).
- **Dokümantasyon:** `.env.example`, `README.md` (Initial Admin Bootstrap bölümü), bu giriş.

---

## 2026-06-14 — Üretim Güvenlik ve Dağıtım Denetimi

- **Üretim güvenlik denetimi tamamlandı.**
- **`APP_LEGACY_OPEN_API=false` dağıtım için zorunlu** — bu mod aktifken billing/agency/admin uçları rol bazlı korunur (plans → public, subscription → AGENCY/ADMIN, checkout → AGENCY, admin/** → ADMIN).
- **Abonelik kapısı doğrulandı:** `/api/ai/match-score`, `/api/agency/tours/{id}/applications`, `/api/applications/{id}/select` aktif ücretli plan ister; FREE/PENDING/PAST_DUE/CANCELED → HTTP 402; ACTIVE Pro/Growth açar. (`AgencySubscriptionServiceTest` + `BillingSecurityIntegrationTest`)
- **Plan limitleri doğrulandı:** FREE 1, Pro 5, Growth 20 — `TourService.create()` içinde kota uygulanır.
- **Ödeme linkleri doğrulandı:** yalnızca backend env (`AGENCY_PRO_PAYMENT_LINK`, `AGENCY_GROWTH_PAYMENT_LINK`); frontend build'e ham link gömülmez; eksik link → 422; uygulama kart verisi saklamaz.
- **Eski `AGENCY_PAYMENT_LINK` referansları temizlendi** (README env tabloları + güvenlik notları). `prodocs/Progress.md` tarihçesinde kalan değiniler tarihîdir.
- **CORS doğrulandı:** `allowedOriginPatterns` + `FRONTEND_ORIGIN`; wildcard `*` yok; credentials açık ama localhost pattern üretim riski oluşturmaz.
- **Auth blocker tespit edildi:** Uygulamada ADMIN kayıt/giriş ucu yok ve seed ADMIN üretmiyor. Manuel aktivasyon için DB'ye elle ADMIN hesabı veya doğrudan `agency_subscriptions` güncellemesi gerekir. README'de belgelendi.
- **`APP_DEV_SEED=false` güvenli:** CREATOR ve AGENCY self-registration ucu mevcut olduğundan giriş mümkün; seed olmadan sadece demo veri kaybolur. (Yalnız ADMIN aksiyonu için yukarıdaki kısıt geçerli.)
- **Kalan sınırlama: sağlayıcı webhook otomasyonu kasıtlı olarak ertelendi.**
- **Doğrulama (2026-06-14):**
  - Backend: `.\mvnw.cmd test` → BUILD SUCCESS — Tests run: 46, Failures: 0
  - `flutter analyze` → No issues found
  - `flutter test` → All tests passed! (53 tests)
  - `flutter build web --release` → Built build\web

---

## 2026-06-14 — Çok Planlı Abonelik Modeli (FREE / Pro / Growth)

- **`SubscriptionPlanCode` enum eklendi:** FREE, AGENCY_PRO, AGENCY_GROWTH.
- **`AgencySubscription.planCode` güncellendi:** String → `SubscriptionPlanCode` enum.
- **`AgencySubscriptionService` genişletildi:**
  - `getCurrentPlanForAgency`, `getCurrentSubscriptionForAgency`, `hasActivePaidSubscription`
  - `canUseAiMatch`, `canManageApplicants`, `canSelectCreator`
  - `getActiveTourLimit` (FREE:1, PRO:5, GROWTH:20), `canCreateAnotherTour`
  - `requireActivePaidSubscription` (eski `requireActiveSubscription` → yeni mesaj)
  - `buildSubscriptionStatusResponse` (feature flags + tour limit dahil)
- **`TourService.create()` tur kota kontrolü:** JWT varken plan limitini aşmaya çalışırsa HTTP 402.
- **`TourRepository`:** `countByAgencyIdAndStatus` sorgusu eklendi.
- **Billing API güncellendi:**
  - `GET /api/billing/agency/plans` (herkese açık) → Free/Pro/Growth plan kartları
  - `GET /api/billing/agency/subscription` → planCode + status + activeTourLimit + feature booleans
  - `POST /api/billing/agency/checkout` → body `{planCode}` ile `AGENCY_PRO_PAYMENT_LINK` veya `AGENCY_GROWTH_PAYMENT_LINK` döner
  - `POST /api/billing/admin/subscriptions/manual-activate` → ADMIN-only, planCode + providerSubscriptionId kabul eder
- **SecurityConfig güncellendi:** `/api/billing/agency/plans` → permitAll; `/api/billing/admin/**` → ADMIN rolü.
- **`application.yml`:** `AGENCY_PRO_PAYMENT_LINK` + `AGENCY_GROWTH_PAYMENT_LINK` env değişkenleri.
- **Frontend modeller güncellendi:** `AgencySubscriptionPlanCode` enum; `isPaid` getter; `AgencyPlan` modeli; `BillingRepository.getPlans()` + `getCheckoutUrl(agencyId, planCode)`.
- **`SubscriptionPlansSection` eklendi:** 3 plan kartı (Free/Pro/Growth); Mevcut Plan rozeti; Aboneliği Başlat CTA; mock modda checkout null döner.
- **`AgencyBoardScreen`:** `subscription.isPaid` kontrolü; ücretli değilse banner + plan kartları.
- **Creator tarafı korundu:** creator başvuru ve tur listeleme değişmedi.
- **Backend birim testleri (18):** Plan limitleri, canUseAiMatch, pendingPro blocked vb.
- **Güvenlik entegrasyon testleri (6):** manual-activate → 401 (anonim) + 403 (creator); subscription → 401/403; plans → 200.
- **Gerçek ödeme sağlayıcı webhook otomasyonu kasıtlı olarak sonraki aşamaya bırakıldı.**
- **Doğrulama (2026-06-14):**
  - Backend: `.\mvnw.cmd test` → BUILD SUCCESS — Tests run: 46, Failures: 0
  - `flutter analyze` → No issues found
  - `flutter test` → All tests passed! (53 tests)
  - `flutter build web --release` → Built build\web

---

## 2026-06-14 — Acente Abonelik Kapısı (Agency Pro Beta)

- **Backend `AgencySubscription` entity eklendi:** `agency_subscriptions` tablosu; `SubscriptionStatus` enum (NONE, PENDING, ACTIVE, PAST_DUE, CANCELED); `AgencySubscriptionRepository` JPA; `AgencySubscriptionService`.
- **Billing API eklendi:**
  - `GET /api/billing/agency/subscription` → güncel abonelik durumu
  - `POST /api/billing/agency/checkout` → `AGENCY_PAYMENT_LINK` env'den harici URL döner; aboneliği PENDING yapar
  - `POST /api/billing/agency/manual-activate` → kontrollü beta aktivasyonu (ADMIN → ACTIVE)
- **Abonelik kapısı:** `requireActiveSubscription()` metodu `POST /api/ai/match-score`, `GET /api/agency/tours/{id}/applications`, `POST /api/applications/{id}/select` uçlarına eklendi. JWT yoksa (legacy demo mod) bypass; ADMIN bypass; AGENCY + aktif değilse HTTP 402.
- **Frontend `BillingRepository` eklendi:** interface + `ApiBillingRepository` + `MockBillingRepository` (demo modda ACTIVE döner) + `ResilientBillingRepository`. `TurIzimDependencies` ve `TurIzimMockBootstrap`'a eklendi.
- **`AgencyProPackageCard` güncellendi:** `StatefulWidget`; CTA `POST /api/billing/agency/checkout` üzerinden `checkoutUrl` alır ve tarayıcıda açar. Uygulama içinde kart işleme yok.
- **`AgencyBoardScreen` güncellendi:** `AgencyBoardSnapshot` + `AgencySubscription` birlikte yüklenir. Aktif abonelik yoksa uyarı banner'ı + Agency Pro kartı hero altında gösterilir. Tour listesi ve navigasyon etkilenmez.
- **Creator tarafı korundu:** creator başvuru ve tur listeleme akışı değişmedi.
- **Gerçek ödeme sağlayıcı webhook otomasyonu kasıtlı olarak MVP sonrasına bırakıldı.**
- **Güvenlik notu:** `APP_LEGACY_OPEN_API=true` (demo) iken gating bypass edilir. Gerçek üretimde `false` + JWT zorunlu.
- **Doğrulama (2026-06-14):**
  - Backend: `.\mvnw.cmd test` → BUILD SUCCESS — Tests run: 22, Failures: 0
  - `flutter analyze` → No issues found
  - `flutter test` → All tests passed!
  - `flutter build web --release` → √ Built build\web

---

## 2026-06-14 — Acente Pro Paket Monetizasyon Kartı

- **`AgencyProPackageCard` eklendi:** Acente operasyon özeti ekranı (Özet sekmesi) altına "Paket & Abonelik" bölümü ve `AgencyProPackageCard` bileşeni eklendi.
- **Harici ödeme linki stratejisi:** "Paketi Satın Al" CTA butonu `--dart-define=AGENCY_PAYMENT_LINK=<url>` ile verilen harici URL'yi tarayıcıda açar. Uygulama içinde kart işleme, webhook veya ödeme durumu takibi yapılmaz.
- **Boş link koruması:** `AGENCY_PAYMENT_LINK` boşsa buton yerine "Ödeme linki henüz tanımlanmadı." mesajı gösterilir; mevcut demo akışı etkilenmez.
- **`url_launcher` paketi eklendi:** `pubspec.yaml`'a `url_launcher: ^6.3.0` eklendi (harici URL açmak için standart Flutter paketi).
- **`ApiConfig.agencyPaymentLink` sabit değişkeni eklendi:** `String.fromEnvironment('AGENCY_PAYMENT_LINK')` ile derleme zamanında alınır; yerel varsayılan boş.
- **Gerçek ödeme entegrasyonu kasıtlı olarak MVP kapsamı dışında bırakıldı:** Kart işleme SDK'ı, webhook/callback, abonelik durumu yönetimi ve fatura sistemi MVP sonrası görev olarak kalır.
- **Dokümantasyon:** `.env.example` + `README.md` (Gelir Modeli bölümü + ortam değişkeni tablosu) güncellendi.
- **Ödeyici taraf:** Acente (creator değil).
- **Doğrulama (2026-06-14):**
  - `flutter analyze` → No issues found
  - `flutter test` → All tests passed!
  - `flutter build web --release --dart-define=API_BASE_URL=http://localhost:8080 --dart-define=AGENCY_PAYMENT_LINK=https://example.com/payment` → √ Built build\web

---

## 2026-06-12 — Dağıtım Hazırlığı (Railway + Vercel)

- **Backend Railway'e hazırlandı:**
  - `backend/Dockerfile` eklendi: multi-stage (Maven wrapper build → JRE 17 runtime), CRLF düzeltmesi ile Linux uyumlu, `EXPOSE 8080`.
  - `backend/railway.json` eklendi: Dockerfile builder, `/api/health` healthcheck, on-failure restart.
  - `backend/.dockerignore` eklendi.
  - `application.yml`: `server.port=${PORT:${SERVER_PORT:8080}}` (Railway dinamik portu); datasource artık `SPRING_DATASOURCE_URL/USERNAME/PASSWORD` → `DB_*` → yerel varsayılan öncelik zinciri ile çalışıyor (yerel geliştirme bozulmadı).
- **CORS yapılandırılabilir yapıldı:** `WebConfig` artık `FRONTEND_ORIGIN` ortam değişkenini okuyor (virgülle çoklu origin); localhost geliştirme origin'leri her zaman açık; credentials açık olduğundan wildcard kullanılmıyor.
- **Frontend Flutter web hosting'e hazırlandı:**
  - `frontend/vercel.json` eklendi: `build/web` çıktı dizini, SPA rewrite, build komutu yok (Vercel imajında Flutter olmadığından önerilen akış yerel build + prebuilt deploy).
  - `frontend/.vercelignore` eklendi (yalnızca `build/web` yüklenir).
  - Üretim build komutu doğrulandı: `flutter build web --release --dart-define=API_BASE_URL=<backend-url>`.
- **Dokümantasyon:** `README.md` dağıtım bölümü (Railway adımları, env tablosu, Vercel/manuel deploy, canlı demo kontrol listesi); `.env.example` yeni değişkenlerle güncellendi (`PORT`, `SPRING_DATASOURCE_*`, `FRONTEND_ORIGIN`, `API_BASE_URL`).
- **Demo vs üretim modu belgelendi:** Demo: `APP_DEV_SEED=true` + `APP_LEGACY_OPEN_API=true` (token'sız erişim, seed veri). Üretim: ikisi de `false` + güçlü `JWT_SECRET`. Bilinen sınırlama: admin rolü için backend'de kullanıcı tanımı gerekir; tam üretim auth sertleştirmesi ayrı görev.
- **OpenRouter:** Anahtar opsiyonel kalır; boşsa AI özeti deterministik fallback ile döner (canlı demo için kabul edilebilir).
- **Doğrulama (2026-06-12):**
  - Backend: `.\mvnw.cmd test` → BUILD SUCCESS — Tests run: 22, Failures: 0.
  - Frontend: `flutter analyze` → No issues found; `flutter test` → All tests passed! (40); `flutter build web --release` → `√ Built build\web`.
- **Kalan iş:** Gerçek canlı dağıtım (Railway servis + PostgreSQL oluşturma, Vercel deploy) ve uçtan uca smoke test; `FRONTEND_ORIGIN`'e gerçek Vercel domain'inin girilmesi; Docker build'in Railway üzerinde ilk kez doğrulanması.

---

## 2026-06-12 — Frontend MVP Demo Akışı Backend'e Bağlandı

- **Tur listesi bağlı:** `CreatorOpenToursScreen` → `GET /api/tours` (resilient: backend kapalıysa mock'a düşer). Kartlarda başlık, çıkış şehri/rota, tarih, müsait creator koltuğu ve "Başvur" akışı mevcut.
- **Creator başvuru akışı bağlı:** Başvuru formu → `POST /api/tours/{tourId}/applications`; 3 zorunlu taahhüt checkbox'u (pre-selected değil) korunuyor. Demo kimlik `MvpDemoIdentity` / JWT oturumu ile geliyor.
- **Acente başvuru listesi bağlı:** `GET /api/agency/tours/{tourId}/applications` + creator profili `GET /api/creators/{id}`; kartlarda üretici adı, öğrenci profili, doğrulama durumu, başvuru durumu ve aksiyon butonları.
- **AI Match Score arayüzde:** Yeni `features/ai_match` dilimi — `AiMatchRepository` (interface), `ApiAiMatchRepository` (`POST /api/ai/match-score`, UUID string gövde), `MockAiMatchRepository` (deterministik çevrimdışı fallback), `ResilientAiMatchRepository` sarmalayıcı.
  - Acente başvuran kartında `AiMatchScoreCard`: uygunluk skoru (0–100), risk seviyesi (Düşük/Orta/Yüksek), AI özeti; `fallbackUsed: true` ise italik not ile normal gösterim.
  - İstekler başvuru başına **bir kez** yapılır ve ekran state'inde cache'lenir (render döngüsünde tekrar çağrı yok); "AI skoru hesaplanıyor..." yükleme durumu ve sayfayı kırmayan hata durumu + "Yeniden dene".
- **Acente manuel seçimi bağlı:** "Seçimi Onayla" → `POST /api/applications/{id}/select` (assignments repository üzerinden); başarı snackbar'ı ve liste yenileme mevcut. Ödeme entegrasyonu yok (mock depozito korunur).
- **Ortam yapılandırması:** `ApiConfig` → `--dart-define=API_BASE_URL` (varsayılan `http://localhost:8080`); hardcoded tek adres yok.
- **Doğrulama:** `flutter analyze` → No issues found; `flutter test` → **All tests passed! (40)** — AI parse/deterministiklik birim testleri ve acente ekranı AI kartı widget assertion'ları eklendi.
- Kalan TODO'lar:
  - AI skoru canlı OpenRouter anahtarıyla uçtan uca manuel test edilmedi (fallback yolu test edildi).
  - Başvuru geri çekme API'si yok (yalnızca çevrimdışı demo).
  - Admin ekranları kısmen mock'ta.
  - Deploy (web build host + backend host) ayrı görev.

---

## 2026-06-12 — AI Match Assistant Backend (Doğrulandı)

- `POST /api/ai/match-score` endpoint'i eklendi: deterministik uygunluk skoru (0–100) + OpenRouter LLM açıklaması + risk seviyesi (`LOW` / `MEDIUM` / `HIGH`).
- Yeni dosyalar: `com.turizim.ai` paketi (`AiMatchController`, `AiMatchService`, `OpenRouterClient`, `AiMatchRequest`, `AiMatchResponse`) ve `RiskLevel` enum'u.
- Deterministik skor rastgelelik içermez; mevcut entity alanlarını kullanır (aktiflik, pasaport/vize uygunluğu — mevcut `PassportType.satisfiesMinimum` hiyerarşisi ile, şehir uyumu). Skor 0–100 aralığına clamp edilir.
- OpenRouter entegrasyonu fallback davranışıyla eklendi: `OPENROUTER_API_KEY` boşsa ağ çağrısı yapılmaz; çağrı başarısız olursa loglanır ve deterministik Türkçe fallback özet döner (`fallbackUsed: true`). Endpoint AI hatasından asla patlamaz.
- Yapılandırma `application.yml` → `app.ai.openrouter.*`; ortam değişkenleri `OPENROUTER_API_KEY`, `OPENROUTER_MODEL` (varsayılan `openai/gpt-4o-mini`). Kodda gerçek anahtar yok.
- `SecurityConfig`: `POST /api/ai/match-score` → `AGENCY` / `ADMIN` rolleri (legacy-open-api=true iken açık, mevcut davranışla tutarlı).
- Birim testler eklendi (`AiMatchServiceTest`): risk seviyesi sınırları, deterministiklik, fallback davranışı, 404 senaryoları.
- Doğrulama: `.\mvnw.cmd test` → **BUILD SUCCESS — Tests run: 22, Failures: 0, Errors: 0** (2026-06-12).
- Açık TODO'lar:
  - Equipment quality, content category ve previous delivery score alanları MVP şemasında yok; eklendiklerinde skor formülü genişletilecek.
  - Frontend (Flutter) entegrasyonu henüz başlamadı.
  - OpenRouter canlı çağrısı gerçek API anahtarıyla manuel test edilmedi (fallback yolu birim testli).

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
