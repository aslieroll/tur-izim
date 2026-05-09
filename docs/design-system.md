# Tasarım sistemi (Flutter MVP)

Dokümantasyon Türkçe; tema sınıfları ve token adları projede İngilizce kalabilir.

## Mimari uyum

- **Flutter + Dart**, **özellik (feature)** bazlı **temiz mimari**.  
- **Mobil öncelik.**  
- **`Google Stitch`** yalnızca **tasarım referansıdır** — backend veya iş kuralının kaynağı değildir. Stitch çıktıları **sosyal akış, sohbet, otel/uçuş rezervasyonu veya uygulama içi video akış bileşeni** gerektirirse kullanılmamalıdır.

## Marka algısı

**Güvenilir, sakin ve modern Türkiye start-up sıcaklığı** — operasyon katmanına uygun, “sosyal zaman tüneline” yakın güç gösterimi yapılmadan.

## Dil ve etiketler

Tüm kritik uyarıların ve form etiketlerinin **ana dili Türkçe olmalıdır** (zorunlu onayların tam metni üründe hukukla desteklenecek şekilde tekrarlanır).

## İlkeler (yaslak küme)

| İlke | Uygulama |
|------|-----------|
| Sosyal ürün yapısı yok | Ana nav’da akış/sohbet yok |
| Teslimat | **Dosya yükleme alanı tasarılmaz** — yalın **URL** girişi ve “harici aç” |
| Yayın doğrulama | **Oyunculu video stream** yok; yalın URL doğrulama ve statü |
| Güven hissiyatı | Boşluğu ferah kullan |

## Yerleşim ve tipografi

- **8px** ızgaralı boşluk; okunabilir gövde metni için **bir sans-serif**.  
- Kritik eylemlerde **tek bir birincil buton**.

## Renk kullanımı (anlam)

Flutter `ThemeData` içinde: **primary**, **surface**, **başarı** (onay, depozitosal serbestiye yakın bildirici), **uyarı** (revizyon, admin bekliyor), **tehlike** / ihlaller.

## MVP bileşenleri (zorunlu ekranda çağrıları)

| Bileşen | Açıklama |
|---------|-----------|
| **30 günlük yayın uyarı kartı** | Gönderiyi kaldırma sonuçları; **ön işaret kullanıcıdan bağımsız** metin bloklarıyla |
| **Başvuru öncesi onay kutuları** | Üç zorunlu onay metni — işaret gerektiren; varsayılan işaret yok |
| **`Assignment`/`depozito` teyidi** | Aynı metin bloklarının yeniden doğrulanması |
| **`Aday Uygunluk Endeksi` kartı** | `suitability_score`, alt öğe **Teknik** ve **yayına uygunluk** dereceleri |
| **`Başvuru sıralayan kart listesi`** | Eksik maddeler, seviye rozet (**Çok Yüksek** … vb.) |
| **Elle seçim kontrolleri** | **Birden fazla aday seçme** kota ile sınırlanır (**yakalayan otomatik atama bileşeni tasarılmaz**) |
| **İçerik üretici atama zaman akış çizgesi** | `WAITING_*` süreleri |
| **İhlal raporu oluşturma** | Gerekçe metni ve isteğe bağlı kanıt bağlantısı |
| **Admin: acente onayı** ve **ihlal incelemesi** ekranı | Süzme ve karar aksiyonları |

## Erişilebilirlik

**48 dp** minimum dokunuş hedefi; metin için **yeterince yüksek kontrast** (WCAG’e yaklaşım önerilir).

## Metin uyarısı (kanca)

“Aday Uygunluk Endeksi”nin **otomatik seçim olmadığı** ve acenteye yalın **referans oluşturmak için** hesapladığı küçük notla desteklenebilir.

## İş mantığının dışına itme

Flutter ekranı, **iş kararının kendisi** üretmez: **sıra skorlarıyla API veya yapılmış mock’un kopyası olarak** kullanıcıya görüntüsünü verir (**çekirdek kural doğrulanmış sunucu verisine dayalı olmalıdır**).
