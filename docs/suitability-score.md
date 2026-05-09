# Aday Uygunluk Endeksi (MVP)

Türkçe ürün adı **Aday Uygunluk Endeksi** (`applications.suitability_score`).

Tur İzim **otomatik seçim**, **otomatik yerleştirme** veya **en yüksek skora göre sistem ataması** yapmaz. **`Assignment`**, ancak **acente elle kabul ettikten** sonra oluşur. **`Match` yoktur.**

---

## Başvuru üçlüsü: skora dahil değildir (zorunlu kapı)

Aşağıdaki alanlar **false / eksik ise** sunucuda **`applications` kaydı oluşturulmamalıdır**; bunlar **Aday Uygunluk Endeksinin parçası değildir**:

- `accepted_publication_commitment`  
- `accepted_content_usage_permission`  
- `accepted_tour_price_claim_condition`  

**Ön seçili kutucuk olamaz.**

---

## Formül

**Aday Uygunluk Endeksi = Teknik Kriter Uyumu × %75 + Yayın Platform Uyumu × %25**

**AUE = (0,75 × T) + (0,25 × Y)**

---

## Yayımlanabilir tur için platform zorunluluğu (MVP)

Tur **`PUBLISHED`** statüsü ile yayımlandığında, bağlı **`tour_content_requirements`** içinde **`INSTAGRAM_PUBLICATION`** veya **`TIKTOK_PUBLICATION`** türlerinden **en az biri seçili olmalıdır**. **Hiçbir yayın platform gereksinimi yoksa tur MVP’de yayımlanamaz.** Bu kural aynı zamanda **Y (Yayın Platform Uyumu)** hesabının paydasının **sıfır olmamasını** garanti eder.

---

## 1. Teknik Kriter Uyumu (T)

**Yalnızca**, turda seçilmiş ve üretici profil ile **doğrudan kıyaslanabilen** gereksinim alt kümesi kullanılır (**teslim kontrol listesi maddeleri T’ye dahil değildir**):

**Bu türler T skorunda yoktur (profilde ilgili kalıcı yetenlik alanı yok; teslim/onayda kontrol):**  
`MIN_5_PHOTOS`, `MIN_3_LOCATIONS`, `DAYLIGHT_SHOOTING`, `AGENCY_BRAND_VISIBLE`, `AGENCY_TAG_REQUIRED`, `THIRTY_DAYS_PUBLICATION_REQUIRED`

**T için profil karşılıkları** (`tour_requirement_type` → `creators`):

| `tour_requirement_type` | Profil karşılığı (`creators`) |
|--------------------------|--------------------------------|
| `MIN_1080P_VIDEO` | `can_record_1080p_video` |
| `VERTICAL_REELS_FORMAT` | `can_create_vertical_video` |
| `RAW_FILES_INCLUDED` | `can_deliver_raw_files` |
| `BASIC_EDITING` | `has_basic_editing_skill` |
| `TRAVEL_VLOG_EXPERIENCE` | `has_travel_vlog_experience` |

> **Not:** `INSTAGRAM_PUBLICATION` ve `TIKTOK_PUBLICATION` **T paydasına dahil edilmez**; **Y (Yayın Platform Uyumu)** içinde ele alınır.

> **Çekim:** `MIN_5_PHOTOS` T’ye girmez; teslim sürecinde doğrulanır.

- **N<sub>T</sub>** = turda seçili ve **yukarıdaki tabloya dahil** gereksinim satırı sayısı.  
- **K<sub>T</sub>** = bunlardan üreticide karşılananların sayısı.  
- **T = (K<sub>T</sub> ÷ N<sub>T</sub>) × 100**. **N<sub>T</sub> = 0** ise (turda tabloya giren teknik gereksinim seçilmemişse) **T = %100** kabul edilir (**payda sıfıra bölünmez**, bu durumda **K<sub>T</sub> = 0**).

`applications.matched_requirement_count`, `total_requirement_count` ve `missing_requirements_text` **yalnızca T** kümesine göre doldurulur.

---

## 2. Yayın Platform Uyumu (Y)

MVP’de yayımlı turlarda **en az bir** yayın gereksinimi vardır; payda **sıfır olamaz**.

Turda seçilmiş olan her bir yayın gereksinimi için:

- **`INSTAGRAM_PUBLICATION`** → üreticide **`has_public_instagram = true`** olmalı.  
- **`TIKTOK_PUBLICATION`** → üreticide **`has_public_tiktok = true`** olmalı.

**Y = (karşılanan yayın platform gereksinim sayısı ÷ turda seçilmiş yayın platform gereksinim sayısı) × 100**

Payda, turda işaretlenen **`INSTAGRAM_PUBLICATION` / `TIKTOK_PUBLICATION`** satırlarının toplamıdır (1 veya 2).

`instagram_url` / `tiktok_url` doğrulama veya güven kartı için kullanılabilir; **Y’nin hesabında** asıl kriter **`has_public_instagram` / `has_public_tiktok`** boole değerleridir.

---

## Saklama (applications)

| Alan | İçerik |
|------|--------|
| `suitability_score` | **AUE** |
| `technical_fit_score` | **T** |
| `publication_fit_score` | **Y** (Yayın Platform Uyumu) |
| Sayıcı ve metinler | **T** özeti (**teslim checklist eksikleri** ayrı akış) |

---

## Uyum etiketi (AUE aralığı)

| AUE aralığı | Türkçe etiket |
|--------------|----------------|
| 85–100 | Çok Yüksek Uyum |
| 70–84 | Yüksek Uyum |
| 50–69 | Orta Uyum |
| 0–49 | Düşük Uyum |

---

## Acente kartında görünüm

**AUE**, **Teknik Kriter Uyumu (T)**, **Yayın Platform Uyumu**, **K<sub>T</sub> / N<sub>T</sub>**, **`missing_requirements_text`**. **Teslim listesi** gereksinimleri (ör. `MIN_5_PHOTOS`) **teslim / yayında** takip edilir; skorda zorunlu gösterilmeyebilir.

---

## Kritik sınır

**Skor tek başına atama oluşturmaz.**

---

## Dokümantasyon

`business-rules.md`, `database-schema.md`, `api-contract.md`.
