# Tur İzim

Tur İzim, boş **ulaşım dahil tur koltuklarına** sahip yerel tur acenteleri ile üniversite öğrencisi genç **UGC içerik üreticileri** ve mikro influencer’ları güvenli şekilde buluşturan bir **B2B/B2C güven ve operasyon platformudur**.

Platform; tarafların güvenli şekilde anlaşmasını, içerik teslimini ve operasyonel sürecin yönetimini kolaylaştırır.

> Tur İzim bir seyahat acentesi değildir.  
> Sosyal medya platformu değildir.  
> Otel veya uçak bileti satışı yapmaz.

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

```bash
docker compose up -d
```

Spring Boot configuration should match the credentials defined in:

```text
docs/database-schema.md
```

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
