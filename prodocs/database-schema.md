# Veritabanı şeması (taslak)

**SGBD:** PostgreSQL. Tablo ve kolon adları **İngilizce `snake_case`**; açıklamalar **Türkçe**.

> **Taslak notu:** Bu şema yalnızca dokümantasyon taslağıdır; ileride Spring Boot JPA varlıkları ve **Flyway** veya **Liquibase** migrasyonları ile uygulanacaktır.

## Kavram ayrımı (iş kuralı)

- **`Match` tablosu yoktur.**
- **`applications`:** İçerik üreticisinin bir tura **başvurusu** (aday kaydı).
- **`assignments`:** Acentenin başvuruyu **elle kabul etmesinden** sonra oluşturulan **atama**. Depozitonun **HELD** olması, üreticinin **atama/deposit son onayında** oluşur (akış **`PRD.md`**, **`user-flows.md`** ile uyumlu).

### Tur gereksinimleri: profil uyumu ile teslim listesi karıştırılmaz

`tour_content_requirements.requirement_type` değerlerinin iki mantıksal kategorisi vardır:

1. **`Aday Uygunluk Endeksi` içinde kullanılabilenler:**
   - **Teknik Kriter Uyumu (T)** — üretici profilinde **kalıcı yetenek** alanları ile kıyaslanabilir türler (örnek eşlemeler `database-schema.md` ve `suitability-score.md` içinde sabitlenir).
   - **Yayın Platform Uyumu (Y)** — turda seçilen **`INSTAGRAM_PUBLICATION`** satırı **`has_public_instagram`** ile; **`TIKTOK_PUBLICATION`** satırı **`has_public_tiktok`** ile karşılanır (URL’ler destek kartı olarak tutulabilir).

2. **Teslim / yayın kontrolü:** Aşağıdaki türler üreticide `capability` olarak **saklanmaz**, **skora girmez**; teslim veya yayın onayında acente doğrular:  
   `MIN_5_PHOTOS`, `MIN_3_LOCATIONS`, `DAYLIGHT_SHOOTING`, `AGENCY_BRAND_VISIBLE`, `AGENCY_TAG_REQUIRED`, `THIRTY_DAYS_PUBLICATION_REQUIRED` — **`creators`** tablosuna boolean olarak **konmaz**, skor bileşeni **olmaz**.

**`MIN_1080P_VIDEO`** üreticide **`can_record_1080p_video`** alanıyla eşlenir ve **Teknik Kriter Uyumu (T)** paydasına girer (`suitability-score.md`).

### Yurt dışı tur uygunluğu: pasaport/vize kapısı

Yurt dışı turlar için pasaport/vize bilgisi **Aday Uygunluk Endeksi** hesabına dahil edilmez. Bu bilgiler yalnızca başvuru öncesi **must-have uygunluk kapısı** olarak kullanılır.

- Tur `INTERNATIONAL` ise acente pasaport/vize gerekliliklerini belirtmelidir.
- Creator gerekli pasaport/vize koşullarını karşılamıyorsa `application` oluşturulmaz.
- Uygunluk kontrolü skor değildir; uygun değilse düşük skor verilmez, başvuru kapısı kapanır.
- Bu kontrol backend servis katmanında doğrulanır.

## Numaralandırmalar (`ENUM`)

- `student_verification_status`: `UNVERIFIED`, `PENDING_REVIEW`, `VERIFIED`, `REJECTED`

