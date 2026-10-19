# Fişly 🧾

Fiş fotoğrafını çek, harcaman otomatik kaydedilsin. Fişly, Türkiye pazarı için yerelleştirilmiş (TL, Türk market zincirleri, Türkçe fiş formatları) kişisel finans uygulamasıdır.

> "Maaşım girdi, ay sonunda nereye gitti bilmiyorum" sorununa çözüm.

[![CI](https://github.com/YunusNakkas/fisly/actions/workflows/ci.yml/badge.svg)](https://github.com/YunusNakkas/fisly/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Özellikler

- 📸 **Fiş tarama:** Kamera veya galeriden fiş yükle, Gemini Vision ile okunsun, harcama otomatik oluşsun. OCR sonucunu düzenleyebilirsin.
- 💸 **Harcama takibi:** Manuel giriş, kategoriler, tarih/kategori/tutar filtreleri, CSV export.
- 📊 **Raporlar:** Aylık özet, kategori dağılımı (pasta grafik), son 6 ay trendi.
- 🎯 **Bütçe:** Aylık genel veya kategori bazlı limit, aşılınca uygulama içi uyarı.
- 🔁 **Abonelikler:** Netflix, Spotify gibi tekrarlayan ödemeleri ve sonraki ödeme tarihini takip et.
- ⭐ **Premium:** RevenueCat ile uygulama içi satın alma.
- 🌍 **Dil:** Türkçe ve İngilizce, açık/koyu tema.

## Teknoloji

| Katman | Teknoloji |
|---|---|
| Mobil | Flutter, Riverpod, Dio, GoRouter, fl_chart |
| Backend | FastAPI, SQLAlchemy (async), Pydantic v2, Alembic |
| Veritabanı | PostgreSQL 16 |
| OCR | Google Gemini Vision API (server-side) |
| Auth | JWT access + refresh token (rotate), bcrypt |
| Depolama | Local (dev) / Cloudflare R2 (production) |
| Deploy | Docker, Fly.io |
| İzleme | Sentry |

Mimari kararlar ve gerekçeleri için [CLAUDE.md](CLAUDE.md) ve [docs/decisions.md](docs/decisions.md) dosyalarına bak.

## Mimari

```
Mobil (Flutter) ──► FastAPI ──► PostgreSQL
                      │
                      ├──► Gemini Vision (fiş OCR)
                      └──► R2 / local storage (fiş görselleri)
```

Gemini API anahtarı istemciye hiç çıkmaz. Fiş işleme tamamen sunucuda yapılır.

## Hızlı Başlangıç

### Gereksinimler

- Python 3.11+
- Flutter 3.x
- Docker (PostgreSQL için)
- [Gemini API anahtarı](https://aistudio.google.com/app/apikey)

### Backend

```bash
# PostgreSQL
docker-compose up -d postgres

cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# .env içinde düzenle:
#   DATABASE_URL=postgresql+asyncpg://fisly:fisly123@localhost:5432/fisly_db
#   SECRET_KEY=<uzun rastgele bir değer>
#   GEMINI_API_KEY=<anahtarın>

alembic upgrade head
uvicorn app.main:app --reload
```

### Mobil

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Android emülatörde `localhost` yerine `http://10.0.2.2:8000/api/v1` kullan. Gerçek cihazda bilgisayarının yerel IP'sini kullan ve `network_security_config.xml` içine geçici olarak ekle.

Build zamanı değişkenleri (`--dart-define`): `API_BASE_URL`, `ENV`, `SENTRY_DSN`, `REVENUECAT_API_KEY_APPLE`, `REVENUECAT_API_KEY_GOOGLE`.

Detaylı kurulum: [docs/flutter-setup.md](docs/flutter-setup.md)

## Testler

```bash
# Backend
cd backend && pytest

# Mobil
cd mobile && flutter test
```

## Proje Yapısı

```
fisly/
├── backend/     # FastAPI uygulaması (routers, services, models, alembic)
├── mobile/      # Flutter uygulaması (feature-first)
├── docs/        # Deploy, billing, storage, mağaza ve hukuki dokümanlar
└── design-brief/
```

## Dokümanlar

- [Fly.io deploy](docs/deploy_fly.md)
- [RevenueCat entegrasyonu](docs/billing_revenuecat.md)
- [R2 depolama planı](docs/storage_r2_plan.md)
- [Mağaza yayın kontrol listesi](docs/store/submission_checklist.md)
- Hukuki metinler: [Gizlilik Politikası](docs/legal/gizlilik_politikasi.md), [KVKK Aydınlatma Metni](docs/legal/kvkk_aydinlatma_metni.md), [Açık Rıza Metni](docs/legal/acik_riza_metni.md)

## Güvenlik

- Şifreler bcrypt ile hash'lenir, access token 15 dakika, refresh token 30 gün geçerlidir.
- `/auth/login` ve `/receipts/scan` rate limit altındadır.
- Fiş yükleme: yalnızca görsel, MIME kontrolü, en fazla 5 MB.
- Secret'lar `.env` veya `fly secrets` ile verilir, repoya commit edilmez.

Güvenlik açığı bulursan lütfen public issue açmadan önce repo sahibiyle iletişime geç.

## Lisans

[MIT](LICENSE) © 2026 Yunus Emre Nakkas
