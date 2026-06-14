# Yürütme Planı — tur.izim MVP

Bu belge Tur İzim MVP'sinin fazlarını, **kullanıcı hikayelerini** ve teknik görevleri tanımlar.  
Tek iş gerçeği: `PRD.md`, `business-rules.md`, `user-flows.md`.  
Uygulama durumu: `Progress.md`.

**Canlı teslim:** https://tur-izim-live.vercel.app (frontend) · https://tur-izim-production.up.railway.app (backend) · Kontrol listesi: `docs/DELIVERY_CHECKLIST.md`

---

## Faz 0 — Dokümantasyon ve Paydaş Hizası ✅

### Kullanıcı Hikayeleri
- Kurucu olarak, iş kurallarının ve kapsam sınırlarının yazılı olmasını istiyorum; böylece geliştirici/AI agent yanlış özellik implemente etmesin.
- Kurucu olarak, tasarım sisteminin tanımlı olmasını istiyorum; böylece UI tutarlı görünsün.

### Teknik Görevler
- [x] PRD yazıldı (`prodocs/PRD.md`)
- [x] İş kuralları yazıldı (`prodocs/business-rules.md`)
- [x] Kullanıcı akışları yazıldı (`prodocs/user-flows.md`)
- [x] Veritabanı şeması yazıldı (`prodocs/database-schema.md`)
- [x] API sözleşmesi taslağı yazıldı (`prodocs/api-contract.md`)
- [x] AUE metodolojisi yazıldı (`prodocs/suitability-score.md`)
- [x] Tasarım sistemi yazıldı (`prodocs/DesignSystem.md`)
- [x] MVP dışı maddeler netleştirildi (otomatik eşleştirme yok, gerçek ödeme yok, sosyal feed yok)

---

## Faz 1 — Teknik Temel ✅

### Kullanıcı Hikayeleri
- Geliştirici olarak, Flutter uygulama iskeletinin çalışmasını istiyorum; böylece özellik dilimlerini entegre edebileyim.
- Geliştirici olarak, backend'in PostgreSQL'e bağlanmasını ve temel sağlık endpoint'inin çalışmasını istiyorum.
- Geliştirici olarak, yerel ortamın Docker Compose ile tek komutla ayağa kalkmasını istiyorum.

### Teknik Görevler
- [x] Flutter uygulama iskeleti (`frontend/lib/`)
- [x] `go_router` navigasyon ve rol bazlı route guard
- [x] Mock repository interface'leri tanımlandı
- [x] Spring Boot REST iskeleti (`backend/`)
- [x] `GET /api/health` endpoint'i
- [x] PostgreSQL bağlantısı ve ortam değişkenleri
- [x] Docker Compose PostgreSQL servisi (`docker-compose.yml`)
- [x] Maven Wrapper (`mvnw`, `mvnw.cmd`)
- [x] Temel domain entity'leri: `UserAccount`, `Agency`, `CreatorProfile`, `Tour`, `TourApplication`, `Assignment`, `MockDeposit`, `PublicationProof`, `ViolationReport`

---

## Faz 2 — Çekirdek Akışlar (Dilim Dilim) 🔄

### 2.1 Oturum, Router, Model, Repository Interface ✅

**Kullanıcı Hikayesi:**  
Bir creator veya acente olarak, giriş yapabilmek ve rolüme göre doğru ekranlara yönlendirilmek istiyorum.

**Teknik Görevler:**
- [x] Session modeli (`UserSession`) ve mock kimlik
- [x] JWT tabanlı kimlik doğrulama (`POST /api/auth/register`, `POST /api/auth/login`)
- [x] `Authorization: Bearer` header desteği
- [x] `/login`, `/register/creator`, `/register/agency` Flutter ekranları
- [x] Demo rol düğmeleri (geliştirme kolaylığı)
- [x] `ApiConfig` ve `API_BASE_URL` dart-define

### 2.2 Tur İlanları ve Listeleme 🔄