- `user_role`: `ADMIN`, `AGENCY`, `CREATOR`
- `agency_status`: `PENDING_APPROVAL`, `APPROVED`, `REJECTED`, `SUSPENDED`
- `tour_status`: `DRAFT`, `PUBLISHED`, `APPLICATION_CLOSED`, `ASSIGNED`, `COMPLETED`, `CANCELLED`
- `tour_requirement_type`: `MIN_1080P_VIDEO`, `VERTICAL_REELS_FORMAT`, `MIN_5_PHOTOS`, `MIN_3_LOCATIONS`, `DAYLIGHT_SHOOTING`, `RAW_FILES_INCLUDED`, `AGENCY_BRAND_VISIBLE`, `BASIC_EDITING`, `TRAVEL_VLOG_EXPERIENCE`, `INSTAGRAM_PUBLICATION`, `TIKTOK_PUBLICATION`, `AGENCY_TAG_REQUIRED`, `THIRTY_DAYS_PUBLICATION_REQUIRED`
- `application_status`: `PENDING`, `ACCEPTED`, `REJECTED`, `WITHDRAWN`
- `assignment_status`: `PENDING_DEPOSIT`, `ACTIVE`, `WAITING_CONTENT_DRAFT`, `WAITING_AGENCY_APPROVAL`, `REVISION_REQUESTED`, `WAITING_PUBLICATION`, `PUBLICATION_SUBMITTED`, `DEPOSIT_RELEASED`, `UNDER_30_DAY_MONITORING`, `COMPLETED`, `VIOLATION_REPORTED`, `CANCELLED`
- `mock_deposit_status`: `PENDING`, `HELD`, `RELEASED_AFTER_PUBLICATION`, `FORFEITED`
- `content_delivery_status`: `WAITING_DRAFT`, `DRAFT_SUBMITTED`, `APPROVED_FOR_PUBLICATION`, `REVISION_REQUESTED`, `REJECTED`
- `publication_status`: `WAITING_PUBLICATION`, `LINK_SUBMITTED`, `VERIFIED`, `MONITORING_30_DAYS`, `COMPLETED_30_DAYS`, `REMOVAL_REPORTED`, `VIOLATION_CONFIRMED`
- `violation_report_status`: `OPEN`, `UNDER_REVIEW`, `CONFIRMED`, `REJECTED`, `RESOLVED`
- `social_platform`: örn. `INSTAGRAM`, `TIKTOK`, `YOUTUBE`, `OTHER`
- `tour_scope`: `DOMESTIC`, `INTERNATIONAL`
- `departure_region` (tur çıkış yönü / beyan kümesi; örnek değer genişleyebilir): `ADANA`, `MERSIN`, `GAZIANTEP`, `HATAY`, `KONYA`, `KAYSERI` vb.
- `passport_type`: `NONE`, `STANDARD`, `GREEN`, `SERVICE`, `DIPLOMATIC`

**Konum doğrulama:** MVP’de otomatik GPS / harita doğrulaması yoktur. `city`, `campus_city`, tur `departure_city` vb. alanlar **beyana dayalıdır**.

## Tablolar (12)

### `users`

| Kolon           | Tip            | Açıklama          |
| --------------- | -------------- | ----------------- |
| `id`            | UUID PK        | Kullanıcı kimliği |
| `email`         | VARCHAR UNIQUE | Giriş e-postası   |
| `password_hash` | VARCHAR        | Parola özeti      |
| `role`          | ENUM           | `user_role`       |
| `created_at`    | TIMESTAMPTZ    | Oluşturulma       |
| `updated_at`    | TIMESTAMPTZ    | Son güncelleme    |

### `agencies`

| Kolon                    | Tip               | Açıklama                      |
| ------------------------ | ----------------- | ----------------------------- |
| `id`                     | UUID PK           | Acente                        |
| `user_id`                | UUID FK → `users` | Bire bir hesap                |
| `legal_name`             | VARCHAR           | Unvan                         |
| `authorized_person_name` | VARCHAR           | Yetkili kişi adı soyadı       |
| `phone_number`           | VARCHAR           | İletişim telefonu             |
| `city`                   | VARCHAR           | İşletilen şehir beyanı (MVP’de tek şehir yeterli; ileride çok şehir genişlemesi için `operating_cities` benzeri yapı düşünülebilir) |
| `status`                 | ENUM              | Varsayılan `PENDING_APPROVAL` |
| `created_at`             | TIMESTAMPTZ       | Oluşturulma                   |
| `updated_at`             | TIMESTAMPTZ       | Son güncelleme                |

### `creators`

**Kalıcı profil:** sosyal/portföy bilgisi + **yüksek seviyeli içerik yetenek bayrakları** + **öğrenci bilgisi (opsiyonel beyan)**. **Malzeme teslim listesi** (MIN_5_PHOTOS vb.) **`creators` üzerinde tutulmaz**; teslim/yayında acente doğrular.

