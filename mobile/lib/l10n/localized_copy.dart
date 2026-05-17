import 'package:flutter/widgets.dart';

bool isTurkishLocale(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'tr';

String copyForLocale(
  BuildContext context, {
  required String en,
  required String tr,
}) {
  return isTurkishLocale(context) ? tr : en;
}

const _monthsEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _monthsTr = [
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

String monthName(BuildContext context, int month) {
  final months = isTurkishLocale(context) ? _monthsTr : _monthsEn;
  return months[month - 1];
}

String shortMonthName(BuildContext context, int month) {
  return monthName(context, month).substring(0, 3);
}

String periodLabel(BuildContext context, String period) => switch (period) {
  'monthly' => copyForLocale(context, en: 'Monthly', tr: 'Aylık'),
  'yearly' => copyForLocale(context, en: 'Yearly', tr: 'Yıllık'),
  'weekly' => copyForLocale(context, en: 'Weekly', tr: 'Haftalık'),
  _ => period,
};

String receiptStatusLabel(BuildContext context, String status) =>
    switch (status) {
      'parsed' => copyForLocale(context, en: 'Parsed', tr: 'Okundu'),
      'failed' => copyForLocale(context, en: 'Failed', tr: 'Başarısız'),
      'manual' => copyForLocale(context, en: 'Edited', tr: 'Düzenlendi'),
      _ => copyForLocale(context, en: 'Pending', tr: 'Bekliyor'),
    };

const _categoryEnToTr = {
  'Groceries': 'Market',
  'Transportation': 'Ulaşım',
  'Bills': 'Faturalar',
  'Food & Drink': 'Yeme-İçme',
  'Health': 'Sağlık',
  'Entertainment': 'Eğlence',
  'Other': 'Diğer',
};

const _categoryTrToEn = {
  'Market': 'Groceries',
  'Ulaşım': 'Transportation',
  'Faturalar': 'Bills',
  'Yeme-İçme': 'Food & Drink',
  'Sağlık': 'Health',
  'Eğlence': 'Entertainment',
  'Diğer': 'Other',
};

String localizedCategoryName(
  BuildContext context,
  String? name, {
  String fallbackEn = 'Category',
  String fallbackTr = 'Kategori',
}) {
  if (name == null || name.isEmpty) {
    return copyForLocale(context, en: fallbackEn, tr: fallbackTr);
  }
  if (isTurkishLocale(context)) return _categoryEnToTr[name] ?? name;
  return _categoryTrToEn[name] ?? name;
}
