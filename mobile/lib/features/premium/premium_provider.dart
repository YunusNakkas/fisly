import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/billing/billing_service.dart';

/// Kullanıcının premium entitlement'a sahip olup olmadığını canlı tutar.
/// Kaynak: RevenueCat CustomerInfo (anlık UX). Backend planı webhook ile senkronlanır.
final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  final notifier = PremiumNotifier();
  notifier.init();
  return notifier;
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false);

  void init() {
    if (!billingEnabled) return;
    Purchases.addCustomerInfoUpdateListener(_apply);
    refresh();
  }

  void _apply(CustomerInfo info) {
    if (!mounted) return;
    state = info.entitlements.active.containsKey(premiumEntitlementId);
  }

  Future<void> refresh() async {
    if (!billingEnabled) return;
    try {
      _apply(await Purchases.getCustomerInfo());
    } catch (_) {}
  }

  @override
  void dispose() {
    if (billingEnabled) {
      Purchases.removeCustomerInfoUpdateListener(_apply);
    }
    super.dispose();
  }
}
