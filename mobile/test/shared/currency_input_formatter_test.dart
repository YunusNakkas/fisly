import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/currency_input_formatter.dart';

void main() {
  const f = CurrencyInputFormatter();

  TextEditingValue apply(String oldText, String newText) => f.formatEditUpdate(
        TextEditingValue(text: oldText),
        TextEditingValue(text: newText),
      );

  test('sağdan doldurur, son iki hane kuruş', () {
    expect(apply('', '5').text, '0,05');
    expect(apply('0,05', '0,050').text, '0,50');
    expect(apply('0,50', '0,500').text, '5,00');
    expect(apply('5,00', '5,000').text, '50,00');
    expect(apply('50,00', '50,000').text, '500,00');
    // 500,00'a 0 eklenince 5000,00 olur (kullanıcının örneği)
    expect(apply('500,00', '500,000').text, '5000,00');
  });

  test('rakam dışı karakterleri yok sayar', () {
    expect(apply('', 'abc12').text, '0,12');
  });

  test('boş girişte boş döner', () {
    expect(apply('0,05', '').text, '');
  });

  test('formatAmountForInput double biçimler', () {
    expect(formatAmountForInput(500.0), '500,00');
    expect(formatAmountForInput(5000.5), '5000,50');
  });
}
