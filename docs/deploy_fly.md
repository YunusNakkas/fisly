# Backend Deploy — Fly.io

Artefaktlar: `backend/Dockerfile`, `backend/.dockerignore`, `backend/fly.toml`.
Tüm komutlar `backend/` dizininde çalıştırılır.

## 0. Ön koşul
```bash
# flyctl kur (macOS)
brew install flyctl
fly auth login   # interaktif → terminalde:  ! fly auth login
```

## 1. Uygulamayı oluştur (deploy etmeden)
```bash
cd backend
fly launch --no-deploy
```
- Mevcut `fly.toml`'u algılar; app adı (`fisly-backend`) ve region (`fra`) onayla.
- Postgres/Redis sorarsa **hayır** de (Postgres'i ayrı kuracağız).

## 2. PostgreSQL (Fly Postgres)
```bash
fly postgres create --name fisly-db --region fra --vm-size shared-cpu-1x --volume-size 3
fly postgres attach fisly-db --app fisly-backend
```
- `attach` otomatik `DATABASE_URL` secret'ı ekler — ama formatı `postgres://...`'tir.
- **Bizim app `postgresql+asyncpg://` ister.** Attach sonrası düzelt:
```bash
# attach'in verdiği URL'i al, şemayı değiştir:
fly secrets set DATABASE_URL="postgresql+asyncpg://<user>:<pass>@<host>:5432/<db>"
```
> Not: `fly pg attach` çıktısındaki connection string'i kopyala, başını `postgresql+asyncpg://` yap.

## 3. Secret'ları ayarla
```bash
fly secrets set \
  SECRET_KEY="$(openssl rand -hex 32)" \
  GEMINI_API_KEY="..." \
  ADMIN_TOKEN="$(openssl rand -hex 24)" \
  R2_ACCOUNT_ID="..." \
  R2_ACCESS_KEY_ID="..." \
  R2_SECRET_ACCESS_KEY="..." \
  CORS_ORIGINS="https://fisly.app,https://www.fisly.app" \
  APP_URL="https://fisly.app" \
  SMTP_HOST="..." SMTP_USER="..." SMTP_PASSWORD="..." \
  SENTRY_DSN="..."
```
- `STORAGE_BACKEND`, `ENV`, `R2_BUCKET` zaten `fly.toml [env]`'de.
- `DATABASE_URL` adım 2'de set edildi.

## 4. Deploy
```bash
fly deploy
```
- `release_command = alembic upgrade head` migration'ları otomatik çalıştırır.
- Health check `/health` yeşil olunca trafik açılır.
```bash
fly logs          # canlı log (stdout handler eklendi)
fly status
fly open /health  # 200 {"status":"ok"} beklenir
```

## 5. Domain + SSL (Cloudflare)
```bash
fly ips list                       # v4 + v6 al
# Cloudflare DNS: A kaydı -> v4 IP, AAAA -> v6 IP (proxy KAPALI / DNS only başla)
fly certs add fisly.app
fly certs add www.fisly.app
fly certs show fisly.app           # validation durumunu izle
```
- Cloudflare proxy (turuncu bulut) açılacaksa SSL mode **Full (strict)** olmalı.
- Sertifika valid olunca `https://fisly.app/health` test et.

## 6. DB Yedekleme (KVKK / finansal veri)
- Fly Postgres otomatik snapshot alır (varsayılan günlük, 5 gün saklama).
```bash
fly postgres backups list --app fisly-db     # snapshot'ları gör
```
- Ek güvenlik: haftalık dış yedek (cron/elle):
```bash
fly postgres connect --app fisly-db          # ya da proxy ile pg_dump
# fly proxy 5433:5432 --app fisly-db
# pg_dump "postgresql://user:pass@localhost:5433/db" > backup_$(date +%F).sql
```
- Yedekleri R2'de ayrı bucket'ta sakla.

## Doğrulama checklist
- [ ] `fly status` — machine running, health passing
- [ ] `POST /api/v1/auth/register` + `login` çalışıyor
- [ ] `POST /api/v1/receipts/scan` → R2'ye yazıyor, presigned URL dönüyor
- [ ] `https://fisly.app` SSL valid
- [ ] Postgres snapshot listesi dolu
- [ ] Sentry'de test event görünüyor (opsiyonel)

## Mobil tarafı
- `mobile` env'inde API base URL'i `https://fisly.app/api/v1` (veya `https://fisly-backend.fly.dev/api/v1`) yap.
