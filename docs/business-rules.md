# İş kuralları (MVP)

## Varlıklar ve kavramlar (`Match` yok)

- **`Application`**: İçerik üreticisi bir **tura başvurdu**.  
- **`Assignment`**: Acente başvuruyu **manuel kabul ettikten sonra** oluşan **atama**. **`Match`** tablosu veya buna paralel süreç yoktur.

## Seçim ve skor

- Sistem içerik üreticisini **otomatik atamaz**, **yüksek skorluyu kendiliğinden seçmez**, **rastgele seçim yapmaz**.  
- Tek işlev: **`Aday Uygunluk Endeksi`** hesaplama ve adayların **sıralanması**.  
- Nihai karar **daima acentedir**; kota dahilinde **bir veya birden fazla** üretici seçilebilir.

Formül ve bileşen ayrımı: **`docs/suitability-score.md`**.

### Tur yayımlama — yayın platformu zorunluluğu (MVP)

- Bir tur **`PUBLISHED`** (yayımlanmış) statüsüne geçirilecekse, **`tour_content_requirements`** içinde **`INSTAGRAM_PUBLICATION`** veya **`TIKTOK_PUBLICATION`** türlerinden **en az biri seçili olmalıdır**.  
- **Hiçbiri yoksa** tur MVP’de **yayımlanamaz** (taslakta kalır veya sunucu reddeder).  
- Bu kural, **Yayın Platform Uyumu (Y)** hesabında paydanın sıfır olmasını engeller (`suitability-score.md`).

### Başvuru kabulü ve kota davranışı

- Acentenin **elle kabulünde**, yalnızca seçilen **`Application`** **`ACCEPTED`** olur (**diğer bekleyen başvurular aynı anda otomatik olarak `REJECTED` yapılmak zorunda değildir**).  
- **`creator_quota` doldurulunca** tur **`APPLICATION_CLOSED`** durumuna çekilir; seçilmemiş kalan **`PENDING`** başvurular kota nedeniyle **`REJECTED`** işlenebilir (iş kuralı net mesaj ile).

## Ödeme ve depozito

- MVP’de **gerçek tahsil yoktur**; **Stripe, iyzico, kart işlemcisi ve gerçek ödeme bağlantıları yoktur**.  
- **`mock_deposits`** yaşam döngüsü kullanılır; tutar **`tours.deposit_amount`** ile ilişkilendirilir.

### Doğru depozito / atama sırası (**HELD**, acenteden sonra değildir)

1. Acente başvuruyu **manuel kabul eder**.  
2. **`Assignment`** oluşturulur; durum **`PENDING_DEPOSIT`**.  
3. **`MockDeposit`** oluşturulur / güncellenir; durum **`PENDING`** (henüz blokaj yoktur).  
4. İçerik üreticisi **son onay** ekranını görür: **30 günlük yayın taahhüdü**, **içerik kullanımına izin**, **tur bedeli ile ilgili iddia/taahhüt koşulu** (kutucuklar **ön işaretlenmez**, başvuru anıyla ayrı doğrulanır).  
5. Üretici bu ekranı onayladığında: **`mock_deposit` → HELD**, **`assignment` → ACTIVE**.  
6. **Depozitonun gerçek anlamda serbest bırakılması** ise yalnızca üretici **yayın gönderisi URL**’yi sistemde ilettikten sonra gerçekleşir (**`RELEASED_AFTER_PUBLICATION`** süreç olarak; kart ücreti çekimi yoktur).

## Teslimat aracı

- Taslak içerik yalnızca **taslak bağlantı (URL)** ile (bulut bağlantısı vb.).  
- Uygulama içinden **dosya veya ham video yükleme** yoktur.

## Yayın ve 30 gün

- Üretici, onayından sonra içeriği **kendi** sosyal hesabından yayınlar ve **URL** bildirir.  
- Gönderi **30 gün** boyunca herkese açık kalmalıdır; erken erişilemez yapılırsa acente **ihlal bildirimi** oluşturur; **otomatik crawler yoktur**.  
- Admin teyidine kadar hak ve kayıtlar MVP kapsamında **kayıtlı tutulur**; **otomatik hukuki takip veya karttan çekim yoktur**.

## İhlal ve talep kaydı

- İhlalin **confirmed** olarak işaretlenmesi sistemde **acentenin, kabul edilen koşullara göre tur bedelinin tamamına ilişkin talep hakkının** oluşabileceği şekilde **işlenir**; finans otomatik değildir.

## İçerik kullanımı ve kayıt

- İçeriğin acentenin **kendi** sosyal ve tanıtım kanallarında kullanımına izin **`agreements`** kaydında işlenir.  
- **PDF çıktı** veya **e-imza ürünü** MVP **yoktur**.

## Revizyon

- Tur başına teslim sürecinde acenteye **tek revizyon** talebi hakkı verilir (**ikinci hak yok**).  
- Revizyon yalnızca **teknik gereksinim kontrol listesi** ihlalleri için kullanılabilir; “estetik beğeni” gibi öznel gerekçe **iş kuralına uygun değildir**.

## Başvuru oluşturma kapısı (skor ile karıştırılmaz)

- `accepted_publication_commitment`, `accepted_content_usage_permission`, `accepted_tour_price_claim_condition` üçünün de **`true`** olması zorundadır (**biri bile `false`** ise **`application` oluşturulamaz** — sunucuda reddedilir); **bunlar Aday Uygunluk Endeksinin parçası değildir** (`suitability-score.md`).  
- **Hiçbir onay kutusu varsayılan işaretli olamaz.**

## Üreticide profil vs teslim listesi (**çakışmayı önlemek için**)

- **`creators`**: kalıcı yetkinlikler (**1080p kayıt, dikey video, foto çekme, ham dosya vb.**) ile sosyal URL / kamuya açık hesap bildirimi — **`database-schema.md`**.  
- **`MIN_5_PHOTOS`, `MIN_3_LOCATIONS`, vb.** teslim sırasında **acente doğrulanan “checklist”** kapsamına girer; **profilde capability olarak tutulmaz** ve **T skoru paydasına girmez.**

## Tekrar doğrulama (atama / depozito öncesi)

- Aynı hukuki bloklar (**30 günlük yayın**, **kullanım izni**, **tur ücretinin iddia edilebilmesi koşulu**), üreticinin **`PENDING_DEPOSIT`** sürecinde **son onayında** yeniden işaret ile teyit edilir.

## Yönetişim ve admin

- Acenteler **admin onayı** olmadan **yayımlanan tur** oluşturmaz (**onay bekleyen** durum **`PENDING_APPROVAL`** ile uyumludur).  
- Üreticide **otomatik güvenilirlik yapay zeka analizi veya görüntü analizi** yoktur.

## Kesin olarak yoktur

| Alan | MVP |
|------|-----|
| Otomatik eşleştirme / sistemsel atama | Hayır |
| Sosyal akış ürünü | Hayır |
| Uygulama içi sohbet/DM kanalı ürünü | Hayır |
| Otel / uçuş rezervasyonu | Hayır |
| Dosya yükleme ile teslim | Hayır (yalın URL) |
