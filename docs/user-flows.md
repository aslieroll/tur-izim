# Kullanıcı akışları (MVP)

Durum kodları İngilizce olabilir; açıklamalar Türkçedir.

---

## Admin

1. Bekleyen acente listesi (`PENDING_APPROVAL`) → `APPROVED` veya `REJECTED`.
2. İhlal raporları: admin `UNDER_REVIEW` sonrasında `CONFIRMED` veya reddedilir. `CONFIRMED` durumunda tur bedeli ile ilgili talep hakları **kayıt düzeyinde** tutulur; MVP gerçek tahsilat içermez.

---

## Acente (Agency)

### Kurumsal kayıt

1. **`PENDING_APPROVAL`** iken yayımlanmış tur oluşturmaz. Profilde `authorized_person_name`, `phone_number`, `city` kullanılabilir (`database-schema.md`).

### Tur ve gereksinimler

2. Tur parametreleri: pilot çıkış, `deposit_amount`, `estimated_tour_price`, `creator_quota`, `transportation_included` (varsayılan `true`, MVP iş kuralı), `tour_scope` (`DOMESTIC` / `INTERNATIONAL`), varsa pasaport/vize gereksinimleri.
3. **`tour_content_requirements`** satırları: hem **uygunluk endeksinde kullanılan** türleri hem **yalnızca teslim / yayında doğrulanan** gereksinimleri içerebilir; ikinci grup **profilde saklanmaz** ve **Teknik uyum paydasına (T) dahil edilmez** (`suitability-score.md`). Tur **`PUBLISHED`** ise **`INSTAGRAM_PUBLICATION`** veya **`TIKTOK_PUBLICATION`** seçimlerinden **en az biri zorunludur**; yoksa tur MVP kapsamında **yayımlanamaz** (`business-rules.md`).

### Yurt dışı tur uygunluğu

4. Tur `INTERNATIONAL` ise acente pasaport/vize gereksinimlerini açıkça belirtir.
5. Pasaport/vize gereksinimi eksik olan yurt dışı tur yayımlanamaz veya taslakta kalır.
6. Creator profilindeki pasaport/vize uygunluğu, yurt dışı tur için başvuru öncesi kontrol edilir.
7. Creator gerekli pasaport/vize uygunluğunu karşılamıyorsa ilan creator karşısına çıkarılmayabilir veya başvuru sunucuda reddedilir.
8. Bu kontrol **Aday Uygunluk Endeksi** hesabına dahil değildir; yalnızca **must-have başvuru kapısıdır**.

### Başvurular ve sıralama

### Başvurular ve sıralama

9. Başvurular **`suitability_score`** azalan sırada listelenir. Kartlar **Teknik Kriter Uyumu**, **Yayın Platform Uyumu** ve `missing_requirements_text` özeti ile desteklenebilir.

### Elle kabul, başvuru statüleri ve kota

10. Acentenin seçtiği **her** başvuru için yalnızca o **`Application`** kaydı **`ACCEPTED`** olur. **Diğer başvurular aynı anda otomatik `REJECTED` olmak zorunda değildir.**
11. **`creator_quota` dolduğunda** tur **`APPLICATION_CLOSED`** yapılır; kalan bekleyen başvurular **kota nedeniyle** **`REJECTED`** olabilir (kullanıcıya net bildirim).

### Atama ve mock depozito sırası

12. Manuel kabul ile **`Assignment`** oluşur; durum **`PENDING_DEPOSIT`**.
13. **`MockDeposit`** oluşur (**`status` = `PENDING`**). **Bu aşamada `HELD` yoktur.**
14. İçerik üreticisi **son onay ekranında** üç taahhüdü kutucukla işaretlemek **zorundadır** (ön seçim yok): 30 günlük yayına erişilirlik şartları, kullanıma izin, tur ücretinin iddia edilebilmesi koşulu.
15. Üretici tamamlayınca: **`mock_deposit` → `HELD`**, **`assignment` → `ACTIVE`** (`creator_deposit_acknowledged_at` damgası `database-schema.md`).

### Taslak ve teslim doğrulama

16. **`content_deliveries`**: yalın **taslak URL**. Teslim onayında `MIN_5_PHOTOS`, `DAYLIGHT_SHOOTING`, `AGENCY_BRAND_VISIBLE`, `AGENCY_TAG_REQUIRED`, `THIRTY_DAYS_PUBLICATION_REQUIRED` vb. **teslim checklist** maddeleri doğrulanır (MVP: **bir kez** teknik checklist revizyon hakkı `business-rules.md`).

### Yayın ve ihlal

17. Yayın URL’sinden sonra süreç `publications`, mock depozito **`RELEASED_AFTER_PUBLICATION`**, ardından 30 günlük izleme.
18. Erişilemez yayın bildirilirse **`violation_reports`** oluşturulur.

---

## İçerik üreticisi (Creator)

### Profil

1. Hesap oluştur; kalıcı alanlar: **`instagram_url`**, **`tiktok_url`**, **`youtube_url`**, **`portfolio_url`**, **`has_public_instagram`**, **`has_public_tiktok`**, **`can_record_1080p_video`**, **`can_create_vertical_video`**, **`can_shoot_photos`**, **`can_deliver_raw_files`**, **`has_basic_editing_skill`**, **`has_travel_vlog_experience`**, **`passport_type`**, **`has_valid_passport`**, **`visa_eligibility_notes`**. **`MIN_5_PHOTOS` vb. teslim gereksinimleri için profilde alan oluşturulmaz.**

### Başvuru ve kapıları

2. Creator, yalnızca **açık ve başvuruya uygun** turlara başvurabilir (bkz. `api-contract.md`).
3. Tur `INTERNATIONAL` ise creator’ın pasaport/vize uygunluğu başvuru öncesi kontrol edilir.
4. Creator gerekli pasaport/vize uygunluğunu karşılamıyorsa **`application` oluşturulmaz**.
5. Pasaport/vize uygunluğu **Aday Uygunluk Endeksi skorunun parçası değildir**; yalnızca yurt dışı tur için uygunluk kapısıdır.
6. Üç **`accepted_*`** işaretinin **tamamı `true`** olmalıdır; aksi halde **`application` oluşturulmaz**. Bu üçlü **skor parçası değildir** (`suitability-score.md`). Kutucuklar **ön işaretlenmez**.
7. Backend; **Aday Uygunluk Endeksi**, **Teknik Kriter Uyumu (T)**, **Yayın Platform Uyumu** değerlerini hesaplayıp `applications` kaydına yazar (iş mantığı **sunucudadır**).

### Acenteden kabul sonrası

5. `Assignment` durumu **`PENDING_DEPOSIT`** iken **mock depozito henüz `HELD` değildir** (`MockDeposit`: `PENDING`).
6. **Son onay ekranı**nda üç taahhüdü tekrar kutucukla işaretledikten sonra **`mock_deposit` → HELD**, **`assignment` → ACTIVE** olur.
7. Dış araçlarla düzenlenen içeriği **taslak URL** olarak gönderir; acente teslim sırasında **teslim checklist** maddelerini doğrular (MVP tek **teknik checklist revizyonu** `business-rules.md`).
8. Onaydan sonra yayın gönderisi URL’sini bildirir; mock depozito **`RELEASED_AFTER_PUBLICATION`** aşamasına geçiş **yayındaki bağlantının iletilmesiyle** bağlanır (gerçek para yok). **Otomatik sosyal medya izleme (crawler) yoktur**; olası aksaklıkta acente **manuel ihlal raporu** açar.
