# Fişly — KVKK Aydınlatma Metni

> ⚠️ **HUKUKİ UYARI:** Bu metin bir taslaktır, hukuki danışmanlık değildir. Yayına almadan önce
> bir avukat / KVKK uzmanı tarafından gözden geçirilmelidir. `[KÖŞELİ PARANTEZ]` içindeki alanları
> kendi bilgilerinizle doldurun. Veri sorumlusu olarak **VERBİS** kayıt yükümlülüğünüz olabilir
> (çalışan sayısı / ciro eşiklerine ve faaliyet türüne göre) — bunu uzmanınızla netleştirin.

**Son güncelleme:** [GG.AA.YYYY]

6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") m.10 uyarınca, veri sorumlusu sıfatıyla
aydınlatma yükümlülüğümüz kapsamında bu metni bilginize sunarız.

## 1. Veri Sorumlusu
- **Unvan:** [ŞİRKET/ŞAHIS UNVANI]
- **Adres:** [ADRES]
- **E-posta:** [kvkk@fisly.app vb.]
- **VERBİS No (varsa):** [____]

## 2. İşlenen Kişisel Veriler
| Kategori | Veriler |
|---|---|
| Kimlik | Ad-soyad (opsiyonel) |
| İletişim | E-posta adresi |
| Hesap/Güvenlik | Şifre (yalnızca **bcrypt ile geri döndürülemez şekilde** saklanır; düz metin tutulmaz), oturum/token kayıtları |
| Finansal & İşlem | Harcama kayıtları (tutar, kategori, satıcı, tarih, not), **fiş görselleri**, fişten çıkarılan veriler (satıcı, toplam tutar, fiş tarihi, ürün kalemleri), abonelik bilgileri, bütçe bilgileri |
| Kullanım | Üyelik planı, aylık fiş tarama kotası |
| Müşteri İlişkileri | Geri bildirim konusu ve mesajı |
| İşlem Güvenliği | IP adresi, erişim/istek log kayıtları, hata (crash) kayıtları |

> Fiş görselleri finansal veri içerir. Lütfen sağlık, din vb. **özel nitelikli** kişisel veri içeren
> belgeleri fiş olarak yüklemeyiniz; uygulama bu tür verileri işlemeyi amaçlamaz.

## 3. İşleme Amaçları
- Üyelik kaydı ve kimlik doğrulama (giriş/çıkış, token yenileme)
- Fiş tarama ve optik karakter tanıma (OCR) ile harcamaların otomatik oluşturulması
- Harcama, abonelik, bütçe ve raporlama hizmetlerinin sunulması
- Hizmet kalitesinin ölçülmesi, hata tespiti ve giderilmesi
- Kullanıcı talep ve geri bildirimlerinin yönetimi
- Yasal yükümlülüklerin yerine getirilmesi ve hizmet güvenliğinin sağlanması (kötüye kullanım/dolandırıcılık önleme, kota uygulaması)

## 4. Hukuki Sebepler (KVKK m.5)
- **Sözleşmenin kurulması/ifası (m.5/2-c):** üyelik ve uygulama hizmetlerinin sunulması, fiş işleme.
- **Hukuki yükümlülük (m.5/2-ç):** yasal saklama ve bilgi verme yükümlülükleri.
- **Meşru menfaat (m.5/2-f):** güvenlik, hata izleme, hizmet iyileştirme.
- **Açık rıza (m.5/1):** fiş görsellerinin OCR amacıyla yurt dışındaki hizmet sağlayıcıya (Google) aktarılması ve işlenmesi için — aşağıdaki 5. ve 6. maddeye bakınız.

## 5. Kişisel Verilerin Aktarımı
Veriler aşağıdaki **yurt dışında yerleşik** hizmet sağlayıcılar (alt işleyenler) aracılığıyla işlenir/saklanır:

| Hizmet sağlayıcı | Amaç | Aktarılan veri | Konum |
|---|---|---|---|
| Google (Gemini Vision API) | Fiş görselinden OCR | Fiş görseli ve içeriği | Yurt dışı (ABD vb.) |
| Cloudflare (R2 depolama) | Fiş görseli saklama | Fiş görselleri | Yurt dışı |
| Fly.io | Uygulama barındırma | Tüm uygulama verisi | AB (Frankfurt) / yurt dışı |
| [SMTP sağlayıcı] | E-posta gönderimi (şifre sıfırlama vb.) | E-posta adresi | [____] |
| Sentry (varsa) | Hata izleme | Teknik/log verisi | Yurt dışı |

Veriler, hizmetin sunulması için **gerekli olduğu ölçüde** ve KVKK m.8-9 çerçevesinde aktarılır.
Yurt dışına aktarım için KVKK m.9'da öngörülen şartlar (yeterlilik kararı, uygun güvenceler veya
açık rıza vb.) sağlanır.

> ⚠️ Yurt dışı aktarım rejimi 2024 KVKK değişiklikleriyle güncellenmiştir. Hangi hukuki dayanağa
> (standart sözleşme, taahhütname, açık rıza vb.) dayanılacağı avukatınızla netleştirilmelidir.

## 6. Veri Toplama Yöntemi
Veriler; mobil uygulama üzerinden kullanıcı tarafından girilen bilgiler, yüklenen fiş görselleri ve
otomatik olarak üretilen teknik kayıtlar (log, hata kaydı) yoluyla **elektronik ortamda** toplanır.

## 7. Saklama Süresi
- Hesap aktif olduğu sürece veriler saklanır.
- Hesap silindiğinde, kişisel veriler yasal saklama süreleri saklı kalmak kaydıyla makul süre içinde
  **silinir, yok edilir veya anonim hale getirilir**.
- Fiş görselleri kullanıcı tarafından silindiğinde depolamadan (R2) da silinir.

## 8. İlgili Kişinin Hakları (KVKK m.11)
Kullanıcı, veri sorumlusuna başvurarak:
- Kişisel verisinin işlenip işlenmediğini öğrenme, işlenmişse bilgi talep etme,
- İşleme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme,
- Yurt içi/yurt dışı aktarılan üçüncü kişileri bilme,
- Eksik/yanlış işlenmişse düzeltilmesini, şartlar oluştuğunda silinmesini/yok edilmesini isteme,
- Düzeltme/silme işlemlerinin aktarılan üçüncü kişilere bildirilmesini isteme,
- Otomatik analiz sonucu aleyhe bir sonuca itiraz etme,
- Hukuka aykırı işleme nedeniyle zararın giderilmesini talep etme
haklarına sahiptir.

## 9. Başvuru
Haklarınızı kullanmak için [kvkk@fisly.app] adresine veya [ADRES] adresine yazılı başvurabilirsiniz.
Başvurular KVKK ve Veri Sorumlusuna Başvuru Usul ve Esasları Hakkında Tebliğ uyarınca en geç **30 gün**
içinde sonuçlandırılır.
