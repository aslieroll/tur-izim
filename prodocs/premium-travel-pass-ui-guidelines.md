# Premium Travel Pass UI Rehberi

Bu rehber, Tur İzim MVP frontend ekranlarının Google Stitch ile üretilen **Premium Travel Pass** görsel yönüne uygun şekilde Flutter’a taşınması için hazırlanmıştır.

Bu dosya yalnızca **görsel dil ve UI uygulama rehberi**dir. İş kurallarında ana kaynaklar:

- `PRD.md`
- `business-rules.md`
- `user-flows.md`
- `database-schema.md`
- `api-contract.md`
- `suitability-score.md`

dosyalarıdır.

Google Stitch çıktıları ve HTML dosyaları **yalnızca görsel referanstır**. Flutter’a doğrudan HTML/Tailwind kodu kopyalanmaz.

Kaynak görsel referanslar:

- `stitch-export/stitch_tur_izim_premium_pass`
- `stitch-export/stitch_tur_izim_premium_pass/DESIGN.md`
- `stitch-export-screen-map.md`

---

## 1. Amaç

Premium Travel Pass görsel yönü; Tur İzim’in daha modern, güven veren, premium ama sade bir operasyon platformu gibi görünmesini sağlar.

Bu rehberin amacı:

- Flutter ekranlarında ortak görsel dil oluşturmak,
- Stitch ekranlarını birebir kopyalamadan doğru yorumlamak,
- renk, kart, spacing, buton ve navigation tutarlılığını sağlamak,
- sosyal medya / otel / uçuş / ödeme uygulaması algısını engellemek,
- Tur İzim’in güvenli içerik iş birliği platformu kimliğini korumaktır.

---

## 2. Ürün Kimliği

Tur İzim şu değildir:

- seyahat acentesi,
- otel rezervasyon uygulaması,
- uçak bileti uygulaması,
- sosyal medya uygulaması,
- video streaming uygulaması,
- ödeme/checkout ürünü.

Tur İzim şudur:

> Tur İzim, yerel tur acentelerinin boş koltuklarını; üniversite öğrencilerinin teknik şartları belirlenmiş fotoğraf/video içerikleri ve 30 günlük yayın taahhüdü karşılığında değerlendirmesini sağlayan şehir bazlı güvenli görev ve içerik teslim platformudur. Süreç; manuel başvuru, Aday Uygunluk Endeksi ile sıralama, acentenin elle seçimi, mock depozito, yalnızca URL ile içerik teslimi ve 30 günlük yayın takibidir.

Bu nedenle UI premium seyahat atmosferinden ilham alabilir; ancak “tatil satın alma / rezervasyon / sosyal keşif” algısı yaratmamalıdır.

---

## 3. Görsel Kimlik

Arayüz şu hissi vermelidir:

- premium,
- güvenilir,
- ferah,
- modern,
- sakin,
- operasyon odaklı,
- üniversite öğrencisi içerik üreticisi kitlesine yakın; abartılı “sosyal etki / takipçi gücü” dili yok,
- acente tarafında profesyonel.

Yanlış hisler:

- booking uygulaması,
- sosyal medya feed’i,
- ödeme ekranı,
- otel/uçuş arama motoru,
- içerik izleme platformu.

Doğru görsel yön:

- açık ve sıcak zemin,
- geniş boşluklar,
- premium kartlar,
- yumuşak gradientler,
- rounded yüzeyler,
- soft shadow,
- Deep Navy metin,
- Royal Indigo ana CTA,
- Soft Coral mikro vurgu.

---

## 4. Renk Paleti

Ana renk rolleri:

| Renk Rolü     | Kullanım                              |
| ------------- | ------------------------------------- |
| Warm White    | Ana sayfa zemini                      |
| Sand Cream    | Sıcak kart yüzeyleri                  |
| Soft Sky Blue | Gradient, dekoratif alan, sakin vurgu |
| Soft Lavender | Gradient, chip, soft panel            |
| Deep Navy     | Ana başlık, güçlü metin, navigation   |
| Royal Indigo  | Ana CTA, aktif durum, skor vurgusu    |
| Soft Coral    | Küçük aksan, aktif nokta, mikro vurgu |
| Success Green | Başarılı/onaylı durum                 |
| Warning Amber | Beklemede/revizyon durumu             |
| Error Red     | İhlal/red/kritik uyarı                |

