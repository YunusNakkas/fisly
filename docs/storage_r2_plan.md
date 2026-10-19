# B1 — Fiş Görseli Storage: Cloudflare R2 Planı

## Amaç
Fiş görsellerini local disk (`uploads/`) yerine **Cloudflare R2** (S3-uyumlu, private bucket) üzerinde sakla.
Bu plan B1 (ephemeral storage) + B2 (auth'suz serving / KVKK) sorununu birlikte çözer.

## Kararlar
- **Private bucket.** Public erişim yok.
- **DB'de object key tutulur** (`receipts/{user_id}/{uuid}.{ext}`), public URL değil.
- **Serving = presigned GET URL** (kısa TTL, örn. 1 saat). Sadece auth'lu, sahibi olan endpoint üretir → KVKK çözümü. Bandwidth backend'i şişirmez.
- **Storage abstraction** ile dev'de local, prod'da R2 (env ile seçilir) → testler R2'siz çalışır.
- R2 sync SDK (boto3) → `asyncio.to_thread` ile async endpoint'lerden çağrılır.

## Mimari: storage_service abstraction
`app/services/storage_service.py` — interface:
- `upload(key: str, data: bytes, content_type: str) -> None`
- `presigned_url(key: str, expires: int = 3600) -> str`
- `delete(key: str) -> None`

İki impl:
- `LocalStorage` — `uploads/` (dev/test, mevcut davranış)
- `R2Storage` — boto3 client, `endpoint_url=https://{ACCOUNT_ID}.r2.cloudflarestorage.com`, `region_name="auto"`, signature v4.

`STORAGE_BACKEND` env'ine göre fabrika seçer (`local` | `r2`).

## Cloudflare R2 kurulumu (panel)
1. R2 etkinleştir → bucket oluştur: `fisly-receipts`.
2. **R2 API Token** oluştur (Object Read & Write, sadece bu bucket). Access Key ID + Secret Key al.
3. Account ID'yi not et (endpoint için).
4. Public access KAPALI bırak (presigned ile erişeceğiz).
5. CORS: gerekirse mobil/web'in fetch ettiği origin için GET izni.

## Kod değişiklikleri

### 1. `requirements.txt`
- `boto3` ekle (R2 S3-uyumlu).

### 2. `app/config.py` — yeni env'ler
```
STORAGE_BACKEND: str = "local"   # local | r2
R2_ACCOUNT_ID: str = ""
R2_ACCESS_KEY_ID: str = ""
R2_SECRET_ACCESS_KEY: str = ""
R2_BUCKET: str = "fisly-receipts"
R2_URL_EXPIRE_SECONDS: int = 3600
```

### 3. `app/services/storage_service.py` (yeni)
- Yukarıdaki abstraction + iki impl + `get_storage()` fabrika.
- boto3 client lazy/singleton.

### 4. `app/routers/receipts.py`
- `scan_receipt`: diske yazma yerine `storage.upload(key, image_bytes, content_type)`.
  - key = `receipts/{current_user.id}/{uuid4}.{ext}`
  - `receipt.image_url = key` (artık key tutuyor, path değil).
- `list_receipts` / `get_receipt`: ORM'i direkt döndürmek yerine response'u **manuel kur**, `image_url = storage.presigned_url(receipt.image_url)`.
  - (Alternatif: schema'da computed field; manuel build daha açık.)
- `delete_receipt`: DB silmeden önce `storage.delete(receipt.image_url)` (best-effort, hata yutulur ama loglanır).

### 5. `app/main.py`
- `StaticFiles` mount + `os.makedirs("uploads")`'ı **prod'da kaldır**. Dev (local backend) için `STORAGE_BACKEND=local` iken koru.

### 6. Schema (`app/schemas/receipt.py`)
- `image_url: str` aynı kalır — artık presigned URL döner. Sözleşme değişmiyor.

## Mobil etkisi
- `fromJson` `image_url` okur → değişmez.
- Şu an detay ekranı imageUrl'i **metin** gösteriyor → presigned URL ile çalışır.
- İleride `Image.network(receipt.imageUrl)` eklenince presigned URL direkt çalışır.
- **Dikkat:** presigned URL TTL'li. Cache'lenip bayatlarsa görsel açılmaz → detay ekranı açılışında fresh çek (zaten `get_receipt` her seferinde yeni üretir).

## Test
- `LocalStorage` default → mevcut testler (`test_*.py`) R2 olmadan geçer.
- Yeni: storage abstraction birim testi (upload→presigned→delete), R2 impl moto/mock ile (opsiyonel).
- Manuel: gerçek R2 token ile `/receipts/scan` → object bucket'ta mı, presigned URL açılıyor mu, `delete` object'i siliyor mu.

## Mevcut veri taşıma
- Pre-launch, `uploads/` içindeki veri test verisi → migration script opsiyonel.
- Gerekirse tek seferlik: local dosyaları R2'ye push + `image_url`'leri key'e çevir.

## Env örneği (`.env.example` güncelle)
```
STORAGE_BACKEND=r2
R2_ACCOUNT_ID=xxxx
R2_ACCESS_KEY_ID=xxxx
R2_SECRET_ACCESS_KEY=xxxx
R2_BUCKET=fisly-receipts
R2_URL_EXPIRE_SECONDS=3600
```

## Adım sırası (uygulama)
1. boto3 + config env'leri ekle.
2. `storage_service.py` yaz (Local + R2 + fabrika).
3. `receipts.py` scan/list/get/delete'i storage'a geçir.
4. `main.py` static mount'u koşullu yap.
5. `.env.example` güncelle.
6. Testleri çalıştır (local backend geçmeli).
7. Gerçek R2 token ile manuel uçtan uca test.

## Tahmin
~1-1.5 gün (R2 kurulum + kod + manuel test dahil). B2 (auth'lu serving) bu işin içinde çözülür.
