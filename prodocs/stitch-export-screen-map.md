# Stitch Export Screen Map

Bu dosya, Google Stitch çıktılarındaki ekranların Tur İzim Flutter MVP içindeki hangi ekran/akışlara karşılık geldiğini gösterir.

Stitch çıktıları yalnızca **görsel referanstır**. HTML/Tailwind kodları Flutter’a doğrudan kopyalanmaz.

Ana kaynak klasör:

```text
stitch-export/stitch_tur_izim_premium_pass
```

İş kuralı kaynakları:

- `PRD.md`
- `business-rules.md`
- `user-flows.md`
- `database-schema.md`
- `api-contract.md`
- `suitability-score.md`
- `DesignSystem.md`
- `premium-travel-pass-ui-guidelines.md`

---

## 1. Genel Kural

Stitch ekranları Flutter’a taşınırken:

- mevcut route yapısı korunur,
- mevcut mock repository yapısı korunur,
- mevcut rol bazlı akışlar korunur,
- business logic Flutter widget içine gömülmez,
- sosyal feed/chat/video upload/gerçek ödeme eklenmez,
- Aday Uygunluk Endeksi otomatik seçim gibi gösterilmez,
- depozito gerçek ödeme gibi gösterilmez,
- içerik teslimi yalnızca URL ile yapılır.

---

## 2. Ekran Haritası

| No  | Stitch Referansı                  | Rol     | Flutter Karşılığı            | Amaç                                              |
| --- | --------------------------------- | ------- | ---------------------------- | ------------------------------------------------- |
| 01  | `01-welcome`                      | Public  | `WelcomeScreen`              | İlk karşılama, rol seçimi, ürün değer önerisi     |
| 02  | `02-creator-open-tours`           | Creator | Creator açık tur listesi     | Başvuruya açık turları premium kartlarla gösterme |
| 03  | `03-creator-applications`         | Creator | Creator başvurularım         | Başvuru durumlarını listeleme                     |
| 04  | `04-creator-application-form`     | Creator | Başvuru formu                | Zorunlu onay checkbox’ları ile başvuru            |
| 05  | `05-creator-deposit-confirmation` | Creator | Mock depozito son onay       | Depozito öncesi son taahhüt onayı                 |
| 06  | `06-agency-dashboard`             | Agency  | Acente operasyon paneli      | Tur, başvuru ve görev özetleri                    |
| 07  | `07-agency-applicants-review`     | Agency  | Başvuran aday listesi        | Adayları AUE’ye göre inceleme                     |
| 08  | `08-agency-candidate-detail`      | Agency  | Aday detay ekranı            | Aday profil + uygunluk detayları                  |
| 09  | `09-admin-dashboard`              | Admin   | Admin paneli                 | Acente onayları ve ihlal kuyruğu                  |
| 10  | `10-admin-agency-approval`        | Admin   | Acente onay detayı           | Acente başvurusunu manuel inceleme                |
| 11  | `11-creator-content-delivery`     | Creator | İçerik teslim ekranı         | Taslak içerik URL gönderimi                       |
| 12  | `12-agency-violation-report`      | Agency  | İhlal bildirimi              | 30 gün kuralı ihlalini bildirme                   |
| 13  | `13-admin-violation-review`       | Admin   | İhlal inceleme               | Admin manuel ihlal kararı                         |
| 14  | `14-creator-tour-detail`          | Creator | Tur detay ekranı             | Tur, gereksinim, depozito, fiyat ve başvuru       |
| 15  | `15-agency-create-tour-step-1`    | Agency  | Tur oluşturma temel bilgiler | Tur adı, tarih, fiyat, depozito, kapsam           |
| 16  | `16-creator-assignments`          | Creator | Görevlerim                   | Seçilmiş görev ve depozito durumları              |
| 17  | `17-agency-content-review`        | Agency  | İçerik inceleme              | Taslak URL ve teknik checklist inceleme           |
| 18  | `18-agency-create-tour-step-2`    | Agency  | Tur içerik kriterleri        | Objektif checkbox gereksinimleri                  |
| 19  | `19-creator-publication-submit`   | Creator | Yayın bildirimi              | Yayındaki post URL bildirimi                      |
| 20  | `20-agency-publication-review`    | Agency  | Yayın inceleme               | Yayın URL kontrolü ve süreç kapatma               |

