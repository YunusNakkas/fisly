import 'package:flutter/services.dart';

/// Sağdan dolduran para girişi: kullanıcı rakam ekledikçe son iki hane kuruş olur,
/// soldaki lira kısmı kayar.
///   "5" → 0,05 · "50" → 0,50 · "500" → 5,00 · "50000" → 500,00 · "500000" → 5000,00
/// Binlik ayraç eklenmez (girilen değer ',' → '.' çevrilerek parse ediliyor).
class CurrencyInputFormatter extends TextInputFormatter {
  final int maxDigits;
  const CurrencyInputFormatter({this.maxDigits = 12});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }
    final cents = int.parse(digits);
    final text = '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Bir double tutarı aynı '1234,56' biçimine çevirir (controller başlangıç değeri için).
String formatAmountForInput(double amount) {
  final cents = (amount * 100).round();
  return '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';
}
