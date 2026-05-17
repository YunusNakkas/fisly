import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../receipts_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/localized_copy.dart';

class ReceiptHistoryScreen extends ConsumerWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(receiptHistoryProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).receiptHistoryTitle,
          style: AppTypography.titleLg,
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).scanTitle,
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () => context.push('/scan'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).commonError,
                style: AppTypography.bodyLg,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(receiptHistoryProvider),
                child: Text(AppLocalizations.of(context).actionRetry),
              ),
            ],
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.refresh(receiptHistoryProvider.future),
          child: items.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 42,
                      color: context.colors.textLo,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        AppLocalizations.of(context).receiptHistoryEmpty,
                        style: TextStyle(color: context.colors.textMid),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _ReceiptTile(
                    item: items[i],
                    onTap: () => context.push('/receipts/${items[i].id}'),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ReceiptTile extends StatelessWidget {
  final ReceiptHistoryItem item;
  final VoidCallback onTap;
  const _ReceiptTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      'parsed' => context.colors.ok,
      'failed' => context.colors.danger,
      'manual' => context.colors.warn,
      _ => context.colors.textMid,
    };

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.receipt_long, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.merchant ??
                          copyForLocale(
                            context,
                            en: 'Unknown receipt',
                            tr: 'Bilinmeyen fiş',
                          ),
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${receiptStatusLabel(context, item.status)} · ${item.receiptDate ?? _date(item.createdAt)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.totalAmount == null ? '-' : _fmtTRY(item.totalAmount!),
                style: AppTypography.amountLg,
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: context.colors.textLo),
            ],
          ),
        ),
      ),
    );
  }
}

String _date(String raw) {
  final d = DateTime.tryParse(raw)?.toLocal();
  if (d == null) return raw;
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

String _fmtTRY(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
    buf.write(intPart[i]);
  }
  return '₺${buf.toString()},${parts[1]}';
}
