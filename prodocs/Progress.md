# İlerleme durumu

Bu dosya **ürün / mühendislik ilerlemesinin** kısa özetidir. Tarihçe için commit mesajları ve iş kayıtları tam kaynak olabilir.

**Son güncelleme:** 2026-05-16 (dokümantasyon teslim formatı — `prodocs` zorunlu dosya adları)

---

## Tamamlanan / istikrarlı

| Alan | Not |
|------|-----|
| Ürün dokümantasyonu | `prodocs/` altında PRD, iş kuralları, akışlar, şema, API taslağı, AUE, tasarım sistemi bileşenleri |
| Flutter | Shell; `flutter analyze` / `test`; router–session–repository arayüz slice (Aşama 2.1) |
| Backend temel | Spring Boot iskeleti; `GET /api/health`; PostgreSQL ortam değişkenleri; Maven Wrapper |
| Yerel veritabanı | Kök `docker-compose.yml` ile PostgreSQL 16 servisi |

## Devam eden veya sıradaki (MVP’ye göre)

| Alan | Not |
|------|-----|
| Backend domain | Entity’ler, migration’lar, asıl REST uçları (`api-contract.md` ile hizalı dilimler) |
| Kimlik doğrulama | Üretim düzeyi JWT/oturum erken aşama veya sonraya bırakılabilir |
| Flutter ↔ API | Mock’tan gerçek API’ye geçiş ve DTO hizalaması |

## Son kararlar

- Ürün ve teknik **kaynak gerçeği** `prodocs/` klasöründedir; teslim dosya adları: `PRD.md`, `DesignSystem.md`, `tech-stack.md`, `Plan.md`, `Progress.md`.
- `Match` dili kullanılmaz; **Assignment** kullanılır.

## Nasıl güncellenir?

Önemli kilometre taşları eklendiğinde bu dosyaya kısa bir not ekleyin.
