# Tasarım Sistemi (Flutter MVP)

Dokümantasyon Türkçe; Flutter tema sınıfları, component adları ve teknik token isimleri İngilizce kalabilir.

Bu dosya Tur İzim Flutter arayüzünün temel UI kurallarını belirler. Detaylı Premium Travel Pass görsel yönü için `premium-travel-pass-ui-guidelines.md`, ürün/iş kuralı sınırları için `PRD.md` ve `business-rules.md` kaynak alınır.

---

## 1. Mimari Uyum

- Frontend: **Flutter + Dart**.
- Mimari: **feature-based clean architecture**.
- Uygulama **mobil öncelikli** tasarlanır; Chrome/web görünümü de responsive olmalıdır.
- Flutter ekranları yalnızca kullanıcı arayüzü ve API/mock repository’den gelen veriyi gösterir.
- Skor hesaplama, depozito durum geçişleri, tek revizyon hakkı, pasaport/vize uygunluk kapısı ve ihlal kararları gibi çekirdek iş kuralları backend servis katmanında doğrulanacak şekilde tasarlanır.
- MVP’de backend henüz yoksa Flutter mock repository, ileride Spring Boot API’den gelecek veriyi taklit eder.

---

## 2. Kaynak Önceliği

UI implementasyonunda kaynak önceliği şu sıradadır:

1. `PRD.md`
2. `business-rules.md`
3. `user-flows.md`
4. `database-schema.md`
5. `api-contract.md`
6. `suitability-score.md`
7. `DesignSystem.md`
8. `premium-travel-pass-ui-guidelines.md`
9. `stitch-export-screen-map.md`
10. `stitch-export` HTML ve görselleri

Google Stitch çıktıları **yalnızca görsel referanstır**. Stitch HTML kodları Flutter’a doğrudan kopyalanmaz.

---

## 3. Marka Algısı

Tur İzim arayüzü şu hissi vermelidir:

- güvenilir,
- sakin,
- modern,
- premium ama abartısız,
- operasyon odaklı,
- Türkiye start-up sıcaklığına sahip.

Arayüz sosyal medya uygulaması, otel/uçuş rezervasyon uygulaması veya klasik seyahat satış platformu gibi görünmemelidir.

Ana konumlandırma:

> Tur İzim, yerel tur acentelerinin boş koltuklarını; üniversite öğrencilerinin teknik şartları belirlenmiş fotoğraf/video içerikleri ve 30 günlük yayın taahhüdü karşılığında değerlendirmesini sağlayan şehir bazlı güvenli görev ve içerik teslim platformudur.

---

## 4. Kesin Yasak UI Yönleri

Aşağıdaki UI yapıları MVP’de kullanılmaz:

- Sosyal medya feed’i.
- Keşfet / sonsuz kaydırmalı içerik akışı.
- Chat / DM / mesajlaşma ürünü.
- Otel rezervasyon ekranı.
- Uçuş rezervasyon ekranı.
- Uçak bileti arama / satın alma dili.
- Video upload alanı.
- Uygulama içi video streaming/player deneyimi.
- Gerçek ödeme sağlayıcı UI’ı.
- Stripe, iyzico, kayıtlı kart, SSL ödeme gibi gerçek tahsilat dili.
- Otomatik eşleştirme / random assignment / sistem seçti hissi.
- AI video analysis UI’ı.

---

## 5. Dil ve Terminoloji

UI metinleri Türkçe olmalıdır.

Şehir ve rota (liste/kart uyumu):

- Tur kartları ve detaylarda **çıkış şehri** ile **tur rotası** (kısa rota özeti veya varış şehri metni) okunaklı gösterilir; **harita, GPS veya otomatik konum seçimi** yoktur — değerler beyana dayalıdır.
- Üretici profil kartlarında **üniversite, bölüm, sınıf, kampüs/şehir** satırı tutarlı bir üst bilgi olarak kullanılabilir.

Doğru terimler:

| Kavram             | UI’da Kullanılacak Terim |
| ------------------ | ------------------------ |
| Application        | Başvuru                  |
| Assignment         | Atama / Görev            |
| Suitability Score  | Aday Uygunluk Endeksi    |
| Deposit            | Depozito                 |
| Content Delivery   | İçerik Teslimi           |
| Publication Submit | Yayın Bildirimi          |
| Violation Report   | İhlal Bildirimi          |
| City / route       | Şehir, çıkış şehri, tur rotası |

Kullanılmayacak terimler:

