# Tur İzim — Final Delivery Checklist

Bu belge projenin teslim / final sunum öncesi doğrulama listesidir.

---

## Canlı Ortam URL'leri

| Kaynak | URL |
|--------|-----|
| **Frontend (Vercel)** | https://tur-izim-live.vercel.app |
| **Backend (Railway)** | https://tur-izim-production.up.railway.app |
| **Health** | https://tur-izim-production.up.railway.app/api/health → `status: UP` veya `ok` |
| **Abonelik planları** | https://tur-izim-production.up.railway.app/api/billing/agency/plans |

---

## Ürün Sınırları (Teslim Notu)

Tur İzim **yalnızca tur operasyonları** içindir:

- ✅ Ulaşım dahil tur ilanları, başvuru, manuel seçim, mock depozito, içerik teslimi (URL)
- ❌ Sosyal medya feed'i
- ❌ Uygulama içi sohbet / chat
- ❌ Otel veya uçak bileti rezervasyonu
- ❌ Uygulama içi kart toplama veya ödeme SDK'sı (harici checkout redirect yalnızca)

---

## Üretim Ortam Değişkenleri (Railway)

| Değişken | Üretim değeri | Not |
|----------|---------------|-----|
| `APP_LEGACY_OPEN_API` | `false` | JWT zorunlu; korumalı uçlar token'sız kapalı |
| `APP_DEV_SEED` | `false` | Demo veri yüklenmez |
| `FRONTEND_ORIGIN` | `https://tur-izim-live.vercel.app` | CORS; virgülle birden fazla origin olabilir |
| `JWT_SECRET` | güçlü rastgele değer | En az 256 bit; repoda **yok** |
| `SPRING_DATASOURCE_*` | Railway PostgreSQL | JDBC formatı |
| `AGENCY_PRO_PAYMENT_LINK` | sağlayıcı URL (opsiyonel) | Boşsa checkout 422 |
| `AGENCY_GROWTH_PAYMENT_LINK` | sağlayıcı URL (opsiyonel) | Boşsa checkout 422 |
| `APP_ADMIN_BOOTSTRAP_ENABLED` | `false` | İlk ADMIN oluşturulduktan sonra **kapatılmalı** |
| `OPENROUTER_API_KEY` | opsiyonel | Boşsa AI Match deterministik fallback |

## Frontend Ortam Değişkenleri (Vercel)

| Değişken | Değer |
|----------|-------|
| `API_BASE_URL` | `https://tur-izim-production.up.railway.app` |

> Ödeme linkleri yalnızca backend env'de tutulur; frontend'e geçirilmez.

---

## Otomatik Test Komutları

### Frontend

```powershell
cd frontend
flutter pub get
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=https://tur-izim-production.up.railway.app
```

### Backend

```powershell
cd backend
.\mvnw.cmd test
```

### Canlı smoke test (PowerShell)

```powershell
.\scripts\smoke-test-live.ps1
```

---

## Manuel Smoke Test Checklist

### Genel

- [ ] `scripts/smoke-test-live.ps1` tüm kontrollerde PASS
- [ ] Tarayıcı konsolunda **CORS policy error** yok
- [ ] Tarayıcı konsolunda **Failed to fetch** yok
- [ ] Tarayıcı konsolunda **Uncaught Error** yok
- [ ] Ağ sekmesinde üretim istekleri `localhost:8080` **hedeflemiyor**

### Karşılama ve oturum

- [ ] https://tur-izim-live.vercel.app açılıyor
- [ ] Creator / Agency rol seçimi çalışıyor
- [ ] Giriş ve kayıt ekranları açılıyor

### Creator (JWT gerekli alanlar)

- [ ] Oturum **yokken** tur listesi (public) yükleniyor
- [ ] Oturum **yokken** Başvurularım / Görevlerim → "Devam etmek için giriş yapın" (401 crash yok)
- [ ] Creator girişi sonrası başvurular ve atamalar yükleniyor

### Agency

- [ ] Agency girişi sonrası operasyon özeti açılıyor
- [ ] Abonelik planları: Ücretsiz, Agency Pro, Agency Growth görünüyor
- [ ] Pro/Growth kartlarında "Aboneliği Başlat" → harici checkout veya yapılandırma mesajı
- [ ] FREE planda AI Match / başvuru listesi → **402** (kilitli özellik; crash yok)

### Backend doğrudan

- [ ] `GET /api/health` → `status: ok`
- [ ] `GET /api/billing/agency/plans` → 3 plan JSON
- [ ] `GET /api/creators/{id}` token'sız → **401** (beklenen)
- [ ] `GET /api/tours` → public liste (backend izin veriyorsa)

### Admin (varsa)

- [ ] ADMIN JWT ile `POST /api/billing/admin/subscriptions/manual-activate` erişilebilir
- [ ] `APP_ADMIN_BOOTSTRAP_ENABLED=false` (bootstrap kapalı)

---

## Kabul Edilebilir HTTP Durumları

| Kod | Ne zaman normal? |
|-----|------------------|
| **401 Unauthorized** | Korumalı uçlara JWT olmadan istek |
| **402 Payment Required** | Ücretli plan gerektiren acente özelliği (AI Match, başvuru yönetimi, seçim) |
| **403 Forbidden** | Yanlış rol veya yetkisiz kaynak erişimi |
| **422 Unprocessable Entity** | Checkout ödeme linki backend'de yapılandırılmamış |

---

## Kabul Edilemez Hatalar

| Belirti | Açıklama |
|---------|----------|
| **CORS policy error** | `FRONTEND_ORIGIN` yanlış veya eksik |
| **Failed to fetch** | Backend erişilemez, yanlış `API_BASE_URL`, ağ kesintisi |
| **localhost:8080 in production** | Vercel build'de `API_BASE_URL` eksik/yanlış |
| **Uncaught Error** | Flutter web'de yakalanmamış exception (özellikle 401 sonrası) |
| **500 Internal Server Error** | Beklenmeyen sunucu hatası; log incelenmeli |

---

## Teslim Öncesi Son Kontrol

- [ ] README.md güncel (canlı URL'ler, güvenlik notları)
- [ ] `.env` / `.env.local` / token dosyaları repoda **yok**
- [ ] `backend/target/` ve `frontend/build/` commit edilmemiş
- [ ] `flutter analyze` ve `flutter test` geçiyor
- [ ] `mvnw test` geçiyor
- [ ] Üretim: `APP_LEGACY_OPEN_API=false`, `APP_DEV_SEED=false`
