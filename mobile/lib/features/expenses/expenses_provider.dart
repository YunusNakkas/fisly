import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

class ExpensesState {
  final List<Map<String, dynamic>> expenses;
  final bool isLoading;
  final DateTime month;

  ExpensesState({
    this.expenses = const [],
    this.isLoading = false,
    DateTime? month,
  }) : month = month ?? DateTime(DateTime.now().year, DateTime.now().month);

  ExpensesState copyWith({
    List<Map<String, dynamic>>? expenses,
    bool? isLoading,
    DateTime? month,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      month: month ?? this.month,
    );
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, ExpensesState>((ref) {
  return ExpensesNotifier(ref.read(apiClientProvider));
});

class ExpensesNotifier extends StateNotifier<ExpensesState> {
  final ApiClient _api;

  ExpensesNotifier(this._api) : super(ExpensesState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final from = state.month;
    final to = DateTime(from.year, from.month + 1, 1);
    try {
      final res = await _api.dio.get('/expenses', queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      });
      if (!mounted) return;
      state = state.copyWith(
        expenses: List<Map<String, dynamic>>.from(res.data),
        isLoading: false,
      );
    } catch (_) {
      // 401 olursa interceptor refresh denedi; başarısızsa auth state anonymous olur
      // ve router /login'e yönlendirir. Burada sadece isLoading'i kapatıyoruz.
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setMonth(DateTime month) async {
    state = state.copyWith(month: DateTime(month.year, month.month));
    await load();
  }

  Future<void> add({
    required String amount,
    String? categoryId,
    String? merchant,
    String? note,
  }) async {
    await _api.dio.post('/expenses', data: {
      'amount': double.parse(amount.replaceAll(',', '.')),
      'category_id': categoryId,
      'merchant': merchant,
      'note': note,
      'currency': 'TRY',
    });
    await load();
  }

  Future<void> update(
    String id, {
    required String amount,
    String? categoryId,
    String? merchant,
    String? note,
    DateTime? spentAt,
  }) async {
    await _api.dio.patch('/expenses/$id', data: {
      'amount': double.parse(amount.replaceAll(',', '.')),
      'category_id': categoryId,
      'merchant': merchant,
      'note': note,
      if (spentAt != null) 'spent_at': spentAt.toUtc().toIso8601String(),
    });
    await load();
  }

  Future<void> delete(String id) async {
    state = state.copyWith(
      expenses: state.expenses.where((e) => e['id'] != id).toList(),
    );
    await _api.dio.delete('/expenses/$id');
  }

  void removeOptimistic(String id) {
    if (mounted) {
      state = state.copyWith(
        expenses: state.expenses.where((e) => e['id'] != id).toList(),
      );
    }
  }

  void undoRemove(Map<String, dynamic> expense) {
    if (!mounted) return;
    final updated = [...state.expenses, expense]
      ..sort((a, b) => (b['spent_at'] as String).compareTo(a['spent_at'] as String));
    state = state.copyWith(expenses: updated);
  }

  Future<void> confirmRemove(String id) async {
    try {
      await _api.dio.delete('/expenses/$id');
    } catch (_) {
      // Sessizce başarısız ol; kullanıcı pull-to-refresh ile senkronize edebilir
    }
  }
}
