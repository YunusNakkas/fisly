# Fişly — Design Brief

## Ürün
Türkçe kişisel finans uygulaması. Kullanıcı fiş fotoğrafı çeker, Gemini Vision OCR otomatik harcama oluşturur. Manuel harcama da girilebilir. Kategorize eder, aylık bütçe takip eder, abonelik ödemelerini hatırlatır.

**Diferansiyatör:** Manuel giriş zahmetini fiş OCR ile ortadan kaldırmak. Türkçe fiş formatları ve Türk market zincirlerini destekler.

## Hedef kitle
25-40 yaş, düzenli geliri olan, harcamalarını kontrol etmek isteyen bireyler. Türkiye pazarı. Para birimi TL (₺), arayüz Türkçe.

## Platform
Flutter mobil (iOS + Android). Material 3 tabanı. Tasarım Material'dan çok sapmamalı — sapıyorsa custom theme tokens lazım.

## Bottom navigation (4 sekme + ortada FAB)
1. **Harcamalar** (`/expenses`) — `Icons.receipt_long`
2. **Özet** (`/reports`) — `Icons.bar_chart`
3. **Abonelikler** (`/subscriptions`) — `Icons.repeat`
4. **Ayarlar** (`/settings`) — `Icons.settings`
- Ortada centerDocked **Fiş Tara FAB** (`Icons.document_scanner`)

---

## Ana ekranlar

### 1. Harcamalar (Expenses)
**Amaç:** Ay bazlı harcama listesi + özet header.

**Yapı:**
- AppBar: tıklanır ay seçici (örn "Mayıs 2026 ▾")
- Üst kart: "Toplam Harcama ₺X.XXX,XX" + kategori bazlı dağılım progress bar'ları (en yüksekten en düşüğe)
- Liste: her satır = bir harcama
  - Sol: kategori avatarı (renkli daire + kategori ikonu, beyaz)
  - Başlık: merchant adı (ör. "BIM", "Migros")
  - Alt: "Kategori adı · 03 Mayıs"
  - Sağ: tutar "₺123,45" (kalın)
  - Sağa swipe → sil (Dismissible), "Geri al" snackbar
  - Tap → düzenle bottom sheet
- "Abonelik Ödemeleri" bölümü (varsa o ay düşen abonelikler ayrı section)
- Empty state: "Bu ay için harcama yok"

### 2. Özet (Reports)
**Amaç:** Görsel rapor — pasta grafik + bütçe progress + breakdown.

**Yapı:**
- AppBar: ay seçici (Harcamalar ile aynı)
- Toplam kartı (gradient/primary color background): "Mayıs 2026 Toplam ₺X.XXX,XX" + alt satır "12 harcama · 5 kategori"
- Bütçeler bölümü (`_BudgetsSection`):
  - Henüz bütçe yoksa → "Bütçeler" CTA kart, dokun → /settings/budgets
  - Varsa → her satır: kategori adı + yüzde + progress bar + "₺spent / ₺amount" + "Kalan: ₺X" veya "Aşım: ₺X"
  - Eşikler: <80% yeşil, 80-100% turuncu, ≥100% kırmızı
- Pasta grafik (fl_chart) — kategori segmentleri, ortada toplam, dokunulan segment büyür
- Kategori breakdown list — her satır renkli nokta + kategori adı + yüzde + tutar + horizontal progress

### 3. Abonelikler
**Amaç:** Tekrarlayan ödeme takibi.

**Yapı:**
- "Aylık abonelik toplamı ₺X" üst banner kart (primaryContainer bg)
- "Aktif" section header:
  - Tile: kategori avatarı (kategorisi varsa) veya isim baş harfi
  - Başlık: "Netflix" + yanında **days-until rozet**:
    - "Bugün" / "Yarın" → kırmızı/deepOrange
    - "2-3 gün" → turuncu
    - "4-7 gün" → mavi
    - 8+ gün → rozet gizli
    - "Gecikti" → kırmızı
  - Alt: "Aylık · Sonraki: 23.05.2026"
  - Sağ: tutar + ⋮ (Düzenle/İptal et/Sil)
  - Liste `nextBillingDate` ASC sıralı
- "İptal edilmiş" section (gri, üstü çizili)

### 4. Ayarlar (Settings)
**Amaç:** Hesap + uygulama yönetimi.

**Yapı:** ListView, section header'lı:
- **HESAP**: Profil (isim/email), Şifre değiştir
- **BÜTÇE**: Bütçeler, Kategoriler
- **DESTEK**: Geri bildirim
- En altta kırmızı "Hesaptan çıkış"
- Her satır: leading icon, başlık + opsiyonel subtitle, trailing chevron

