// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Fişly';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navExpenses => 'Harcamalar';

  @override
  String get navReports => 'Özet';

  @override
  String get navSubscriptions => 'Abonelikler';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionDelete => 'Sil';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionContinue => 'Devam';

  @override
  String get actionStart => 'Başla';

  @override
  String get actionSkip => 'Atla';

  @override
  String get actionLogin => 'Giriş yap';

  @override
  String get actionRegister => 'Kayıt ol';

  @override
  String get actionLogout => 'Çıkış yap';

  @override
  String get actionBack => 'Geri';

  @override
  String get actionRetry => 'Tekrar dene';

  @override
  String get loginTitle => 'Tekrar hoş geldin';

  @override
  String get loginSubtitle => 'Hesabınla devam et, harcamaların seni bekliyor.';

  @override
  String get loginEmail => 'E-posta';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginForgotPassword => 'Şifremi unuttum';

  @override
  String get loginNoAccount => 'Hesabın yok mu?';

  @override
  String get loginFailed => 'E-posta veya şifre hatalı';

  @override
  String get registerTitle => 'Hesabını oluştur';

  @override
  String get registerSubtitle =>
      '30 saniyede başla. İlk 30 fiş tarama ücretsiz.';

  @override
  String get registerFullName => 'Ad';

  @override
  String get registerHaveAccount => 'Hesabın var mı?';

  @override
  String get registerEmailExists => 'Bu e-posta zaten kayıtlı';

  @override
  String get forgotTitle => 'Şifreni mi unuttun?';

  @override
  String get forgotSubtitle =>
      'E-postanı gir, şifre sıfırlama bağlantısını gönderelim.';

  @override
  String get forgotSent => 'Bağlantı gönderildi';

  @override
  String get forgotSentDescription =>
      'Eğer bu e-posta sistemde kayıtlıysa sıfırlama bağlantısını gönderdik. Spam klasörünü de kontrol et.';

  @override
  String get forgotSubmit => 'Bağlantı gönder';

  @override
  String get forgotResetWithToken => 'Token ile şifre sıfırla';

  @override
  String get forgotBackToLogin => 'Girişe dön';

  @override
  String get forgotHint =>
      'İpucu: Mail gelmediyse spam klasörüne bak veya birkaç dakika sonra tekrar dene.';

  @override
  String get resetTitle => 'Yeni şifre belirle';

  @override
  String get resetSubtitle =>
      'E-posta ile aldığın sıfırlama token\'ını gir ve yeni şifreni belirle.';

  @override
  String get resetTokenLabel => 'Sıfırlama token';

  @override
  String get resetTokenHint => 'E-postandan al';

  @override
  String get resetNewPassword => 'Yeni şifre';

  @override
  String get resetSubmit => 'Şifreyi güncelle';

  @override
  String get resetSuccess => 'Şifren güncellendi, giriş yapabilirsin';

  @override
  String get resetInvalidToken => 'Token geçersiz veya süresi dolmuş';

  @override
  String get settingsAccount => 'Hesap';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsPasswordChange => 'Şifre değiştir';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageTr => 'Türkçe';

  @override
  String get settingsLanguageEn => 'İngilizce';

  @override
  String get settingsData => 'Veri';

  @override
  String get settingsCategories => 'Kategoriler';

  @override
  String get settingsBudgets => 'Bütçeler';

  @override
  String get settingsOther => 'Diğer';

  @override
  String get settingsFeedback => 'Geri bildirim / Şikayet';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsLogout => 'Çıkış yap';

  @override
  String get settingsLogoutConfirm => 'Çıkış yapmak istediğinden emin misin?';

  @override
  String get onboardingWelcomeTitle => 'Fişini çek,\ngerisini biz\nhalledelim.';

  @override
  String get onboardingWelcomeBody =>
      'Gemini yapay zekâ fişlerini saniyeler içinde okur, kategorize eder ve bütçeni takip eder.';

  @override
  String get onboardingScanTitle => 'Türk fişlerini tanır,\nürünleri ayırır.';

  @override
  String get onboardingScanBody =>
      'BİM, Migros, A101, ŞOK — yerel zincirleri ve termal kağıt fişleri okur. Kategorileri otomatik atar.';

  @override
  String get onboardingBudgetTitle => 'Bütçeni aşma,\naboneliklerini\nunutma.';

  @override
  String get onboardingBudgetBody =>
      'Aylık limit koy, kategori bazlı takip et. Yaklaşan abonelik ödemelerini önceden gör.';

  @override
  String get commonError => 'Bir hata oluştu';

  @override
  String get commonLoading => 'Yükleniyor…';

  @override
  String get commonEmpty => 'Henüz veri yok';

  @override
  String get commonRequired => 'Bu alan gerekli';

  @override
  String get validationEmailRequired => 'E-posta gerekli';

  @override
  String get validationEmailInvalid => 'Geçerli bir e-posta gir';

  @override
  String get validationPasswordRequired => 'Şifre gerekli';

  @override
  String get validationPasswordMin => 'En az 8 karakter olmalı';

  @override
  String get validationPasswordMin6 => 'En az 6 karakter';

  @override
  String get validationNameRequired => 'Ad soyad gerekli';

  @override
  String get validationAmountInvalid => 'Geçerli bir tutar gir';

  @override
  String get validationAmountPositive => '0\'dan büyük olmalı';

  @override
  String get validationRequired => 'Bu alan gerekli';

  @override
  String get registerSubtitleShort =>
      'Harcamalarını kontrol altına almaya başla.';

  @override
  String get registerFullNameLabel => 'Ad Soyad';

  @override
  String get registerHaveAccountAction => 'Zaten hesabım var';

  @override
  String get registerOr => 'veya';

  @override
  String get registerFailed => 'Kayıt olunamadı, tekrar dene';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSubtitle => 'İsim ve e-posta';

  @override
  String get profileFullNameLabel => 'Ad Soyad';

  @override
  String get profileEmailLabel => 'E-posta';

  @override
  String get profileSaveAction => 'Kaydet';

  @override
  String get profileSaved => 'Profil güncellendi';

  @override
  String get profileSaveFailed => 'Güncellenemedi';

  @override
  String get passwordChangeTitle => 'Şifre değiştir';

  @override
  String get passwordChangeCurrent => 'Mevcut şifre';

  @override
  String get passwordChangeNew => 'Yeni şifre';

  @override
  String get passwordChangeConfirm => 'Yeni şifre (tekrar)';

  @override
  String get passwordChangeMismatch => 'Şifreler eşleşmiyor';

  @override
  String get passwordChangeSubmit => 'Güncelle';

  @override
  String get passwordChangeSuccess => 'Şifre güncellendi';

  @override
  String get passwordChangeFailed => 'Güncellenemedi';

  @override
  String get passwordHint =>
      'Güvenli bir şifre için en az 8 karakter, bir büyük harf, bir rakam ve bir özel karakter içermeli.';

  @override
  String get passwordCheckMin8 => 'En az 8 karakter';

  @override
  String get passwordCheckUpper => 'Bir büyük harf';

  @override
  String get passwordCheckDigit => 'Bir rakam';

  @override
  String get passwordCheckSpecial => 'Bir özel karakter';

  @override
  String get feedbackTitle => 'Geri Bildirim';

  @override
  String get feedbackSubtitle => 'Görüş, öneri ve hata bildirimi';

  @override
  String get feedbackTypeLabel => 'Tür';

  @override
  String get feedbackTypeBug => 'Hata bildirimi';

  @override
  String get feedbackTypeFeature => 'Öneri';

  @override
  String get feedbackTypeComplaint => 'Şikayet';

  @override
  String get feedbackTypeOther => 'Diğer';

  @override
  String get feedbackSubjectLabel => 'Başlık';

  @override
  String get feedbackMessageLabel => 'Mesaj';

  @override
  String get feedbackSubjectRequired => 'Başlık gerekli';

  @override
  String get feedbackMessageRequired => 'Mesaj gerekli';

  @override
  String get feedbackSubmit => 'Gönder';

  @override
  String get feedbackSent => 'Geri bildirim gönderildi, teşekkürler!';

  @override
  String get feedbackFailed => 'Gönderilemedi';

  @override
  String get feedbackFooter =>
      'Geri bildiriminiz uygulamayı iyileştirmemize yardım ediyor.';

  @override
  String get settingsAccountSection => 'Hesap';

  @override
  String get settingsBudgetSection => 'Bütçe';

  @override
  String get settingsSupportSection => 'Destek';

  @override
  String get settingsProfileSubtitle => 'İsim ve e-posta';

  @override
  String get settingsBudgetsSubtitle => 'Aylık ve kategori bazlı limitler';

  @override
  String get settingsCategoriesSubtitle => 'Sistem ve özel kategoriler';

  @override
  String get settingsFeedbackSubtitle => 'Görüş, öneri ve hata bildirimi';

  @override
  String get settingsLogoutAction => 'Çık';

  @override
  String get settingsLogoutDismiss => 'Vazgeç';

  @override
  String get settingsLogoutQuestion => 'Hesaptan çıkmak istediğine emin misin?';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get dashboardThisMonth => 'Bu Ay';

  @override
  String get dashboardAlerts => 'Uyarılar';

  @override
  String get dashboardRecentExpenses => 'Son Harcamalar';

  @override
  String get dashboardReceiptHistory => 'Fiş Geçmişi';

  @override
  String get dashboardSeeAll => 'Tümü';

  @override
  String get dashboardOpen => 'Aç';

  @override
  String get dashboardLoadFailed => 'Panel yüklenemedi';

  @override
  String dashboardExpenseCount(int count, int cats) {
    return '$count harcama · $cats kategori';
  }

  @override
  String get expensesTitleShort => 'Harcamalar';

  @override
  String get expensesAddTitle => 'Harcama Ekle';

  @override
  String get expensesEditTitle => 'Harcamayı Düzenle';

  @override
  String get expensesEmptyState => 'Henüz harcaman yok';

  @override
  String get expensesAmount => 'Tutar (TL)';

  @override
  String get expensesMerchant => 'Market / Mağaza';

  @override
  String get expensesNote => 'Not';

  @override
  String get expensesDateLabel => 'Tarih';

  @override
  String get expensesSaved => 'Harcama eklendi';

  @override
  String get expensesUpdated => 'Harcama güncellendi';

  @override
  String get expensesDeleted => 'Harcama silindi';

  @override
  String get expensesDeleteTitle => 'Harcamayı sil';

  @override
  String get expensesDeleteBody => 'Bu harcama kalıcı olarak silinecek.';

  @override
  String get expensesFilterTitle => 'Harcama filtreleri';

  @override
  String get expensesFilterMin => 'Min tutar';

  @override
  String get expensesFilterMax => 'Maks tutar';

  @override
  String get expensesFilterReceiptOnly => 'Sadece fişli';

  @override
  String get expensesFilterApply => 'Uygula';

  @override
  String get expensesFilterClear => 'Temizle';

  @override
  String get expensesSaveFailed => 'Kaydedilemedi';

  @override
  String get reportsTitle => 'Özet';

  @override
  String get reportsThisMonth => 'Bu ay';

  @override
  String get reportsCategoryBreakdown => 'Kategori dağılımı';

  @override
  String get reportsTrends => 'Aylık trend';

  @override
  String get reportsExportCsv => 'CSV olarak dışa aktar';

  @override
  String get reportsNoData => 'Bu ay için veri yok';

  @override
  String get reportsExportSuccess => 'Rapor paylaşıldı';

  @override
  String get reportsExportFailed => 'Dışa aktarılamadı';

  @override
  String get budgetsTitle => 'Bütçeler';

  @override
  String get budgetsAddTitle => 'Bütçe Ekle';

  @override
  String get budgetsEditTitle => 'Bütçeyi Düzenle';

  @override
  String get budgetsAmount => 'Tutar (TL)';

  @override
  String get budgetsPeriodLabel => 'Periyot';

  @override
  String get budgetsPeriodMonthly => 'Aylık';

  @override
  String get budgetsPeriodWeekly => 'Haftalık';

  @override
  String get budgetsGeneral => 'Genel';

  @override
  String get budgetsEmptyState => 'Henüz bütçe yok';

  @override
  String get budgetsAddHint => 'Genel veya kategori bazlı limit ekle.';

  @override
  String get budgetsSaved => 'Bütçe eklendi';

  @override
  String get budgetsUpdated => 'Bütçe güncellendi';

  @override
  String get budgetsDeleted => 'Bütçe silindi';

  @override
  String get subscriptionsTitle => 'Abonelikler';

  @override
  String get subscriptionsAddTitle => 'Abonelik Ekle';

  @override
  String get subscriptionsEditTitle => 'Aboneliği Düzenle';

  @override
  String get subscriptionsName => 'Ad (Netflix, Spotify…)';

  @override
  String get subscriptionsAmount => 'Tutar (TL)';

  @override
  String get subscriptionsPeriodLabel => 'Periyot';

  @override
  String get subscriptionsPeriodMonthly => 'Aylık';

  @override
  String get subscriptionsPeriodYearly => 'Yıllık';

  @override
  String get subscriptionsPeriodWeekly => 'Haftalık';

  @override
  String get subscriptionsNextPayment => 'Sonraki ödeme';

  @override
  String get subscriptionsCategoryOptional => 'Kategori (opsiyonel)';

  @override
  String get subscriptionsActive => 'Aktif';

  @override
  String get subscriptionsCancelled => 'İptal edildi';

  @override
  String get subscriptionsCancelAction => 'İptal et';

  @override
  String get subscriptionsEmptyState => 'Henüz abonelik yok';

  @override
  String get subscriptionsSaved => 'Abonelik eklendi';

  @override
  String get subscriptionsUpdated => 'Abonelik güncellendi';

  @override
  String get subscriptionsDeleted => 'Abonelik silindi';

  @override
  String get categoriesTitle => 'Kategoriler';

  @override
  String get categoriesAddTitle => 'Kategori Ekle';

  @override
  String get categoriesEditTitle => 'Kategoriyi Düzenle';

  @override
  String get categoriesNameLabel => 'Ad';

  @override
  String get categoriesIconLabel => 'İkon';

  @override
  String get categoriesColorLabel => 'Renk';

  @override
  String get categoriesSystem => 'Sistem';

  @override
  String get categoriesUser => 'Senin';

  @override
  String get categoriesEmptyState => 'Henüz kategori eklemedin';

  @override
  String get categoriesSaved => 'Kategori eklendi';

  @override
  String get categoriesUpdated => 'Kategori güncellendi';

  @override
  String get categoriesDeleted => 'Kategori silindi';

  @override
  String get categoriesDeleteTitle => 'Kategoriyi sil';

  @override
  String get categoriesDeleteBody =>
      'Bu kategoriyi silmek istediğine emin misin?';

  @override
  String get categoriesSystemNotDeletable => 'Sistem kategorileri silinemez';

  @override
  String get scanTitle => 'Fiş Tara';

  @override
  String get scanCameraAction => 'Kameradan çek';

  @override
  String get scanGalleryAction => 'Galeriden seç';

  @override
  String get scanProcessing => 'Fiş okunuyor…';

  @override
  String get scanFailed => 'Fiş okunamadı';

  @override
  String get scanNoItems => 'Üründen ayrılamadı, manuel ekle';

  @override
  String get scanSaveAll => 'Hepsini kaydet';

  @override
  String get scanTotal => 'Toplam';

  @override
  String get scanReceiptDateLabel => 'Fiş tarihi';

  @override
  String get scanMerchantLabel => 'Market';

  @override
  String get scanItemNameLabel => 'Ürün adı';

  @override
  String get scanItemAmountLabel => 'Tutar';

  @override
  String get scanCategoryPickTitle => 'Kategori seç';

  @override
  String get scanCategoryEmpty => 'Kategori seç';

  @override
  String get receiptHistoryTitle => 'Fiş Geçmişi';

  @override
  String get receiptHistoryEmpty => 'Henüz taradığın fiş yok';

  @override
  String get receiptDetailTitle => 'Fiş Detayı';

  @override
  String get receiptDetailItems => 'Ürünler';

  @override
  String get receiptDetailLinkedExpenses => 'Bağlantılı harcamalar';

  @override
  String get receiptDetailMerchant => 'Market';

  @override
  String get receiptDetailDate => 'Tarih';

  @override
  String get receiptDetailTotal => 'Toplam';

  @override
  String get receiptDetailDeleteConfirm =>
      'Bu fiş ve bağlı tüm harcamalar silinecek.';

  @override
  String get receiptDetailDeleted => 'Fiş silindi';
}
