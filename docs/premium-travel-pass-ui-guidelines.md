# Premium Travel Pass UI Rehberi

Bu rehber, `stitch-export/stitch_tur_izim_premium_pass/premium_travel_pass/DESIGN.md` dosyasındaki Google Stitch tasarım yönünü Tur İzim MVP frontend çalışmaları için yorumlar. Amaç, Flutter ekranlarını uygulamadan önce onaylı görsel dili, UI kurallarını ve MVP sınırlarını netleştirmektir.

## Görsel Kimlik

Premium Travel Pass dili; sıcak, ferah, güven veren ve profesyonel bir operasyon platformu hissi vermelidir. Tur İzim bir seyahat acentesi, otel/uçuş pazarı veya sosyal medya uygulaması değildir. Bu nedenle görsel kimlik, lüks seyahat atmosferinden ilham alırken ürün vaadini "güvenli iş birliği ve operasyon akışı" olarak konumlandırmalıdır.

Ekranlar modern kurumsal yapı ile glassmorphism etkisini birleştirmelidir. Büyük boşluklar, yumuşak gölgeler, açık zeminler, gök mavisi/lavanta geçişleri ve premium fotoğraf/illüstrasyon alanları kullanılabilir. Ancak bu öğeler tur satışı veya rezervasyon ürünü algısı yaratmamalıdır.

## Renk Kullanımı

Ana zemin Warm White / açık yüzey tonları olmalıdır. Stitch kaynağındaki temel yüzey rengi `#fdf7ff`, kart yüzeyleri için `#ffffff`, `#f8f2fa`, `#f2ecf4` ve `#ece6ee` ailesi kullanılır. Flutter tarafında mevcut tasarım tokenlarıyla uyum korunmalıdır.

Deep Navy, ana metin ve navigasyon otoritesi için kullanılır. Başlıklar, önemli metinler ve bilgi hiyerarşisi yüksek kontrastlı ancak sert olmayan lacivert tonlarında kalmalıdır.

Royal Indigo, birincil aksiyon rengidir. Ana CTA, seçili tab, aktif chip, önemli skor vurgusu ve odak durumlarında kullanılmalıdır. Aynı ekranda çok fazla indigo blok kullanılmamalı; aksiyon hiyerarşisi net kalmalıdır.

Soft Sky Blue ve Soft Lavender dekoratif/ikincil atmosfer tonlarıdır. Arka plan gradientleri, chip zeminleri, hero görselleri ve cam etkili yüzeylerde kullanılabilir. Ana metin veya kritik CTA rengi gibi davranmamalıdır.

Sand Cream sıcak destek yüzeyidir. Bilgi kartları, tur kartı gövdesi veya yumuşak zemin ayrımı için kullanılabilir; soğuk lavanta/mavi cam yüzeylerle çakışmayacak ölçüde kullanılmalıdır.

Soft Coral yalnızca küçük aksan olarak kullanılmalıdır. Aktif bottom navigation noktası, küçük uyarı/rozet vurgusu veya dikkat çekici mikro detay için uygundur. Geniş buton, büyük kart zemini veya baskın tema rengi olarak kullanılmamalıdır.

Hata ve ihlal akışlarında kırmızı kullanılabilir, fakat bu renk yalnızca gerçekten kritik veya negatif karar alanlarında kullanılmalıdır. Tur İzim'in genel arayüzü hata/uyarı panosu gibi görünmemelidir.

## Tipografi

Ana başlıklar premium ve editorial his için serif karakterde düşünülmelidir. Stitch referansı `Noto Serif` kullanır; Flutter tarafında mevcut tema ile uyumlu en yakın başlık stili seçilmelidir.

Fonksiyonel UI metinleri, gövde metinleri, butonlar, form etiketleri ve liste detayları modern sans-serif karakterde kalmalıdır. Stitch referansı `Plus Jakarta Sans` kullanır; mevcut Flutter tema tipografisi ile çelişmeden uygulanmalıdır.