Önerilen HEX ailesi:

```text
Warm White: #FFFBF7
Sand Cream: #FFF4EC
Soft Sky Blue: #DCEBFF
Soft Lavender: #EEF2FF
Deep Navy: #1E2A5A
Royal Indigo: #4F46E5
Soft Coral: #FF6B6B
Slate Text: #1F2937
Muted Text: #6B7280
Success Green: #22C55E
Warning Amber: #F59E0B
Error Red: #EF4444
```

Stitch Material tonlarıyla uyumlu alternatifler:

```text
background: #fdf7ff
surface-container-lowest: #ffffff
surface-container-low: #f8f2fa
surface-container: #f2ecf4
surface-container-high: #ece6ee
primary: #4f378a
primary-container: #6750a4
secondary-container: #e1d4fd
outline-variant: #cbc4d2
on-surface: #1d1b20
on-surface-variant: #494551
```

Royal Indigo yalnızca ana aksiyon ve önemli vurgu için kullanılmalıdır.  
Soft Coral ana tema rengi değil, mikro aksan rengidir.  
Kırmızı yalnızca gerçek ihlal, red veya kritik hata durumlarında kullanılmalıdır.

---

## 5. Gradient Kullanımı

Premium Travel Pass atmosferi için soft gradient kullanılabilir.

Örnek yönler:

```text
Soft Sky Blue → Soft Lavender
Warm White → Sand Cream
Lavender → White
```

Kullanım alanları:

- welcome hero,
- dashboard üst alanı,
- dekoratif arka plan lekeleri,
- özel bilgi kartları,
- onay/başarı ekranları.

Gradient; metin okunabilirliğini düşürmemeli ve ekranı tatil rezervasyonu gibi göstermemelidir.

---

## 6. Tipografi

Stitch referansı:

- Başlıklar: `Noto Serif`
- Gövde ve UI metinleri: `Plus Jakarta Sans`

Flutter’da mevcut font yapısı korunabilir. Ancak görsel his şu şekilde olmalıdır:

| Metin Tipi      | Stil                                 |
| --------------- | ------------------------------------ |
| Ana başlık      | Premium, güçlü, geniş satır aralıklı |
| Section başlığı | Net, yarı kalın                      |
| Gövde           | Okunaklı, sade                       |
| Label / meta    | Küçük, uppercase veya yarı kalın     |
| Buton           | 600 weight, kısa ve eylem odaklı     |

Türkçe metinler uzun olabileceği için kartlar ve butonlar daraltılmamalıdır.

---

## 7. Spacing ve Layout

Genel layout mobil önceliklidir.

Temel spacing:

| Kullanım            | Öneri        |
| ------------------- | ------------ |
| Sayfa yatay padding | 20–24px      |
| Küçük öğe arası     | 8px          |
| Kart içi grup arası | 12–16px      |
| Kart padding        | 20–24px      |
| Bölüm arası         | 32–48px      |
| Dokunma hedefi      | minimum 48dp |

Chrome/web görünümünde içerik çok genişlememelidir. Merkezlenmiş ve okunabilir max-width tercih edilmelidir.

---

## 8. Kart Stili

Kartlar Premium Travel Pass dilinin ana taşıyıcısıdır.

Kart kuralları:

- Radius: 20–24px.
- Shadow: düşük opaklıklı, yumuşak, Deep Navy tabanlı.
- Border: çok hafif outline veya transparan beyaz.
- Surface: beyaz, lavanta veya sand cream tonları.
- İçerik hiyerarşisi net: başlık → meta → durum → aksiyon.

Kart tipleri:

| Kart Tipi                   | Kullanım                         |
| --------------------------- | -------------------------------- |
| Hero Card                   | Welcome, tour detail üst alanı   |
| Surface Card                | Form, dashboard, liste           |
| Metric Card                 | Dashboard sayıları               |
| Tour Card                   | Creator tur listesi              |
| Applicant Card              | Agency başvuran listesi          |
| Status Card                 | Assignment, deposit, publication |
| Warning Card                | İhlal, 30 gün uyarısı            |
| External Link Card          | İçerik/yayın URL gösterimi       |
| PassportVisaRequirementCard | Yurt dışı uygunluk bilgisi       |

