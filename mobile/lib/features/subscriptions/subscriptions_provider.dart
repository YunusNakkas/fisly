import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

class Subscription {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final String period;
  final String nextBillingDate;
  final String status;
  final String? categoryId;

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.period,
    required this.nextBillingDate,
    required this.status,
    required this.categoryId,
  });

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
        id: j['id'] as String,
        name: j['name'] as String,
        amount: double.parse(j['amount'].toString()),
        currency: j['currency'] as String,
        period: j['period'] as String,
        nextBillingDate: j['next_billing_date'] as String,
        status: j['status'] as String,
        categoryId: j['category_id'] as String?,
      );

  String get periodLabel => switch (period) {
        'monthly' => 'Aylık',
        'yearly' => 'Yıllık',
        'weekly' => 'Haftalık',
        _ => period,
      };
}

class SubscriptionsState {
  final List<Subscription> items;
  final bool isLoading;
  const SubscriptionsState({this.items = const [], this.isLoading = false});
  SubscriptionsState copyWith({List<Subscription>? items, bool? isLoading}) =>
      SubscriptionsState(items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
}

final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, SubscriptionsState>((ref) {
  return SubscriptionsNotifier(ref.read(apiClientProvider));
});

class SubscriptionsNotifier extends StateNotifier<SubscriptionsState> {
  final ApiClient _api;
  SubscriptionsNotifier(this._api) : super(const SubscriptionsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _api.dio.get('/subscriptions');
      if (!mounted) return;
      final items = (res.data as List)
          .map((e) => Subscription.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> add({
    required String name,
    required String amount,
    required String period,
    required String startDate,
    required String nextBillingDate,
    String? categoryId,
  }) async {
    await _api.dio.post('/subscriptions', data: {
      'name': name,
      'amount': double.parse(amount.replaceAll(',', '.')),
      'currency': 'TRY',
      'period': period,
      'start_date': startDate,
      'next_billing_date': nextBillingDate,
      if (categoryId != null) 'category_id': categoryId,
    });
    await load();
  }

  Future<void> update({
    required String id,
    required String name,
    required String amount,
    required String nextBillingDate,
    String? categoryId,
  }) async {
    await _api.dio.patch('/subscriptions/$id', data: {
      'name': name,
      'amount': double.parse(amount.replaceAll(',', '.')),
      'next_billing_date': nextBillingDate,
      if (categoryId != null) 'category_id': categoryId,
    });
    await load();
  }

  Future<void> cancel(String id) async {
    await _api.dio.post('/subscriptions/$id/cancel');
    await load();
  }

  Future<void> remove(String id) async {
    final prev = state.items;
    state = state.copyWith(items: prev.where((s) => s.id != id).toList());
    try {
      await _api.dio.delete('/subscriptions/$id');
    } catch (_) {
      if (mounted) state = state.copyWith(items: prev);
      rethrow;
    }
  }
}
