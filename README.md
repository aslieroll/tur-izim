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
| `DATABASE_URL` | PostgreSQL JDBC bağlantı URL'si |
| `POSTGRES_USER` | Veritabanı kullanıcı adı |
| `POSTGRES_PASSWORD` | Veritabanı şifresi |
| `OPENROUTER_API_KEY` | OpenRouter API anahtarı (AI özellikler) |
| `OPENROUTER_MODEL` | Kullanılacak model (varsayılan: `openai/gpt-4o-mini`) |
| `FRONTEND_API_BASE_URL` | Flutter'ın bağlandığı backend URL'si |

> Gerçek değerleri asla Git'e eklemeyin. `.env` dosyası `.gitignore` ile hariç tutulmuştur.

---

## Dağıtım Notları

- Üretimde `POSTGRES_PASSWORD` ve `OPENROUTER_API_KEY` gerçek secret manager veya CI/CD environment secrets ile verilmelidir.
- `app.dev-seed=false` yapılmalıdır (demo veri üretimde açık kalmamalıdır).
- `app.security.legacy-open-api=false` yapılarak tüm korumalı uçlar JWT zorunlu hale getirilmelidir.
- Flutter web derlemesi: `flutter build web --dart-define=API_BASE_URL=<production-url>`
- Backend: `./mvnw package` → üretilen `.jar` dosyası container veya VM'de çalıştırılır.
- CORS ayarları üretim alan adına göre güncellenmelidir.

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
