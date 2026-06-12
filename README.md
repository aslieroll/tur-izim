# tur.izim

**Tur İzim**, yerel tur acentelerinin boş ulaşım dahil tur koltuklarını; üniversite öğrencisi genç UGC içerik üreticileri ve mikro-influencer adaylarıyla buluşturan **B2B/B2C güven ve operasyon platformudur**.

> Tur İzim bir seyahat acentesi değildir. Sosyal medya platformu değildir. Otel veya uçak bileti satışı yapmaz.

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
- Gerçek ödeme entegrasyonu
- Otomatik eşleştirme / random assignment
- Video upload veya uygulama içi streaming
- Otomatik sosyal medya izleme
- AI video analizi

---

## AI Kullanımı

Tur İzim MVP'sinde AI şu şekilde kullanılmıştır:

- **Ürün geliştirme desteği** — PRD, iş kuralları, kullanıcı akışları ve API sözleşmesi taslaklarının oluşturulmasında OpenRouter üzerinden LLM asistanı kullanıldı
- **Kod iskelet ve review** — Flutter widget iskeletleri ve Spring Boot controller/service desenleri için yardımcı araç
- **AUE skoru** — Kural tabanlı formül (AI değil); `suitability-score.md` bakınız

Planlanan (MVP sonrası):
- Creator başvuru kalitesi hakkında açıklayıcı AI önerileri (karar verici değil, karar destekleyici)

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
| `FRONTEND_ORIGIN` | `https://<app>.vercel.app` | CORS; virgülle birden fazla origin olabilir |
| `APP_DEV_SEED` | `true` | Boş DB'ye demo acente/creator/tur ekler; gerçek üretimde `false` |
| `APP_LEGACY_OPEN_API` | `true` | Demo: API token'sız erişilir. Gerçek üretimde `false` (JWT zorunlu) |
| `JWT_SECRET` | güçlü rastgele değer | `APP_LEGACY_OPEN_API=false` ise zorunlu |
| `OPENROUTER_API_KEY` | (opsiyonel) | Boşsa AI özeti deterministik fallback döner — demo için yeterli |
| `OPENROUTER_MODEL` | `openai/gpt-4o-mini` | Varsayılan |
| `PORT` | — | Railway otomatik verir; elle girmeyin |

> **Demo vs üretim:** Canlı demo için `APP_DEV_SEED=true` + `APP_LEGACY_OPEN_API=true` kullanılabilir; bu modda frontend token göndermeden çalışır. Gerçek üretimde ikisi de `false` olmalı ve frontend JWT oturumu ile çalışır (bilinen sınırlama: admin için backend'de kullanıcı tanımı gerekir).

### Frontend — Vercel (Flutter web)

Vercel build ortamında Flutter yüklü olmadığı için **önerilen yol: yerelde build + hazır çıktıyı deploy**. Depoda hazır: `frontend/vercel.json` (SPA rewrite + `build/web` çıktı dizini) ve `frontend/.vercelignore`.

```bash
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://<railway-backend-domain>
npx vercel deploy --prod
```

`vercel` CLI ilk çalıştırmada proje bağlama soruları sorar; `vercel.json` build komutu çalıştırmaz, yalnızca `build/web` içeriğini yayınlar.

Alternatif statik hostlar: `build/web` klasörü Netlify veya Firebase Hosting'e de aynen yüklenebilir.

> Deploy sonrası backend'de `FRONTEND_ORIGIN` değişkenine Vercel domain'ini eklemeyi unutmayın; aksi halde tarayıcı CORS hatası verir.

### Canlı Demo Kontrol Listesi

1. [ ] Railway PostgreSQL çalışıyor; backend healthcheck (`/api/health`) yeşil.
2. [ ] Backend log'unda seed mesajı var (demo acente + 2 creator + 3 tur).
3. [ ] `https://<backend>/api/tours` JSON liste dönüyor.
4. [ ] `FRONTEND_ORIGIN` Vercel domain'i ile ayarlı.
5. [ ] Flutter web build `API_BASE_URL=https://<backend>` ile alındı ve deploy edildi.
6. [ ] Tarayıcıda: tur listesi → başvuru → acente başvuran listesi → AI Eşleşme Asistanı kartı görünüyor.
7. [ ] `POST /api/ai/match-score` yanıt veriyor (OpenRouter anahtarı yoksa `fallbackUsed: true` — demo için normal).

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
├── stitch-export/    # Google Stitch UI referans dosyaları (görsel referans)
├── docker-compose.yml
├── .env.example      # Ortam değişkeni şablonu
└── README.md
```