---

## 3. Detaylı Ekran Notları

### 01 — Welcome

**Flutter karşılığı:** `WelcomeScreen`

Korunacak görsel yön:

- premium hero alanı,
- sıcak açık zemin,
- güçlü başlık,
- kısa değer önerisi,
- net rol seçim CTA’ları.

Business düzeltmeleri:

- Tur İzim seyahat acentesi gibi anlatılmamalı.
- Otel/uçuş rezervasyonu dili kullanılmamalı.
- “Tatil satın al” gibi CTA olmamalı.
- Creator ve Agency ayrımı net olmalı.

---

### 02 — Creator Açık Turlar

**Flutter karşılığı:** Creator açık tur listesi

Korunacak görsel yön:

- premium tur kartları,
- fiyat/depozito bilgisi,
- ulaşım dahil etiketi,
- **çıkış şehri** ve **tur rotası** (kısa rota özeti) ile tarih bilgisi — coğrafya beyana dayalıdır; harita/GPS yok,
- soft chip’ler.

Business düzeltmeleri:

- Liste yalnızca başvuruya açık turları göstermeli.
- Yurt dışı turda creator pasaport/vize uygun değilse ilan gösterilmemeli veya CTA engellenmeli.
- AUE bu ekranda otomatik seçim gibi gösterilmemeli.
- Otel/uçuş filtreleri eklenmemeli.

---

### 03 — Creator Başvurularım

**Flutter karşılığı:** Creator başvuru listesi

Korunacak görsel yön:

- durum kartları,
- başvuru statüsü chip’i,
- Aday Uygunluk Endeksi özeti,
- sade liste.

Business düzeltmeleri:

- Başvuru statüleri açık gösterilmeli.
- `PENDING_REVIEW`, `ACCEPTED`, `REJECTED`, `WITHDRAWN` gibi durumlar karıştırılmamalı.
- “Eşleşme” dili kullanılmamalı.

---

### 04 — Creator Başvuru Formu

**Flutter karşılığı:** Başvuru formu

Korunacak görsel yön:

- tek ana kart,
- açık checkbox alanları,
- net primary CTA.

Business düzeltmeleri:

- Üç zorunlu checkbox ön işaretli olmamalı.
- Checkbox’lar:
  - 30 gün yayın taahhüdü,
  - içerik kullanım izni,
  - erken kaldırma/gizleme durumunda tur bedeli talep koşulu.
- Üçünden biri eksikse başvuru oluşturulmamalı.
- Bu üçlü AUE skoruna dahil edilmemeli.

---

### 05 — Creator Depozito Onayı

**Flutter karşılığı:** Mock depozito son onay ekranı

Korunacak görsel yön:

- güven hissi veren onay kartı,
- depozito durumu,
- açık taahhüt metinleri,
- tek primary CTA.

Business düzeltmeleri:

- Gerçek ödeme/kart/checkout dili yok.
- `Kapora` değil, `Depozito`.
- Bu aşamada creator son onay verir.
- Son onaydan sonra mock deposit `HELD`, assignment `ACTIVE` olur.

---

### 06 — Agency Dashboard

**Flutter karşılığı:** Acente operasyon paneli

Korunacak görsel yön:

- premium dashboard üst alanı,
- metrik kartları,
- tur kartları,
- yeni tur oluştur CTA’sı,
- operasyon odaklı görünüm.

Business düzeltmeleri:

- Dashboard otel/uçuş satış paneli gibi olmamalı.
- Tur kartlarında:
  - normal satış fiyatı,
  - beklenen depozito,
  - creator quota,
  - başvuru sayısı,
  - atanan creator sayısı gösterilebilir.
- Otomatik match/otomatik seçim dili yok.

---

### 07 — Agency Başvuran Aday Listesi

**Flutter karşılığı:** Acente aday inceleme listesi

Korunacak görsel yön:

- aday kartları,
- AUE skoru,
- teknik/yayın kırılımı,
- incele/seç CTA’sı.

Business düzeltmeleri:

- AUE sadece karar destek bilgisidir.
- Liste skor azalan sıralanabilir ama sistem otomatik seçmez.
- Son kararı acente manuel verir.
- “En iyi aday otomatik seçildi” dili kullanılmaz.

---

### 08 — Agency Aday Detayı

**Flutter karşılığı:** Aday detay ekranı