**Hedef kullanıcı:** Üniversite öğrencisi içerik üreticisi. Öğrenci bilgileri AUE hesabına dahil edilmez.

| Kolon                        | Tip                            | Açıklama                                                               |
| ---------------------------- | ------------------------------ | ---------------------------------------------------------------------- |
| `id`                         | UUID PK                        | İçerik üreticisi                                                       |
| `user_id`                    | UUID FK → `users`              | Hesap                                                                  |
| `display_name`               | VARCHAR                        | Görünen ad                                                             |
| `bio`                        | TEXT                           | İsteğe bağlı                                                           |
| `instagram_url`              | VARCHAR                        | Opsiyonel profil bağlantısı                                            |
| `tiktok_url`                 | VARCHAR                        | Opsiyonel profil bağlantısı                                            |
| `youtube_url`                | VARCHAR                        | Opsiyonel profil bağlantısı                                            |
| `portfolio_url`              | VARCHAR                        | Opsiyonel portfolio bağlantısı                                         |
| `has_public_instagram`       | BOOLEAN                        | Kamuya açık Instagram (Yayın Platform Uyumu için)                      |
| `has_public_tiktok`          | BOOLEAN                        | Kamuya açık TikTok (Yayın Platform Uyumu için)                         |
| `can_create_vertical_video`  | BOOLEAN                        | Dikey video üretebilir                                                 |
| `can_shoot_photos`           | BOOLEAN                        | Fotoğraf çekebilir                                                     |
| `can_deliver_raw_files`      | BOOLEAN                        | Ham dosya teslimi                                                      |
| `has_basic_editing_skill`    | BOOLEAN                        | Temel kurgu montaj bilgisi                                             |
| `has_travel_vlog_experience` | BOOLEAN                        | Seyahat vlog deneyimi                                                  |
| `can_record_1080p_video`     | BOOLEAN                        | En az 1080p video çekim/kayıt yapabilme (`MIN_1080P_VIDEO` karşılığı)  |
| `created_at`                 | TIMESTAMPTZ                    | Oluşturulma                                                            |
| `updated_at`                 | TIMESTAMPTZ                    | Son güncelleme                                                         |
| `passport_type`              | ENUM nullable                  | `passport_type`; yurt dışı tur uygunluğu için bildirilen pasaport türü |
| `has_valid_passport`         | BOOLEAN NOT NULL DEFAULT FALSE | Geçerli pasaport var mı?                                               |
| `visa_eligibility_notes`     | TEXT nullable                  | Vize uygunluğu / açıklama notu; MVP’de manuel beyan ve kontrol için    |
| `university_name`            | VARCHAR nullable               | Üniversite / okul adı (opsiyonel beyan)                       |
| `department_name`            | VARCHAR nullable               | Bölüm adı (opsiyonel beyan)                               |
| `class_year`                 | INT nullable                   | Sınıf (1-4+); opsiyonel                                        |
| `campus_city`                | VARCHAR nullable               | Kampüs şehri (opsiyonel beyan)                              |
| `student_verification_status`| ENUM NOT NULL DEFAULT UNVERIFIED | UNVERIFIED / PENDING_REVIEW / VERIFIED / REJECTED             |

**Öğrenci profil notu:** Bu alanlar AUE hesabına dahil edilmez; otomatik belge doğrulama yoktur; başvuruyu bloke etmez.

**Kaldırılan / yanlıştı:** `capability_min_5_photos`, `capability_min_3_locations`, `capability_daylight_shooting`, `capability_agency_brand_visible`, `capability_agency_tag_required`, `capability_thirty_days_publication_required` ve teslim checklist’inden kopyalanmış tüm **`creators`** alanları.

### `tours`