- Match
- Eşleşme
- Sistem seni seçti
- Otomatik atama
- Kapora
- Rezervasyon
- Satın al
- Ödeme yap
- Influencer
- Mikro-influencer
- Fenomen
- Takipçi gücü / sosyal etki puanı
- Sponsorlu içerik pazarı

Kullanılacak yeni terimler (creator tarafı):

| Eski | Yeni |
| ---- | ---- |
| Creator (UGC / influencer) | Öğrenci içerik üreticisi |
| Mikro-influencer | Üniversite öğrencisi |
| Sosyal etki | Teknik içerik yetkinliği |

`Kapora` yerine her yerde **Depozito** kullanılmalıdır.

---

## 6. Renk Kullanımı

Flutter `ThemeData` ve ortak tokenlarda şu anlam haritası korunur:

| Renk Rolü        | Kullanım                                       |
| ---------------- | ---------------------------------------------- |
| `primary`        | Ana CTA, aktif tab/chip, önemli vurgu          |
| `surface`        | Sayfa zemini ve kart yüzeyi                    |
| `surfaceVariant` | İkincil kart, chip ve soft alanlar             |
| `success`        | Onaylandı, tamamlandı, pozitif depozito durumu |
| `warning`        | Beklemede, revizyon, admin incelemesi          |
| `danger`         | İhlal, red, kritik uyarı                       |
| `muted`          | İkincil açıklama ve meta metinler              |

Premium Travel Pass yönünde:

- açık warm white / lavanta yüzeyler,
- Deep Navy başlık/metin,
- Royal Indigo ana aksiyon,
- Soft Coral küçük vurgu,
- yumuşak mavi/lavanta gradientler kullanılabilir.

Soft Coral baskın ana renk yapılmamalıdır. Kritik hata/ihlal dışında kırmızı yoğun kullanılmamalıdır.

---

## 7. Tipografi

- Başlıklar güçlü ve okunabilir olmalıdır.
- Premium yön için başlıklarda serif hissi kullanılabilir; ancak Flutter tarafında mevcut font yapısı bozulmayacaksa uygulanmalıdır.
- Gövde, buton, form etiketi ve kart detaylarında sade sans-serif görünüm tercih edilir.
- Türkçe metinler uzun olabileceği için satır yüksekliği rahat tutulmalıdır.
- Çok uzun metinler kart içinde sıkıştırılmamalıdır.

---

## 8. Layout ve Spacing

- Mobil öncelikli layout.
- 4px / 8px grid mantığı.
- Sayfa yatay boşluğu genellikle 20–24px.
- Kart içi padding en az 16px, premium ekranlarda 20–24px.
- Bölümler arasında 32–48px aralık kullanılabilir.
- Chrome/web genişliğinde içerik sınırsız yayılmamalı; okunabilir max-width kullanılmalıdır.
- Dashboard ekranlarında kartlar rastgele dağılmış gibi değil, bento/grid düzeninde görünmelidir.

---

## 9. Kart Kuralları

Kartlar Tur İzim’in ana bilgi taşıyıcılarıdır.

- Köşeler yumuşak olmalı.
- Büyük kartlarda 20–24px radius tercih edilebilir.
- Gölge düşük opaklıklı ve yumuşak olmalıdır.
- Kartlar aşırı koyu veya ağır görünmemelidir.
- Bilgi hiyerarşisi net olmalıdır: başlık → durum → meta → CTA.
- Tur kartlarında görsel kullanılabilir; fakat booking marketplace algısı oluşturulmamalıdır.
- Creator portfolyo/önizleme görselleri sosyal feed’e dönüşmemelidir.

---

## 10. Buton Hiyerarşisi

Aynı ekranda birden fazla güçlü primary CTA kullanılmamalıdır.

| Buton Tipi  | Kullanım                                  |
| ----------- | ----------------------------------------- |
| Primary     | Ana akışı ilerleten eylem                 |
| Secondary   | Alternatif ama daha düşük öncelikli eylem |
| Tertiary    | Geri, iptal, admin girişi, detay linki    |
| Destructive | Reddet, ihlal bildir, kritik karar        |

Primary buton örnekleri:

- Başvuruyu Gönder
- Depozitoyu Onayla
- İçerik Linkini Gönder
- Yayını Bildir
- Seçimi Onayla
- Acenteyi Onayla

Destructive butonlar açıklamasız yalnız bırakılmamalıdır.

---

## 11. Form Kuralları

Formlar sade ve görev odaklı olmalıdır.

- Input alanları açık yüzeyli, net border/focus state’e sahip olmalıdır.
- Label metinleri kısa ve anlaşılır olmalıdır.
- Yardımcı açıklamalar muted renkte gösterilmelidir.
- Hata mesajları net ve kullanıcıya ne yapacağını söyleyen yapıda olmalıdır.
- Zorunlu checkbox’lar hiçbir zaman ön işaretli gelmemelidir.

