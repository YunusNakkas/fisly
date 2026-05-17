import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingDone = 'fisly_onboarding_done';

/// null = still loading from prefs, false = not done, true = done
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool?>((
  ref,
) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool?> {
  OnboardingNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) state = prefs.getBool(_kOnboardingDone) ?? false;
  }

  Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
    if (mounted) state = true;
  }
}