| Kolon                     | Tip                              | Açıklama                                                          |
| ------------------------- | -------------------------------- | ----------------------------------------------------------------- |
| `id`                      | UUID PK                          | Tur ilanı                                                         |
| `agency_id`               | UUID FK → `agencies`             | Sahip                                                             |
| `title`                   | VARCHAR                          | Başlık                                                            |
| `description`             | TEXT                             | Açıklama                                                          |
| `departure_city`          | VARCHAR                          | Çıkış şehri (liste/detay görünümü için zorunlu beyan formatı)                            |
| `departure_region`        | ENUM                             | Çıkış yönünü kodlayan beyan kümesi (`departure_region` enum; örnek: `ADANA`, `MERSIN`, …) |
| `destination_city`       | VARCHAR nullable                 | Varış şehri / bağlantılı bölüm özeti (`route_summary` boş ise UI’da kullanılır) |
| `destination_cluster`     | ENUM                             | `KAPADOKYA`, `GUNEY` vb. (varış veya bağlantılı rota kümesi)                                   |
| `route_summary`          | VARCHAR nullable                 | Tek satır kısa tur rotası metni                                                                |
| `status`                  | ENUM                             | `tour_status`                                                     |
| `starts_at`               | TIMESTAMPTZ                      | Başlangıç                                                         |
| `ends_at`                 | TIMESTAMPTZ                      | Bitiş                                                             |
| `transportation_included` | BOOLEAN NOT NULL DEFAULT TRUE    | Ulaşım dahil (**MVP ürün kuralına uygun**; tipik olarak `true`)   |
| `tour_scope`              | ENUM NOT NULL DEFAULT `DOMESTIC` | `DOMESTIC` veya `INTERNATIONAL`                                   |
| `requires_passport`       | BOOLEAN NOT NULL DEFAULT FALSE   | Yurt dışı turda geçerli pasaport gerekir mi?                      |
| `required_passport_type`  | ENUM nullable                    | Belirli pasaport türü gerekiyorsa `passport_type`; yoksa nullable |
| `requires_visa`           | BOOLEAN NOT NULL DEFAULT FALSE   | Vize gerekliliği var mı?                                          |
| `visa_requirement_note`   | TEXT nullable                    | Vize gerekliliği açıklaması; örn. ülke, belge, istisna notu       |
| `seats_offered`           | INT                              | Koltuk                                                            |
| `creator_quota`           | INT                              | Seçilebilecek içerik üreticisi üst sayısı                         |
| `deposit_amount`          | NUMERIC(12,2)                    | Mock depozito tutarı                                              |
| `estimated_tour_price`    | NUMERIC(12,2)                    | Referans tur fiyatı                                               |
| `created_at`              | TIMESTAMPTZ                      | Oluşturulma                                                       |
| `updated_at`              | TIMESTAMPTZ                      | Son güncelleme                                                    |

### `tour_content_requirements`

| Kolon              | Tip               | Açıklama                |
| ------------------ | ----------------- | ----------------------- |
| `id`               | UUID PK           | Satır                   |
| `tour_id`          | UUID FK → `tours` | Tur                     |
| `requirement_type` | ENUM              | `tour_requirement_type` |

**MVP yayımlama kuralı:** Tur **`tour_status = PUBLISHED`** olarak yayımlandığında, bu tura bağlı gereksinimler arasında **`INSTAGRAM_PUBLICATION` veya `TIKTOK_PUBLICATION`** türünden **en az biri zorunludur** (ikisi birlikte de seçilebilir). Bunlardan **hiçbiri yoksa** tur MVP kapsamında **yayımlanamaz**. Bkz. `business-rules.md`, `suitability-score.md`.
**Not:** Pasaport/vize gereksinimleri `tour_content_requirements` içinde tutulmaz. Bunlar içerik üretim kriteri değil, yurt dışı tur için başvuru uygunluk kapısıdır ve `tours` + `creators` alanları üzerinden kontrol edilir.

### `applications`

Üç **`accepted_*`** alanı başvuru **ön koşuldur** (**skor bileşeni değildir**); herhangi biri **`false`** ise başvuru **oluşturulmamalıdır** (sunucuda doğrulama).

Yurt dışı turlarda pasaport/vize uygunluğu da başvuru ön koşuludur. Creator, turun pasaport/vize gereksinimlerini karşılamıyorsa **`application` kaydı oluşturulmaz**. Bu uygunluk da **Aday Uygunluk Endeksi** skoruna dahil edilmez.