Başvuru ve depozito öncesi zorunlu üçlü:

1. 30 günlük yayın taahhüdü.
2. Acente içerik kullanım izni.
3. Erken kaldırma/gizleme durumunda tur bedeli talep koşulu.

Bu üçlü **Aday Uygunluk Endeksi skoru değildir**, yalnızca başvuru/depozito kapısıdır.

---

## 12. Pasaport / Vize UI Kuralı

Yurt dışı turlarda pasaport/vize uygunluğu ayrı bir başvuru kapısıdır.

UI kuralları:

- Tur oluşturma ekranında acente, turu `Yurt içi` veya `Yurt dışı` olarak seçmelidir.
- Yurt dışı seçilirse pasaport/vize gereksinimi alanları görünmelidir.
- Creator profilinde pasaport türü ve geçerli pasaport bilgisi alınabilir.
- Creator gerekli uygunluğu karşılamıyorsa başvuru CTA’sı pasif olabilir veya başvuru denemesi net hata mesajıyla engellenir.
- Bu uygunluk AUE kartının alt skoru gibi gösterilmemelidir.
- Uygun değilse “skor düşük” denmez; “Pasaport/vize gereksinimi karşılanmadı” gibi açık mesaj verilir.

---

## 13. Aday Uygunluk Endeksi UI Kuralı

AUE yalnızca karar destek bilgisidir.

UI’da mutlaka şu his korunmalıdır:

- Sistem otomatik seçim yapmıyor.
- Acente nihai kararı veriyor.
- Skor sadece teknik/yayın uygunluğu referansıdır.

AUE kartında gösterilebilecek bilgiler:

- Aday Uygunluk Endeksi
- Teknik Kriter Uyumu
- Yayın Platform Uyumu
- Eksik teknik gereksinimler
- “Bu skor karar destek amaçlıdır. Nihai seçim acenteye aittir.” notu

AUE, “Kazandın”, “Seçildin”, “Sistem seni önerdi” gibi ifadelerle kullanılmaz.

---

## 14. Depozito UI Kuralı

MVP’de gerçek ödeme yoktur.

Doğru dil:

- Depozito onayı
- Mock depozito
- Depozito durumu
- Depozito beklemede
- Depozito güvence olarak tutuluyor
- Yayın bildirimi sonrası depozito serbest bırakma süreci

Kaçınılacak dil:

- Kredi kartı
- Karttan çekim
- SSL ödeme
- Ödeme sağlayıcı
- Stripe / iyzico
- Kaydedilmiş kart
- Ödeme yap

Depozito ekranı gerçek checkout gibi değil, operasyonel güvence adımı gibi görünmelidir.

---

## 15. İçerik Teslim UI Kuralı

İçerik teslimi yalnızca URL ile yapılır.

Doğru UI:

- Taslak içerik URL alanı
- Harici bağlantıyı aç
- Google Drive / iCloud / Dropbox gibi bağlantı örneği
- Link doğrulama mesajı
- Teknik checklist

Yasak UI:

- Video yükle
- Dosya seç
- Sürükle-bırak upload
- Uygulama içi medya kütüphanesi
- Video player / streaming deneyimi

İçerik önizlemesi gerekiyorsa yalnızca harici link kartı veya statik placeholder kullanılmalıdır.

---

## 16. Revizyon UI Kuralı

MVP’de acentenin yalnızca **bir teknik revizyon hakkı** vardır.

Revizyon gerekçesi:

- çözünürlük eksikliği,
- format uyumsuzluğu,
- gündüz çekimi şartı,
- minimum fotoğraf/lokasyon şartı,
- acente etiketi/görünürlüğü gibi objektif checklist maddeleri.

Geçersiz gerekçe:

- güzel olmamış,
- daha estetik olsun,
- beğenmedim,
- vibe uymadı.

UI, revizyon alanında teknik gerekçe yazımını desteklemelidir.

---

## 17. Yayın ve 30 Günlük Takip UI Kuralı

Creator, onaylanan içeriği kendi sosyal hesabında yayınlar ve yayın URL’sini bildirir.

UI’da gösterilecek ana bilgi:

- Yayın URL
- Platform
- Bildirim tarihi
- 30 gün public kalma uyarısı
- İzleme başlangıç/bitiş bilgisi
- İhlal bildirimi aksiyonu

Otomatik sosyal medya crawler, otomatik silinme tespiti veya otomatik ceza dili kullanılmaz.

---

## 18. Navigation Kuralları

