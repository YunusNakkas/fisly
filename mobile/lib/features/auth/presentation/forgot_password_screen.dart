import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .forgotPassword(_emailController.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        setState(() => _error = t.commonError);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        title: Text(t.loginForgotPassword, style: AppTypography.titleLg),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: context.colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.lg + 4),
                  ),
                  child: Center(
                    child: Icon(
                      _sent
                          ? Icons.mark_email_read_outlined
                          : Icons.mail_lock_outlined,
                      size: 32,
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _sent ? t.forgotSent : t.forgotTitle,
                  style: AppTypography.displaySm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _sent ? t.forgotSentDescription : t.forgotSubtitle,
                  style: AppTypography.bodyLg.copyWith(
                    color: context.colors.textMid,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (!_sent) ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enabled: !_submitting,
                    decoration: InputDecoration(
                      labelText: t.loginEmail,
                      hintText: 'ornek@mail.com',
                    ),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return t.validationEmailRequired;
                      if (!s.contains('@') || !s.contains('.')) {
                        return t.validationEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: AppTypography.bodyMd.copyWith(
                        color: context.colors.danger,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(t.forgotSubmit),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md + 2),
                    ),
                    child: Text(
                      t.forgotHint,
                      style: AppTypography.bodySm.copyWith(
                        color: context.colors.textMid,
                        height: 1.5,
                      ),
                    ),
                  ),
                ] else ...[
                  FilledButton(
                    onPressed: () => context.go('/reset-password'),
                    child: Text(t.forgotResetWithToken),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/login'),
                    child: Text(t.forgotBackToLogin),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
