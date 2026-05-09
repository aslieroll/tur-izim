# Tur İzim - Agent Çalışma Rehberi

Bu dosya, Tur İzim projesinde çalışan AI agent’lar için kalıcı proje rehberidir. Tüm görevlerde bu çerçeveye uy.

## 1) Proje Kimliği

Tur İzim; yerel tur acentelerinin boş, ulaşım dahil koltuklarını genç UGC creator ve micro-influencer adaylarıyla buluşturan B2B/B2C güven ve operasyon platformudur.

Tur İzim aşağıdakiler **değildir**:

- Travel agency
- Social media app
- Hotel marketplace
- Flight marketplace
- Video streaming/feed platform
- Chat app

## 2) MVP Kapsam Sınırı (İhlal Kontrolü Zorunlu)

Her implementasyon isteğinden önce, aşağıdaki kapsam dışı maddeleri kontrol et:

- Social feed
- Chat
- Hotel booking
- Flight booking
- Video upload
- Real payment integration
- Automatic social media monitoring
- Automatic matching
- Random assignment
- AI video analysis (MVP)

İstek bu maddelerden birini içeriyorsa:

1. Implement etmeyi reddet.
2. Kısa ve net şekilde neden kapsam dışı olduğunu açıkla.
3. Gerekirse MVP uyumlu alternatif öner.

## 3) İş Kuralı Terminolojisi ve Akış

- `Application`: creator’ın bir tura başvurması.
- `Assignment`: acentanın creator’ı manuel seçmesi.
- `Match` dili kullanma; `Assignment` kullan.
- AUE (Aday Uygunluk Endeksi) yalnızca karar desteğidir; otomatik seçim mekanizması değildir.
- Acenta creator’ı manuel seçer; sistem otomatik atama yapmaz.

Creator onay kapısı:

- Aşağıdaki üç onay kutusu zorunludur ve pre-selected olamaz:
  1. 30 günlük yayın taahhüdü
  2. Acenta içerik kullanım izni
  3. Erken kaldırma durumunda tur bedeli talep koşulu

`MockDeposit` süreci:

- Acenta application kabulü -> `PENDING`
- Creator final onayı -> `HELD`
- Creator yayın URL teslimi -> release

Yayın koşulu:

- Post en az 30 gün public kalmalı.
- Erken kaldırma/gizleme/archive/silinme/inaccessible durumunda acenta violation raporlayabilir.
- Violation kararını admin manuel verir.
- MVP’de gerçek para otomatik tahsil edilmez.

## 4) Mimari Sınırlar

- Öncelik frontend geliştirme (Flutter + Dart).
- Backend daha sonra (Java Spring Boot + PostgreSQL).
- Frontend ve backend klasörleri ayrık kalmalı.
- Backend hazır değilken mock repository + API-ready interface yaklaşımı kullanılmalı.
- Flutter widget içinde core business logic yazılmamalı.
- Business logic Spring Boot service katmanına taşınacak şekilde tasarlanmalı.
- Google Stitch yalnızca UI referansıdır; iş kuralı ve backend mimarisi kaynağı değildir.

## 5) Çalışma Şekli ve Doğrulama

- Büyük işi tek seferde yapma; küçük, review edilebilir slice’lar halinde ilerle.
- Büyük değişikliklerden önce plan hazırla.
- Küçük ve net işlerde doğrudan implement et.
- Build/analyze/test/runtime hatalarında sistematik debug uygula.
- Her Flutter değişikliği sonrası sırayla çalıştır:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
- `analyze` veya `test` başarısızsa ilerleme.

Frontend çalıştırma:

- `cd C:\dev\tur-izim\frontend`
- `flutter run -d chrome`

## 6) Kod Stili ve Yapı Kuralları

- Clean architecture prensibini koru.
- Feature-based Flutter klasör yapısını koru.
- Repository interface’leri implementation’dan önce tanımla.
- Mock data deterministik olmalı.
- AUE mock değerleri widget içinde yeniden hesaplanmamalı; precomputed olmalı.
- UI metinleri Türkçe kalmalı.
- Teknik class/file/enum/endpoint adları İngilizce kalabilir.
- Gereksiz package ekleme.
- Büyük dosya ve kopya logic üretme.
- Açık talep olmadan backend kodu oluşturma/değiştirme.

## 7) Güncel Durum Referansı

- Aşama 0 dokümantasyon tamam.
- Flutter frontend shell çalışıyor.
- `flutter analyze`, `flutter test`, `flutter run -d chrome` çalışır durumda.
- Aşama 2.1 router/session/model/repository interface slice debug edilip çalışıyor.

## 8) Kaynak Dokümanlar (Source of Truth)

Karar çelişkisi olduğunda önce aşağıdaki dokümanları esas al:

- `docs/prd.md`
- `docs/business-rules.md`
- `docs/user-flows.md`
- `docs/database-schema.md`
- `docs/suitability-score.md`
- `docs/api-contract.md`
- `docs/design-system.md`
