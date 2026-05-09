# API sözleşmesi (taslak)

**Backend:** Java **Spring Boot**, **PostgreSQL**. Temel kök `/api`; sürüm örn. `/api/v1` uygulanırken eklenir. JSON gövdeler varsayılarak.

**Katmanlı mimari:** `Controller → Service → Repository`. **İş kuralları** (skor hesapları, depozito geçişleri, tek revizyon, `assignment` oluşturma, ihlalin teyidi) **serviste** bulunmalıdır (`prd.md`, `business-rules.md` uyumu).

Tur İzim’de **`Match`** kaynak ucu **yoktur**; atanmışlık **`assignments`** üzerinden yönetilir.

---

## 1. Auth (Kimlik)

| Kavramsal uç          | Açıklama                                                                                |
| --------------------- | --------------------------------------------------------------------------------------- |
| `POST /auth/register` | Kayıt; rol parametresine göre `CREATOR`, `AGENCY` veya `ADMIN` oluşturma politikası ile |
| `POST /auth/login`    | Oturum / JWT yayını                                                                     |

Gerçek yol yapısı uygulanırken güvenlik şeması (Spring Security vb.) ile hizalanır.

---

## 2. Agencies (Agency tarafı + admin doğrulama)

| Metot       | Örnek yol                                            | Açıklama                                            |
| ----------- | ---------------------------------------------------- | --------------------------------------------------- |
| `POST`      | `/agencies/register` veya `/agencies/me` oluşturma   | Acente profil kaydı (**`PENDING_APPROVAL`** başlar) |
| `GET/PATCH` | `/agencies/me`                                       | Güncellenmiş profil                                 |
| `POST`      | `/admin/agencies/{id}/approve`                       | Admin onayı                                         |
| `POST`      | `/admin/agencies/{id}/reject` veya süspansiyon sonra | Red / **ileride suspend** uyumlu şema ile           |

---

## 3. Creators

| Metot       | Yol                                                | Açıklama                                                                                                                                                                                                                                                                                                                                                                                           |
| ----------- | -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `POST`      | `/creators/register` veya kombine `/auth/register` | İçerik üreticisi                                                                                                                                                                                                                                                                                                                                                                                   |
| `GET/PATCH` | `/creators/me`                                     | Creator profil bilgileri: sosyal URL’ler, yayın platformu uygunluk booleanları, içerik üretim yetkinlikleri (`can_record_1080p_video`, `can_create_vertical_video`, `can_deliver_raw_files`, `has_basic_editing_skill`, `has_travel_vlog_experience`, `has_public_instagram`, `has_public_tiktok`) ve yurt dışı tur uygunluğu için `passport_type`, `has_valid_passport`, `visa_eligibility_notes` |

---

## 4. Tours

| Metot  | Yol                                | Açıklama                                                                                                                                                                                           |
| ------ | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `POST` | `/tours`                           | Tur oluştur — yalnızca **onaylı** acente; pilot + `estimated_tour_price`, **`creator_quota`**, **`deposit_amount`**, `tour_scope`, pasaport/vize alanları ve `tour_requirement_type` satırları ile |
| `GET`  | `/tours/public` veya `/tours/open` | **Yayımlanmış**, creator profiline göre başvuruya uygun liste. Yurt dışı turda pasaport/vize uygunluğu yoksa creator’a gösterilmeyebilir veya başvuru engellenir                                   |
| `GET`  | `/tours/{id}`                      | Tekil tur detayı; yurt dışı tur ise pasaport/vize gereksinim bilgileri görünür                                                                                                                     |

---

## 5. Applications

| Metot    | Yol                            | Açıklama                                                                                                                                                                                                                                                                                                                                              |
| -------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `POST`   | `/tours/{tourId}/applications` | İçerik üreticisi **başvurur**. **`accepted_*` üçünün de `true` olması zorunlu**dur; aksi halde **başvuru kaydı oluşturulmaz** (**skor parçası değildirler** — `suitability-score.md`). UI’da **ön işaret yoktur**. Tur `INTERNATIONAL` ise creator’ın pasaport/vize uygunluğu da sunucuda kontrol edilir; uygun değilse **application oluşturulmaz**. |
| Sunucuda | Hesaplama çıktıları            | **`suitability_score`**, `technical_fit_score`, `publication_fit_score`, **Teknik uyum için** sayıcılar ve **`missing_requirements_text`** yazılır (teslim checklist eksikleri ayrı ekrandan)                                                                                                                                                         |
| `GET`    | `/tours/{tourId}/applications` | **Acenteye:** sırayla **skora göre** listelemek (**yüksek puana sistemsel seçim yapılmaz**)                                                                                                                                                                                                                                                           |

