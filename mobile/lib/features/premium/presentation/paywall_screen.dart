import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/billing/billing_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/localized_copy.dart';
import '../premium_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<Package> _packages = [];
  bool _loading = true;
  bool _purchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    if (!billingEnabled) {
      setState(() {
        _loading = false;
        _error = copyForLocale(
          context,
          en: 'In-app purchases are not available right now.',
          tr: 'Uygulama içi satın alma şu an kullanılamıyor.',
        );
      });
      return;
    }
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? [];
      setState(() {
        _packages = packages;
        _loading = false;
        _error = packages.isEmpty
            ? copyForLocale(
                context,
                en: 'No subscription plans found.',
                tr: 'Abonelik planı bulunamadı.',
              )
            : null;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = copyForLocale(
          context,
          en: 'Could not load plans. Please try again.',
          tr: 'Planlar yüklenemedi. Lütfen tekrar dene.',
        );
      });
    }
  }

  Future<void> _purchase(Package pkg) async {
    setState(() => _purchasing = true);
    try {
      await Purchases.purchasePackage(pkg);
      await ref.read(premiumProvider.notifier).refresh();
      if (!mounted) return;
      if (ref.read(premiumProvider)) {
        context.pop();
        _snack(copyForLocale(context, en: 'Welcome to Premium!', tr: 'Premium aktif!'));
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError && mounted) {
        _snack(copyForLocale(
          context,
          en: 'Purchase failed. Please try again.',
          tr: 'Satın alma başarısız. Lütfen tekrar dene.',
        ));
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      await Purchases.restorePurchases();
      await ref.read(premiumProvider.notifier).refresh();
      if (!mounted) return;
      final premium = ref.read(premiumProvider);
      _snack(premium
          ? copyForLocale(context, en: 'Purchases restored.', tr: 'Satın alımlar geri yüklendi.')
          : copyForLocale(context, en: 'No active subscription found.', tr: 'Aktif abonelik bulunamadı.'));
      if (premium) context.pop();
    } catch (_) {
      if (mounted) {
        _snack(copyForLocale(context, en: 'Could not restore.', tr: 'Geri yüklenemedi.'));
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text(
          copyForLocale(context, en: 'Fişly Premium', tr: 'Fişly Premium'),
          style: AppTypography.titleLg,
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  Text(
                    copyForLocale(
                      context,
                      en: 'Unlock the full Fişly experience',
                      tr: 'Fişly’nin tamamının kilidini aç',
                    ),
                    style: AppTypography.displaySm.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  const _Benefit(tr: 'Sınırsız fiş tarama', en: 'Unlimited receipt scans'),
                  const _Benefit(tr: 'Detaylı raporlar ve içgörüler', en: 'Detailed reports & insights'),
                  const _Benefit(tr: 'Reklamsız deneyim', en: 'Ad-free experience'),
                  const _Benefit(tr: 'Öncelikli destek', en: 'Priority support'),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Text(_error!, style: AppTypography.bodyMd.copyWith(color: context.colors.danger))
                  else
                    ..._packages.map((p) => _PlanCard(
                          package: p,
                          enabled: !_purchasing,
                          onTap: () => _purchase(p),
                        )),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _purchasing ? null : _restore,
                    child: Text(
                      copyForLocale(context, en: 'Restore purchases', tr: 'Satın alımları geri yükle'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    copyForLocale(
                      context,
                      en: 'Subscription renews automatically until cancelled. '
                          'Manage it from your store account.',
                      tr: 'Abonelik iptal edilene kadar otomatik yenilenir. '
                          'Mağaza hesabından yönetebilirsin.',
                    ),
                    style: AppTypography.caption.copyWith(color: context.colors.textLo),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final String tr;
  final String en;
  const _Benefit({required this.tr, required this.en});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 20, color: context.colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              copyForLocale(context, en: en, tr: tr),
              style: AppTypography.bodyLg,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Package package;
  final bool enabled;
  final VoidCallback onTap;
  const _PlanCard({required this.package, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final isAnnual = package.packageType == PackageType.annual;
    final title = isAnnual
        ? copyForLocale(context, en: 'Yearly', tr: 'Yıllık')
        : copyForLocale(context, en: 'Monthly', tr: 'Aylık');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg + 2),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg + 2),
              border: Border.all(
                color: isAnnual
                    ? context.colors.primary
                    : context.colors.outline,
                width: isAnnual ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AppTypography.titleMd),
                          if (isAnnual) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: context.colors.primaryContainer,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                copyForLocale(context, en: 'Best value', tr: 'En avantajlı'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(product.priceString, style: AppTypography.bodyLg),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colors.textLo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