Kartlar sosyal medya post’u gibi görünmemelidir. Beğeni, yorum, paylaş, takip et gibi sosyal medya etkileşimleri kullanılmaz.

---

## 9. Glassmorphism Kullanımı

Glassmorphism dikkatli kullanılmalıdır.

Uygun kullanım:

- Welcome hero üzerindeki CTA alanı,
- özel onay kartı,
- dashboard üst özet alanı,
- form veya confirmation ekranında odak kartı,
- görsel üzerinde küçük overlay kartlar.

Aşırı kullanım ekranı dağınık gösterir. Her kart cam panel olmamalıdır.

Önerilen his:

```text
white surface + low opacity + blur + soft border + ambient shadow
```

---

## 10. Buton Hiyerarşisi

Aynı ekranda tek güçlü primary CTA olmalıdır.

### Primary Button

Kullanım:

- Başvuruyu Gönder
- Depozitoyu Onayla
- İçerik Linkini Gönder
- Yayını Bildir
- Seçimi Onayla
- Acenteyi Onayla
- Yeni Tur Oluştur

Stil:

- Royal Indigo background,
- beyaz metin,
- pill veya yüksek radius,
- 48dp minimum yükseklik,
- hafif shadow.

### Secondary Button

Kullanım:

- Detayları Gör
- Geri Dön
- Taslak Kaydet
- İncele

Stil:

- açık yüzey,
- indigo border veya soft lavender background,
- primary ile rekabet etmeyen görünüm.

### Destructive Button

Kullanım:

- Reddet
- İhlal Bildir
- Başvuruyu Reddet
- Kararı Reddet

Stil:

- Error Red veya error container,
- yanında açıklayıcı bağlam,
- tek başına agresif görünmemeli.

---

## 11. Bottom Navigation

Mobilde bottom navigation kullanılabilir.

Stitch referansına yakın stil:

- Deep Navy zemin,
- blur etkisi,
- üst köşelerde geniş radius,
- aktif item beyaz,
- pasif item düşük opaklık,
- aktif durumda küçük Soft Coral nokta.

Etiketler Türkçe olmalıdır.

Örnek creator nav:

```text
Turlar
Başvurularım
Görevlerim
Profil
```

Örnek agency nav:

```text
Panel
İlanlar
Başvurular
İçerikler
```

Örnek admin nav:

```text
Panel
Acenteler
İhlaller
```

Odak formlarında bottom nav saklanabilir:

- başvuru formu,
- depozito onayı,
- içerik teslimi,
- yayın bildirimi,
- ihlal bildirimi,
- admin karar ekranı.

---

## 12. Dashboard Kuralları

Dashboard ekranları düz liste gibi değil, premium operasyon paneli gibi görünmelidir.

Agency dashboard için:

- üstte kısa karşılama / operasyon özeti,
- aktif tur sayısı,
- bekleyen başvuru sayısı,
- atanmış creator sayısı,
- yeni tur oluştur CTA,
- tur kartları,
- yeni başvuru satırları.

Creator dashboard / listeler için:

- açık turlar,
- başvurularım,
- görevlerim,
- yayın / depozito durumları.

Admin dashboard için:

- bekleyen acente onayları,
- ihlal kuyruğu,
- hızlı karar kartları.

Dashboard metrikleri tek başına kuru sayı gibi durmamalı; label, ikon, açıklama ve soft kart içinde sunulmalıdır.

---

## 13. Liste ve Kart Akışları

Creator tur kartı:

- tur görseli veya dekoratif header,
- başlık,
- rota,
- tarih,
- üretici kotası,
- normal satış fiyatı,
- beklenen depozito,
- ulaşım dahil etiketi,
- yurt dışıysa pasaport/vize gereksinim rozeti,
- detay CTA.

Agency applicant card:

- creator adı,
- Aday Uygunluk Endeksi,
- Teknik Kriter Uyumu,
- Yayın Platform Uyumu,
- eksik maddeler,
- karar destek notu,
- incele/seç CTA.

Admin list card:

- acente / ihlal adı,
- durum,
- tarih,
- özet,
- incele CTA.

