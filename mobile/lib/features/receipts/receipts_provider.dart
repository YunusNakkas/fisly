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

class ReceiptHistoryItem {
  final String id;
  final String? merchant;
  final double? totalAmount;
  final String? receiptDate;
  final String status;
  final String createdAt;

  const ReceiptHistoryItem({
    required this.id,
    required this.merchant,
    required this.totalAmount,
    required this.receiptDate,
    required this.status,
    required this.createdAt,
  });

  factory ReceiptHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReceiptHistoryItem(
      id: json['id'] as String,
      merchant: json['merchant'] as String?,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? ''),
      receiptDate: json['receipt_date'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

class ReceiptDetail {
  final String id;
  final String imageUrl;
  final String? merchant;
  final double? totalAmount;
  final String? receiptDate;
  final String status;
  final Map<String, dynamic>? rawOcrData;
  final String createdAt;
  final List<Map<String, dynamic>> expenses;

  const ReceiptDetail({
    required this.id,
    required this.imageUrl,
    required this.merchant,
    required this.totalAmount,
    required this.receiptDate,
    required this.status,
    required this.rawOcrData,
    required this.createdAt,
    required this.expenses,
  });

  factory ReceiptDetail.fromJson(
    Map<String, dynamic> json,
    List<Map<String, dynamic>> expenses,
  ) {
    return ReceiptDetail(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      merchant: json['merchant'] as String?,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? ''),
      receiptDate: json['receipt_date'] as String?,
      status: json['status'] as String,
      rawOcrData: json['raw_ocr_data'] as Map<String, dynamic>?,
      createdAt: json['created_at'] as String,
      expenses: expenses,
    );
  }

  List<Map<String, dynamic>> get rawItems {
    final rawItems = rawOcrData?['items'];
    if (rawItems is! List) return const [];
    return rawItems.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
}

class ReceiptsState {
  final bool isScanning;
  final String? error;
  final ScanResult? lastScan;

  const ReceiptsState({this.isScanning = false, this.error, this.lastScan});

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

final receiptsProvider = StateNotifierProvider<ReceiptsNotifier, ReceiptsState>(
  (ref) {
    return ReceiptsNotifier(ref.read(apiClientProvider));
  },
);

final receiptHistoryProvider =
    FutureProvider.autoDispose<List<ReceiptHistoryItem>>((ref) async {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.get('/receipts');
      return (res.data as List)
          .map((e) => ReceiptHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    });

final receiptDetailProvider = FutureProvider.autoDispose
    .family<ReceiptDetail, String>((ref, id) async {
      final api = ref.read(apiClientProvider);
      final responses = await Future.wait([
        api.dio.get('/receipts/$id'),
        api.dio.get('/expenses', queryParameters: {'receipt_id': id}),
      ]);
      return ReceiptDetail.fromJson(
        responses[0].data as Map<String, dynamic>,
        List<Map<String, dynamic>>.from(responses[1].data as List),
      );
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
          : 'Could not scan receipt. Try again.';
      if (mounted) state = state.copyWith(isScanning: false, error: msg);
      return null;
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          isScanning: false,
          error: 'An unexpected error occurred.',
        );
      }
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
    await _api.dio.patch(
      '/expenses/$expenseId',
      data: {
        'amount': amount,
        'category_id': ?categoryId,
        'merchant': ?merchant,
        'note': ?note,
        'spent_at': ?spentAt,
      },
    );
  }

  Future<void> updateAllExpenses(List<ScannedItem> items) async {
    await Future.wait(
      items.map(
        (item) => _api.dio.patch(
          '/expenses/${item.expenseId}',
          data: {
            'amount': item.amount,
            'merchant': item.name,
            if (item.categoryId != null) 'category_id': item.categoryId,
          },
        ),
      ),
    );
  }

  void reset() {
    if (mounted) state = const ReceiptsState();
  }
}
