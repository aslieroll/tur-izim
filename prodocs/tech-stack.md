# Teknoloji Yığını — tur.izim MVP

Bu dosya Tur İzim MVP için geçerli **teknik bileşenleri**, seçim gerekçelerini ve AI kullanımını özetler.  
Ayrıntılı iş kuralları ve kapsam: `PRD.md`, `business-rules.md`.

---

## 1. Frontend

| Bileşen | Değer |
|---------|-------|
| Dil | Dart |
| Çatı | Flutter 3.x |
| Hedef platform | Mobil öncelikli; Chrome/web ile geliştirme ve test |
| Mimari | Feature tabanlı clean architecture; repository interface'leri |
| Veri (MVP) | Mock repository; DTO şekilleri `api-contract.md` ile uyumlu |
| Durum yönetimi | Provider / ChangeNotifier (şişman widget'tan kaçınılır) |
| Navigasyon | `go_router` |

**Neden Flutter?**  
Tek kod tabanından hem mobil hem web hedeflenebilir. MVP için Chrome/web üzerinde hızlı iterasyon sağlar; ileride iOS/Android dağıtımı ekstra maliyet gerektirmez. Dart'ın tip güvenliği, repository interface soyutlamasını ve mock↔gerçek geçişini temiz tutar.

---

## 2. Backend

| Bileşen | Değer |
|---------|-------|
| Dil | Java 17+ |
| Çatı | Spring Boot 3.x |
| API stili | REST + JSON |
| Katman yapısı | Controller → Service → Repository |
| İş kuralları | Service katmanında (Flutter widget'ta değil) |
| Derleme | Maven Wrapper (`mvnw` / `mvnw.cmd`) |
| Güvenlik | Spring Security; JWT (Bearer token); `CREATOR` / `AGENCY` / `ADMIN` rolleri |

**Neden Java + Spring Boot?**  
Güvenli ve iyi test edilmiş bir enterprise ekosistemi. JPA/Hibernate ile PostgreSQL entegrasyonu hızlıdır. Spring Security, JWT tabanlı rol yönetimini standart yapıyla sağlar. Yerel tur acentelerinin faturalama ve hukuki entegrasyonu gereken bir sonraki aşamada Java ekosistemi olgun kütüphaneler sunar.

---

## 3. Veritabanı

| Bileşen | Değer |
|---------|-------|
| Veritabanı | PostgreSQL 16 |
| Yerel çalıştırma | Docker Compose (`docker-compose.yml`) |
| Şema yönetimi | TODO: Flyway veya Liquibase migrasyonları (şu an `ddl-auto=update`) |
| Şema kaynağı | `prodocs/database-schema.md` |

**Neden PostgreSQL?**  
Açık kaynak, üretimde kanıtlanmış, JSON sütun desteği var. Tur/başvuru/depozito gibi ilişkisel yapılar için güçlü JOIN ve constraint desteği sunar. Docker Compose ile yerel geliştirme sıfır kurulum maliyetiyle çalışır.

---

## 4. Ödeme Stratejisi

| Yaklaşım | Açıklama |
|----------|----------|
| Harici checkout linki | Backend `AGENCY_PRO_PAYMENT_LINK` / `AGENCY_GROWTH_PAYMENT_LINK` env'den URL döner |
| Kart işleme | Uygulama içi kart işleme **yoktur**; sağlayıcı sayfasına yönlendirilir |
| Kart verisi | Hiçbir kart verisi backend'de saklanmaz; PCI-DSS kapsam dışı |
| Manuel aktivasyon (beta) | Admin `POST /api/billing/admin/subscriptions/manual-activate` ile ACTIVE yapar |
| Webhook (sonraki aşama) | iyzico / PayTR webhook entegrasyonu; `ACTIVE→PAST_DUE` otomatik geçiş |

---

## 5. AI Servisi

| Bileşen | Değer |
|---------|-------|
| Sağlayıcı | OpenRouter API |
| Varsayılan model | `openai/gpt-4o-mini` |
| Ortam değişkeni | `OPENROUTER_API_KEY`, `OPENROUTER_MODEL` |

**MVP'de AI kullanım alanları:**

- **Ürün geliştirme desteği** — PRD, iş kuralları, kullanıcı akışları ve API sözleşmesi taslaklarının oluşturulmasında LLM asistanı olarak kullanıldı (Cursor Agent).
- **Kod iskelet ve review** — Flutter widget iskeletleri, Spring Boot servis desenleri için yardımcı araç.
- **Dokümantasyon tutarlılığı** — Birden fazla dokümanın çelişki analizi ve terminoloji kontrolü.

**MVP sonrası planlanan AI kullanımı:**

- Creator başvuru kalitesi hakkında açıklayıcı öneriler (karar verici değil, karar destekleyici)
- Acente tur ilanı içerik kontrolü (teknik şart tutarlılığı)

**AI kapsamı dışında kalan:**

- Otomatik creator seçimi / eşleştirme
- Otomatik sosyal medya izleme
- Video analizi (MVP)
- Gerçek ödeme akışı

**Neden OpenRouter?**  
Tek API anahtarıyla birden fazla LLM'e (GPT-4o, Claude, Gemini) erişim sağlar. Model değişikliği sadece `OPENROUTER_MODEL` ortam değişkeni güncellenerek yapılabilir; kod değişikliği gerektirmez. `gpt-4o-mini` düşük maliyet / yeterli kalite dengesi sunar.

---

## 5. Yerel Geliştirme Altyapısı

| Bileşen | Değer |
|---------|-------|
| Konteyner | Docker Desktop |
| Orkestrasyon | Docker Compose (kök `docker-compose.yml`) |
| Yerel seed | `app.dev-seed=true` ile demo acente + creator + tur verisi |

---

## 6. Bilinçli MVP Dışı / Ertelenen

| Bileşen | Gerekçe |
|---------|---------|
| Gerçek ödeme ağ geçidi | Harici checkout linki (beta); webhook otomasyonu MVP sonrası |
| Kart veri depolama | Asla; uygulama kart verisi saklamaz, PCI-DSS kapsam dışı |
| Flyway/Liquibase | `ddl-auto=update` MVP için kabul edilebilir; üretim öncesi geçilmeli |
| Redis / önbellek | MVP ölçeği gerektirmiyor |
| Message queue | MVP ölçeği gerektirmiyor |
| e-İmza | PDF/e-imza entegrasyonu MVP sonrası |
| Admin mobil UI | MVP'de web yeterli |

---

## İlgili Dokümanlar

- `PRD.md` — ürün kapsamı ve sınırlar
- `api-contract.md` — REST sözleşmesi taslağı
- `database-schema.md` — kalıcı veri modeli
- `suitability-score.md` — AUE formülü