Korunacak görsel yön:

- aday profil özeti,
- AUE detay kartı,
- eksik kriter listesi,
- karar CTA’sı.

Business düzeltmeleri:

- Pasaport/vize uygunluğu gerekiyorsa AUE alt skoru gibi değil, ayrı uygunluk kapısı olarak gösterilmeli.
- Seçim manuel olmalı.
- Kabul edilirse assignment oluşur; doğrudan depozito HELD olmaz.

---

### 09 — Admin Dashboard

**Flutter karşılığı:** Admin paneli

Korunacak görsel yön:

- onay bekleyen acenteler,
- ihlal kuyruğu,
- kısa metrik kartları.

Business düzeltmeleri:

- Admin kararları manuel inceleme gibi görünmeli.
- Otomatik yaptırım dili kullanılmamalı.

---

### 10 — Admin Acente Onayı

**Flutter karşılığı:** Acente onay detay ekranı

Korunacak görsel yön:

- acente bilgi kartı,
- belge/bilgi özeti,
- onay/red CTA’ları.

Business düzeltmeleri:

- Sadece onaylı acente tur yayımlayabilir.
- Eksik bilgiyle onay verilmemeli.
- Tur şirketi olmayan kullanıcı kabul edilmemeli.

---

### 11 — Creator İçerik Teslimi

**Flutter karşılığı:** İçerik teslim URL ekranı

Korunacak görsel yön:

- external link input,
- checklist kartı,
- teslim CTA’sı.

Business düzeltmeleri:

- Video upload yok.
- Dosya seç/sürükle-bırak yok.
- İçerik teslimi yalnızca harici URL ile.
- Google Drive / iCloud / Dropbox gibi örnekler verilebilir.

---

### 12 — Agency İhlal Bildirimi

**Flutter karşılığı:** İhlal bildirim formu

Korunacak görsel yön:

- uyarı kartı,
- açıklama alanı,
- kanıt URL input,
- destructive CTA.

Business düzeltmeleri:

- İhlal manuel bildirilir.
- Otomatik sosyal medya crawler yok.
- Otomatik ceza/tahsilat dili yok.

---

### 13 — Admin İhlal İnceleme

**Flutter karşılığı:** Admin ihlal karar ekranı

Korunacak görsel yön:

- kanıt kartı,
- taraf bilgileri,
- karar notu,
- onay/red CTA’ları.

Business düzeltmeleri:

- Admin manuel karar verir.
- Yayının 30 gün public kalma kuralı temel alınır.
- Otomatik para cezası dili kullanılmaz.

---

### 14 — Creator Tur Detayı

**Flutter karşılığı:** Creator tur detay ekranı

Korunacak görsel yön:

- büyük hero/tur kartı,
- rota/tarih/fiyat/depozito,
- gereksinim listesi,
- başvuru CTA’sı.

Business düzeltmeleri:

- Tur yurt dışıysa pasaport/vize gereksinimleri açık gösterilmeli.
- Creator uygun değilse CTA engellenmeli.
- Başvuru CTA’sı booking satın alma gibi görünmemeli.
- “Rezervasyon yap” kullanılmamalı.

---

### 15 — Agency Tur Oluşturma Step 1

**Flutter karşılığı:** Tur oluşturma temel bilgiler

Korunacak görsel yön:

- sade form,
- premium kart,
- net alan grupları.

Business düzeltmeleri:

- Tur adı, tarih, çıkış, varış, fiyat, depozito, quota alınmalı.
- `Yurt içi / Yurt dışı` seçimi olmalı.
- Yurt dışı seçilirse pasaport/vize gereksinim alanları açılmalı.
- `transportation_included` MVP’de varsayılan true olmalı.
- Otel/uçuş alanı eklenmemeli.

---

### 16 — Creator Görevlerim

**Flutter karşılığı:** Creator assignment listesi

Korunacak görsel yön:

- görev kartları,
- durum timeline’ı,
- depozito statüsü,
- sonraki aksiyon CTA’sı.

Business düzeltmeleri:

- Assignment, başvuru kabulünden sonra oluşur.
- Match dili kullanılmaz.
- Depozito durumu mock olarak gösterilir.

---

### 17 — Agency İçerik İnceleme

**Flutter karşılığı:** Acente taslak içerik inceleme ekranı

