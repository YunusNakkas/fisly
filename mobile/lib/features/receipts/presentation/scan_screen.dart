import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../receipts_provider.dart';
import '../../categories/categories_provider.dart';
import '../../auth/profile_provider.dart';
import '../../../shared/category_chip_picker.dart';
import '../../../shared/category_icons.dart';
import '../../../shared/section_label.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/localized_copy.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  ScanResult? _scanResult;
  bool _saving = false;

  Future<void> _pickAndScan(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null) return;

    final result = await ref
        .read(receiptsProvider.notifier)
        .scan(File(picked.path));
    if (!mounted) return;

    if (result == null) {
      final error = ref.read(receiptsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? AppLocalizations.of(context).commonError),
          backgroundColor: context.colors.danger,
        ),
      );
      return;
    }

    setState(() => _scanResult = result);
    ref.invalidate(profileProvider);
  }

  Future<void> _saveAll() async {
    if (_scanResult == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(receiptsProvider.notifier)
          .updateAllExpenses(_scanResult!.expenses);
      if (mounted) {
        ref.read(receiptsProvider.notifier).reset();
        context.go('/expenses');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).expensesSaved)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).expensesSaveFailed),
            backgroundColor: context.colors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _editItem(ScannedItem item) {
    final nameController = TextEditingController(text: item.name);
    final amountController = TextEditingController(
      text: item.amount.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                copyForLocale(context, en: 'Edit Item', tr: 'Kalemi Düzenle'),
                style: AppTypography.titleLg,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).scanItemNameLabel,
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) {
                    return AppLocalizations.of(context).commonRequired;
                  }
                  if (t.length > 255) {
                    return copyForLocale(
                      context,
                      en: 'Maximum 255 characters',
                      tr: 'En fazla 255 karakter',
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).expensesAmount,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  final d = double.tryParse(
                    (v?.trim() ?? '').replaceAll(',', '.'),
                  );
                  if (d == null) {
                    return AppLocalizations.of(context).validationAmountInvalid;
                  }
                  if (d <= 0) {
                    return AppLocalizations.of(
                      context,
                    ).validationAmountPositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  setState(() {
                    item.name = nameController.text.trim();
                    item.amount = double.parse(
                      amountController.text.trim().replaceAll(',', '.'),
                    );
                  });
                  Navigator.pop(sheetCtx);
                },
                child: Text(AppLocalizations.of(context).actionSave),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanning = ref.watch(receiptsProvider).isScanning;

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text(
          scanning
              ? AppLocalizations.of(context).scanProcessing
              : AppLocalizations.of(context).scanTitle,
          style: AppTypography.titleLg,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/expenses'),
        ),
      ),
      body: scanning
          ? const _ScanningView()
          : _scanResult == null
          ? _PickerView(onPick: _pickAndScan)
          : _ResultView(
              result: _scanResult!,
              onItemTap: _editItem,
              onCategoryChanged: (item, catId, catName) {
                setState(() {
                  item.categoryId = catId;
                  item.categoryName = catName;
                });
              },
              onRescan: () => setState(() => _scanResult = null),
              onSave: _saveAll,
              saving: _saving,
            ),
    );
  }
}

