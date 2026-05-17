import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

class PasswordChangeScreen extends ConsumerStatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  ConsumerState<PasswordChangeScreen> createState() =>
      _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends ConsumerState<PasswordChangeScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _saving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(profileUpdaterProvider)
          .changePassword(
            currentPassword: _currentCtrl.text,
            newPassword: _newCtrl.text,
          );
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.passwordChangeSuccess)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.passwordChangeFailed),
            backgroundColor: context.colors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pwd = _newCtrl.text;
    final checks = [
      (t.passwordCheckMin8, pwd.length >= 8),
      (t.passwordCheckUpper, RegExp(r'[A-ZÇĞİÖŞÜ]').hasMatch(pwd)),
      (t.passwordCheckDigit, RegExp(r'[0-9]').hasMatch(pwd)),
      (t.passwordCheckSpecial, RegExp(r'[^A-Za-z0-9]').hasMatch(pwd)),
    ];

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text(t.passwordChangeTitle, style: AppTypography.titleLg),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: context.colors.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.passwordHint,
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        color: context.colors.onPrimaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _currentCtrl,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: t.passwordChangeCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              validator: (v) =>
                  (v?.isEmpty ?? true) ? t.validationPasswordRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newCtrl,
              obscureText: _obscureNew,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: t.passwordChangeNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? t.validationPasswordMin6 : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: t.passwordChangeConfirm),
              validator: (v) =>
                  v != _newCtrl.text ? t.passwordChangeMismatch : null,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < checks.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _ChecklistRow(label: checks[i].$1, ok: checks[i].$2),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(t.resetSubmit),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String label;
  final bool ok;
  const _ChecklistRow({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: ok ? context.colors.ok : context.colors.surfaceContainer,
            shape: BoxShape.circle,
            border: ok ? null : Border.all(color: context.colors.outline),
          ),
          child: ok
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            fontSize: 13,
            color: ok ? context.colors.textHi : context.colors.textMid,
          ),
        ),
      ],
    );
  }
}
