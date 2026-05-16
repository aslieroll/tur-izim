# Teknoloji yığını

Bu dosya Tur İzim MVP için geçerli **teknik bileşenleri** özetler. Ayrıntılı iş kuralları ve kapsam `PRD.md` ile `business-rules.md` içindedir.

## İstemci (frontend)

| Bileşen | Açıklama |
|--------|-----------|
| **Dil / çatı** | Dart, Flutter |
| **Hedef** | Mobil öncelikli; web (ör. Chrome) geliştirme ve test |
| **Mimari** | Feature tabanlı temiz mimari; repository arayüzleri |
| **Veri (MVP)** | Mock repository; DTO şekilleri `api-contract.md` ile uyumlu olacak şekilde |

## Sunucu (backend)

| Bileşen | Açıklama |
|--------|-----------|
| **Dil / çatı** | Java 17+, Spring Boot 3.x |
| **API** | REST + JSON |
| **Yapı** | Controller → Service → Repository; iş kuralları servis katmanında |
| **Derleme** | Maven (tercihen depo içi `mvnw` / `mvnw.cmd`) |

## Veri ve altyapı

| Bileşen | Açıklama |
|--------|-----------|
| **Veritabanı** | PostgreSQL (MVP şeması `database-schema.md`) |
| **Yerel ortam** | Docker Compose ile PostgreSQL (kök `docker-compose.yml`) |

## Bilinçli MVP dışı / ertelenen

- Gerçek ödeme ağ geçidi (mock depozito)
- Üretim düzeyi kimlik doğrulama (JWT vb. aşamalandırılabilir; durum `Progress.md`)

## İlgili dokümanlar

- `PRD.md` — ürün kapsamı ve sınırlar  
- `api-contract.md` — REST sözleşmesi taslağı  
- `database-schema.md` — kalıcı model  
