# Tur İzim — Ürün Gereksinimleri Dokümanı (PRD)

Versiyon: MVP (pilota odaklı)  
Okuyucu: Türkçe konuşan kurucu / ürün sahibi  
Teknik adlar (tablo, API, kod): İngilizce

---

## 1. Ürün Özeti

**Tur İzim**, yerel **tur acenteleri** ile boş kontenjanı olan **ulaşım dahil** turlarda koltuk doldurmak isteyen genç **UGC içerik üreticileri** ve **mikro influencer**ları bir araya getiren **B2B/B2C güven ve operasyon** platformudur.

Süreç; **manuel başvuru**, **sıralama** (**Aday Uygunluk Endeksi**), **acentenin elle seçimi**, **taslak teslim bağlantısı**, **tek teknik revizyon hakkı**, **yayındaki bağlantının bildirilmesi** ve **mock depozito** ile yönetilir.

**Ürün sınırları:** Tur İzim bir **seyahat acentesi yazılımı** gibi sıfırdan paket satmaz; uygulama içi **sosyal zaman tüneline**, **sohbete**, **otel/uçak pazarına**, **video akışı** veya **dosya yüklemeyle** teslime sahip **değildir**. Yayın doğrulama ve ihlaller **manuel** bildirilir; MVP’de gerçek para hareketi **yoktur**.

---

## 2. Problem Tanımı

Acentelerde boş kontenjan ve görünürlük ihtiyacı; üreticilerde ise **şeffaf teknik şartlar** ve **güvenilir teslim** eksikliği tek kanalda buluşmuyor. Tur İzim, **başvuru–sıralama–elle seçim–atama** (`Assignment`) modeliyle taraflara ortak dil ve izlenebilir operasyon sunar; **karar** her zaman acentededir.

---

## 3. Hedef Kullanıcılar

| Rol         | Kim                            | Ne yapar?                                                                                                                                                                                |
| ----------- | ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Creator** | Genç UGC veya mikro influencer | İçerik üretir/düzenler; onaylı içeriği **kendi** sosyal hesabında yayınlar; gönderiyi **en az 30 gün** herkese açık tutar.                                                               |
| **Agency**  | Yerel tur acentesi             | İlan açar, teknik gereksinim seçer, başvuranları skora göre inceler, **elle** seçer, taslağı onaylar veya **bir kez** teknik revizyon ister, yayın bağlantısını inceler, ihlal bildirir. |
| **Admin**   | Platform yöneticisi            | Acente hesabını onaylar; ihlal raporlarını inceler; MVP’de güven katmanını yönetir (ileride hesap askısı vb. genişleyebilir).                                                            |

---

## 4. MVP Kapsamı

**Pilot coğrafya:** İlk fazda yalnızca **Adana / Mersin çıkışlı** ve **ulaşım dahil** acente turları önceliklidir. Başlangıç varış kümeleri **Kapadokya** ve **Güney** turlarıdır.

**Tur tipi:** MVP’de sistem yalnızca **tur şirketlerinin ulaşım dahil turlarını** kapsar. Otel pazaryeri, uçak bileti, tekil konaklama veya uçuş rezervasyonu yoktur.

**Yurt içi / yurt dışı ayrımı:** Acente tur ilanı oluştururken turu **yurt içi** veya **yurt dışı** olarak işaretlemelidir. Yurt dışı turlar MVP’de opsiyonel olarak desteklenebilir; ancak her yurt dışı turda pasaport/vize gereklilikleri açıkça belirtilmelidir.

**Pasaport / vize uygunluğu:** Yurt dışı turlarda acente, ilanın gerektirdiği pasaport ve vize koşullarını belirtir. İçerik üreticisi profilinde pasaport uygunluğu ve gerekiyorsa vize uygunluğu bilgileri tutulur. Creator bu gereklilikleri karşılamıyorsa sistem ilanı göstermemeli veya başvuruyu engellemelidir. Bu kontrol **must-have uygunluk kapısıdır**, Aday Uygunluk Endeksi skorunun parçası değildir.

**Kapsam dışı (MVP):** Ülke geneli lansman, sınırsız tur kategorisi, otel/uçuş pazaryeri, gerçek ödeme entegrasyonu, sosyal medya akışı, sohbet, uygulama içi video oynatma/streaming ve dosya yükleme ile içerik teslimi.

## **Uçtan uca özet:** Admin onaylı acente **ulaşım dahil** tur yayımlar → tur yurt dışı ise pasaport/vize uygunluk kapıları kontrol edilir → üreticide yalnız kalıcı yetenekler/sosyal bilgiler tanımlanır (`MIN_5_PHOTOS` gibi maddeler `tour_content_requirements` üzerinde kalır; teslim/onayda kontrol edilir — bkz. `suitability-score.md`) → başvuru gönderilebilmesi için kullanıcı üç `accepted_*` kutusunu **manuel olarak işaretler**; kutular varsayılan işaretli gelmez (**kapı şartı**, skor bileşeni değil) → **AUE = Teknik %75 + Yayın Platformu %25** → acente kota içinde elle seçer (**yalnızca seçilen `ACCEPTED`**; diğerleri anında reddedilmez; kota dolunca tur **`APPLICATION_CLOSED`**, kalanlar **`REJECTED`**) → **`Assignment`** **`PENDING_DEPOSIT`**, **`MockDeposit`** **`PENDING`** (henüz **HELD değil**) → üreticide **son taahhüt onayından** sonra **HELD / ACTIVE** → taslak **URL**; **teslim checklist** onayda → **yayındaki bağlantı ile** **`RELEASED_AFTER_PUBLICATION`** (**gerçek ödeme ve otomatik crawler yok**).

