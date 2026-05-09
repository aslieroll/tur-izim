# Tur İzim — Google Stitch için ürün ve arayüz brief’i

Bu dosya **sıfırdan** mobil uygulama ve web arayüzü tasarımı üretmek için hazırlanmıştır. Kaynak: `docs/prd.md` ve `docs/design-system.md`. **Stitch yalnızca tasarım referansıdır**; iş kurallarının veya backend’in tek kaynağı değildir.

---

## 1) Stitch’e tek cümlelik talimat (prompt’a yapıştır)

Türkçe etiketli, mobil öncelikli, güven ve operasyon hissi veren bir B2B/B2C uygulama tasarla: **Tur İzim** — yerel tur acenteleri ile boş kontenjanı olan **ulaşım dahil** turlara **üniversite öğrencisi içerik üreticilerinin** **manuel başvurduğu**, **şehir bazlı** güven ve operasyon platformu. Acente **şehir** ve **tur çıkış şehri** bilgisini girer; öğrenci üretici **üniversite, bölüm, sınıf ve kampüs/şehir** beyanını profilinde kullanabilir. **Sosyal akış, sohbet, otel/uçuş rezervasyonu, video akışı oynatıcı ve dosya yükleme ile içerik teslimi yok.** Teslim ve yayın **yalnızca URL** ile. Harita, GPS veya otomatik konum doğrulaması yok. Ana renkler: primary, surface; durumlar için başarı, uyarı, tehlike. 8px grid, tek birincil eylem, 48dp dokunma hedefi. Üç rol: **Creator**, **Agency**, **Admin**. Metinler **Türkçe**; teknik tablo/API isimleri İngilizce kalabilir.

---

## 2) Ürün kimliği (PRD özeti)

> Tur İzim, yerel tur acentelerinin boş koltuklarını; üniversite öğrencilerinin teknik şartları belirlenmiş fotoğraf/video içerikleri ve 30 günlük yayın taahhüdü karşılığında değerlendirmesini sağlayan şehir bazlı güvenli görev ve içerik teslim platformudur.

| Alan | Açıklama |
|------|----------|
| Ne | B2B/B2C **güven ve operasyon** platformu: acenteler boş koltukları doldurmak için **üniversite öğrencisi içerik üreticileri** (öğrenci içerik üreticisi) ile buluşur; **şehir bazlı** çalışır. |
| Ne değil | Seyahat acentesi yazılımı gibi sıfırdan paket satışı değil; sosyal feed, chat, otel/uçuş pazarı, video streaming, uygulama içi dosya yükleme ile teslim **değil**. |
| Şehir bazlı kullanım | Tek şehir veya tek coğrafyayla **sınırlı bir ürün değildir**. Acente kayıt/profil ve tur ilanında **şehir** ile **çıkış şehri** (ve tur rotası / varış özeti) bilgisini **manuel** girer. Konum GPS veya harita ile doğrulanmaz. Örnek varış kümeleri (tasarım örneği): **Kapadokya**, **Güney**; **ulaşım dahil** acente turları. |
| Süreç özeti | Manuel başvuru → **Aday Uygunluk Endeksi (AUE)** ile sıralama / karar desteği → acente **elle seçim** → `Assignment` → mock depozito → taslak **URL** → (en fazla bir teknik revizyon) → yayın **URL** → 30 gün izleme / ihlal bildirimi (manuel). |

**Terminoloji (UI’da Türkçe, “match” kullanma):**

- **Başvuru** = creator’ın tura başvurması (`Application`).
- **Atama** = acentanın creator’ı **manuel seçmesi** (`Assignment`). “Eşleşme / match” dili kullanılmaz.

---

## 3) Stitch’in kesinlikle üretmemesi gerekenler (PRD + tasarım sistemi)

Aşağıdakiler **ekran veya ana navigasyonda yer almamalı**:

- Sosyal zaman tüneli, feed, “keşfet”.
- Sohbet, DM, canlı destek sohbeti ürünü gibi yapı.
- Otel / uçuş arama veya rezervasyon akışı.
- Video oynatıcı, hikâye benzeri tam ekran sosyal deneyim.
- Ham medya / video **dosya yükleme** alanı (teslim sadece **URL metin alanı** + “harici aç”).
- “Sistem seni seçti”, otomatik atama, rastgele eşleştirme UI’sı.
- Gerçek ödeme (kart, iyzico, Stripe) akışı — yalnızca **mock depozito** durumları ve bilgilendirme.

---

## 4) Marka ve his (design-system)

- **Algı:** Güvenilir, sakin, modern Türkiye start-up sıcaklığı; operasyon aracı; “sosyal uygulama” gösterişi yok.
- **Boşluk:** Ferah layout; bilgi yoğunluğu kartlarla kontrollü.
- **Dil:** Kritik uyarılar ve formlar **Türkçe**; hukuki metinler placeholder olarak “metin eklenecek” notu bırakılabilir.