**Kullanıcı Hikayeleri:**
- Acente olarak, ulaşım dahil tur ilanı oluşturmak istiyorum; böylece creator'lar başvurabilsin.
- Creator olarak, açık turları listeleyip detaylarını görmek istiyorum; böylece uygun olana başvurayım.
- Creator olarak, yurt dışı tur için pasaport/vize gereksinimini başvurmadan önce görmek istiyorum.

**Teknik Görevler:**
- [x] `GET /api/tours` (yayımlı turlar listesi)
- [x] `GET /api/tours/{id}` (tur detayı)
- [x] `GET /api/agency/{agencyId}/tours` (acente kendi turları)
- [ ] `POST /api/agency/tours` (tur oluşturma)
- [ ] `PUT /api/agency/tours/{id}` (tur güncelleme)
- [ ] Flutter: Tur listesi ekranı (creator)
- [ ] Flutter: Tur detay ekranı (creator + pasaport/vize kapısı)
- [ ] Flutter: Tur oluşturma ekranı (acente)
- [ ] Flutter: Yurt dışı tur uygunluk kontrolü

### 2.3 Başvuru (Application) Akışı 🔄

**Kullanıcı Hikayeleri:**
- Creator olarak, bir tura başvurmak istiyorum; ancak 3 zorunlu onay checkbox'unu işaretlemeden başvuru yapamayım.
- Acente olarak, tura başvuranları AUE skoruna göre sıralanmış görmek istiyorum.

**Teknik Görevler:**
- [ ] `POST /api/applications` (başvuru oluşturma; 3 checkbox zorunlu kapı)
- [ ] `GET /api/agency/tours/{tourId}/applications` (başvuranlar listesi, AUE skoru ile)
- [ ] Flutter: Başvuru formu ekranı (3 checkbox pre-selected değil)
- [ ] Flutter: Başvurularım ekranı (creator)
- [ ] Flutter: Başvuranlar listesi ekranı (acente, AUE sıralamalı)
- [x] AUE (Aday Uygunluk Endeksi) skoru hesabı (backend service)

### 2.4 Manuel Seçim ve Assignment Akışı 🔄

**Kullanıcı Hikayeleri:**
- Acente olarak, beğendiğim creator'ı manuel olarak seçmek istiyorum; sistem benim yerime seçim yapmamalı.
- Creator olarak, seçildikten sonra depozito onayı ekranına yönlendirilmek istiyorum.

**Teknik Görevler:**
- [ ] `POST /api/agency/applications/{id}/accept` (manuel kabul → Assignment PENDING_DEPOSIT + MockDeposit PENDING)
- [ ] `POST /api/agency/applications/{id}/reject` (red)
- [ ] Flutter: Acente başvuru değerlendirme ekranı
- [ ] Flutter: Creator depozito onay ekranı (3 taahhüt checkbox tekrar — pre-selected değil)
- [ ] MockDeposit `PENDING → HELD` geçişi (creator son onay sonrası)
- [ ] Assignment `PENDING_DEPOSIT → ACTIVE` geçişi

### 2.5 İçerik Teslimi ve Yayın Akışı 🔄

**Kullanıcı Hikayeleri:**
- Creator olarak, içerik taslak URL'sini göndermek istiyorum; yalnızca URL ile, dosya yükleme yok.
- Acente olarak, taslağı teknik checklist ile inceleyip onaylamak veya bir kez revizyon istemek istiyorum.
- Creator olarak, onaylanan içeriği kendi sosyal hesabımda yayınlayıp URL'yi bildirmek istiyorum.

**Teknik Görevler:**
- [ ] `POST /api/assignments/{id}/submit-draft` (taslak URL gönderimi)
- [ ] `POST /api/assignments/{id}/approve-draft` (acente onayı)
- [ ] `POST /api/assignments/{id}/request-revision` (teknik revizyon; yalnızca bir kez)
- [ ] `POST /api/assignments/{id}/submit-publication` (yayın URL bildirimi)
- [ ] MockDeposit `HELD → RELEASED_AFTER_PUBLICATION` geçişi
- [ ] Flutter: Taslak gönderim ekranı (creator)
- [ ] Flutter: Taslak inceleme ekranı (acente; teknik checklist)
- [ ] Flutter: Yayın bildirimi ekranı (creator)
- [ ] Flutter: 30 günlük yayın takip göstergesi