---

## 14. Form Stili

Formlar kart içinde, sade ve görev odaklı görünmelidir.

Genel kurallar:

- tek kolon mobil layout,
- label-caps veya net label,
- açık yüzey input,
- net focus state,
- muted helper text,
- zorunlu alanlarda açık uyarı,
- form sonunda tek primary CTA.

Formlarda uzun metin varsa kart içinde bölümlere ayrılmalıdır.

---

## 15. Checkbox / Radio Kuralları

Checkbox ve radio alanları yalnızca objektif seçimler için kullanılmalıdır.

Uygun kriterler:

- 1080p video,
- dikey reels formatı,
- ham dosya teslimi,
- minimum fotoğraf sayısı,
- minimum lokasyon sayısı,
- gündüz çekimi,
- Instagram yayını,
- TikTok yayını,
- acente etiketi,
- 30 gün public yayın.

Uygun olmayan kriterler:

- güzel video,
- estetik içerik,
- yaratıcı olsun,
- vibe uygun olsun,
- kaliteli hissettirsin.

Başvuru ve depozito onayındaki üç zorunlu checkbox **asla ön işaretli olmamalıdır**.

---

## 16. Pasaport / Vize UI Kuralları

Yurt dışı tur akışında pasaport/vize uygunluğu ayrı bir kapıdır.

### Agency tarafı

Tur oluşturma formunda:

- tur kapsamı: `Yurt içi` / `Yurt dışı`,
- geçerli pasaport gerekli mi?,
- belirli pasaport türü gerekli mi?,
- vize gerekli mi?,
- vize açıklama notu.

Yurt dışı turda gereklilikler boş bırakılmamalıdır.

### Creator tarafı

Profilde:

- pasaport türü,
- geçerli pasaport var mı?,
- vize uygunluk notu.

Tur listesi / detay:

- uygun creator için gereklilik kartı gösterilebilir,
- uygun olmayan creator için başvuru CTA engellenir,
- hata mesajı açık olmalıdır.

Doğru hata dili:

```text
Bu yurt dışı tur için pasaport/vize gereksinimi karşılanmadığı için başvuru oluşturulamaz.
```

Yanlış hata dili:

```text
Aday Uygunluk Endeksin düşük olduğu için başvuramazsın.
```

Pasaport/vize uygunluğu AUE alt skoru gibi gösterilmemelidir.

---

## 17. Aday Uygunluk Endeksi Görünümü

AUE kartı karar destek bilgisidir.

Gösterilebilecek alanlar:

- Aday Uygunluk Endeksi,
- Teknik Kriter Uyumu,
- Yayın Platform Uyumu,
- eksik teknik gereksinimler,
- uyum etiketi.

Zorunlu not:

```text
Bu skor yalnızca karar destek amaçlıdır. Nihai seçim acenteye aittir.
```

AUE asla şu şekilde sunulmaz:

- sistem seni seçti,
- otomatik atama,
- en iyi aday otomatik seçildi,
- eşleşme tamamlandı,
- match bulundu.

---

## 18. Depozito Görünümü

MVP’de gerçek ödeme yoktur. Depozito ekranı checkout gibi tasarlanmamalıdır.

Doğru dil:

- Depozito onayı,
- Depozito durumu,
- Güvence olarak bekletiliyor,
- Yayın bildirimi sonrası serbest bırakma süreci.

Yanlış dil:

- Kredi kartı,
- Karttan çekim,
- SSL ödeme,
- Stripe,
- iyzico,
- ödeme yap,
- kart bilgileri.

Eğer Stitch ekranında ödeme hissi veren metinler varsa Flutter’a taşınmamalıdır.

---

## 19. İçerik Teslim Görünümü

İçerik teslim ekranlarında yalnızca URL kullanılır.

Doğru yapı:

- taslak içerik URL input,
- harici bağlantıyı aç ikonu,
- teknik checklist,
- revizyon notu,
- submit CTA.

Yasak yapı:

- dosya yükle,
- video yükle,
- drag-and-drop,
- medya kütüphanesi,
- uygulama içi video player,
- streaming preview.

Önizleme gerekiyorsa statik placeholder veya external link card kullanılmalıdır.

---