**Yurt dışı uygunluk kontrolü:** Pasaport/vize uygunluğu Aday Uygunluk Endeksi hesabına dahil edilmez. Bu kontrol başvuru öncesi must-have kapıdır. Creator uygun değilse düşük skor verilmez; başvuru kaydı oluşturulmaz.

Durum güncelleme (**`accept`/`reject`**) doğrudan veya `Applications` altı yolları ile acente yetkisiyle yapılır.

---

## 6. Assignments

| Metot  | Yol                                                                                             | Açıklama                                                                                                                                      |
| ------ | ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `POST` | `/tours/{tourId}/applications/{applicationId}/accept`                                           | **Yalnızca acente** — `Assignment` oluşur (**`PENDING_DEPOSIT`**), bağlı **`mock_deposit`** **`PENDING`** olur (**`HELD` değildir**)          |
| `POST` | `/assignments/{assignmentId}/confirm-deposit` (örnek yol adı; uygulanırken güvenliği netleştir) | **Yalnızca ilgili içerik üreticisi** — üç kutunun tekrarı **doğrulanmalı**; servis **`mock_deposit` → HELD**, **`assignment` → ACTIVE** yapar |

**Otomatik `Assignment` üreten uç yoktur.** **`accept`** çağrısı doğrudan **`HELD`** yapmaz.

---

## 7. Deposits (Mock)

| Kavram           | Açıklama                                                                                                                                                       |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| Sunucu durumları | Acenteden sonra **`PENDING`** → üretici onayından sonra **`HELD`** → yayın bağlantısından sonra **`RELEASED_AFTER_PUBLICATION`** / gerekiyorsa **`FORFEITED`** |
| Örnek            | `GET /assignments/{id}/deposit` veya gömülü DTO                                                                                                                | **Gerçek ödeme sağlayıcı çağrısı yoktur** |

---

## 8. Deliveries (Taslak bağlantı)

| Metot  | Yol                                             | Açıklama                                               |
| ------ | ----------------------------------------------- | ------------------------------------------------------ |
| `POST` | `/assignments/{id}/deliveries/draft`            | **`draft_content_url`** gönder                         |
| `POST` | `/assignments/{id}/deliveries/approve`          | Acente onayı                                           |
| `POST` | `/assignments/{id}/deliveries/request-revision` | **Tek** revizyon; **teknik kontrol listesi** gerekçesi |

---

## 9. Publications

| Metot          | Yol                                             | Açıklama                                                                                   |
| -------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `POST`         | `/assignments/{id}/publications/submit-link`    | **`published_url`**, `platform`                                                            |
| Sunucu         | Durum geçişleri                                 | `LINK_SUBMITTED` → `VERIFIED` (manuel) → `MONITORING_30_DAYS`; **otomatik sosyal API yok** |
| Tarih alanları | `monitoring_start_date` / `monitoring_end_date` | 30 günlük pencere                                                                          |

---

## 10. Agreements

| Metot          | Yol                                                                                  | Açıklama                                                                                                                                                                                                               |
| -------------- | ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sunucu tetikli | **`Assignment`** oluşturma ve **`confirm-deposit`** (üreticide son onay) adımlarında | **`agreements`** satırı (`agreement_version`, izin bayrakları, `required_publication_days=30`, `accepted_at`); `accepted_at`, **ilk veya yeniden doğrulanan onay zamanında** atanır (`database-schema.md` ile tutarlı) |

**PDF ve e-imza uçları yoktur.**

---

## 11. Violations

| Metot       | Yol                                                                 | Açıklama                                                             |
| ----------- | ------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `POST`      | `/publications/{id}/violations` veya `/assignments/{id}/violations` | Acente **manuel** rapor — `reason`, `evidence_url`                   |
| `GET/PATCH` | `/admin/violations/...`                                             | Admin incelemesi; **`CONFIRMED`** sonrası kayıtlı talep hakkı sonucu |

---

## 12. Admin — özet

- Bekleyen acenteler, ihlal listesi ve rapor detayı (yukarıdaki gruplarla birleştirilebilir).

## Ortak standartlar

- Hata gövdesi: `{ "code", "message", "details?" }`
- Sayfalama: `page`, `size`, `sort`

## API’de yasaklı ürün davranışları

- Rastgele veya skorla **otomatik `Assignment`**.
- **Stripe / iyzico** veya kart çekimi.
- Çoklu revizyon hakkı.
- **Medya dosyası multipart** ile taslak beklenmesi (MVP yalnızca **URL**).
- Yurt dışı turda pasaport/vize uygunluğu yokken başvuru kaydı oluşturulması.