Mobilde bottom navigation kullanılabilir, ancak her ekranda zorunlu değildir.

Bottom nav kullanılabilecek ana alanlar:

- Creator açık turlar
- Creator başvurularım
- Creator görevlerim
- Agency dashboard
- Agency ilanlar/başvurular
- Admin dashboard

Odak formlarında bottom nav sadeleştirilebilir:

- Başvuru formu
- Depozito onayı
- İçerik teslimi
- Yayın bildirimi
- İhlal bildirimi
- Admin karar ekranları

Navigation etiketleri Türkçe olmalıdır.

---

## 19. MVP Bileşenleri

Flutter tarafında ortak component olarak geliştirilebilecek MVP bileşenleri:

| Bileşen                          | Açıklama                     |
| -------------------------------- | ---------------------------- |
| `TurIzimPrimaryButton`           | Ana CTA                      |
| `TurIzimSurfaceCard`             | Standart premium kart        |
| `TurIzimSectionHeader`           | Bölüm başlığı                |
| `TurIzimStatusPill`              | Durum rozeti                 |
| `TurIzimInfoBanner`              | Bilgi/uyarı kartı            |
| `SuitabilityScoreCard`           | AUE ve alt skorlar           |
| `ApplicationCommitmentChecklist` | Başvuru checkbox üçlüsü      |
| `DepositConfirmationChecklist`   | Depozito öncesi tekrar onay  |
| `PublicationCommitmentNotice`    | 30 gün yayın uyarısı         |
| `AssignmentTimeline`             | Görev adımları               |
| `ViolationReportForm`            | İhlal bildirim formu         |
| `ExternalLinkInput`              | Teslim/yayın URL alanı       |
| `PassportVisaRequirementCard`    | Yurt dışı tur uygunluk kartı |

---

## 20. Erişilebilirlik

- Dokunma hedefleri minimum 48dp olmalıdır.
- Kontrast yeterli olmalıdır.
- CTA metinleri açık ve eylem odaklı olmalıdır.
- Form hataları yalnızca renkle anlatılmamalı; metinle de açıklanmalıdır.
- Uzun Türkçe metinlerde okunabilir satır aralığı korunmalıdır.
- Butonlar ve inputlar küçük ekranda taşmamalıdır.

---

## 21. Flutter’da İş Mantığının Dışarıda Tutulması

Flutter ekranları:

- skor formülünü kendi içinde tekrar hesaplamaz,
- assignment oluşturma kararını kendisi vermez,
- depozito durum makinesini UI içinde yönetmez,
- revizyon hakkını sadece local sayaçla dayatmaz,
- pasaport/vize uygunluk kapısını sadece frontend kontrolüne bırakmaz,
- ihlal kararını otomatik vermez.

Flutter bu kuralları mock/API’den gelen veriyle gösterir. Gerçek doğrulama ileride Spring Boot servis katmanında yapılır.

---

## 22. Google Stitch Kullanım Sınırı

Google Stitch:

- görsel atmosfer,
- ekran kompozisyonu,
- spacing,
- kart yapısı,
- renk dili,
- component referansı

için kullanılır.

Google Stitch:

- iş kuralı,
- backend mimarisi,
- veritabanı şeması,
- API sözleşmesi,
- ödeme akışı,
- otomatik eşleştirme mantığı

belirlemez.

Stitch HTML dosyaları Flutter widget’ına birebir kopyalanmaz. Flutter’da mevcut proje mimarisi, route yapısı, mock repository ve business-rule sınırları korunarak uygulanır.

---

## 23. UI Kontrol Listesi

Bir ekran tamamlandığında şu sorular kontrol edilir:

- [ ] Sosyal feed/chat hissi var mı?
- [ ] Otel/uçuş rezervasyonu algısı oluşuyor mu?
- [ ] Video upload veya video streaming UI’ı eklendi mi?
- [ ] Gerçek ödeme veya kart dili var mı?
- [ ] “Kapora” yerine “Depozito” kullanıldı mı?
- [ ] AUE otomatik seçim gibi gösteriliyor mu?
- [ ] Başvuru checkbox’ları ön işaretli mi?
- [ ] İçerik teslimi sadece URL ile mi?
- [ ] Yayın için 30 gün public kalma kuralı doğru mu?
- [ ] Yurt dışı turda pasaport/vize uygunluğu ayrı kapı olarak mı gösteriliyor?
- [ ] Ekranda tek güçlü primary CTA kuralı korunuyor mu?
- [ ] Mobilde overflow var mı?
- [ ] `flutter analyze` temiz mi?
- [ ] `flutter test` geçiyor mu?
