# tur.izim

**Tur İzim**, yerel tur acentelerinin boş ulaşım dahil tur koltuklarını; üniversite öğrencisi genç UGC içerik üreticileri ve mikro-influencer adaylarıyla buluşturan **B2B/B2C güven ve operasyon platformudur**.

> Tur İzim bir seyahat acentesi değildir. Sosyal medya platformu değildir. Otel veya uçak bileti satışı yapmaz. Uygulama içinde sosyal feed, sohbet veya kart bilgisi saklama **yoktur**.

---

## Canlı Ortam (Production)

| Kaynak | URL |
|--------|-----|
| **Frontend** | https://tur-izim-live.vercel.app |
| **Backend** | https://tur-izim-production.up.railway.app |
| **Health** | https://tur-izim-production.up.railway.app/api/health (`status: UP`) |
| **Abonelik planları** | https://tur-izim-production.up.railway.app/api/billing/agency/plans |

Hızlı doğrulama: `.\scripts\smoke-test-live.ps1`  
Teslim kontrol listesi: `docs/DELIVERY_CHECKLIST.md`

---

## Hedef Kullanıcılar

| Rol | Kim | Ne yapar? |
|-----|-----|-----------|
| **Creator** | Üniversite öğrencisi içerik üreticisi | Tura başvurur, içerik üretir, onaylı içeriği kendi sosyal hesabında en az 30 gün yayınlar |
| **Agency** | Yerel tur acentesi | Ulaşım dahil tur ilanı açar, başvuranları skorla inceler, **manuel** seçim yapar, içeriği onaylar |
| **Admin** | Platform yöneticisi | Acente hesabını onaylar, ihlal raporlarını manuel inceler |

---

## Temel MVP Özellikleri

- **Tur ilanları** — Ulaşım dahil acente turları; yurt içi / yurt dışı ayrımı; pasaport/vize kapısı
- **Başvuru sistemi** — Creator başvurusu; 3 zorunlu onay checkbox'u (pre-selected değil)
- **Aday Uygunluk Endeksi (AUE)** — Teknik %75 + Yayın Platform %25; karar desteği, otomatik seçim değil
- **Manuel acente seçimi** — `Assignment`; sistem asla otomatik atama yapmaz
- **Mock depozito** — `PENDING → HELD → RELEASED_AFTER_PUBLICATION`; gerçek para hareketi yok
- **İçerik teslimi** — Yalnızca URL ile; dosya/video yükleme yok
- **Yayın takibi** — 30 günlük public kalma zorunluluğu; URL bildirimi
- **İhlal bildirimi** — Acente raporlar; admin manuel inceler

---

## MVP Kapsam Dışı