Türkçe metinler daha uzun olabileceği için satır yüksekliği cömert tutulmalıdır. Başlıklar sıkışmamalı; slogan, açıklama, form yardımcı metinleri ve kart detayları rahat okunmalıdır.

`label-caps` yaklaşımı; bölüm üst yazıları, meta bilgiler, chip etiketleri ve durum rozetleri için kullanılabilir. Büyük metin bloklarında tamamen büyük harf kullanımından kaçınılmalıdır.

## Spacing ve Layout

Mobil öncelikli düzen korunmalıdır. Sayfa yatay boşluğu Stitch referansında 24px'tir; Flutter ekranlarında mevcut margin tokenlarıyla bu geniş, ferah hissin karşılığı korunmalıdır.

4px grid mantığı takip edilmelidir. Küçük ilişkili öğeler 8px, orta grup aralıkları 16px, kart içi boşluklar en az 20px, büyük bölüm aralıkları 32-48px aralığında olmalıdır.

Ekranlar tek parça bir operasyon akışı gibi okunmalıdır. Header, içerik kartları, CTA ve bottom navigation arasında görsel ilişki olmalı; rastgele bloklar gibi görünmemelidir.

Web/Chrome genişliğinde içerik sınırsız yayılmamalıdır. Mobil ve tablet tasarımda `max-width` mantığı korunmalı; büyük ekranlarda ortalanmış ve okunabilir bir kolon yapısı tercih edilmelidir.

## Kart Kuralları

Kartlar rounded-xl veya daha büyük yumuşak köşelerle kullanılmalıdır. Stitch referansında büyük kartlar 16-24px aralığında yuvarlatılmıştır. Aynı ekranda kart radius değerleri tutarlı olmalıdır.

Derinlik ağır gölgelerle değil, tonal yüzeyler ve ambient shadow ile sağlanmalıdır. Tipik kart gölgesi düşük opaklıklı Deep Navy tonunda, yumuşak blur ile uygulanmalıdır.

Seyahat/tur kartlarında görsel header kullanılabilir. Görsel üstüne koyu gradient ve okunabilir başlık eklenebilir. Kart gövdesi Sand Cream veya açık yüzey tonunda olmalı; bilgi gridleri, chipler ve CTA net hiyerarşiyle yerleşmelidir.

Glassmorphism yalnızca seçili alanlarda kullanılmalıdır: welcome hero, overlay, özel onay kartı veya odaklanmış işlem paneli. Çok fazla cam panel ekranı dağınık gösterebilir.

## Buton Hiyerarşisi

Birincil buton Royal Indigo zemin ve beyaz metin kullanır. Ana akışı ilerleten CTA'lar, örneğin `Başvur`, `Devam Et`, `İncelemeye Gönder`, `Acenteyi Onayla` bu gruptadır. Butonlar pill veya yüksek radius ile kullanılmalı ve çok hafif gölge almalıdır.

İkincil butonlar açık yüzey, ince border veya düşük opaklıklı indigo yüzey kullanabilir. Aynı ekranda birincil butonla rekabet etmemelidir.

Tersiyer aksiyonlar metin butonu, sessiz ikonlu aksiyon veya düşük kontrastlı link gibi görünmelidir. Admin girişleri, iptal/geri dön gibi eylemler bu hiyerarşidedir.

Destructive aksiyonlar yalnızca ihlal/ret gibi gerçek riskli işlemlerde kırmızı kullanılmalıdır. Kırmızı aksiyonların yanında açıklama veya onay bağlamı bulunmalıdır.

## Bottom Navigation Stili

Bottom navigation, mobilde Deep Navy zeminli, blur etkili, üst köşeleri geniş yuvarlatılmış bir bar olarak kullanılabilir. Aktif durum beyaz ikon/metin ve küçük Soft Coral nokta ile belirtilmelidir.

Pasif öğeler düşük opaklıklı açık indigo/beyaz tonlarında kalmalıdır. Navigation etiketleri kısa, tutarlı ve tercihen Türkçe olmalıdır. Stitch export içinde bazı etiketler İngilizce (`Tours`, `Applications`, `Profile`) görünebilir; Flutter uygulamasında Türkçe ürün diline uygun karşılıklar kullanılmalıdır.