| Kolon                                 | Tip                       | Açıklama                                                                                          |
| ------------------------------------- | ------------------------- | ------------------------------------------------------------------------------------------------- |
| `id`                                  | UUID PK                   | Başvuru                                                                                           |
| `tour_id`                             | UUID FK → `tours`         | Tur                                                                                               |
| `creator_id`                          | UUID FK → `creators`      | Başvuran                                                                                          |
| `status`                              | ENUM                      | İlk `PENDING`                                                                                     |
| `message`                             | TEXT                      | İsteğe bağlı not                                                                                  |
| `accepted_publication_commitment`     | BOOLEAN NOT NULL          | Kapı şartı; **ön seçili olamaz**                                                                  |
| `accepted_content_usage_permission`   | BOOLEAN NOT NULL          | Kapı şartı; **ön seçili olamaz**                                                                  |
| `accepted_tour_price_claim_condition` | BOOLEAN NOT NULL          | Kapı şartı; **ön seçili olamaz**                                                                  |
| `suitability_score`                   | NUMERIC(5,2)              | Aday Uygunluk Endeksi (0–100)                                                                     |
| `technical_fit_score`                 | NUMERIC(5,2)              | Teknik Kriter Uyumu % (yalnız profille kıyaslanabilir gereksinimler)                              |
| `publication_fit_score`               | NUMERIC(5,2)              | Türkçe ürün adıyla **Yayın Platform Uyumu** yüzdesi (`publication_fit_score` kod adıyla saklanır) |
| `matched_requirement_count`           | INT                       | T paydasına giren gereksinimlerden karşılanan sayı (K<sub>T</sub>)                                |
| `total_requirement_count`             | INT                       | T paydasına giren toplam (N<sub>T</sub>)                                                          |
| `missing_requirements_text`           | TEXT                      | Teknik uyum özeti (**teslim checklist’inin eksikleri ayrıca onay sırasında** izlenir)             |
| `created_at`                          | TIMESTAMPTZ               | Başvuru zamanı                                                                                    |
| `updated_at`                          | TIMESTAMPTZ               | Son güncelleme                                                                                    |
| UNIQUE                                | (`tour_id`, `creator_id`) | Tek başvuru                                                                                       |

### `assignments`

| Kolon                             | Tip                             | Açıklama                                                                                              |
| --------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `id`                              | UUID PK                         | Atama                                                                                                 |
| `tour_id`                         | UUID FK → `tours`               | Tur                                                                                                   |
| `creator_id`                      | UUID FK → `creators`            | Seçilen üretici                                                                                       |
| `application_id`                  | UUID FK UNIQUE → `applications` | Kaynak başvuru                                                                                        |
| `status`                          | ENUM                            | Acentenin kabulünden sonra genelde **`PENDING_DEPOSIT`** başlar                                       |
| `selected_at`                     | TIMESTAMPTZ                     | Acentenin seçim zamanı                                                                                |
| `creator_deposit_acknowledged_at` | TIMESTAMPTZ nullable            | Üretici **asıl/atama-depozito son onay**ını verdiği an (**HELD→ACTIVE tetik bileşeni** ile uyum için) |
| `updated_at`                      | TIMESTAMPTZ                     | Son güncelleme                                                                                        |

### `mock_deposits`

| Kolon                               | Tip                            | Açıklama                                                                                                                  |
| ----------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| `id`                                | UUID PK                        | Kayıt                                                                                                                     |
| `assignment_id`                     | UUID FK UNIQUE → `assignments` | Bire bir                                                                                                                  |
| `status`                            | ENUM                           | Acenteden sonra **`PENDING`**, üretici onayından sonra **`HELD`**; yayın URL sonrası **`RELEASED_AFTER_PUBLICATION`** vb. |
| `amount_snapshot` veya uyumlu kolon | NUMERIC/VARCHAR                | `tours.deposit_amount` ile tutarlı gösterim                                                                               |
| `updated_at`                        | TIMESTAMPTZ                    | Son güncelleme                                                                                                            |

