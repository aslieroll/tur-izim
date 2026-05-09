# Aday Uygunluk Endeksi (MVP)

Türkçe ürün adı **Aday Uygunluk Endeksi** (`applications.suitability_score`).

Tur İzim **otomatik seçim**, **otomatik yerleştirme** veya **en yüksek skora göre sistem ataması** yapmaz. **`Assignment`**, ancak **acente elle kabul ettikten** sonra oluşur. **`Match` yoktur.**

---

## Başvuru kapıları: skora dahil değildir

Aşağıdaki alanlar **false / eksik ise** sunucuda **`applications` kaydı oluşturulmamalıdır**; bunlar **Aday Uygunluk Endeksinin parçası değildir**:

- `accepted_publication_commitment`
- `accepted_content_usage_permission`
- `accepted_tour_price_claim_condition`

**Ön seçili kutucuk olamaz.** Creator bu üç onayı manuel olarak işaretlemelidir.

Yurt dışı turlar için ayrıca pasaport/vize uygunluğu kontrol edilir:

- Tur `INTERNATIONAL` ise creator’ın pasaport/vize uygunluğu başvuru öncesi kontrol edilmelidir.
- Creator turun pasaport/vize gereksinimlerini karşılamıyorsa **`applications` kaydı oluşturulmamalıdır**.
- Pasaport/vize uygunluğu **T**, **Y** veya **AUE** hesabına dahil edilmez.
- Uygun olmayan creator’a düşük skor verilmez; başvuru kapısı kapanır.

---

## Formül

**Aday Uygunluk Endeksi = Teknik Kriter Uyumu × %75 + Yayın Platform Uyumu × %25**

**AUE = (0,75 × T) + (0,25 × Y)**

> **Skor dışı kapılar:** Başvuru checkbox üçlüsü ve yurt dışı tur pasaport/vize uygunluğu bu formülün parçası değildir. Bunlar yalnızca başvuru oluşturma ön koşuludur.

---

## Yayımlanabilir tur için platform zorunluluğu (MVP)

Tur **`PUBLISHED`** statüsü ile yayımlandığında, bağlı **`tour_content_requirements`** içinde **`INSTAGRAM_PUBLICATION`** veya **`TIKTOK_PUBLICATION`** türlerinden **en az biri seçili olmalıdır**. **Hiçbir yayın platform gereksinimi yoksa tur MVP’de yayımlanamaz.** Bu kural aynı zamanda **Y (Yayın Platform Uyumu)** hesabının paydasının **sıfır olmamasını** garanti eder.

---

## 1. Teknik Kriter Uyumu (T)

**Yalnızca**, turda seçilmiş ve üretici profil ile **doğrudan kıyaslanabilen** gereksinim alt kümesi kullanılır (**teslim kontrol listesi maddeleri T’ye dahil değildir**):

**Bu türler T skorunda yoktur (profilde ilgili kalıcı yetenlik alanı yok; teslim/onayda kontrol):**  
`MIN_5_PHOTOS`, `MIN_3_LOCATIONS`, `DAYLIGHT_SHOOTING`, `AGENCY_BRAND_VISIBLE`, `AGENCY_TAG_REQUIRED`, `THIRTY_DAYS_PUBLICATION_REQUIRED`

**T için profil karşılıkları** (`tour_requirement_type` → `creators`):

| `tour_requirement_type`  | Profil karşılığı (`creators`) |
| ------------------------ | ----------------------------- |
| `MIN_1080P_VIDEO`        | `can_record_1080p_video`      |
| `VERTICAL_REELS_FORMAT`  | `can_create_vertical_video`   |
| `RAW_FILES_INCLUDED`     | `can_deliver_raw_files`       |
| `BASIC_EDITING`          | `has_basic_editing_skill`     |
| `TRAVEL_VLOG_EXPERIENCE` | `has_travel_vlog_experience`  |

> **Not:** `INSTAGRAM_PUBLICATION` ve `TIKTOK_PUBLICATION` **T paydasına dahil edilmez**; **Y (Yayın Platform Uyumu)** içinde ele alınır.

> **Çekim:** `MIN_5_PHOTOS` T’ye girmez; teslim sürecinde doğrulanır.

- **N<sub>T</sub>** = turda seçili ve **yukarıdaki tabloya dahil** gereksinim satırı sayısı.
- **K<sub>T</sub>** = bunlardan üreticide karşılananların sayısı.
- **T = (K<sub>T</sub> ÷ N<sub>T</sub>) × 100**.
- **N<sub>T</sub> = 0** ise (turda tabloya giren teknik gereksinim seçilmemişse) **T = %100** kabul edilir (**payda sıfıra bölünmez**, bu durumda **K<sub>T</sub> = 0**).

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

## Pasaport/vize uygunluğu ve skor ayrımı

Pasaport/vize uygunluğu içerik üretim kalitesi, teknik üretim yetkinliği veya yayın platform uyumu değildir. Bu nedenle:

- `technical_fit_score` içine girmez.
- `publication_fit_score` içine girmez.
- `suitability_score` değerini artırmaz veya düşürmez.
- `matched_requirement_count`, `total_requirement_count` ve `missing_requirements_text` içinde gösterilmez.
- Yalnızca yurt dışı tur için başvuru oluşturma uygunluğu olarak değerlendirilir.

Örnek:

- Creator’ın AUE değeri 95 olabilir.
- Ancak tur `INTERNATIONAL` ve creator’ın geçerli pasaportu yoksa başvuru oluşturulmaz.
- Bu durumda sistem “AUE düşük” demez; “pasaport/vize gereksinimi karşılanmadı” mesajı döner.

---

## Saklama (applications)

| Alan                    | İçerik                                                 |
| ----------------------- | ------------------------------------------------------ |
| `suitability_score`     | **AUE**                                                |
| `technical_fit_score`   | **T**                                                  |
| `publication_fit_score` | **Y** (Yayın Platform Uyumu)                           |
| Sayıcı ve metinler      | **T** özeti (**teslim checklist eksikleri** ayrı akış) |

---

## Uyum etiketi (AUE aralığı)

| AUE aralığı | Türkçe etiket   |
| ----------- | --------------- |
| 85–100      | Çok Yüksek Uyum |
| 70–84       | Yüksek Uyum     |
| 50–69       | Orta Uyum       |
| 0–49        | Düşük Uyum      |

---

## Acente kartında görünüm

**AUE**, **Teknik Kriter Uyumu (T)**, **Yayın Platform Uyumu**, **K<sub>T</sub> / N<sub>T</sub>**, **`missing_requirements_text`**.

**Teslim listesi** gereksinimleri (ör. `MIN_5_PHOTOS`) **teslim / yayında** takip edilir; skorda zorunlu gösterilmeyebilir.

Pasaport/vize uygunluğu acente kartında gerekiyorsa ayrı “uygunluk kapısı” bilgisi olarak gösterilebilir; **AUE’nin alt kırılımı gibi gösterilmemelidir**.

---

## Kritik sınır

**Skor tek başına atama oluşturmaz.**

Aday Uygunluk Endeksi yalnızca karar destek bilgisidir. Sistem otomatik seçim, otomatik yerleştirme veya rastgele atama yapmaz.

Pasaport/vize uygunluğu ise karar destek skoru değildir; yurt dışı turlar için başvuru ön koşuludur.

---

## Dokümantasyon

`business-rules.md`, `database-schema.md`, `api-contract.md`.
