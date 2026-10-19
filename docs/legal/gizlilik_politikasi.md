# Fişly — Gizlilik Politikası / Privacy Policy

> ⚠️ **HUKUKİ UYARI:** Taslaktır, hukuki danışmanlık değildir. Avukat onayından geçmelidir.
> App Store ve Google Play, uygulama listelemesinde **erişilebilir bir gizlilik politikası URL'i**
> ister (örn. `https://fisly.app/privacy`). Bu metni o adreste yayınlayın. Ayrıca her iki mağazanın
> **veri güvenliği / App Privacy** formlarını bu metinle tutarlı doldurun.

**Son güncelleme:** [GG.AA.YYYY]
**Veri Sorumlusu:** [ŞİRKET/ŞAHIS UNVANI] — İletişim: [privacy@fisly.app]

Fişly ("Uygulama"), kişisel finans takibi sunan bir mobil uygulamadır. Gizliliğinize önem veriyoruz.
Bu politika hangi verileri, neden ve nasıl işlediğimizi açıklar. Detaylı KVKK aydınlatması için
[KVKK Aydınlatma Metni](kvkk_aydinlatma_metni.md)'ne bakınız.

## 1. Topladığımız Veriler
- **Hesap bilgileri:** e-posta, ad-soyad (opsiyonel), şifre (geri döndürülemez şekilde hash'lenir).
- **Finansal veriler:** harcamalar, fiş görselleri ve fişten çıkarılan bilgiler, abonelikler, bütçeler.
- **Kullanım bilgileri:** plan, fiş tarama kotası, geri bildirimler.
- **Teknik veriler:** IP adresi, log ve hata (crash) kayıtları.

Banka hesabı/kart bilgisi **toplamıyoruz**; uygulama bankaya bağlanmaz.

## 2. Verileri Neden İşliyoruz
- Hesabınızı oluşturmak ve girişinizi doğrulamak,
- Fişlerinizi tarayıp (OCR) harcamalarınızı otomatik oluşturmak,
- Harcama/abonelik/bütçe ve rapor hizmetlerini sunmak,
- Hataları gidermek, hizmeti güvenli tutmak ve iyileştirmek,
- Taleplerinizi yanıtlamak ve yasal yükümlülükleri yerine getirmek.

## 3. Üçüncü Taraf Hizmet Sağlayıcılar
Hizmeti sunmak için aşağıdaki sağlayıcıları kullanırız ve veriler **yurt dışında** işlenebilir:
- **Google (Gemini Vision):** fiş görselinden OCR.
- **Cloudflare (R2):** fiş görseli depolama.
- **Fly.io:** uygulama barındırma (Frankfurt/AB).
- **[SMTP sağlayıcı]:** e-posta gönderimi.
- **Sentry (varsa):** hata izleme.

Verilerinizi pazarlama amacıyla **üçüncü taraflara satmayız**.

## 4. Veri Güvenliği
- Şifreler bcrypt ile hash'lenir; düz metin saklanmaz.
- İletişim HTTPS/TLS ile şifrelenir.
- Fiş görselleri özel (private) depolamada tutulur ve yalnızca süreli, kimliği doğrulanmış
  bağlantılarla erişilir.
- Erişim kontrolü, oturum token'ları ve oran sınırlama (rate limiting) uygulanır.

## 5. Saklama ve Silme
Verileriniz hesabınız aktif olduğu sürece saklanır. Hesabınızı sildiğinizde veya fiş/harcamaları
sildiğinizde, ilgili veriler yasal süreler saklı kalmak üzere makul sürede silinir veya anonimleştirilir.
Fiş görselleri silindiğinde depolamadan da kaldırılır.

## 6. Haklarınız
KVKK m.11 kapsamında verilerinize erişme, düzeltme, silme, aktarımı öğrenme ve itiraz haklarına
sahipsiniz. Başvuru: [privacy@fisly.app].

## 7. Çocukların Gizliliği
Uygulama 18 yaş altı kullanıcılara yönelik değildir; bilerek 18 yaş altından veri toplamayız.

## 8. Değişiklikler
Bu politika güncellenebilir. Önemli değişiklikleri uygulama içinde veya e-posta ile bildiririz.
Güncel sürüm her zaman bu adreste yayınlanır.

## 9. İletişim
Sorularınız için: [privacy@fisly.app] — [ADRES]

---

### English summary
Fişly is a personal finance app. We collect account info (email, optional name, hashed password),
financial data (expenses, receipt images and extracted data, subscriptions, budgets), usage and
technical data. We use Google (Gemini) for receipt OCR, Cloudflare R2 for image storage, Fly.io for
hosting, an email provider, and Sentry for error monitoring — data may be processed outside Türkiye.
We do not sell your data. Passwords are hashed; traffic is encrypted; receipt images are private and
accessed only via short-lived authenticated links. You can access, correct, or delete your data and
delete your account at any time. Contact: [privacy@fisly.app].