- Sosyal medya feed'i
- Uygulama içi chat / mesajlaşma
- Otel veya uçak bileti rezervasyonu
- Uygulama içi kart toplama veya ödeme SDK entegrasyonu
- Gerçek ödeme webhook otomasyonu (harici checkout redirect MVP'de yeterli)
- Otomatik eşleştirme / random assignment
- Video upload veya uygulama içi streaming
- Otomatik sosyal medya izleme
- AI video analizi

---

## AI Eşleşme Asistanı (AI Match Assistant)

Acente panelinde, başvuru inceleme sırasında kullanılan **karar destek** özelliğidir:

- Endpoint: `POST /api/ai/match-score`
- Girdi: tur + creator profil özeti
- Çıktı: uyum skoru, risk seviyesi, kısa Türkçe açıklama
- **Otomatik seçim yapmaz**; acente creator'ı yine **manuel** seçer
- Aktif ücretli plan (Agency Pro / Growth) gerektirir; FREE planda **HTTP 402**
- `OPENROUTER_API_KEY` boşsa backend deterministik fallback döner (`fallbackUsed: true`)

---

## AI Kullanımı (Geliştirme)

Tur İzim MVP'sinde AI şu şekilde kullanılmıştır:

- **Ürün geliştirme desteği** — PRD, iş kuralları, kullanıcı akışları ve API sözleşmesi taslaklarının oluşturulmasında OpenRouter üzerinden LLM asistanı kullanıldı
- **Kod iskelet ve review** — Flutter widget iskeletleri ve Spring Boot controller/service desenleri için yardımcı araç
- **AUE skoru** — Kural tabanlı formül (AI değil); `suitability-score.md` bakınız
- **AI Match Assistant** — Acente başvuru inceleme kartında açıklayıcı özet (karar verici değil)

Planlanan (MVP sonrası):
- Creator başvuru kalitesi hakkında ek açıklayıcı AI önerileri

---

## Teknoloji Yığını

| Katman | Teknoloji |
|--------|-----------|
| Frontend | Flutter + Dart (mobil öncelikli, Chrome/web destekli) |
| Backend | Java 17 + Spring Boot 3.x + Maven |
| Veritabanı | PostgreSQL 16 |
| AI servisi | OpenRouter API (`openai/gpt-4o-mini` varsayılan) |
| Yerel altyapı | Docker Compose (PostgreSQL) |

---

## Depoyu Çalıştırma

### Gereksinimler

- Docker Desktop (PostgreSQL için)
- JDK 17+
- Flutter SDK 3.x
- PowerShell (Windows) veya bash (macOS/Linux)

### 1. Ortam Değişkenleri

```bash
# Kök dizindeki şablonu kopyalayın:
cp .env.example .env
# .env dosyasını düzenleyip gerçek değerleri girin (asla Git'e eklemeyin)
```

### 2. PostgreSQL (Docker Compose)

```bash
# Veritabanını başlat
docker compose up -d postgres

# Durdur (veri korunur)
docker compose stop postgres

# Kaldır (veriyi silmez)
docker compose down
```

### 3. Backend (Spring Boot)

```powershell
cd backend
$env:DB_URL="jdbc:postgresql://localhost:5432/turizim"
$env:DB_USERNAME="turizim"
$env:DB_PASSWORD="turizim_dev_password"
.\mvnw.cmd spring-boot:run
```

Backend varsayılan olarak `http://localhost:8080` adresinde çalışır.  
Health check: `GET /api/health`

İlk çalıştırmada `app.dev-seed=true` (varsayılan) ile demo veri otomatik eklenir:
- Demo acente (onaylı) + 2 creator + 3 tur
- Şifre: `Demo123!` (konsol log'unda görünür)

Ayrıntılar: `backend/README.md`

### 4. Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

Backend hazır değilse mock repository'ler otomatik devreye girer.  
API adresi: `--dart-define=API_BASE_URL=http://localhost:8080`

---

## Ortam Değişkenleri

Şablon: `.env.example`

| Değişken | Açıklama |
|----------|----------|
| `DATABASE_URL` | PostgreSQL JDBC bağlantı URL'si (yerel) |
| `POSTGRES_USER` | Veritabanı kullanıcı adı (yerel) |
| `POSTGRES_PASSWORD` | Veritabanı şifresi (yerel) |
| `SPRING_DATASOURCE_URL` | Deploy için açık JDBC URL (Railway vb.) |
| `SPRING_DATASOURCE_USERNAME` | Deploy veritabanı kullanıcısı |
| `SPRING_DATASOURCE_PASSWORD` | Deploy veritabanı şifresi |
| `PORT` | Platform tarafından verilen dinamik port (yerelde 8080) |
| `FRONTEND_ORIGIN` | CORS için dağıtılan frontend origin'i |
| `APP_DEV_SEED` | Boş DB'ye demo veri (demo: `true`, üretim: `false`) |
| `APP_LEGACY_OPEN_API` | Token'sız API erişimi (demo: `true`, üretim: `false`) |
| `JWT_SECRET` | JWT imza anahtarı (üretimde zorunlu) |
| `OPENROUTER_API_KEY` | OpenRouter API anahtarı (boşsa AI fallback özet) |
| `OPENROUTER_MODEL` | Kullanılacak model (varsayılan: `openai/gpt-4o-mini`) |
| `API_BASE_URL` | Flutter `--dart-define` ile geçirilen backend URL'si |
| `AGENCY_PRO_PAYMENT_LINK` | Agency Pro harici checkout linki (backend env); boşsa checkout 422 döner |
| `AGENCY_GROWTH_PAYMENT_LINK` | Agency Growth harici checkout linki (backend env); boşsa checkout 422 döner |
| `APP_ADMIN_BOOTSTRAP_ENABLED` | İlk ADMIN bootstrap (varsayılan: `false`; üretimde tek seferlik `true`) |
| `APP_ADMIN_EMAIL` | Bootstrap ADMIN e-postası (yalnızca Railway env) |
| `APP_ADMIN_PASSWORD` | Bootstrap ADMIN şifresi (yalnızca Railway env; asla repoya yazmayın) |

> Gerçek değerleri asla Git'e eklemeyin. `.env` dosyası `.gitignore` ile hariç tutulmuştur.

---

## Dağıtım

Hedef: **Backend → Railway** (Dockerfile ile), **Veritabanı → Railway PostgreSQL**, **Frontend → Vercel** (Flutter web build çıktısı).

### Backend — Railway

Depoda hazır: `backend/Dockerfile` (multi-stage, Java 17) ve `backend/railway.json` (healthcheck: `/api/health`).

1. Railway'de yeni proje oluşturun, **PostgreSQL** eklentisi ekleyin.
2. GitHub deposunu servis olarak bağlayın; **Root Directory** = `backend`.
3. Railway, `railway.json` sayesinde Dockerfile ile build eder.
4. Servise ortam değişkenlerini girin (aşağıdaki tablo).
5. Domain oluşturun (Settings → Networking → Generate Domain) ve
   `https://<domain>/api/health` ile doğrulayın.

| Değişken | Demo değeri | Açıklama |
|----------|-------------|----------|
| `SPRING_DATASOURCE_URL` | `jdbc:postgresql://<host>:<port>/<db>` | Railway PostgreSQL bilgilerinden **JDBC formatında** yazın (Railway'in verdiği `postgresql://` URL'sini `jdbc:postgresql://` yapın, kullanıcı/şifreyi ayırın) |
| `SPRING_DATASOURCE_USERNAME` | Railway PG kullanıcı | |
| `SPRING_DATASOURCE_PASSWORD` | Railway PG şifre | Asla repoya yazmayın |
| `FRONTEND_ORIGIN` | `https://tur-izim-live.vercel.app` | CORS; virgülle birden fazla origin olabilir |
| `APP_DEV_SEED` | `false` | Üretimde demo veri yüklenmez; yerel demo için `true` |
| `APP_LEGACY_OPEN_API` | `false` | Üretimde JWT zorunlu; yerel demo için geçici `true` |
| `JWT_SECRET` | güçlü rastgele değer | `APP_LEGACY_OPEN_API=false` ise zorunlu |
| `OPENROUTER_API_KEY` | (opsiyonel) | Boşsa AI özeti deterministik fallback döner — demo için yeterli |
| `OPENROUTER_MODEL` | `openai/gpt-4o-mini` | Varsayılan |
| `AGENCY_PRO_PAYMENT_LINK` | sağlayıcı checkout URL | Agency Pro abonelik linki; yalnızca backend env, frontend'e geçmez |
| `AGENCY_GROWTH_PAYMENT_LINK` | sağlayıcı checkout URL | Agency Growth abonelik linki; yalnızca backend env, frontend'e geçmez |
| `APP_ADMIN_BOOTSTRAP_ENABLED` | `false` (üretim) | İlk deploy'da tek seferlik `true`; ADMIN oluşturulduktan sonra **kapatın** |
| `APP_ADMIN_EMAIL` | güçlü admin e-posta | Bootstrap için; genel kayıt API'si yoktur |
| `APP_ADMIN_PASSWORD` | güçlü şifre | Bootstrap için; asla repoya yazmayın |
| `PORT` | — | Railway otomatik verir; elle girmeyin |

> **Demo vs üretim:** Yerel veya geçici demo için `APP_DEV_SEED=true` + `APP_LEGACY_OPEN_API=true` kullanılabilir. **Canlı teslim ortamında** (`tur-izim-live.vercel.app`) ikisi de `false` olmalı; frontend JWT oturumu ile çalışır, korumalı uçlara token'sız erişim 401 döner.

### Frontend — Vercel (Flutter web)

Vercel UI'da uzun Flutter komutu 256 karakter sınırına takılır; `frontend/vercel-build.sh` + `npm run vercel-build` kullanın.

**Vercel proje ayarları:**

| Alan | Değer |
|------|-------|
| Root Directory | `frontend` |
| Framework Preset | Other |
| Build Command | `npm run vercel-build` |
| Output Directory | `build/web` |
| Environment Variable | `API_BASE_URL=https://tur-izim-production.up.railway.app` |

Build sırasında script Flutter stable'ı `$HOME/flutter` altına kurar, `flutter pub get` ve `flutter build web --release` çalıştırır. `API_BASE_URL` env yoksa yukarıdaki Railway URL varsayılan olarak kullanılır.

Yerel doğrulama:

```bash
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://tur-izim-production.up.railway.app
```

Depoda hazır: `frontend/vercel.json` (SPA rewrite), `frontend/package.json`, `frontend/vercel-build.sh`.

> Deploy sonrası backend'de `FRONTEND_ORIGIN` değişkenine Vercel domain'ini eklemeyi unutmayın; aksi halde tarayıcı CORS hatası verir.

### Canlı Ortam Kontrol Listesi

1. [ ] `.\scripts\smoke-test-live.ps1` → tüm kontroller PASS
2. [ ] Railway PostgreSQL çalışıyor; `GET /api/health` → `status: ok`
3. [ ] `GET /api/billing/agency/plans` → FREE, AGENCY_PRO, AGENCY_GROWTH
4. [ ] `FRONTEND_ORIGIN=https://tur-izim-live.vercel.app` (CORS hatası yok)
5. [ ] `APP_LEGACY_OPEN_API=false`, `APP_DEV_SEED=false`, `APP_ADMIN_BOOTSTRAP_ENABLED=false`
6. [ ] Vercel build `API_BASE_URL=https://tur-izim-production.up.railway.app`
7. [ ] Tarayıcı: public tur listesi; JWT olmadan korumalı creator ekranları → giriş isteği (401 crash yok)
8. [ ] Agency girişi: plan kartları + harici checkout; FREE planda kilitli özellikler → 402

Ayrıntılı liste: `docs/DELIVERY_CHECKLIST.md`

---

## Güvenlik Sertleştirme Notları (Canlı Teslim)

Canlı ortam (`tur-izim-production` / `tur-izim-live`) için zorunlu ayarlar:

| Ayar | Üretim değeri |
|------|---------------|
| `APP_LEGACY_OPEN_API` | `false` — JWT zorunlu; korumalı uçlar token'sız kapalı |
| `APP_DEV_SEED` | `false` — demo seed yüklenmez |
| `APP_ADMIN_BOOTSTRAP_ENABLED` | `false` — ilk ADMIN oluşturulduktan sonra kapatılmalı |
| `FRONTEND_ORIGIN` | `https://tur-izim-live.vercel.app` |
| `JWT_SECRET` | Güçlü rastgele değer (repoda yok) |

Ek notlar:

- `AGENCY_PRO_PAYMENT_LINK` / `AGENCY_GROWTH_PAYMENT_LINK` yalnızca backend env'de; kart verisi uygulamada **saklanmaz**
- `/api/billing/admin/subscriptions/manual-activate` yalnızca ADMIN JWT ile
- Kabul edilebilir yanıtlar: **401** (oturumsuz), **402** (ücretli plan kapısı), **403** (yanlış rol)
- Kabul edilemez: CORS hatası, `Failed to fetch`, `localhost:8080` üretimde, Uncaught Error, **500**

Tam iyzico/PayTR webhook otomasyonu kasıtlı olarak MVP sonrasına bırakılmıştır.

---

## Initial Admin Bootstrap

Genel admin kayıt API'si **yoktur**; ilk üretim/beta ADMIN hesabı yalnızca startup bootstrap ile oluşturulur.

### Ne zaman gerekli?

- İlk Railway deploy'unda, `POST /api/billing/admin/subscriptions/manual-activate` için ADMIN JWT gerektiğinde.
- Webhook otomasyonu kasıtlı olarak ertelendiği için kontrollü beta'da manuel abonelik aktivasyonu bu ADMIN hesabıyla yapılır.

### İlk deploy adımları

1. Railway env'de ayarlayın (gerçek değerleri **asla** repoya yazmayın):
   ```
   APP_ADMIN_BOOTSTRAP_ENABLED=true
   APP_ADMIN_EMAIL=<güçlü-admin-e-posta>
   APP_ADMIN_PASSWORD=<güçlü-şifre>
   ```
2. Backend'i deploy edin. Startup'ta sistemde ADMIN yoksa **tek bir** `UserRole.ADMIN` hesabı oluşturulur (şifre BCrypt ile hash'lenir).
3. `POST /api/auth/login` ile ADMIN olarak giriş yapın; JWT alın.
4. `POST /api/billing/admin/subscriptions/manual-activate` ile acente aboneliğini `ACTIVE` yapın.
5. Giriş doğrulandıktan sonra Railway'de **`APP_ADMIN_BOOTSTRAP_ENABLED=false`** yapın ve yeniden deploy edin.

### Güvenlik kuralları

- Varsayılan: `APP_ADMIN_BOOTSTRAP_ENABLED=false` — bootstrap kapalıdır.
- Zaten bir ADMIN varsa ikinci admin **oluşturulmaz**.
- E-posta zaten kayıtlıysa mevcut kullanıcı **değiştirilmez**.
- Şifre değerleri **asla loglanmaz** ve repoya **commit edilmez**.
- Bootstrap sonrası env'deki `APP_ADMIN_PASSWORD` değerini Railway'den kaldırabilirsiniz (bootstrap kapalıyken kullanılmaz).

---

## Gelir Modeli

Turİzim'de ödeyici **tur acentesidir**; creator ücretsiz kullanır.

### Abonelik Planları

| Plan | Fiyat | Aktif Tur | AI Asistan | Başvuru Yönetimi |
|------|-------|-----------|------------|-----------------|
| **Ücretsiz** | 0 ₺ | 1 | ✗ | ✗ |
| **Agency Pro** | 499 ₺/ay | 5 | ✓ | ✓ |
| **Agency Growth** | 999 ₺/ay | 20 | ✓ | ✓ + öncelikli destek |

### Ödeme Akışı

1. Acente "Aboneliği Başlat" butonuna tıklar.
2. Frontend `POST /api/billing/agency/checkout` (body: `{"planCode":"AGENCY_PRO"}`) çağırır.
3. Backend `AGENCY_PRO_PAYMENT_LINK` veya `AGENCY_GROWTH_PAYMENT_LINK` env'den URL döner; aboneliği `PENDING` yapar.
4. Frontend URL'yi yeni sekmede açar. **Uygulama içinde kart işleme yapılmaz, kart verisi saklanmaz.**
5. Beta döneminde admin `POST /api/billing/admin/subscriptions/manual-activate` (ADMIN JWT zorunlu) ile `ACTIVE` yapar.

### Abonelik Kapısı

Aktif ücretli plan yoksa (FREE / PENDING / PAST_DUE / CANCELED):
- Acente panelinde uyarı banner'ı + plan karşılaştırma bölümü gösterilir.
- `/api/ai/match-score`, `/api/agency/tours/{id}/applications`, `/api/applications/{id}/select` → **HTTP 402**.
- Creator tarafı ve tur listesi etkilenmez.

### Üretim Gereksinimleri

```bash
# Backend Railway env (canlı teslim)
APP_LEGACY_OPEN_API=false
APP_DEV_SEED=false
APP_ADMIN_BOOTSTRAP_ENABLED=false
JWT_SECRET=<en az 256-bit rastgele>
FRONTEND_ORIGIN=https://tur-izim-live.vercel.app
AGENCY_PRO_PAYMENT_LINK=https://<provider>/checkout/pro
AGENCY_GROWTH_PAYMENT_LINK=https://<provider>/checkout/growth

# Frontend Vercel (ödeme linkleri frontend'e geçirilmez)
API_BASE_URL=https://tur-izim-production.up.railway.app
```

**MVP sonrası:** iyzico/PayTR webhook otomasyonu, `ACTIVE`→`PAST_DUE` otomatik geçiş, fatura yönetimi.

---

## Dokümantasyon

Tüm ürün ve teknik belgeler `prodocs/` klasöründedir:

| Dosya | İçerik |
|-------|--------|
| `prodocs/PRD.md` | Ürün gereksinimleri |
| `prodocs/business-rules.md` | İş kuralları |
| `prodocs/user-flows.md` | Kullanıcı akışları |
| `prodocs/tech-stack.md` | Teknoloji yığını ve gerekçeler |
| `prodocs/Plan.md` | Yürütme planı ve kullanıcı hikayeleri |
| `prodocs/DesignSystem.md` | Flutter tasarım sistemi |
| `prodocs/Progress.md` | Geliştirme ilerlemesi |
| `prodocs/api-contract.md` | REST API sözleşmesi |
| `prodocs/database-schema.md` | Veritabanı şeması |
| `prodocs/suitability-score.md` | AUE (Aday Uygunluk Endeksi) |

Klasör indeksi: `prodocs/README.md`

---

## Depo Yapısı

```
tur-izim/
├── backend/          # Java Spring Boot REST API (PostgreSQL)
├── frontend/         # Flutter / Dart, mobil öncelikli uygulama
├── prodocs/          # Ürün ve teknik dokümantasyon
├── docs/             # Teslim kontrol listesi (DELIVERY_CHECKLIST.md)
├── scripts/          # Canlı smoke test (smoke-test-live.ps1)
├── stitch-export/    # Google Stitch UI referans dosyaları (görsel referans)
├── docker-compose.yml
├── .env.example      # Ortam değişkeni şablonu
└── README.md
```
