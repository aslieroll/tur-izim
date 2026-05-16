# Tur İzim — Backend (Spring Boot)

Java 17 + Spring Boot 3 ile REST API iskeleti. Aşama 1.1: sağlık uç noktası ve PostgreSQL ortam değişkenleri.

## Gereksinimler

- JDK 17 veya 21 (`JAVA_HOME` ayarlı olmalı; Windows’ta `mvnw.cmd` bunu ister)
- Maven kurulu değilse depodaki **Maven Wrapper** kullanılır (`mvnw.cmd` / `mvnw`)
- Yerel veritabanı: depo kökünde Docker Compose ile PostgreSQL (`postgres:16`)

## Ortam değişkenleri

Depo kökünde `.env.example` şablonuna bakın. İsterseniz yerelde `.env` oluşturup değişkenleri doldurabilirsiniz; **`.env` ve içindeki sırları asla commit etmeyin** — kök `.gitignore` `.env` dosyasını hariç tutar. Üretim sırları repoda bulunmamalıdır.

| Değişken | Açıklama | `application.yml` varsayılanı (Compose ile uyumlu) |
|----------|-----------|------------------------------------------------------|
| `DB_URL` | JDBC URL | `jdbc:postgresql://localhost:5432/turizim` |
| `DB_USERNAME` | Veritabanı kullanıcısı | `turizim` |
| `DB_PASSWORD` | Veritabanı şifresi | `turizim_dev_password` |
| `SERVER_PORT` | HTTP port | `8080` |

Kök `docker-compose.yml` içindeki PostgreSQL kullanıcı/veritabanı/şifre ile bağlanırken `DB_PASSWORD`, Compose’daki `POSTGRES_PASSWORD` ile **aynı** olmalıdır (`turizim_dev_password`). `.env.example` içindeki `change_me_for_local_only` yalnızca şablondur; Docker ile çalışırken yukarıdaki Compose şifresini kullanın.

## PostgreSQL’i Docker ile başlatma / durdurma

Depo **kökünden**:

```bash
docker compose up -d postgres
```

Durdurma:

```bash
docker compose stop postgres
```

## Çalıştırma

Backend dizininde (Unix):

```bash
cd backend
export DB_URL=jdbc:postgresql://localhost:5432/turizim
export DB_USERNAME=turizim
export DB_PASSWORD=turizim_dev_password
./mvnw spring-boot:run
```

Windows (PowerShell) — örnek komutlar:

```powershell
docker compose up -d postgres

cd backend
$env:DB_URL="jdbc:postgresql://localhost:5432/turizim"
$env:DB_USERNAME="turizim"
$env:DB_PASSWORD="turizim_dev_password"
.\mvnw.cmd spring-boot:run
```

`mvnw.cmd` için JDK gerekir; gerekirse önce örneğin `$env:JAVA_HOME="C:\Program Files\Java\jdk-21"` ayarlayın.

Doğrulama:

```bash
curl http://localhost:8080/api/health
```

Örnek yanıt:

```json
{
  "status": "UP",
  "service": "tur-izim-backend"
}
```

## Testler

PostgreSQL gerektirmez; test profili bellek içi H2 kullanır.

```bash
cd backend
./mvnw test
```

Windows: `.\mvnw.cmd test` (önce `JAVA_HOME`).

## Şu anki uç noktalar

| Metot | Yol | Açıklama |
|-------|-----|----------|
| GET | `/api/health` | Servis ayakta mı kontrolü |

## Paket düzeni

`com.turizim` altında alan bazlı paketler: `common`, `config`, `user`, `creator`, `agency`, `tour`, `application`, `assignment`, `deposit`, `publication`, `admin`. İş mantığı ileride servis katmanında toplanacak; bu aşamada çoğu paket yalnızca yer tutucudur.
