# Yürütme planı (özet)

Bu belge Tur İzim MVP’sinin **yüksek seviye fazları**nı tanımlar. Öncelik sırası ve iş bölümü ekip koşullarına göre güncellenebilir; tek iş gerçeği `PRD.md` ve `business-rules.md` ile `user-flows.md`’tir.

## Faz 0 — Dokümantasyon ve paydaş hizası

- Ürün gereksinimleri, iş kuralları, akışlar, veri modeli, API taslağı, AUE metodolojisi, tasarım ilkeleri (`prodocs/`).
- MVP dışı maddelerin netleştirilmesi (otomatik eşleştirme yok, gerçek ödeme yok, vb.).

## Faz 1 — Teknik temel

- Flutter uygulama iskeleti; router, oturum/mock kimlik, paylaşılan modeller.
- Spring Boot REST iskeleti; PostgreSQL bağlantısı; veri erişimi ve servis katmanı düzeni.
- Yerel geliştirme: Docker Compose PostgreSQL, ortam değişkenleri.

## Faz 2 — Çekirdek akışlar (dilim dilim)

- Acente ve creator profilleri (sözleşmeye uygun alanlar).
- Tur listeleme / detay; yurt dışı pasaport–vize kapısı.
- Başvuru (`Application`) ve zorunlu onay kutuları.
- AUE gösterimi ve sıralama; **manuel** acente seçimi ile **Assignment** oluşturma.
- Mock depozito yaşam döngüsü ve içerik teslimi (bağlantı / yayın URL’si).

## Faz 3 — Güven, operasyon, sertleştirme

- Kimlik doğrulama ve yetkilendirme (MVP sonrası veya genişletilmiş MVP).
- Admin manuel ihlal incelemesi akışları.
- Test, gözlemlenebilirlik, dağıtım stratejisi (ürün kararına bağlı).

## Risk ve bağımlılıklar

- Backend ile frontend paralel ilerlerken contract (`api-contract.md`) değişimlerinin iki tarafta uyumu.
- Tasarım referansı (Stitch) ile iş kurallarının karıştırılmaması (`DesignSystem.md`, `premium-travel-pass-ui-guidelines.md`).

## İzleme

Uygulama durumu ve tamamlanan iş kalemleri için `Progress.md` güncellenir.
