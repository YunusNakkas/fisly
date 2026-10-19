import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/profile_provider.dart';
import '../../../core/api/media_url.dart';
import '../../../shared/section_label.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/localized_copy.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: Text(t.profileTitle, style: AppTypography.titleLg)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.colors.danger),
              const SizedBox(height: 12),
              Text(t.commonError, style: AppTypography.bodyLg),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: Text(t.actionRetry),
              ),
            ],
          ),
        ),
        data: (p) {
          final displayName =
              (p.fullName != null && p.fullName!.trim().isNotEmpty)
              ? p.fullName!
              : p.email.split('@').first;
          final initial = displayName.isNotEmpty
              ? displayName.substring(0, 1).toUpperCase()
              : '?';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Avatar + name section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      _EditableAvatar(initial: initial, avatarUrl: p.avatarUrl),
                      const SizedBox(height: 12),
                      Text(displayName, style: AppTypography.titleLg),
                      const SizedBox(height: 2),
                      Text(p.email, style: AppTypography.caption),
                    ],
                  ),
                ),
              ),
              SectionLabel(t.profileSubtitle),
              _InfoCard(
                rows: [
                  _InfoRow(
                    label: t.profileFullNameLabel,
                    value: p.fullName ?? '—',
                    onEdit: () => _showEditNameSheet(context, ref, p.fullName),
                  ),
                  _InfoRow(label: t.profileEmailLabel, value: p.email),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showChangePasswordSheet(context, ref),
                  icon: const Icon(Icons.lock_outline),
                  label: Text(t.settingsPasswordChange),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditNameSheet(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController(text: current ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

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
        child: StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setState(() => saving = true);
              try {
                await ref
                    .read(profileUpdaterProvider)
                    .updateName(controller.text.trim());
                ref.invalidate(profileProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(t.profileSaved)));
                }
              } catch (e) {
                if (ctx.mounted) {
                  setState(() => saving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.profileSaveFailed),
                      backgroundColor: context.colors.danger,
                    ),
                  );
                }
              }
            }

            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.profileFullNameLabel, style: AppTypography.titleLg),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: t.profileFullNameLabel,
                    ),
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? t.validationNameRequired
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: saving ? null : save,
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(t.profileSaveAction),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;
    bool obscureCurrent = true;
    bool obscureNew = true;

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
        child: StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setState(() => saving = true);
              try {
                await ref
                    .read(profileUpdaterProvider)
                    .changePassword(
                      currentPassword: currentCtrl.text,
                      newPassword: newCtrl.text,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.passwordChangeSuccess)),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  setState(() => saving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.passwordChangeFailed),
                      backgroundColor: context.colors.danger,
                    ),
                  );
                }
              }
            }

            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.passwordChangeTitle, style: AppTypography.titleLg),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: currentCtrl,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: t.passwordChangeCurrent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                    validator: (v) => (v?.isEmpty ?? true)
                        ? t.validationPasswordRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: t.passwordChangeNew,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscureNew = !obscureNew),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return t.validationPasswordMin6;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: t.passwordChangeConfirm,
                    ),
                    validator: (v) =>
                        v != newCtrl.text ? t.passwordChangeMismatch : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: saving ? null : save,
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(t.passwordChangeSubmit),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;
  const _InfoRow({required this.label, required this.value, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              Icon(Icons.edit_outlined, size: 18, color: context.colors.textLo),
          ],
        ),
      ),
    );
  }
}

// ─── Editable avatar (galeriden fotoğraf seç + yükle) ──────────────
class _EditableAvatar extends ConsumerStatefulWidget {
  final String initial;
  final String? avatarUrl;
  const _EditableAvatar({required this.initial, required this.avatarUrl});

  @override
  ConsumerState<_EditableAvatar> createState() => _EditableAvatarState();
}

class _EditableAvatarState extends ConsumerState<_EditableAvatar> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    if (_uploading) return;
    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final denied = e.code == 'photo_access_denied';
      _snack(denied
          ? copyForLocale(context,
              en: 'Photo access is denied. Enable it in Settings.',
              tr: 'Fotoğraf erişimi reddedildi. Ayarlar’dan izin ver.')
          : AppLocalizations.of(context).commonError);
      return;
    }
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      await ref.read(profileUpdaterProvider).uploadAvatar(File(picked.path));
      ref.invalidate(profileProvider);
      if (mounted) {
        _snack(copyForLocale(context,
            en: 'Profile photo updated', tr: 'Profil fotoğrafı güncellendi'));
      }
    } catch (_) {
      if (mounted) {
        _snack(copyForLocale(context,
            en: 'Could not upload photo. Please try again.',
            tr: 'Fotoğraf yüklenemedi. Lütfen tekrar dene.'));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final url = absoluteMediaUrl(widget.avatarUrl);
    return GestureDetector(
      onTap: _pickAndUpload,
      child: Stack(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.colors.primary, context.colors.primaryDim],
              ),
              image: (url != null && url.isNotEmpty)
                  ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                  : null,
            ),
            child: (url == null || url.isEmpty)
                ? Center(
                    child: Text(
                      widget.initial,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          if (_uploading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.surface,
                border: Border.all(color: context.colors.bg, width: 2),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
