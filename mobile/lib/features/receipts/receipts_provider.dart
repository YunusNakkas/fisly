import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class ScannedItem {
  final String expenseId;
  String name;
  double amount;
  String? categoryId;
  String? categoryName;

  ScannedItem({
    required this.expenseId,
    required this.name,
    required this.amount,
    this.categoryId,
    this.categoryName,
  });

  factory ScannedItem.fromJson(Map<String, dynamic> json) {
    return ScannedItem(
      expenseId: json['expense_id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
    );
  }
}

class ScanResult {
  final String receiptId;
  final String? merchant;
  final double? totalAmount;
  final String? receiptDate;
  final List<ScannedItem> expenses;

  ScanResult({
    required this.receiptId,
    this.merchant,
    this.totalAmount,
    this.receiptDate,
    this.expenses = const [],
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      receiptId: json['receipt_id'] as String,
      merchant: json['merchant'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      receiptDate: json['receipt_date'] as String?,
      expenses: (json['expenses'] as List<dynamic>? ?? [])
          .map((e) => ScannedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReceiptsState {
  final bool isScanning;
  final String? error;
  final ScanResult? lastScan;

  const ReceiptsState({
    this.isScanning = false,
    this.error,
    this.lastScan,
  });

  ReceiptsState copyWith({
    bool? isScanning,
    String? error,
    ScanResult? lastScan,
    bool clearError = false,
    bool clearScan = false,
  }) {
    return ReceiptsState(
      isScanning: isScanning ?? this.isScanning,
      error: clearError ? null : (error ?? this.error),
      lastScan: clearScan ? null : (lastScan ?? this.lastScan),
    );
  }
}

final receiptsProvider = StateNotifierProvider<ReceiptsNotifier, ReceiptsState>((ref) {
  return ReceiptsNotifier(ref.read(apiClientProvider));
});

class ReceiptsNotifier extends StateNotifier<ReceiptsState> {
  final ApiClient _api;

  ReceiptsNotifier(this._api) : super(const ReceiptsState());

  Future<ScanResult?> scan(File imageFile) async {
    state = state.copyWith(isScanning: true, clearError: true);
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      final res = await _api.dio.post('/receipts/scan', data: formData);
      final result = ScanResult.fromJson(res.data as Map<String, dynamic>);
      if (mounted) state = state.copyWith(isScanning: false, lastScan: result);
      return result;
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?.containsKey('detail') == true
          ? e.response!.data['detail'] as String
          : 'Fiş taranamadı. Tekrar deneyin.';
      if (mounted) state = state.copyWith(isScanning: false, error: msg);
      return null;
    } catch (_) {
      if (mounted) state = state.copyWith(isScanning: false, error: 'Beklenmeyen bir hata oluştu.');
      return null;
    }
  }

  Future<void> updateExpense(
    String expenseId, {
    required double amount,
    String? categoryId,
    String? merchant,
    String? note,
    String? spentAt,
  }) async {
    await _api.dio.patch('/expenses/$expenseId', data: {
      'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (merchant != null) 'merchant': merchant,
      if (note != null) 'note': note,
      if (spentAt != null) 'spent_at': spentAt,
    });
  }

  Future<void> updateAllExpenses(List<ScannedItem> items) async {
    await Future.wait(items.map((item) => _api.dio.patch(
      '/expenses/${item.expenseId}',
      data: {
        'amount': item.amount,
        'merchant': item.name,
        if (item.categoryId != null) 'category_id': item.categoryId,
      },
    )));
  }

  void reset() {
    if (mounted) state = const ReceiptsState();
  }
}