Korunacak görsel yön:

- external link kartı,
- checklist,
- onay/revizyon CTA’ları.

Business düzeltmeleri:

- İçerik uygulama içinde oynatılmaz.
- Acentenin yalnızca bir teknik revizyon hakkı vardır.
- Revizyon gerekçesi objektif checklist maddelerine dayanmalıdır.
- “Güzel olmamış” gibi subjektif gerekçe yok.

---

### 18 — Agency Tur Oluşturma Step 2

**Flutter karşılığı:** Tur içerik kriterleri

Korunacak görsel yön:

- checkbox grupları,
- objektif teknik kriterler,
- yayın platformu seçimi.

Business düzeltmeleri:

- Kriterler objektif olmalı:
  - 1080p,
  - dikey format,
  - ham dosya,
  - minimum fotoğraf,
  - minimum lokasyon,
  - gündüz çekimi,
  - Instagram/TikTok yayını.
- Sanatsal beklenti yazılamaz.
- En az bir yayın platformu seçilmeden tur published olamaz.

---

### 19 — Creator Yayın Bildirimi

**Flutter karşılığı:** Yayın URL gönderme ekranı

Korunacak görsel yön:

- yayın URL input,
- 30 gün public uyarısı,
- depozito serbest bırakma bilgilendirmesi,
- tek CTA.

Business düzeltmeleri:

- Yayın URL’si zorunlu.
- 30 gün public kalma kuralı açık yazılmalı.
- Otomatik sosyal medya doğrulama yok.

---

### 20 — Agency Yayın İnceleme

**Flutter karşılığı:** Agency yayın URL inceleme

Korunacak görsel yön:

- yayın link kartı,
- görev özeti,
- onay/ihlal bildir CTA’ları.

Business düzeltmeleri:

- Yayın bildirimi sonrası depozito release süreci başlar.
- Gerçek ödeme entegrasyonu yok.
- İhlal varsa manuel bildirim yapılır.

---

## 4. Business Rule Düzeltme Listesi

Stitch ekranlarında görülebilecek ama Flutter’a taşınmaması gereken riskli ifadeler:

| Riskli İfade/Yön    | Doğru Kullanım                   |
| ------------------- | -------------------------------- |
| Kapora              | Depozito                         |
| Rezervasyon yap     | Başvur                           |
| Satın al            | Başvur / Detayları Gör           |
| Match / Eşleşme     | Başvuru / Atama                  |
| Sistem seni seçti   | Acente başvurunu değerlendirecek |
| Otomatik atama      | Manuel acente seçimi             |
| Video yükle         | İçerik URL’si gönder             |
| Dosya seç           | Harici bağlantı paylaş           |
| Kredi kartı / ödeme | Mock depozito onayı              |
| 6 ay yayında tut    | 30 gün public kalmalı            |
| Güzel video         | Objektif teknik kriter           |

---

## 5. Flutter’a Taşıma Sırası

Önerilen implementasyon sırası:

1. Shared UI foundation:
   - theme tokens,
   - premium cards,
   - status pills,
   - primary/secondary buttons,
   - section headers.

2. Agency dashboard:
   - mevcut çalışan acente ekranını Premium Travel Pass yönüne çek.

3. Creator açık tur listesi.

4. Creator tur detay.

5. Creator başvuru formu.

6. Creator görevlerim / içerik teslim / yayın bildirimi.

7. Agency başvuran aday listesi / aday detay.

8. Agency içerik inceleme / yayın inceleme.

9. Admin dashboard / acente onay / ihlal inceleme.

Tüm ekranlar tek seferde dönüştürülmemelidir.

---

## 6. Uygulama Kontrolü

Her Flutter değişikliğinden sonra:

```powershell
cd C:\dev\tur-izim\frontend
flutter analyze
flutter test
flutter run -d chrome
```

Kontrol:

- mobilde overflow yok,
- Chrome/web görünümü bozulmadı,
- route akışı çalışıyor,
- mock repository bozulmadı,
- business logic UI içine gömülmedi,
- yasak kapsam eklenmedi.

---

## 7. Son Not

Bu dosya, Stitch ekranlarını Flutter’a taşırken hangi ekranın ne amaçla kullanılacağını belirler.

Karar kuralı:

> Ürün mantığında çelişki varsa Stitch değil, Tur İzim dokümanları kazanır.
