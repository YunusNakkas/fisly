import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../receipts_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/section_label.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/localized_copy.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final String receiptId;
  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(receiptDetailProvider(receiptId));

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).receiptDetailTitle,
          style: AppTypography.titleLg,
        ),
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
                onPressed: () =>
                    ref.invalidate(receiptDetailProvider(receiptId)),
                child: Text(AppLocalizations.of(context).actionRetry),
              ),
            ],
          ),
        ),
        data: (receipt) => RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(receiptDetailProvider(receiptId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              _HeaderCard(receipt: receipt),
              const SizedBox(height: 18),
              SectionLabel(
                AppLocalizations.of(context).receiptDetailLinkedExpenses,
              ),
              _ExpenseList(items: receipt.expenses),
              const SizedBox(height: 18),
              SectionLabel(AppLocalizations.of(context).receiptDetailItems),
              _RawItems(items: receipt.rawItems),
              const SizedBox(height: 18),
              SectionLabel(
                copyForLocale(context, en: 'Raw OCR', tr: 'Ham OCR'),
              ),
              _RawOcr(data: receipt.rawOcrData),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ReceiptDetail receipt;
  const _HeaderCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final color = switch (receipt.status) {
      'parsed' => context.colors.ok,
      'failed' => context.colors.danger,
      'manual' => context.colors.warn,
      _ => context.colors.textMid,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.receipt_long, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.merchant ??
                          copyForLocale(
                            context,
                            en: 'Unknown receipt',
                            tr: 'Bilinmeyen fiş',
                          ),
                      style: AppTypography.titleMd,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${receiptStatusLabel(context, receipt.status)} · ${receipt.receiptDate ?? _date(receipt.createdAt)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).scanTotal,
            style: AppTypography.caption,
          ),
          const SizedBox(height: 2),
          Text(
            receipt.totalAmount == null ? '-' : _fmtTRY(receipt.totalAmount!),
            style: AppTypography.displaySm,
          ),
          const SizedBox(height: 12),
          Text(
            receipt.imageUrl,
            style: AppTypography.labelXs.copyWith(color: context.colors.textLo),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _ExpenseList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyPanel(
        copyForLocale(
          context,
          en: 'No expenses were created from this receipt',
          tr: 'Bu fişten harcama oluşmamış',
        ),
      );
    }
    return _Panel(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: Text(
              (items[i]['note'] as String?) ??
                  (items[i]['merchant'] as String?) ??
                  copyForLocale(context, en: 'Expense', tr: 'Harcama'),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(_date(items[i]['spent_at'] as String? ?? '')),
            trailing: Text(
              _fmtTRY(double.tryParse(items[i]['amount'].toString()) ?? 0),
              style: AppTypography.amountMd,
            ),
          ),
        ],
      ],
    );
  }
}

class _RawItems extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _RawItems({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyPanel(
        copyForLocale(
          context,
          en: 'No OCR items found',
          tr: 'OCR kalemi bulunamadı',
        ),
      );
    }
    return _Panel(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: Text(
              items[i]['name']?.toString() ??
                  copyForLocale(context, en: 'Item', tr: 'Kalem'),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              localizedCategoryName(
                context,
                items[i]['category']?.toString(),
                fallbackEn: 'No category',
                fallbackTr: 'Kategori yok',
              ),
            ),
            trailing: Text(_rawAmount(items[i]), style: AppTypography.amountMd),
          ),
        ],
      ],
    );
  }
}

class _RawOcr extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _RawOcr({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return _EmptyPanel(
        copyForLocale(context, en: 'No raw OCR', tr: 'Ham OCR yok'),
      );
    }
    final rows = data!.entries
        .where((entry) => entry.key != 'items')
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: SelectableText(
        rows.isEmpty
            ? copyForLocale(
                context,
                en: 'Only item data is available',
                tr: 'Sadece kalem verisi var',
              )
            : rows,
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final List<Widget> children;
  const _Panel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(children: children),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String text;
  const _EmptyPanel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: context.colors.textMid)),
      ),
    );
  }
}

String _rawAmount(Map<String, dynamic> item) {
  final value = item['total'] ?? item['unit_price'] ?? item['amount'];
  final amount = double.tryParse(value?.toString() ?? '');
  return amount == null ? '-' : _fmtTRY(amount);
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
