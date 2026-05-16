# Tur İzim

Tur İzim, boş **ulaşım dahil tur koltuklarına** sahip yerel tur acenteleri ile üniversite öğrencisi genç **UGC içerik üreticileri** ve mikro influencer’ları güvenli şekilde buluşturan bir **B2B/B2C güven ve operasyon platformudur**.

Platform; tarafların güvenli şekilde anlaşmasını, içerik teslimini ve operasyonel sürecin yönetimini kolaylaştırır.

<<<<<<< HEAD
> Tur İzim bir seyahat acentesi değildir.  
> Sosyal medya platformu değildir.  
> Otel veya uçak bileti satışı yapmaz.
=======
| Dizin | Rol |
|--------|-----|
| `backend/` | Java Spring Boot REST API (PostgreSQL) |
| `frontend/` | Flutter / Dart, mobil öncelikli uygulama |
| `prodocs/` | Türkçe ürün ve teknik dokümantasyon (PRD, plan, ilerleme, tasarım sistemi, API, şema, akışlar) |
>>>>>>> 2511fe9 (Backend temel yapısını ve prodocs teslim dokümanlarını düzenle)

---

# Target Users

## Agencies
- Yerel tur acenteleri
- Boş ulaşım dahil tur koltuklarını değerlendirmek isteyen işletmeler

## Creators
- Üniversite öğrencileri
- UGC içerik üreticileri
- Mikro influencer’lar
- Seyahat içerikleri üretebilen genç kullanıcılar

<<<<<<< HEAD
---

# MVP Scope

## Included

- Ulaşım dahil tur ilanları
- Creator başvuru sistemi
- Suitability score (aday uygunluk skoru)
- Manuel creator seçimi
- Mock deposit sistemi
- Teknik içerik checklist yapısı
- Link tabanlı içerik teslimi
- Yayın URL doğrulama akışı
- İhlal bildirim sistemi
- Üniversite ve öğrenci bilgisi doğrulama alanları

## Excluded

- Otomatik eşleştirme
- Gerçek ödeme sistemi
- Uygulama içi video upload
- Sosyal medya feed sistemi
- Chat / mesajlaşma
- Otel rezervasyonu
- Uçak bileti satışı
- Otomatik sosyal medya takibi

---

# Pilot Region

İlk MVP operasyonu:

## Departure Cities
- Adana
- Mersin

## Initial Tour Categories
- Kapadokya turları
- Güneydoğu turları

## Tour Type
- Sadece ulaşım dahil acente turları

---

# Repository Structure

| Directory | Description |
|---|---|
| `backend/` | Java Spring Boot REST API + PostgreSQL |
| `frontend/` | Flutter / Dart mobile application |
| `docs/` | PRD, business rules, flows, API contracts, database schema, design system |

---

# Tech Stack

## Frontend
- Flutter
- Dart

## Backend
- Java
- Spring Boot

## Database
- PostgreSQL

---

# Local Development

## PostgreSQL

Development database can be started with:
=======
## Yerel PostgreSQL (Docker Compose)

Docker yüklüyse depo kökünden yalnızca veritabanı servisini başlatın:
>>>>>>> 2511fe9 (Backend temel yapısını ve prodocs teslim dokümanlarını düzenle)

```bash
docker compose up -d postgres
```

<<<<<<< HEAD
Spring Boot configuration should match the credentials defined in:
=======
Durdurma (konteyneri durdurur; named volume ile veri kalır):

```bash
docker compose stop postgres
```

Konteyneri kaldırıp ağları temizlemek (volume’ü silmez):

```bash
docker compose down
```

**Gizlilik:** `POSTGRES_PASSWORD`, API anahtarları veya üretim sırları **asla** Git’e eklenmemelidir. Ortam değişkenleri için kökteki `.env.example` şablonuna bakın; kişisel `.env` dosyası oluşturun (`.gitignore` ile hariç tutulur). Üretimde gerçek sırlar yapılandırma veya gizli yönetim araçları ile verilir.

**Backend + PostgreSQL (PowerShell):**

```powershell
docker compose up -d postgres

cd backend
$env:DB_URL="jdbc:postgresql://localhost:5432/turizim"
$env:DB_USERNAME="turizim"
$env:DB_PASSWORD="turizim_dev_password"
.\mvnw.cmd spring-boot:run
```

JDK için `JAVA_HOME` ayarlı değilse `mvnw` hata verir; yolunu kendi kurulumunuza göre verin.

Ayrıntılı backend adımları: `backend/README.md`.
>>>>>>> 2511fe9 (Backend temel yapısını ve prodocs teslim dokümanlarını düzenle)

```text
docs/database-schema.md
```

<<<<<<< HEAD
---

# Core Business Rules

- Creator selection is always manual.
- System only provides scoring and ranking support.
- Content requirements are objective and checkbox-based.
- No artistic evaluation exists in the system.
- Content delivery is link-based.
- Mock deposit protects agencies against no-show risk.
- Publication visibility minimum is 30 days.
- Creator users are university students only.
- International tours may require passport/visa eligibility.
- Agencies define technical content requirements during listing creation.

---

# Documentation

| Document | Description |
|---|---|
| `docs/prd.md` | Product requirements document |
| `docs/product-scope.md` | MVP scope and exclusions |
| `docs/business-rules.md` | Core business rules |
| `docs/user-flows.md` | User flows |
| `docs/api-contract.md` | API contracts |
| `docs/database-schema.md` | PostgreSQL schema |
| `docs/design-system.md` | UI design system |
| `docs/suitability-score.md` | Scoring algorithm details |
| `docs/cursor-prompts.md` | Cursor AI development prompts |

---

# Important Notes

Tur İzim focuses on operational simplicity and scalable architecture.

The MVP intentionally avoids:
- social platform complexity,
- real-time systems,
- heavy media infrastructure,
- automatic moderation systems.

The primary goal is validating the marketplace and operational workflow between local tour agencies and university student creators.
=======
**Birincil kaynak:** `prodocs/` klasörü.

| Dosya | Açıklama |
|--------|-----------|
| `prodocs/PRD.md` | Ürün gereksinimleri |
| `prodocs/tech-stack.md` | Teknoloji yığını |
| `prodocs/Plan.md` | Yürütme planı (özet) |
| `prodocs/DesignSystem.md` | Tasarım sistemi (Flutter) |
| `prodocs/Progress.md` | İlerleme özeti |
| `prodocs/business-rules.md` | İş kuralları |
| `prodocs/user-flows.md` | Kullanıcı akışları |
| `prodocs/product-scope.md` | Ürün kapsamı özeti |
| `prodocs/api-contract.md` | API sözleşmesi taslağı |
| `prodocs/database-schema.md` | Veri modeli |
| `prodocs/suitability-score.md` | Aday Uygunluk Endeksi (AUE) |
| `prodocs/premium-travel-pass-ui-guidelines.md` | UI kılavuzu |
| `prodocs/stitch-export-screen-map.md` | Stitch ekran eşlemesi |
| `prodocs/cursor-prompts.md` | Cursor teknik prompt şablonları |

Klasör indeksi: `prodocs/README.md`.

> **Not:** Kök `docs/` dizininde yalnızca sınırlı arşiv dosyaları kalmış olabilir; **tam doküman seti `prodocs/` altındadır.**
>>>>>>> 2511fe9 (Backend temel yapısını ve prodocs teslim dokümanlarını düzenle)