### `content_deliveries`

| Kolon               | Tip                     | Açıklama                              |
| ------------------- | ----------------------- | ------------------------------------- |
| `id`                | UUID PK                 | Teslim satırı                         |
| `assignment_id`     | UUID FK → `assignments` | İşlem                                 |
| `draft_content_url` | TEXT                    | Taslak bağlantı                       |
| `notes`             | TEXT                    | Kontrol ve revizyon notları           |
| `status`            | ENUM                    | `content_delivery_status`             |
| `revision_count`    | INT NOT NULL DEFAULT 0  | MVP en fazla **bir** talep için sayaç |
| `submitted_at`      | TIMESTAMPTZ             | Üretici gönderimi                     |
| `approved_at`       | TIMESTAMPTZ             | Acente onayı                          |
| `updated_at`        | TIMESTAMPTZ             | Son güncelleme                        |

### `publications`

| Kolon                   | Tip                            | Açıklama                                                    |
| ----------------------- | ------------------------------ | ----------------------------------------------------------- |
| `id`                    | UUID PK                        | Yayın kaydı                                                 |
| `assignment_id`         | UUID FK UNIQUE → `assignments` | MVP 1:1                                                     |
| `platform`              | ENUM                           | `social_platform`                                           |
| `published_url`         | TEXT                           | Gönderi URL (**depozitonun salınması bu teslim için şart**) |
| `status`                | ENUM                           | `publication_status`                                        |
| `submitted_at`          | TIMESTAMPTZ                    | Üretici URL bildirir                                        |
| `verified_at`           | TIMESTAMPTZ                    | Manuel doğrulama                                            |
| `monitoring_start_date` | DATE                           | İzlem penceresi başı                                        |
| `monitoring_end_date`   | DATE                           | İzlem penceresi sonu                                        |
| `updated_at`            | TIMESTAMPTZ                    | Son güncelleme                                              |

### `agreements`

Atama oluştuktan ve üretici **deposit son onayı** sürecinden sonra zaman damgasının işlenmesi üründe doğrulanır.

| Kolon                              | Tip                            | Açıklama          |
| ---------------------------------- | ------------------------------ | ----------------- |
| `id`                               | UUID PK                        | Kayıt             |
| `assignment_id`                    | UUID FK UNIQUE → `assignments` | Atama             |
| `creator_id`                       | UUID FK → `creators`           | Taraflardan       |
| `agency_id`                        | UUID FK → `agencies`           | Taraflardan       |
| `allows_agency_social_media_usage` | BOOLEAN                        |                   |
| `allows_promotional_usage`         | BOOLEAN                        |                   |
| `requires_creator_publication`     | BOOLEAN                        |                   |
| `required_publication_days`        | INT NOT NULL DEFAULT 30        |                   |
| `accepted_at`                      | TIMESTAMPTZ                    | Kayıtlı kabul anı |
| `agreement_version`                | VARCHAR                        | Metin sürümü      |

### `violation_reports`

| Kolon                   | Tip                      | Açıklama                  |
| ----------------------- | ------------------------ | ------------------------- |
| `id`                    | UUID PK                  | Bildirim                  |
| `assignment_id`         | UUID FK → `assignments`  |                           |
| `publication_id`        | UUID FK → `publications` | İlişkilendirilmiş yayın   |
| `reported_by_agency_id` | UUID FK → `agencies`     | Bildiren                  |
| `reason`                | TEXT                     | Gerekçe                   |
| `evidence_url`          | TEXT                     | Opsiyonel                 |
| `status`                | ENUM                     | `violation_report_status` |
| `created_at`            | TIMESTAMPTZ              | Oluşturulma               |
| `resolved_at`           | TIMESTAMPTZ              | Çözüm                     |
| `updated_at`            | TIMESTAMPTZ              | Son güncelleme            |

## İndeksler (özet)

FK indeksleri; `applications(tour_id, suitability_score DESC)` sıralama; benzersiz e-posta.

## Migrasyonlar

Flyway/Liquibase + JPA ile `backend`.