## 20. Yayın Bildirimi Görünümü

Creator, yayındaki gönderi URL’sini bildirir.

Ekranda olmalı:

- yayın URL input,
- platform seçimi veya gösterimi,
- 30 gün public kalma uyarısı,
- depozito süreci bilgilendirmesi,
- tek primary CTA: `Yayını Bildir`.

Metin:

```text
Paylaşım en az 30 gün boyunca herkese açık kalmalıdır.
```

---

## 21. İhlal Bildirimi Görünümü

İhlal bildirimi agency tarafından manuel yapılır.

Form alanları:

- ihlal nedeni,
- açıklama,
- kanıt URL,
- ilgili yayın/görev özeti.

Destructive CTA kullanılabilir:

```text
İhlal Bildir
```

Ama UI otomatik ceza veya otomatik tahsilat ima etmemelidir.

Yanlış dil:

```text
Ceza otomatik kesilecek.
Karttan tahsil edilecek.
Sistem otomatik tespit etti.
```

---

## 22. Admin Karar Ekranları

Admin ekranları manuel inceleme hissi vermelidir.

Admin karar ekranlarında:

- başvuru/acente/ihlal özeti,
- kanıt bağlantısı,
- taraf bilgileri,
- karar notu,
- onay/red CTA’ları,
- işlem geçmişi alanı

bulunabilir.

Admin kararı otomatik yaptırım gibi gösterilmemelidir.

---

## 23. Görsel Kullanımı

Stitch ekranlarında premium seyahat görselleri bulunabilir. Flutter’da bu görseller doğrudan kullanılmak zorunda değildir.

Görsel kullanılacaksa:

- tur atmosferini desteklemeli,
- booking sitesi gibi durmamalı,
- sosyal medya feed post’u gibi görünmemeli,
- kart hiyerarşisini bozmamalı.

MVP’de görsel asset yoksa placeholder kullanılabilir.

Placeholder önerisi:

- soft gradient,
- rota/destination ikonları,
- abstract travel illustration,
- düşük kontrastlı dekoratif pattern.

---

## 24. Stitch’ten Flutter’a Taşıma Kuralı

Stitch HTML dosyaları Flutter’a kopyalanmaz.

Doğru yaklaşım:

1. `stitch-export-screen-map.md` dosyasından hedef ekran bulunur.
2. İlgili Stitch HTML ve screen görseli görsel referans olarak incelenir.
3. Mevcut Flutter route/session/mock repository yapısı korunur.
4. Ekran mevcut Flutter widget mimarisine uygun şekilde yeniden oluşturulur.
5. İş kuralları dokümanlara göre düzeltilir.
6. `flutter analyze` ve `flutter test` çalıştırılır.

---

## 25. Yasak UI Yönleri

Aşağıdakiler Flutter implementasyonuna taşınmayacaktır:

- sosyal feed,
- chat,
- otel rezervasyonu,
- uçuş rezervasyonu,
- uçak bileti arama,
- video upload,
- gerçek video player/streaming,
- gerçek ödeme sağlayıcı UI’ı,
- otomatik match,
- random assignment,
- AI video analysis.

---

## 26. Kontrol Listesi

Her ekran tamamlandığında kontrol:

- [ ] Tur İzim sosyal medya uygulaması gibi görünüyor mu?
- [ ] Otel/uçuş rezervasyon algısı var mı?
- [ ] Video upload veya video streaming UI’ı var mı?
- [ ] Gerçek ödeme/kart/SSL dili var mı?
- [ ] `Kapora` yerine `Depozito` kullanıldı mı?
- [ ] AUE karar destek olarak mı gösteriliyor?
- [ ] Başvuru checkbox’ları ön işaretli değil mi?
- [ ] İçerik teslimi yalnızca URL ile mi?
- [ ] Yayın bildirimi 30 gün public kuralını söylüyor mu?
- [ ] Pasaport/vize uygunluğu skor değil, ayrı kapı olarak mı gösteriliyor?
- [ ] Ekranda tek güçlü primary CTA var mı?
- [ ] Mobilde overflow yok mu?
- [ ] Chrome/web görünümü bozulmadı mı?
- [ ] `flutter analyze` temiz mi?
- [ ] `flutter test` geçiyor mu?
