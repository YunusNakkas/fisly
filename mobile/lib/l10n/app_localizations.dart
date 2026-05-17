import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Fişly'**
  String get appName;

  /// No description provided for @navDashboard.
  ///
  /// In tr, this message translates to:
  /// **'Panel'**
  String get navDashboard;

  /// No description provided for @navExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalar'**
  String get navExpenses;

  /// No description provided for @navReports.
  ///
  /// In tr, this message translates to:
  /// **'Özet'**
  String get navReports;

  /// No description provided for @navSubscriptions.
  ///
  /// In tr, this message translates to:
  /// **'Abonelikler'**
  String get navSubscriptions;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @actionSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get actionEdit;

  /// No description provided for @actionContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get actionContinue;

  /// No description provided for @actionStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get actionStart;

  /// No description provided for @actionSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get actionSkip;

  /// No description provided for @actionLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get actionLogin;

  /// No description provided for @actionRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get actionRegister;

  /// No description provided for @actionLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get actionLogout;

  /// No description provided for @actionBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get actionBack;

  /// No description provided for @actionRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get actionRetry;

  /// No description provided for @loginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar hoş geldin'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınla devam et, harcamaların seni bekliyor.'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get loginPassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get loginNoAccount;

  /// No description provided for @loginFailed.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı'**
  String get loginFailed;

  /// No description provided for @registerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını oluştur'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'30 saniyede başla. İlk 30 fiş tarama ücretsiz.'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get registerFullName;

  /// No description provided for @registerHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın var mı?'**
  String get registerHaveAccount;

  /// No description provided for @registerEmailExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kayıtlı'**
  String get registerEmailExists;

  /// No description provided for @forgotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni mi unuttun?'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı gir, şifre sıfırlama bağlantısını gönderelim.'**
  String get forgotSubtitle;

  /// No description provided for @forgotSent.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı gönderildi'**
  String get forgotSent;

  /// No description provided for @forgotSentDescription.
  ///
  /// In tr, this message translates to:
  /// **'Eğer bu e-posta sistemde kayıtlıysa sıfırlama bağlantısını gönderdik. Spam klasörünü de kontrol et.'**
  String get forgotSentDescription;

  /// No description provided for @forgotSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı gönder'**
  String get forgotSubmit;

  /// No description provided for @forgotResetWithToken.
  ///
  /// In tr, this message translates to:
  /// **'Token ile şifre sıfırla'**
  String get forgotResetWithToken;

  /// No description provided for @forgotBackToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Girişe dön'**
  String get forgotBackToLogin;

  /// No description provided for @forgotHint.
  ///
  /// In tr, this message translates to:
  /// **'İpucu: Mail gelmediyse spam klasörüne bak veya birkaç dakika sonra tekrar dene.'**
  String get forgotHint;

  /// No description provided for @resetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre belirle'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ile aldığın sıfırlama token\'ını gir ve yeni şifreni belirle.'**
  String get resetSubtitle;

  /// No description provided for @resetTokenLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama token'**
  String get resetTokenLabel;

  /// No description provided for @resetTokenHint.
  ///
  /// In tr, this message translates to:
  /// **'E-postandan al'**
  String get resetTokenHint;

  /// No description provided for @resetNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get resetNewPassword;

  /// No description provided for @resetSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi güncelle'**
  String get resetSubmit;

  /// No description provided for @resetSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Şifren güncellendi, giriş yapabilirsin'**
  String get resetSuccess;

  /// No description provided for @resetInvalidToken.
  ///
  /// In tr, this message translates to:
  /// **'Token geçersiz veya süresi dolmuş'**
  String get resetInvalidToken;

  /// No description provided for @settingsAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get settingsAccount;

  /// No description provided for @settingsProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get settingsProfile;

  /// No description provided for @settingsPasswordChange.
  ///
  /// In tr, this message translates to:
  /// **'Şifre değiştir'**
  String get settingsPasswordChange;

  /// No description provided for @settingsAppearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageTr.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get settingsLanguageTr;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get settingsLanguageEn;

  /// No description provided for @settingsData.
  ///
  /// In tr, this message translates to:
  /// **'Veri'**
  String get settingsData;

  /// No description provided for @settingsCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get settingsCategories;

  /// No description provided for @settingsBudgets.
  ///
  /// In tr, this message translates to:
  /// **'Bütçeler'**
  String get settingsBudgets;

  /// No description provided for @settingsOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get settingsOther;

  /// No description provided for @settingsFeedback.
  ///
  /// In tr, this message translates to:
  /// **'Geri bildirim / Şikayet'**
  String get settingsFeedback;

  /// No description provided for @settingsAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsAbout;

  /// No description provided for @settingsLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinden emin misin?'**
  String get settingsLogoutConfirm;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fişini çek,\ngerisini biz\nhalledelim.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In tr, this message translates to:
  /// **'Gemini yapay zekâ fişlerini saniyeler içinde okur, kategorize eder ve bütçeni takip eder.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingScanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Türk fişlerini tanır,\nürünleri ayırır.'**
  String get onboardingScanTitle;

  /// No description provided for @onboardingScanBody.
  ///
  /// In tr, this message translates to:
  /// **'BİM, Migros, A101, ŞOK — yerel zincirleri ve termal kağıt fişleri okur. Kategorileri otomatik atar.'**
  String get onboardingScanBody;

  /// No description provided for @onboardingBudgetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçeni aşma,\naboneliklerini\nunutma.'**
  String get onboardingBudgetTitle;

  /// No description provided for @onboardingBudgetBody.
  ///
  /// In tr, this message translates to:
  /// **'Aylık limit koy, kategori bazlı takip et. Yaklaşan abonelik ödemelerini önceden gör.'**
  String get onboardingBudgetBody;

  /// No description provided for @commonError.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get commonError;

  /// No description provided for @commonLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor…'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz veri yok'**
  String get commonEmpty;

  /// No description provided for @commonRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan gerekli'**
  String get commonRequired;

  /// No description provided for @validationEmailRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gerekli'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta gir'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMin.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter olmalı'**
  String get validationPasswordMin;

  /// No description provided for @validationPasswordMin6.
  ///
  /// In tr, this message translates to:
  /// **'En az 6 karakter'**
  String get validationPasswordMin6;

  /// No description provided for @validationNameRequired.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad gerekli'**
  String get validationNameRequired;

  /// No description provided for @validationAmountInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir tutar gir'**
  String get validationAmountInvalid;

  /// No description provided for @validationAmountPositive.
  ///
  /// In tr, this message translates to:
  /// **'0\'dan büyük olmalı'**
  String get validationAmountPositive;

  /// No description provided for @validationRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan gerekli'**
  String get validationRequired;

  /// No description provided for @registerSubtitleShort.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalarını kontrol altına almaya başla.'**
  String get registerSubtitleShort;

  /// No description provided for @registerFullNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get registerFullNameLabel;

  /// No description provided for @registerHaveAccountAction.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabım var'**
  String get registerHaveAccountAction;

  /// No description provided for @registerOr.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get registerOr;

  /// No description provided for @registerFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt olunamadı, tekrar dene'**
  String get registerFailed;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İsim ve e-posta'**
  String get profileSubtitle;

  /// No description provided for @profileFullNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get profileFullNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get profileEmailLabel;

  /// No description provided for @profileSaveAction.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get profileSaveAction;

  /// No description provided for @profileSaved.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellendi'**
  String get profileSaved;

  /// No description provided for @profileSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Güncellenemedi'**
  String get profileSaveFailed;

  /// No description provided for @passwordChangeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre değiştir'**
  String get passwordChangeTitle;

  /// No description provided for @passwordChangeCurrent.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut şifre'**
  String get passwordChangeCurrent;

  /// No description provided for @passwordChangeNew.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get passwordChangeNew;

  /// No description provided for @passwordChangeConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre (tekrar)'**
  String get passwordChangeConfirm;

  /// No description provided for @passwordChangeMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get passwordChangeMismatch;

  /// No description provided for @passwordChangeSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get passwordChangeSubmit;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Şifre güncellendi'**
  String get passwordChangeSuccess;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In tr, this message translates to:
  /// **'Güncellenemedi'**
  String get passwordChangeFailed;

  /// No description provided for @passwordHint.
  ///
  /// In tr, this message translates to:
  /// **'Güvenli bir şifre için en az 8 karakter, bir büyük harf, bir rakam ve bir özel karakter içermeli.'**
  String get passwordHint;

  /// No description provided for @passwordCheckMin8.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter'**
  String get passwordCheckMin8;

  /// No description provided for @passwordCheckUpper.
  ///
  /// In tr, this message translates to:
  /// **'Bir büyük harf'**
  String get passwordCheckUpper;

  /// No description provided for @passwordCheckDigit.
  ///
  /// In tr, this message translates to:
  /// **'Bir rakam'**
  String get passwordCheckDigit;

  /// No description provided for @passwordCheckSpecial.
  ///
  /// In tr, this message translates to:
  /// **'Bir özel karakter'**
  String get passwordCheckSpecial;

  /// No description provided for @feedbackTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geri Bildirim'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Görüş, öneri ve hata bildirimi'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackTypeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tür'**
  String get feedbackTypeLabel;

  /// No description provided for @feedbackTypeBug.
  ///
  /// In tr, this message translates to:
  /// **'Hata bildirimi'**
  String get feedbackTypeBug;

  /// No description provided for @feedbackTypeFeature.
  ///
  /// In tr, this message translates to:
  /// **'Öneri'**
  String get feedbackTypeFeature;

  /// No description provided for @feedbackTypeComplaint.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet'**
  String get feedbackTypeComplaint;

  /// No description provided for @feedbackTypeOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get feedbackTypeOther;

  /// No description provided for @feedbackSubjectLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get feedbackSubjectLabel;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackSubjectRequired.
  ///
  /// In tr, this message translates to:
  /// **'Başlık gerekli'**
  String get feedbackSubjectRequired;

  /// No description provided for @feedbackMessageRequired.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gerekli'**
  String get feedbackMessageRequired;

  /// No description provided for @feedbackSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get feedbackSubmit;

  /// No description provided for @feedbackSent.
  ///
  /// In tr, this message translates to:
  /// **'Geri bildirim gönderildi, teşekkürler!'**
  String get feedbackSent;

  /// No description provided for @feedbackFailed.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilemedi'**
  String get feedbackFailed;

  /// No description provided for @feedbackFooter.
  ///
  /// In tr, this message translates to:
  /// **'Geri bildiriminiz uygulamayı iyileştirmemize yardım ediyor.'**
  String get feedbackFooter;

  /// No description provided for @settingsAccountSection.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get settingsAccountSection;

  /// No description provided for @settingsBudgetSection.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe'**
  String get settingsBudgetSection;

  /// No description provided for @settingsSupportSection.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get settingsSupportSection;

  /// No description provided for @settingsProfileSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İsim ve e-posta'**
  String get settingsProfileSubtitle;

  /// No description provided for @settingsBudgetsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Aylık ve kategori bazlı limitler'**
  String get settingsBudgetsSubtitle;

  /// No description provided for @settingsCategoriesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sistem ve özel kategoriler'**
  String get settingsCategoriesSubtitle;

  /// No description provided for @settingsFeedbackSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Görüş, öneri ve hata bildirimi'**
  String get settingsFeedbackSubtitle;

  /// No description provided for @settingsLogoutAction.
  ///
  /// In tr, this message translates to:
  /// **'Çık'**
  String get settingsLogoutAction;

  /// No description provided for @settingsLogoutDismiss.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get settingsLogoutDismiss;

  /// No description provided for @settingsLogoutQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Hesaptan çıkmak istediğine emin misin?'**
  String get settingsLogoutQuestion;

  /// No description provided for @settingsVersion.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm'**
  String get settingsVersion;

  /// No description provided for @dashboardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Panel'**
  String get dashboardTitle;

  /// No description provided for @dashboardThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get dashboardThisMonth;

  /// No description provided for @dashboardAlerts.
  ///
  /// In tr, this message translates to:
  /// **'Uyarılar'**
  String get dashboardAlerts;

  /// No description provided for @dashboardRecentExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Son Harcamalar'**
  String get dashboardRecentExpenses;

  /// No description provided for @dashboardReceiptHistory.
  ///
  /// In tr, this message translates to:
  /// **'Fiş Geçmişi'**
  String get dashboardReceiptHistory;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardOpen.
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get dashboardOpen;

  /// No description provided for @dashboardLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Panel yüklenemedi'**
  String get dashboardLoadFailed;

  /// No description provided for @dashboardExpenseCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} harcama · {cats} kategori'**
  String dashboardExpenseCount(int count, int cats);

  /// No description provided for @expensesTitleShort.
  ///
  /// In tr, this message translates to:
  /// **'Harcamalar'**
  String get expensesTitleShort;

  /// No description provided for @expensesAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Ekle'**
  String get expensesAddTitle;

  /// No description provided for @expensesEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcamayı Düzenle'**
  String get expensesEditTitle;

  /// No description provided for @expensesEmptyState.
  ///
  /// In tr, this message translates to:
  /// **'Henüz harcaman yok'**
  String get expensesEmptyState;

  /// No description provided for @expensesAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar (TL)'**
  String get expensesAmount;

  /// No description provided for @expensesMerchant.
  ///
  /// In tr, this message translates to:
  /// **'Market / Mağaza'**
  String get expensesMerchant;

  /// No description provided for @expensesNote.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get expensesNote;

  /// No description provided for @expensesDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get expensesDateLabel;

  /// No description provided for @expensesSaved.
  ///
  /// In tr, this message translates to:
  /// **'Harcama eklendi'**
  String get expensesSaved;

  /// No description provided for @expensesUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Harcama güncellendi'**
  String get expensesUpdated;

  /// No description provided for @expensesDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Harcama silindi'**
  String get expensesDeleted;

  /// No description provided for @expensesDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcamayı sil'**
  String get expensesDeleteTitle;

  /// No description provided for @expensesDeleteBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu harcama kalıcı olarak silinecek.'**
  String get expensesDeleteBody;

  /// No description provided for @expensesFilterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Harcama filtreleri'**
  String get expensesFilterTitle;

  /// No description provided for @expensesFilterMin.
  ///
  /// In tr, this message translates to:
  /// **'Min tutar'**
  String get expensesFilterMin;

  /// No description provided for @expensesFilterMax.
  ///
  /// In tr, this message translates to:
  /// **'Maks tutar'**
  String get expensesFilterMax;

  /// No description provided for @expensesFilterReceiptOnly.
  ///
  /// In tr, this message translates to:
  /// **'Sadece fişli'**
  String get expensesFilterReceiptOnly;

  /// No description provided for @expensesFilterApply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get expensesFilterApply;

  /// No description provided for @expensesFilterClear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get expensesFilterClear;

  /// No description provided for @expensesSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi'**
  String get expensesSaveFailed;

  /// No description provided for @reportsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özet'**
  String get reportsTitle;

  /// No description provided for @reportsThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay'**
  String get reportsThisMonth;

  /// No description provided for @reportsCategoryBreakdown.
  ///
  /// In tr, this message translates to:
  /// **'Kategori dağılımı'**
  String get reportsCategoryBreakdown;

  /// No description provided for @reportsTrends.
  ///
  /// In tr, this message translates to:
  /// **'Aylık trend'**
  String get reportsTrends;

  /// No description provided for @reportsExportCsv.
  ///
  /// In tr, this message translates to:
  /// **'CSV olarak dışa aktar'**
  String get reportsExportCsv;

  /// No description provided for @reportsNoData.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay için veri yok'**
  String get reportsNoData;

  /// No description provided for @reportsExportSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Rapor paylaşıldı'**
  String get reportsExportSuccess;

  /// No description provided for @reportsExportFailed.
  ///
  /// In tr, this message translates to:
  /// **'Dışa aktarılamadı'**
  String get reportsExportFailed;

  /// No description provided for @budgetsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçeler'**
  String get budgetsTitle;

  /// No description provided for @budgetsAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Ekle'**
  String get budgetsAddTitle;

  /// No description provided for @budgetsEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçeyi Düzenle'**
  String get budgetsEditTitle;

  /// No description provided for @budgetsAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar (TL)'**
  String get budgetsAmount;

  /// No description provided for @budgetsPeriodLabel.
  ///
  /// In tr, this message translates to:
  /// **'Periyot'**
  String get budgetsPeriodLabel;

  /// No description provided for @budgetsPeriodMonthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get budgetsPeriodMonthly;

  /// No description provided for @budgetsPeriodWeekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get budgetsPeriodWeekly;

  /// No description provided for @budgetsGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get budgetsGeneral;

  /// No description provided for @budgetsEmptyState.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bütçe yok'**
  String get budgetsEmptyState;

  /// No description provided for @budgetsAddHint.
  ///
  /// In tr, this message translates to:
  /// **'Genel veya kategori bazlı limit ekle.'**
  String get budgetsAddHint;

  /// No description provided for @budgetsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe eklendi'**
  String get budgetsSaved;

  /// No description provided for @budgetsUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe güncellendi'**
  String get budgetsUpdated;

  /// No description provided for @budgetsDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe silindi'**
  String get budgetsDeleted;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Abonelikler'**
  String get subscriptionsTitle;

  /// No description provided for @subscriptionsAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik Ekle'**
  String get subscriptionsAddTitle;

  /// No description provided for @subscriptionsEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aboneliği Düzenle'**
  String get subscriptionsEditTitle;

  /// No description provided for @subscriptionsName.
  ///
  /// In tr, this message translates to:
  /// **'Ad (Netflix, Spotify…)'**
  String get subscriptionsName;

  /// No description provided for @subscriptionsAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar (TL)'**
  String get subscriptionsAmount;

  /// No description provided for @subscriptionsPeriodLabel.
  ///
  /// In tr, this message translates to:
  /// **'Periyot'**
  String get subscriptionsPeriodLabel;

  /// No description provided for @subscriptionsPeriodMonthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get subscriptionsPeriodMonthly;

  /// No description provided for @subscriptionsPeriodYearly.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get subscriptionsPeriodYearly;

  /// No description provided for @subscriptionsPeriodWeekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get subscriptionsPeriodWeekly;

  /// No description provided for @subscriptionsNextPayment.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki ödeme'**
  String get subscriptionsNextPayment;

  /// No description provided for @subscriptionsCategoryOptional.
  ///
  /// In tr, this message translates to:
  /// **'Kategori (opsiyonel)'**
  String get subscriptionsCategoryOptional;

  /// No description provided for @subscriptionsActive.
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get subscriptionsActive;

  /// No description provided for @subscriptionsCancelled.
  ///
  /// In tr, this message translates to:
  /// **'İptal edildi'**
  String get subscriptionsCancelled;

  /// No description provided for @subscriptionsCancelAction.
  ///
  /// In tr, this message translates to:
  /// **'İptal et'**
  String get subscriptionsCancelAction;

  /// No description provided for @subscriptionsEmptyState.
  ///
  /// In tr, this message translates to:
  /// **'Henüz abonelik yok'**
  String get subscriptionsEmptyState;

  /// No description provided for @subscriptionsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik eklendi'**
  String get subscriptionsSaved;

  /// No description provided for @subscriptionsUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik güncellendi'**
  String get subscriptionsUpdated;

  /// No description provided for @subscriptionsDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik silindi'**
  String get subscriptionsDeleted;

  /// No description provided for @categoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get categoriesTitle;

  /// No description provided for @categoriesAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Ekle'**
  String get categoriesAddTitle;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriyi Düzenle'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get categoriesNameLabel;

  /// No description provided for @categoriesIconLabel.
  ///
  /// In tr, this message translates to:
  /// **'İkon'**
  String get categoriesIconLabel;

  /// No description provided for @categoriesColorLabel.
  ///
  /// In tr, this message translates to:
  /// **'Renk'**
  String get categoriesColorLabel;

  /// No description provided for @categoriesSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get categoriesSystem;

  /// No description provided for @categoriesUser.
  ///
  /// In tr, this message translates to:
  /// **'Senin'**
  String get categoriesUser;

  /// No description provided for @categoriesEmptyState.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kategori eklemedin'**
  String get categoriesEmptyState;

  /// No description provided for @categoriesSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kategori eklendi'**
  String get categoriesSaved;

  /// No description provided for @categoriesUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Kategori güncellendi'**
  String get categoriesUpdated;

  /// No description provided for @categoriesDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Kategori silindi'**
  String get categoriesDeleted;

  /// No description provided for @categoriesDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriyi sil'**
  String get categoriesDeleteTitle;

  /// No description provided for @categoriesDeleteBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoriyi silmek istediğine emin misin?'**
  String get categoriesDeleteBody;

  /// No description provided for @categoriesSystemNotDeletable.
  ///
  /// In tr, this message translates to:
  /// **'Sistem kategorileri silinemez'**
  String get categoriesSystemNotDeletable;

  /// No description provided for @scanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fiş Tara'**
  String get scanTitle;

  /// No description provided for @scanCameraAction.
  ///
  /// In tr, this message translates to:
  /// **'Kameradan çek'**
  String get scanCameraAction;

  /// No description provided for @scanGalleryAction.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden seç'**
  String get scanGalleryAction;

  /// No description provided for @scanProcessing.
  ///
  /// In tr, this message translates to:
  /// **'Fiş okunuyor…'**
  String get scanProcessing;

  /// No description provided for @scanFailed.
  ///
  /// In tr, this message translates to:
  /// **'Fiş okunamadı'**
  String get scanFailed;

  /// No description provided for @scanNoItems.
  ///
  /// In tr, this message translates to:
  /// **'Üründen ayrılamadı, manuel ekle'**
  String get scanNoItems;

  /// No description provided for @scanSaveAll.
  ///
  /// In tr, this message translates to:
  /// **'Hepsini kaydet'**
  String get scanSaveAll;

  /// No description provided for @scanTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get scanTotal;

  /// No description provided for @scanReceiptDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Fiş tarihi'**
  String get scanReceiptDateLabel;

  /// No description provided for @scanMerchantLabel.
  ///
  /// In tr, this message translates to:
  /// **'Market'**
  String get scanMerchantLabel;

  /// No description provided for @scanItemNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ürün adı'**
  String get scanItemNameLabel;

  /// No description provided for @scanItemAmountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get scanItemAmountLabel;

  /// No description provided for @scanCategoryPickTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategori seç'**
  String get scanCategoryPickTitle;

  /// No description provided for @scanCategoryEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Kategori seç'**
  String get scanCategoryEmpty;

  /// No description provided for @receiptHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fiş Geçmişi'**
  String get receiptHistoryTitle;

  /// No description provided for @receiptHistoryEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz taradığın fiş yok'**
  String get receiptHistoryEmpty;

  /// No description provided for @receiptDetailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Fiş Detayı'**
  String get receiptDetailTitle;

  /// No description provided for @receiptDetailItems.
  ///
  /// In tr, this message translates to:
  /// **'Ürünler'**
  String get receiptDetailItems;

  /// No description provided for @receiptDetailLinkedExpenses.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantılı harcamalar'**
  String get receiptDetailLinkedExpenses;

  /// No description provided for @receiptDetailMerchant.
  ///
  /// In tr, this message translates to:
  /// **'Market'**
  String get receiptDetailMerchant;

  /// No description provided for @receiptDetailDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get receiptDetailDate;

  /// No description provided for @receiptDetailTotal.
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get receiptDetailTotal;

  /// No description provided for @receiptDetailDeleteConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu fiş ve bağlı tüm harcamalar silinecek.'**
  String get receiptDetailDeleteConfirm;

  /// No description provided for @receiptDetailDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Fiş silindi'**
  String get receiptDetailDeleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
