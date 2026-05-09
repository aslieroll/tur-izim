# Tur İzim

Boş **ulaşım dahil** tur koltukları olan yerel tur acenteleri ile genç **UGC içerik üreticileri** ve mikro influencer’ları buluşturan **B2B/B2C güven ve operasyon** platformu. Tur İzim bir seyahat acentesi, sosyal ağ veya otel/uçuş satıcısı değildir.

## Depo yapısı

| Dizin | Rol |
|--------|-----|
| `backend/` | Java Spring Boot REST API (PostgreSQL) |
| `frontend/` | Flutter / Dart, mobil öncelikli uygulama |
| `docs/` | Türkçe PRD, kapsam, iş kuralları, akışlar, API şeması, veri modeli, tasarım sistemi; Cursor için İngilizce şablonlar |

## Pilot kapsamı

- Çıkış: yalnızca **Adana / Mersin**  
- İlk varışlar: **Kapadokya**, **Güney** turları  
- Tur tipi: yalnızca **ulaşım dahil acente turları**

## MVP sınırları

- Otomatik eşleştirme yok: yalnızca **uygunluk skoru ve sıralama**; içerik üreticisini **acente elle seçer**.  
- **Mock depozito** (gerçek ödeme yok).  
- **Bağlantı tabanlı** içerik (uygulama içi video yükleme yok).  
- **Manuel** yayın URL’si ve ihlal bildirimi (otomatik sosyal izleme yok).  
- Sosyal akış, sohbet, otel ve uçuş rezervasyonu yok.

## Yerel veritabanı (isteğe bağlı)

Depo kökünden:

```bash
docker compose up -d
```

PostgreSQL geliştirme için yayınlanır; Spring Boot yapılandırması aynı kimlik bilgileriyle eşleştirilir (`docs/database-schema.md` ve ileride `backend` ayarları).

## Dokümantasyon

Ana referans: `docs/prd.md`. Özet kapsam `docs/product-scope.md`, kurallar `docs/business-rules.md`, akışlar `docs/user-flows.md`. API ve veri modeli: `docs/api-contract.md`, `docs/database-schema.md`. Geliştirme komut şablonları: `docs/cursor-prompts.md` (İngilizce).
