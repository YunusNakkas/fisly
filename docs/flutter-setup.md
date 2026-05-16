# Flutter Kurulum (macOS)

## 1. Homebrew ile Flutter Kur

```bash
brew install --cask flutter
```

Homebrew yoksa önce kur:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 2. PATH'e Ekle

`~/.zshrc` dosyasına ekle:
```bash
export PATH="$PATH:$HOME/flutter/bin"
```

Sonra:
```bash
source ~/.zshrc
```

---

## 3. Xcode Kur (iOS için)

1. App Store'dan **Xcode** indir (büyük dosya, ~15GB, zaman alır)
2. Kurduktan sonra:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```
3. iOS Simulator için:
```bash
open -a Simulator
```

---

## 4. Android Studio Kur (Android için)

1. https://developer.android.com/studio adresinden indir ve kur
2. Android Studio aç → **More Actions → SDK Manager**
3. SDK Tools sekmesinde şunları işaretle:
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools
4. Lisansları kabul et:
```bash
flutter doctor --android-licenses
```
5. Android Emulator oluştur: Android Studio → **More Actions → Virtual Device Manager → Create Device**

---

## 5. VS Code Kurulumu (opsiyonel ama önerilir)

1. VS Code'u aç
2. Extensions → **Flutter** ve **Dart** eklentilerini kur
3. `Ctrl+Shift+P` → **Flutter: New Project** ile proje açabilirsin

---

## 6. flutter doctor Çalıştır

```bash
flutter doctor
```

Çıktıda her satır ✓ olana kadar eksikleri tamamla. Örnek çıktı:
```
[✓] Flutter
[✓] Xcode
[✓] Android toolchain
[✓] VS Code
[✗] Connected device  ← emulator başlatınca çözülür
```

---

## 7. Flutter Projesi Oluştur

```bash
cd /Users/yunusemrenakkas/Desktop/fişly
flutter create mobile --org com.fisly --platforms ios,android
cd mobile
flutter run
```

---

## Sık Karşılaşılan Sorunlar

| Hata | Çözüm |
|------|-------|
| `flutter: command not found` | PATH ayarını kontrol et, `source ~/.zshrc` çalıştır |
| Xcode license hatası | `sudo xcodebuild -license accept` |
| Android licenses hatası | `flutter doctor --android-licenses` |
| CocoaPods eksik (iOS) | `sudo gem install cocoapods` |
| Emulator açılmıyor | Android Studio → Virtual Device Manager'dan emulator'u manuel başlat |

---

## Kurulum Sonrası Test

```bash
flutter doctor -v   # detaylı durum
flutter devices     # bağlı cihaz/emulator listesi
flutter run         # uygulamayı çalıştır
```