---

## Faz 3 — Güven, Operasyon, Sertleştirme 📋

### Kullanıcı Hikayeleri
- Acente olarak, creator yayını 30 gün dolmadan kaldırırsa ihlal bildirimi açmak istiyorum.
- Admin olarak, ihlal raporlarını inceleyip karar vermek istiyorum.
- Tüm kullanıcılar olarak, hesaplarımın güvenli olmasını istiyorum (JWT zorunlu, CORS kısıtlı).

### Teknik Görevler
- [ ] `POST /api/violations` (ihlal bildirimi; acente)
- [ ] `GET /api/admin/violations` (ihlal listesi; admin)
- [ ] `POST /api/admin/violations/{id}/decide` (karar; admin)
- [ ] `GET /api/admin/agencies/pending` (onay bekleyen acenteler)
- [ ] `POST /api/admin/agencies/{id}/approve` (acente onayı)
- [ ] Flutter: İhlal bildirimi ekranı (acente)
- [ ] Flutter: Admin ihlal inceleme ekranı
- [ ] Flutter: Admin acente onay ekranı
- [ ] `app.security.legacy-open-api=false` yapılandırması (tüm korumalı uçlar JWT zorunlu)
- [ ] Flyway veya Liquibase migrasyonları (üretim öncesi)
- [ ] CORS üretim domain kısıtlaması
- [ ] TODO: Dağıtım stratejisi (cloud provider seçimi yapılmadı)

---

## Kapsam Dışı (Hiçbir Fazda Uygulanmayacak — MVP)

- Sosyal medya feed'i
- Uygulama içi chat / mesajlaşma
- Otomatik creator eşleştirmesi
- Gerçek ödeme entegrasyonu (Stripe, iyzico)
- Video upload veya uygulama içi streaming
- Otomatik sosyal medya izleme / crawler
- AI video analizi
- Otel veya uçak bileti rezervasyonu

---

## Sonraki Adım — Webhook Otomasyonu (Henüz Başlanmadı)

Hedef: Ödeme sağlayıcısından gelen webhook ile abonelik durumunu otomatik güncelle.

| Görev | Açıklama |
|-------|----------|
| Webhook endpoint | `POST /api/billing/webhooks/<provider>` |
| İmza doğrulama | Provider secret ile HMAC kontrolü |
| `ACTIVE` geçişi | `payment_intent.succeeded` → abonelik ACTIVE |
| `PAST_DUE` geçişi | `invoice.payment_failed` → PAST_DUE |
| Yenileme | `invoice.paid` → `currentPeriodEnd` güncelleme |
| Test | Webhook test aracı (Stripe CLI veya provider sandbox) |

> Bu adım tamamlanana kadar beta aktivasyon manuel: `POST /api/billing/admin/subscriptions/manual-activate` (ADMIN JWT).

---

## Risk ve Bağımlılıklar

| Risk | Önlem |
|------|-------|
| Flutter ↔ backend API contract kayması | `api-contract.md` her iki tarafın tek gerçeği; değişimde her iki repo güncellenmeli |
| `ddl-auto=update` üretimde tehlikeli | Faz 3'te Flyway/Liquibase geçişi zorunlu |
| JWT secret güvenliği | `.env.example`'da boş; üretimde secret manager kullanılmalı |
| Admin işlemleri için demo giriş | `app.security.legacy-open-api=false` ile kapatılmalı |
| Stitch tasarım dosyalarının iş kuralı olarak yorumlanması | `DesignSystem.md` ve `PRD.md` önceliklidir; Stitch yalnızca görsel referans |
