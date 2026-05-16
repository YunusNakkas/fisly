import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

class Budget {
  final String id;
  final String? categoryId;
  final double amount;
  final String period;
  final String startsOn;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startsOn,
  });

  factory Budget.fromJson(Map<String, dynamic> j) => Budget(
        id: j['id'] as String,
        categoryId: j['category_id'] as String?,
        amount: double.parse(j['amount'].toString()),
        period: j['period'] as String,
        startsOn: j['starts_on'] as String,
      );
}

class BudgetProgress {
  final String budgetId;
  final String? categoryId;
  final String? categoryName;
  final double amount;
  final double spent;
  final double remaining;
  final double percent;

  const BudgetProgress({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.spent,
    required this.remaining,
    required this.percent,
  });

  factory BudgetProgress.fromJson(Map<String, dynamic> j) => BudgetProgress(
        budgetId: j['budget_id'] as String,
        categoryId: j['category_id'] as String?,
        categoryName: j['category_name'] as String?,
        amount: double.parse(j['amount'].toString()),
        spent: double.parse(j['spent'].toString()),
        remaining: double.parse(j['remaining'].toString()),
        percent: (j['percent'] as num).toDouble(),
      );
}

class BudgetsState {
  final List<Budget> items;
  final bool isLoading;
  const BudgetsState({this.items = const [], this.isLoading = false});
  BudgetsState copyWith({List<Budget>? items, bool? isLoading}) =>
      BudgetsState(items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
}

final budgetsProvider = StateNotifierProvider<BudgetsNotifier, BudgetsState>((ref) {
  return BudgetsNotifier(ref.read(apiClientProvider));
});

class BudgetsNotifier extends StateNotifier<BudgetsState> {
  final ApiClient _api;
  BudgetsNotifier(this._api) : super(const BudgetsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _api.dio.get('/budgets');
      if (!mounted) return;
      final items = (res.data as List)
          .map((e) => Budget.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> add({
    required String amount,
    required String period,
    String? categoryId,
  }) async {
    await _api.dio.post('/budgets', data: {
      'amount': double.parse(amount.replaceAll(',', '.')),
      'period': period,
      if (categoryId != null) 'category_id': categoryId,
    });
    await load();
  }

  Future<void> update({required String id, required String amount}) async {
    await _api.dio.patch('/budgets/$id', data: {
      'amount': double.parse(amount.replaceAll(',', '.')),
    });
    await load();
  }

  Future<void> remove(String id) async {
    final prev = state.items;
    state = state.copyWith(items: prev.where((b) => b.id != id).toList());
    try {
      await _api.dio.delete('/budgets/$id');
    } catch (_) {
      if (mounted) state = state.copyWith(items: prev);
      rethrow;
    }
  }
}

final budgetsProgressProvider = FutureProvider.autoDispose<List<BudgetProgress>>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get('/budgets/progress');
  return (res.data as List)
      .map((e) => BudgetProgress.fromJson(e as Map<String, dynamic>))
      .toList();
});
