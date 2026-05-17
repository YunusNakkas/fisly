import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../feedback_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  FeedbackKind _kind = FeedbackKind.suggestion;
  bool _saving = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.colors.danger;
    final t = AppLocalizations.of(context);
    try {
      await ref
          .read(feedbackSubmitProvider)
          .submit(
            kind: _kind,
            subject: _subjectController.text.trim(),
            message: _messageController.text.trim(),
          );
      messenger.showSnackBar(SnackBar(content: Text(t.feedbackSent)));
      if (!mounted) return;
      context.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(t.feedbackFailed), backgroundColor: danger),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _kindLabel(AppLocalizations t, FeedbackKind k) => switch (k) {
    FeedbackKind.bug => t.feedbackTypeBug,
    FeedbackKind.suggestion => t.feedbackTypeFeature,
    FeedbackKind.complaint => t.feedbackTypeComplaint,
    FeedbackKind.other => t.feedbackTypeOther,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text(t.feedbackTitle, style: AppTypography.titleLg),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(
              t.feedbackTypeLabel,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textMid,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FeedbackKind.values.map((k) {
                final selected = _kind == k;
                final (icon, color) = _kindStyle(k);
                return InkWell(
                  onTap: () => setState(() => _kind = k),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.12)
                          : context.colors.surface,
                      border: Border.all(
                        color: selected ? color : context.colors.outline,
                        width: selected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 14, color: color),
                        const SizedBox(width: 6),
                        Text(
                          _kindLabel(t, k),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? color : context.colors.textHi,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: t.feedbackSubjectLabel),
              validator: (v) => (v?.trim().isEmpty ?? true)
                  ? t.feedbackSubjectRequired
                  : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: t.feedbackMessageLabel,
                alignLabelWithHint: true,
              ),
              minLines: 5,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v?.trim().isEmpty ?? true)
                  ? t.feedbackMessageRequired
                  : null,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(t.feedbackSubmit),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.feedbackFooter,
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _kindStyle(FeedbackKind k) => switch (k) {
    FeedbackKind.bug => (Icons.bolt, AppColors.danger),
    FeedbackKind.suggestion => (Icons.auto_awesome, const Color(0xFF8B5CF6)),
    FeedbackKind.complaint => (Icons.error_outline, AppColors.warn),
    FeedbackKind.other => (Icons.chat_bubble_outline, AppColors.textMid),
  };
}