// ─── Picker view ───────────────────────────────────────────────────
class _PickerView extends ConsumerWidget {
  final void Function(ImageSource) onPick;
  const _PickerView({required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;
    final atLimit = profile?.isAtQuotaLimit ?? false;

    return Column(
      children: [
        if (profile != null && profile.quotaLimit != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: _QuotaBanner(
              used: profile.quotaUsed,
              limit: profile.quotaLimit!,
              atLimit: atLimit,
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _BigReceiptIllustration(),
                const SizedBox(height: 22),
                Text(
                  copyForLocale(
                    context,
                    en: 'Scan your receipt\nor pick from gallery',
                    tr: 'Fişini tara veya\ngaleriden seç',
                  ),
                  textAlign: TextAlign.center,
                  style: AppTypography.displaySm.copyWith(
                    fontSize: 24,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  copyForLocale(
                    context,
                    en: 'Gemini AI will read your receipt in seconds and categorize the items.',
                    tr: 'Gemini yapay zekâ fişini saniyeler içinde okuyup ürünleri kategorilere ayıracak.',
                  ),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: context.colors.textMid,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md + 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: context.colors.textMid,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        copyForLocale(
                          context,
                          en: 'Your photos are only used for reading receipts.',
                          tr: 'Fotoğrafların sadece okuma için kullanılır.',
                        ),
                        style: AppTypography.caption.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: atLimit ? null : () => onPick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(AppLocalizations.of(context).scanCameraAction),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: atLimit ? null : () => onPick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(AppLocalizations.of(context).scanGalleryAction),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BigReceiptIllustration extends StatelessWidget {
  const _BigReceiptIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        children: [
          // Dotted ring decoration
          Positioned.fill(
            child: CustomPaint(
              painter: _DottedCirclePainter(
                color: context.colors.primaryContainer,
              ),
            ),
          ),
          // Mock receipt card
          Positioned(
            left: 40,
            top: 24,
            child: Container(
              width: 80,
              height: 110,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.colors.outline, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _line(0.6, context.colors.outline, 4),
                  const SizedBox(height: 4),
                  _line(0.8, context.colors.outlineSoft, 3),
                  const SizedBox(height: 4),
                  _line(0.7, context.colors.outlineSoft, 3),
                  const SizedBox(height: 6),
                  Container(height: 1, color: context.colors.outline),
                  const SizedBox(height: 6),
                  _line(0.85, context.colors.outlineSoft, 3),
                  const SizedBox(height: 4),
                  _line(0.6, context.colors.outlineSoft, 3),
                  const SizedBox(height: 4),
                  _line(0.75, context.colors.outlineSoft, 3),
                  const SizedBox(height: 6),
                  Container(height: 1, color: context.colors.outline),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _line(0.55, context.colors.primary, 5),
                  ),
                ],
              ),
            ),
          ),
          // Sparkle accent
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.45),
                    offset: const Offset(0, 6),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(double fraction, Color color, double height) {
    return FractionallySizedBox(
      widthFactor: fraction,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;
  _DottedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final r = size.width / 2 - 4;
    const dashWidth = 2.0;
    const dashGap = 6.0;
    final circumference = 2 * 3.1415926 * r;
    final dashCount = (circumference / (dashWidth + dashGap)).floor();
    for (int i = 0; i < dashCount; i++) {
      final start = (i * (dashWidth + dashGap)) / r;
      final end = start + dashWidth / r;
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: r,
        ),
        start - 3.1415926 / 2,
        end - start,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DottedCirclePainter old) => old.color != color;
}

// ─── Quota banner ──────────────────────────────────────────────────
class _QuotaBanner extends StatelessWidget {
  final int used;
  final int limit;
  final bool atLimit;

  const _QuotaBanner({
    required this.used,
    required this.limit,
    required this.atLimit,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final Color color;
    if (atLimit) {
      color = context.colors.danger;
    } else if (fraction >= 0.8) {
      color = context.colors.warn;
    } else {
      color = context.colors.ok;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bu ay tarama kotan',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textMid,
                ),
              ),
              Text(
                '$used/$limit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm / 2),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (atLimit) ...[
            const SizedBox(height: 6),
            Text(
              copyForLocale(
                context,
                en: 'Upgrade to Premium for unlimited scans.',
                tr: 'Premium’a geçerek sınırsız tarama yapabilirsin.',
              ),
              style: AppTypography.caption.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Scanning view (animated steps) ────────────────────────────────
class _ScanningView extends StatefulWidget {
  const _ScanningView();

  @override
  State<_ScanningView> createState() => _ScanningViewState();
}

class _ScanningViewState extends State<_ScanningView> {
  int _step = 0;
  Timer? _timer;

  final _steps = const ['uploading', 'extracting', 'parsing', 'assigning'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      setState(() {
        if (_step < _steps.length - 1) _step++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _ScanBeamMock(),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              children: [
                for (int i = 0; i < _steps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _ProgressStep(
                    label: _stepLabel(context, _steps[i]),
                    status: i < _step
                        ? _StepStatus.done
                        : (i == _step
                              ? _StepStatus.active
                              : _StepStatus.pending),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 12, color: context.colors.primary),
              const SizedBox(width: 6),
              Text(
                'Gemini Vision · ~3 sn',
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  color: context.colors.textLo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _stepLabel(BuildContext context, String step) => switch (step) {
    'uploading' => copyForLocale(
      context,
      en: 'Uploading image',
      tr: 'Görüntü yükleniyor',
    ),
    'extracting' => copyForLocale(
      context,
      en: 'Extracting text',
      tr: 'Metin çıkarılıyor',
    ),
    'parsing' => copyForLocale(
      context,
      en: 'Parsing items',
      tr: 'Ürünler ayrıştırılıyor',
    ),
    'assigning' => copyForLocale(
      context,
      en: 'Assigning categories',
      tr: 'Kategoriler atanıyor',
    ),
    _ => step,
  };
}

class _ScanBeamMock extends StatefulWidget {
  const _ScanBeamMock();

  @override
  State<_ScanBeamMock> createState() => _ScanBeamMockState();
}

class _ScanBeamMockState extends State<_ScanBeamMock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 280,
      child: Stack(
        children: [
          // Mock receipt
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF7),
                border: Border.all(color: context.colors.outline),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33141E1E),
                    offset: Offset(0, 16),
                    blurRadius: 38,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BİM A.Ş.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.textMid,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '16.05.2026 18:32',
                    style: TextStyle(fontSize: 9, color: AppColors.textLo),
                  ),
                  const SizedBox(height: 8),
                  for (final w in [0.9, 0.7, 0.85, 0.6, 0.75, 0.55, 0.8])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: FractionallySizedBox(
                        widthFactor: w,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.outline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Beam
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) {
              final top = 10 + _ctrl.value * 240;
              return Positioned(
                left: 8,
                right: 8,
                top: top,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0x005B5BD6),
                        AppColors.primary,
                        Color(0x005B5BD6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Corner markers
          ..._corners(),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const side = BorderSide(color: AppColors.primary, width: 3);
    return [
      Positioned(
        left: -4,
        top: -4,
        child: SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: side, left: side),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        right: -4,
        top: -4,
        child: SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: side, right: side),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: -4,
        bottom: -4,
        child: SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: side, left: side),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        right: -4,
        bottom: -4,
        child: SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: side, right: side),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

enum _StepStatus { done, active, pending }

class _ProgressStep extends StatelessWidget {
  final String label;
  final _StepStatus status;
  const _ProgressStep({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case _StepStatus.done:
        color = AppColors.ok;
        break;
      case _StepStatus.active:
        color = AppColors.primary;
        break;
      case _StepStatus.pending:
        color = AppColors.textLo;
        break;
    }

    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: status == _StepStatus.pending
                ? AppColors.surfaceContainer
                : color,
            shape: BoxShape.circle,
            border: status == _StepStatus.pending
                ? Border.all(color: AppColors.outline, width: 1.5)
                : null,
          ),
          child: status == _StepStatus.done
              ? const Icon(Icons.check, size: 11, color: Colors.white)
              : status == _StepStatus.active
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: status == _StepStatus.pending
                ? AppColors.textLo
                : AppColors.textHi,
          ),
        ),
      ],
    );
  }
}

// ─── Result view ───────────────────────────────────────────────────
class _ResultView extends ConsumerWidget {
  final ScanResult result;
  final void Function(ScannedItem) onItemTap;
  final void Function(ScannedItem, String?, String?) onCategoryChanged;
  final VoidCallback onRescan;
  final VoidCallback onSave;
  final bool saving;

  const _ResultView({
    required this.result,
    required this.onItemTap,
    required this.onCategoryChanged,
    required this.onRescan,
    required this.onSave,
    required this.saving,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    final categoryById = <String, Category>{
      for (final c in categories) c.id: c,
    };

    final total = result.expenses.fold<double>(0, (sum, e) => sum + e.amount);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          children: [
            _MerchantHeader(
              merchant:
                  result.merchant ??
                  copyForLocale(context, en: 'Unknown', tr: 'Bilinmiyor'),
              itemCount: result.expenses.length,
              date: result.receiptDate,
            ),
            const SizedBox(height: 16),
            SectionLabel(
              copyForLocale(
                context,
                en: 'Detected items',
                tr: 'Tespit edilen ürünler',
              ),
            ),
            _ItemsCard(
              items: result.expenses,
              categories: categories,
              categoryById: categoryById,
              onTap: onItemTap,
              onCategoryChanged: onCategoryChanged,
            ),
            const SizedBox(height: 16),
            _TotalCard(total: total),
          ],
        ),
        // Sticky bottom action bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.bg,
                  AppColors.bg,
                  AppColors.bg.withValues(alpha: 0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onRescan,
                    icon: const Icon(Icons.replay, size: 18),
                    label: Text(
                      copyForLocale(context, en: 'Rescan', tr: 'Yeniden'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: saving ? null : onSave,
                      icon: saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(AppLocalizations.of(context).scanSaveAll),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MerchantHeader extends StatelessWidget {
  final String merchant;
  final int itemCount;
  final String? date;

  const _MerchantHeader({
    required this.merchant,
    required this.itemCount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md + 2),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant,
                  style: AppTypography.titleMd.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (date != null) _displayDate(context, date!),
                    copyForLocale(
                      context,
                      en: '$itemCount items',
                      tr: '$itemCount ürün',
                    ),
                  ].join(' · '),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 11,
                  color: AppColors.onPrimaryContainer,
                ),
                const SizedBox(width: 3),
                Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayDate(BuildContext context, String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')} ${monthName(context, d.month)} ${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _ItemsCard extends StatelessWidget {
  final List<ScannedItem> items;
  final List<Category> categories;
  final Map<String, Category> categoryById;
  final void Function(ScannedItem) onTap;
  final void Function(ScannedItem, String?, String?) onCategoryChanged;

  const _ItemsCard({
    required this.items,
    required this.categories,
    required this.categoryById,
    required this.onTap,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.outlineSoft),
              _ItemRow(
                item: items[i],
                category: items[i].categoryId != null
                    ? categoryById[items[i].categoryId]
                    : null,
                categories: categories,
                onTap: () => onTap(items[i]),
                onCategoryChanged: (id, name) =>
                    onCategoryChanged(items[i], id, name),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final ScannedItem item;
  final Category? category;
  final List<Category> categories;
  final VoidCallback onTap;
  final void Function(String?, String?) onCategoryChanged;

  const _ItemRow({
    required this.item,
    required this.category,
    required this.categories,
    required this.onTap,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category != null ? colorFromHex(category!.color) : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Small colored dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: catColor ?? AppColors.textLo,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _CategoryChip(
                    selectedCategory: category,
                    categories: categories,
                    onChanged: onCategoryChanged,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(_fmtTRY(item.amount), style: AppTypography.amountLg),
            const SizedBox(width: 6),
            const Icon(Icons.edit_outlined, size: 16, color: AppColors.textLo),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category? selectedCategory;
  final List<Category> categories;
  final void Function(String?, String?) onChanged;

  const _CategoryChip({
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
  });

  void _showPicker(BuildContext context) {
    String? selectedId = selectedCategory?.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).scanCategoryPickTitle,
                      style: AppTypography.titleLg,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CategoryChipPicker(
                categories: categories,
                selectedId: selectedId,
                onChanged: (id) {
                  setState(() => selectedId = id);
                  if (id == null) {
                    onChanged(null, null);
                  } else {
                    final c = categories.firstWhere((c) => c.id == id);
                    onChanged(c.id, c.name);
                  }
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = selectedCategory != null
        ? colorFromHex(selectedCategory!.color)
        : AppColors.textLo;
    final label = selectedCategory != null
        ? localizedCategoryName(context, selectedCategory!.name)
        : AppLocalizations.of(context).scanCategoryPickTitle;

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.expand_more, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              'Toplam',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(_fmtTRY(total), style: AppTypography.displaySm),
        ],
      ),
    );
  }
}

// ─── Formatters ────────────────────────────────────────────────────
String _fmt(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
    buf.write(intPart[i]);
  }
  return '${buf.toString()},${parts[1]}';
}

String _fmtTRY(double v) => '₺${_fmt(v)}';
