import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/receipts/receipts_provider.dart';

void main() {
  test('ScanResult parses scanned expense items', () {
    final result = ScanResult.fromJson({
      'receipt_id': 'receipt-1',
      'merchant': 'Market',
      'total_amount': 180.25,
      'receipt_date': '2026-05-10',
      'expenses': [
        {
          'expense_id': 'expense-1',
          'name': 'Ekmek',
          'amount': 30,
          'category_id': 'cat-1',
          'category_name': 'Market',
        },
      ],
    });

    expect(result.receiptId, 'receipt-1');
    expect(result.totalAmount, 180.25);
    expect(result.expenses.single.expenseId, 'expense-1');
    expect(result.expenses.single.amount, 30);
  });

  test('ReceiptHistoryItem parses nullable total amount', () {
    final parsed = ReceiptHistoryItem.fromJson({
      'id': 'receipt-1',
      'merchant': 'Cafe',
      'total_amount': '99.90',
      'receipt_date': '2026-05-11',
      'status': 'parsed',
      'created_at': '2026-05-11T12:00:00Z',
    });

    final failed = ReceiptHistoryItem.fromJson({
      'id': 'receipt-2',
      'merchant': null,
      'total_amount': null,
      'receipt_date': null,
      'status': 'failed',
      'created_at': '2026-05-11T12:00:00Z',
    });

    expect(parsed.totalAmount, 99.90);
    expect(parsed.status, 'parsed');
    expect(failed.totalAmount, isNull);
    expect(failed.merchant, isNull);
  });

  test('ReceiptDetail exposes raw OCR items and linked expenses', () {
    final detail = ReceiptDetail.fromJson(
      {
        'id': 'receipt-1',
        'image_url': '/uploads/receipt.jpg',
        'merchant': 'Market',
        'total_amount': '120.50',
        'receipt_date': '2026-05-10',
        'status': 'parsed',
        'created_at': '2026-05-10T10:00:00Z',
        'raw_ocr_data': {
          'merchant': 'Market',
          'items': [
            {'name': 'Süt', 'total': '45.00', 'category': 'Market'},
          ],
        },
      },
      [
        {'id': 'expense-1', 'amount': '45.00', 'note': 'Süt'},
      ],
    );

    expect(detail.id, 'receipt-1');
    expect(detail.totalAmount, 120.50);
    expect(detail.rawItems.single['name'], 'Süt');
    expect(detail.expenses.single['id'], 'expense-1');
  });
}