## 5. MVP Dışı Bırakılanlar

- En yüksek skorluyu veya rastgele adayı **sistemin ataması**; **Match** varlığı.
- **Stripe, iyzico**, kart ve gerçek ödeme sağlayıcıları.
- Uygulama içi **medya / video dosyası yükleme**; teslim ve yayın **bağlantı (URL)** ile.
- Sosyal medyada **otomatik izleme** veya **yapay zeka ile video analizi**.
- Uygulama içi **sosyal akış**, **sohbet**, **video akışı oynatıcı**.
- **Otel veya uçuş rezervasyonu** ve bu pazarlara ilişkin arayüz.
- Yurt dışı tur uygunluğu için pasaport/vize şartını yok sayarak başvuru alma. Yurt dışı turda uygunluk kapısı karşılanmıyorsa creator başvuramaz.

---

## 6. Kullanıcı Rolleri

Bkz. Bölüm 3. **`Application`** başvuru; **`Assignment`** yalnızca acente kabulünden sonra.

---

## 7. Temel Kullanıcı Akışları

Özet sıra için `docs/user-flows.md`. PRD doğruluğunda kritik adımlar:

1–3. Kayıtlar ve admin onayı; yayın için acente **onaylı** olmalı.  
10. Başvuruda üç onay kutusu (**30 gün yayın**, **içerik kullanımı**, **tur fiyatı iddia koşulu**) — **varsayılan işaretlenmez**.  
11–14. Üç **`accepted_*` kapı şartından** sonra skor oluşur (**skoranın bileşeni değildir**); **otomatik seçim yapmaz**.
15–20. Kota içinde elle kabul → `Assignment` (`PENDING_DEPOSIT`), `MockDeposit` (`PENDING`); **`HELD` ancak üretici son taahütsal onayı verince**.
19–26. Taslak bağlantı; **tek revizyon**; revizyon yalnızca **teknik kontrol listesi** ile; “güzel değil” gibi öznel gerekçe **geçerli değil**.  
27–30. Yayın bağlantısı; depozito **yayından sonra serbest**; 30 günlük izlemeye girer.

---

## 8. İş Kuralları

- **`Assignment`** kullanılır; **`Match` yoktur**.
- **`Application` ≠ `Assignment`**.
- Skor **yalnızca sıralama / karar desteği**; atlama yapısı `docs/suitability-score.md`.
- Acente düşük skorluyu veya sıralama dışı birini **istemesi halinde seçebilir**; sistem **en yüksek skorluyu atamaz**.
- Yurt dışı turlarda pasaport/vize uygunluğu **başvuru öncesi zorunlu kapıdır**. Bu kontrol Aday Uygunluk Endeksi’ne ek puan olarak katılmaz; uygun değilse creator başvuramaz veya ilanı göremez.
  Ayrıntı: **`docs/business-rules.md`**.

---

## 9. 30 Günlük Yayın Taahhüdü

İçerik üreticisi, acente tarafından onaylanan içeriği **kendi kişisel** sosyal medya hesabında yayınlar ve URL’yi Tur İzim üzerinden bildirir. Gönderi **en az 30 gün boyunca herkese açık ve erişilebilir** kalmalıdır. Süre dolmadan **silme, gizleme, arşivleme veya erişilemez kılma** halinde acente, kabul ettiği koşullara dayanarak **tur bedelinin tamamını talep etmeyi** (MVP’de **kayıtlı hak/iş kuralları**; **otomatik borç/tahsilat yok**) esas alabilir.

**Ürün zorunluluğu:** Bu koşullar içerik üreticisine **başvuru öncesinde**, ayrıca **atama / depozito onayından önce tekrar** gösterilir. İlgili onay kutuları **ön seçili gelmez**.

**İçerik kullanım izni (özet):** Üreticinin teslim ettiği video/fotoğrafların acentenin **kendi** sosyal ve tanıtım kanallarında kullanımına ilişkin onay **`agreements`** ile kaydedilir (MVP’de PDF ve e-imza ürünü yoktur — bkz. `database-schema.md`).

---

## 10. Depozito Mantığı (Mock)

Gerçek para **işlenmez**. **`mock_deposit` ve `assignment` durumu geçişlerinde** akış:

1. **Acentenin başvuruyu elle kabulünden** hemen sonra **`Assignment`** **`PENDING_DEPOSIT`** olarak açılır; **`mock_deposit`** kaydı **`status` = `PENDING`** olur. **Bu anda `HELD` yoktur.**
2. İçerik üreticisi **son onay ekranında** üç taahhüdü (30 günlük yayın, kullanım izni, tur bedeli iddia koşulu) tekrar kutucukla onaylar; ardından **`mock_deposit` → HELD**, **`assignment` → ACTIVE`** olur.
3. **Yayındaki gönderi URL’si** üretici tarafından iletildikten sonra **`RELEASED_AFTER_PUBLICATION`** yapılması hedeflenir (**gerçek para hareketi yoktur**). İş akışında **`FORFEITED`** kullanılabilir.

---

## 11. İçerik Teslim ve Onay Akışı

Taslak yalnızca **taslak bağlantı (URL)** ile gönderilir. **`MIN_5_PHOTOS`**, **`DAYLIGHT_SHOOTING`**, **`AGENCY_BRAND_VISIBLE`** vb. maddeler **üreticide yetenlik alanı olarak tutulmaz**; teslim/onay sırasında **checklist doğrulanır**. Acentenin **yalnızca bir teknik checklist revizyon talebi** olabilir; öznel güzellik yorumları **geçerli gerekçe değildir**.

---

## 12. Aday Uygunluk Endeksi

Ürün adıyla **Türkçe: Aday Uygunluk Endeksi.** **Teknik Kriter Uyumu** ve **Yayın Platform Uyumu**, başvuru onay kutucuklarıyla **birleştirilmez** (**onlar kapıdır**). Bilgi kümesinin tamamı: **`docs/suitability-score.md`**.
Pasaport/vize uygunluğu, başvuru checkbox üçlüsü gibi **skor bileşeni değildir**. Bu bilgiler yalnızca yurt dışı turlar için başvuru uygunluk kapısıdır.

---

## 13. Frontend Öncelikli Geliştirme Kararı

Proje MVP’de **önce Flutter** ile ilerleyecektir. İlk fazda **`mock`** veriler ve **`API uyumlu repository`** soyutlamaları kullanılır. **Temel iş kuralları** (skor matematiği, depozito geçişleri, revizyon limitleri, durum makineleri, ihlal teyidi) **Flutter’da çekirdek iş mantığı olarak tutulmaz** — bu kararlar **Spring Boot servis katmanında** doğrulanacak şekilde tasarlanır. Flutter, ilerideki API yanıtlarını taklit eden **mock repository** çıktılarını gösterebilir; backend hazır olunca gerçek API repository’leri ile değiştirilir.

---

## 14. Google Stitch Kullanım Sınırı

Google **Stitch** yalnızca **tasarım referansı** için kullanılır; **backend mimarisi**, **iş kuralları** veya **veri şeması** için **tek doğruluk kaynağı olamaz**. Stitch tabanlı ekranlar **Flutter’da özellik bazlı temiz mimari** ile uyumlu taşınır; **sosyal akış, sohbet, otel/uçuş rezervasyonu, uygulama içi video akış mimarisi** eklenmez.

---

## 15. Başarı Kriterleri

- Pilot parametreleriyle bir **tur** yayınlanır; başvurular **endekse göre** sıralanır; kota dahilinde **elle** seçim ve **Assignment** oluşur.
- **URL ile taslak** ve **teknik revizyon** kuralına uygun uçtan uca teslim ve yayın.
- Yayın bağlantısı sonrası **mock depozito serbest**, ardından 30 günlük izlemeye geçiş.
- Dokümantasyon ile **PostgreSQL taslağı** ve **REST sözleşmesi tutarlı** kalır.

---

## 16. Riskler ve Kısıtlar

- Elle doğrulama ve manuel bildirimlere dayalı **güven** modeli (**otomatik crawler yok**).
- Teknik ve hukuki şartların kullanıcıya net gösterimi ihtiyacı.
- Önden Flutter + mock yaklaşımında **iş mantığının tekrarsızlığı**: UI’ya mock oran yazılmamalıdır (çift doğrulama riski).
- Pilotta **dar coğrafya** operasyon geri bildirimini sınırlar.

---

## 17. Gelecek Sürümler

Ödemeli tahsilat, e-imza/zarf, otomatik veya yarı otomatik yayın denetimi, coğrafya genişlemesi, AI destek önerileri (iş kuralından bağımsız), admin tarafında **askıya alma** aksiyonlarının sıkılaştırılması vb. (öncelik sırası belirsizdir.)

---

## İlgili dokümanlar

| Dosya                  | İçerik                          |
| ---------------------- | ------------------------------- |
| `product-scope.md`     | Kısa ürün kapsamı               |
| `business-rules.md`    | İş kuralları maddeleri          |
| `user-flows.md`        | Rol akışları                    |
| `suitability-score.md` | Aday Uygunluk Endeksi           |
| `database-schema.md`   | Veritabanı taslağı              |
| `api-contract.md`      | REST uçları (taslak)            |
| `design-system.md`     | Flutter arayüz ilkeleri         |
| `cursor-prompts.md`    | Cursor için İngilizce şablonlar |