Bottom navigation her odak formunda zorunlu değildir. İhlal bildirimi, depozito onayı veya kritik karar gibi odaklanmış ekranlarda navigation saklanabilir veya geri aksiyonu öne çıkarılabilir.

## Dashboard, Liste ve Kart Stili

Dashboard ekranlarında bento/grid yaklaşımı kullanılabilir. İstatistik kartları açık yüzey, düşük opaklıklı dekoratif blur ve label-caps başlıklarla sunulmalıdır.

Liste öğeleri minimal, yüksek okunabilirlikli ve operasyon odaklı olmalıdır. Avatar, durum rozeti, tarih, AUE skoru veya ilgili işlem CTA'sı gibi veriler tek bakışta anlaşılmalıdır.

Creator ve agency listelerinde sosyal medya feed hissi verilmemelidir. İçerik görselleri portfolyo veya kanıt/önizleme bağlamında kullanılabilir; sonsuz akış, beğeni, yorum, takip et gibi sosyal medya etkileşimleri kullanılmamalıdır.

AUE gösterimleri karar destek olarak tasarlanmalıdır. Yüksek skor görsel olarak vurgulanabilir, fakat sistemin otomatik seçim yaptığı algısı yaratılmamalıdır. Final seçim açıkça acenteye ait olmalıdır.

## Form Stili

Formlar kart içinde, temiz bölüm başlıklarıyla ve label-caps etiketlerle sunulmalıdır. Input alanları açık yüzey, ince border, 8-16px radius ve net focus state kullanmalıdır.

Checkbox/radio kriterleri objektif olmalıdır. Teknik format, çözünürlük, platform, tarih, URL erişimi, 30 günlük yayın taahhüdü gibi doğrulanabilir maddeler kullanılmalıdır.

Creator onay kapısındaki zorunlu checkbox'lar asla pre-selected olmamalıdır. Bunlar 30 günlük yayın taahhüdü, acente içerik kullanım izni ve erken kaldırma durumunda tur bedeli talep koşuludur.

İçerik teslimi in-app upload değil, harici cloud/link alanı olarak tasarlanmalıdır. Google Drive, iCloud, Dropbox veya benzeri bağlantı metni kullanılabilir; uygulama içi video yükleme UI'ı kullanılmamalıdır.

MockDeposit ve ödeme benzeri akışlarda gerçek ödeme sağlayıcı UI'ı kullanılmamalıdır. Kredi kartı, SSL, payment provider, tahsilat veya gerçek ödeme dili MVP kapsamı dışıdır. Depozito UI'ı mock/operasyonel güvence olarak anlaşılmalıdır.

## Yasak UI Yönleri

Aşağıdaki UI yönleri MVP kapsamı dışıdır ve Flutter implementasyonunda kullanılmamalıdır:

- Sosyal medya feed'i yok.
- Chat UI yok.
- Otel rezervasyon UI'ı yok.
- Uçuş rezervasyon UI'ı yok.
- Video upload UI'ı yok.
- Gerçek ödeme sağlayıcı UI'ı yok.
- Random assignment veya automatic matching UI'ı yok.
- AI video analysis UI'ı yok.

## İş Kuralı Notları

`Application`, creator'ın tura başvurmasıdır. `Assignment`, acentenin creator'ı manuel seçmesidir. `Match` dili kullanılmamalıdır.

Aday Uygunluk Endeksi yalnızca karar destek bilgisidir. UI skorları sıralayabilir veya görünür kılabilir, fakat nihai seçim acenteye aittir.

Yayınlanan post en az 30 gün public erişilebilir kalmalıdır. Stitch export içinde görülen 6 ay gibi ifadeler Flutter implementasyonuna taşınmamalıdır.

İhlal incelemesi admin tarafından manuel yapılır. UI bu manuel değerlendirme hissini korumalı; otomatik ceza, otomatik tahsilat veya otomatik karar dili kullanılmamalıdır.