**Alt ekranlar:** /settings/profile, /settings/password, /settings/budgets, /settings/categories, /settings/feedback

### 5. Fiş Tara (modal — bottom nav göstermez)
**Amaç:** Kamera/galeri → OCR → düzenleme → kaydet.

**3 state:**
- **Picker view (initial):** büyük receipt ikonu, "Fişini tara veya galeriden seç" başlık, açıklama metni, "Kameradan Çek" (filled) + "Galeriden Seç" (outlined). Quota banner: "Bu ay X/30 fiş" progress bar (yeşil/turuncu/kırmızı). Limit dolarsa butonlar disabled.
- **Scanning view:** ortada CircularProgressIndicator + "Fiş okunuyor..."
- **Result view:** üstte "BIM — 5 ürün tespit edildi" başlığı, liste:
  - Her satır: ürün adı + kategori dropdown + tutar + edit ikonu
  - Satıra tap → isim+tutar düzenle bottom sheet
  - Altta toplam + "Yeniden Tara" / "Tümünü Kaydet"

### Kategoriler (/settings/categories)
- 2 section: **Sistem kategorileri** (read-only) + **Kendi kategorilerin**
- Tile: renkli daire + kategori ikonu + isim + (kullanıcı kategorisi için ⋮ menüsü)
- FAB: ekle → bottom sheet (isim + 18 icon picker grid + 12 renk picker chips)
- Sistem kategorileri: Market, Ulaşım, Faturalar, Yeme-İçme, Sağlık, Eğlence, Diğer

### Bütçeler (/settings/budgets)
- Liste: genel ve kategori bazlı bütçeler
- Tile: kategori avatarı (genel için cüzdan ikonu), kategori adı / "Genel bütçe", periyot, sağda tutar + ⋮
- FAB ekle → sheet (tutar + periyot dropdown [Aylık/Haftalık] + kategori dropdown [Genel veya seç])

### Auth (login/register/forgot-password) — public
- Standart form ekranları, email + şifre

---

## Kritik UI bileşenleri

### Kategori avatarı
- Daire (radius 24)
- Arka plan: kategorinin hex rengi
- İçinde: Material icon (beyaz)
- İkon set (18 sabit): shopping_cart, directions_car, receipt_long, restaurant, local_hospital, movie, home, school, fitness_center, pets, flight, card_giftcard, work, phone_android, sports_esports, savings, more_horiz, tag
- Renk palet (12 sabit hex): #10b981, #3b82f6, #f59e0b, #ef4444, #ec4899, #8b5cf6, #6b7280, #14b8a6, #f97316, #0ea5e9, #a855f7, #84cc16

### Para tutarı formatı
- Türkçe locale: nokta binlik ayırıcı, virgül ondalık
- Örnek: ₺1.234,56 — her zaman 2 ondalık
- Kategori renkleriyle vurgu, ana tutarlar kalın

### Days-until rozet
- Küçük pill, padding (8,2), border-radius 10
- Arka plan: rengin alpha 0.12
- Border: rengin alpha 0.3
- Text: 11px, w600, renk üstte

### Bütçe progress bar
- minHeight 8, borderRadius 4
- Renk eşikleri: <80% yeşil, 80-100% turuncu, ≥100% kırmızı

### Empty states
- Şu an çoğu yerde sadece centered text var (örn "Bu ay için harcama yok", "Henüz abonelik yok", "Henüz bütçe yok")
- Tasarım: her empty state'e açıklayıcı text + opsiyonel illüstrasyon + CTA buton

---

## Stil yön (boş bırakıldı — tercih buraya)

[Aşağıdan birini seç veya kendin yaz:]



**Seçenek B — Modern Finans (Revolut/Monzo tarzı):**
- Koyu kart + açık zemin kontrastı
- Renkli kategori chip'leri öne çıkar
- Büyük tipografi, hava bol


---

## Tasarımın değiştirmemesi gerekenler
- Bottom nav 4 tab + scan FAB yapısı (router/MainShell buna bağlı)
- Ekran rotaları (`/expenses`, `/reports`, vs.) — navigation yapısı sabit
- Veri akışı: her ekran async data (loading/error/empty branch'leri olmalı)
- Modal davranışı: FAB tap → /scan tam ekran (bottom nav görünmez)
- Türkçe metinler (i18n yok şu an, hardcoded)

## Tasarımın iyileştirebileceği yerler
- Tipografi hiyerarşisi (şu an her yerde Material default)
- Empty state'ler (zayıf)
- Onboarding (yok)
- App icon, launch screen (default)
- Tutarlı spacing/padding tokens
- Pie chart estetiği (fl_chart sınırlı stil)
- Form input'ları (şu an basic Material outlined)