---

## 5) Tasarım token’ları (Stitch / Figma için öneri)

| Token | Kullanım |
|-------|----------|
| `spacing` | 8px taban (8, 16, 24, 32). |
| `radius` | Kartlar için tutarlı köşe (ör. 12–16). |
| `font` | Tek okunaklı sans-serif ailesi; başlık / gövde / caption hiyerarşisi. |
| `color.primary` | Birincil aksiyon ve vurgu. |
| `color.surface` | Arka plan ve kart yüzeyi. |
| `color.success` | Onay, başarılı adım, depozito serbeste yakın pozitif durum. |
| `color.warning` | Revizyon, beklemede, admin incelemesi. |
| `color.danger` | İhlal, red, kritik uyarı. |

**Eylem kuralı:** Aynı ekranda birden fazla güçlü birincil buton olmasın; kritik adımda **tek primary**.

---

## 6) Erişilebilirlik ve platform

- Dokunma hedefi **en az 48×48 dp** (mobil).
- Metin kontrastı yüksek (WCAG’e yaklaşım).
- **Web:** Aynı bilgi mimarisi; breakpoint’lerde yan menü → üst sekme / hamburger; tablolar dar ekranda kartlara dönüşebilir.
- **Mobil uygulama:** Bottom nav veya üst sekmeler; derin akışlarda üst başlık + geri.

---

## 7) Bilgi mimarisi (rol bazlı — Stitch’e ekran listesi)

### Ortak

- Karşılama / rol seçimi veya giriş sonrası rol yönlendirmesi.
- Ayarlar (profil özeti, çıkış — detay MVP’de sade tutulabilir).

### Creator (üniversite öğrencisi içerik üreticisi)

1. **Gösterge paneli:** Açık ilanlar özeti, başvurularım, atamalarım kısayolları.
2. **Yayımdaki turlar listesi:** Kart — başlık, çıkış şehir/bölge, varış kümesi, tarih aralığı, üretici kotası, depozito tutarı, tahmini tur fiyatı (varsa), ulaşım dahil etiketi.
3. **Tur detayı:** Gereksinim özeti, üç taahhüt metni (salt okunur önizleme) + başvuru CTA’sı (tasarımda buton olabilir; metin “iş kuralı kapısı” olduğunu belirtsin).
4. **Başvuru ekranı:** Üç **zorunlu** checkbox — **varsayılan işaretli değil**; kısa not alanı; bilgi: “AUE skor bileşeni değildir”.
5. **Başvurularım:** Durum + AUE satırı (referans amaçlı).
6. **Atama hub’ı:** Zaman çizgisi / adımlar: depozito teyidi → taslak URL → acente onayı / revizyon → yayın URL → izleme.
7. **Taslak URL:** Tek satır URL + “harici aç”; dosya yükleme yok.
8. **Yayın URL:** Tek satır + durum rozeti.
9. **30 günlük yayın uyarı kartı** (tekrarlayan bileşen): silme/gizleme sonuçları; ön işaret yok, bilgilendirici metin.

### Agency (acenta)

1. **Operasyon özeti:** Bekleyen başvuru sayısı, ilan kartları.
2. **İlanlarım:** Kart — başlık, durum, üretici kotası, bekleyen başvuru sayısı.
3. **İlan oluşturma / düzenleme (taslak):** Başlık, tarih, kota, depozito, tahmini fiyat, ulaşım dahil; gereksinim seçimi (çoklu seçim listesi — tasarım için).
4. **Başvuranlar listesi:** Kartlar **AUE azalan** sırada (görsel olarak sıra numarası veya küçük “sıra” etiketi); her kartta: **Aday Uygunluk Endeksi**, Teknik uyum, Yayın platform uyumu, eksik maddeler özeti, küçük not: “otomatik seçim yok”.
5. **Elle seçim:** Kota içinde çoklu seçim **checkbox** veya benzeri — **“Sistem ataması” animasyonu veya tek tıkla en iyiyi seç” yok.**
6. **Taslak inceleme:** URL gösterimi, checklist maddeleri (tik kutuları acente tarafı), tek revizyon talebi alanı (teknik gerekçe).
7. **Yayın doğrulama:** URL + statü; video embed yok.
8. **İhlal bildirimi:** Gerekçe metni + isteğe bağlı kanıt URL’si.

### Admin

1. **Bekleyen acenteler:** Liste, onay / red.
2. **İhlal kuyruğu:** Süzme, detay, karar (onaylı / reddedilmiş — metin notu).

---

## 8) Zorunlu UI bileşenleri (design-system → Stitch bileşen seti)

Stitch’e şunu söyleyebilirsin: Aşağıdaki bileşenleri **design system bileşeni** olarak üret (varyantlı).

| Bileşen adı (İngilizce etiket OK) | Türkçe kullanım |
|-----------------------------------|-----------------|
| `PublicationCommitmentNotice` | 30 günlük yayın taahhüdü uyarı kartı; checkbox yok, sadece metin. |
| `ApplicationCommitmentChecklist` | Üç onay kutusu; **default unchecked**. |
| `DepositConfirmationChecklist` | Atama / depozito öncesi aynı üçlünün tekrarı. |
| `SuitabilityScoreCard` | AUE + alt satırlar: Teknik Kriter Uyumu, Yayın Platform Uyumu; kısa dipnot: karar desteği, otomatik seçim yok. |
| `ApplicantRankedList` | Sıralı kart listesi, eksik gereksinim özeti, uyum rozeti (Çok Yüksek / Yüksek / Orta / Düşük — metin olarak). |
| `QuotaSelectionBar` | “Seçilen / kota” sayacı; çoklu seçimde kota aşımını engelleyen UI ipucu. |
| `AssignmentTimeline` | Üretici tarafı bekleyen adımlar (WAITING_* benzeri etiketler Türkçe). |
| `ViolationReportForm` | Gerekçe + opsiyonel kanıt URL. |
| `AdminReviewTable` | Desktop’ta tablo, mobilde kart. |

---

## 9) Ekran başına Stitch prompt şablonları (kopyala-yapıştır)

Her prompt’un sonuna ekle: *“Türkçe UI metinleri. Sosyal feed, chat, otel/uçuş, video player, dosya yükleme yok. Teslim ve yayın sadece URL alanı.”*

**Örnek 1 — Creator açık turlar**

> Mobil öncelikli liste ekranı: üstte “İlanlar (yayımda)” başlığı. Her kartta tur başlığı, “Çıkış şehri → tur rotası / varış özeti” formatında kısa rota satırı (ör. “Kayseri → Kapadokya”), tarih aralığı, “Üretici kotası: 1/2”, depozito TRY, tahmini tur fiyatı. Alt kısımda ince durum rozeti. 8px grid, ferah padding.

**Örnek 2 — Agency başvuranlar**

> Acente ekranı: tur başlığı ve kota özeti üstte. Altında kart listesi; her kartta üretici adı, “Aday Uygunluk Endeksi: 88/100”, genişletilebilir bölümde Teknik ve Yayın skorları, eksik maddeler metni. Altta bilgi şeridi: “Endeks otomatik seçim yapmaz.” Seçim için checkbox’lar ve “Seçimi onayla” tek primary (kota aşımı uyarısı).

**Örnek 3 — Başvuru taahhütleri**

> Form ekranı: üç ayrı onay kutusu, uzun Türkçe açıklama metinleri (placeholder Lorem yerine madde madde özet). Hiçbiri ön işaretli değil. Altında tek primary “Başvuruyu gönder”.

---

## 10) Durum ve renk eşlemesi (tasarım tutarlılığı)

| Kullanıcıya görünen durum (Türkçe örnek) | Renk rolü |
|------------------------------------------|-----------|
| Onaylandı, tamamlandı, depozito serbest | success |
| Beklemede, incelemede, revizyon talebi | warning |
| Red, ihlal, kota doldu (kritik) | danger |
| Nötr liste / arka plan | surface, outline |

---

## 11) Web vs uygulama farkları (tek brief içinde)

| Konu | Web | Mobil uygulama |
|------|-----|----------------|
| Nav | Sol sidebar veya üst + sekme | Bottom bar veya üst AppBar |
| Tablolar | Admin ve acente geniş listeler | Yatay scroll veya kart kırılımı |
| URL alanları | Geniş tek satır + kopyala | Aynı + “harici uygulamada aç” ikon |
| Yoğun formlar | İki sütun mümkün | Tek sütun, adımlara bölünmüş |

---

## 12) Doğrulama listesi (Stitch çıktısını kontrol etmek için)

- [ ] Ana menüde feed / chat / keşfet yok.
- [ ] Teslim ve yayın için **sadece URL**; upload alanı yok.
- [ ] Başvuru ve depozito ekranlarında üç onay **ön işaretli değil**.
- [ ] Acente tarafında “sistem seçsin” veya “auto match” yok.
- [ ] AUE kartında “karar desteği” dipnotu var veya eklenebilir alan bırakılmış.
- [ ] Tek ekranda tek güçlü primary CTA kuralına uyulmuş.
- [ ] 48dp dokunma ve yeterli kontrast belirtilmiş veya görselde uygulanmış.

---

## 13) İlgili dokümanlar (iş kuralı derinliği için — Stitch dışı)

Stitch tasarımını kod veya backend’e bağlarken şu dosyalar kaynak olur: `docs/business-rules.md`, `docs/user-flows.md`, `docs/suitability-score.md`, `docs/database-schema.md`, `docs/api-contract.md`.

---

**Dosya adı önerisi projede:** `docs/google-stitch-urun-ve-tasarim-brief.md`  
**Versiyon:** Şehir bazlı MVP ile hizalı; PRD ve `design-system.md` ile senkron.
