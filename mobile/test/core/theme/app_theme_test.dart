import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ThemeModeNotifier loads stored dark mode', () async {
    SharedPreferences.setMockInitialValues({'fisly_theme_mode': 'dark'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('ThemeModeNotifier persists selected mode', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(themeModeProvider.notifier).setMode(ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();

    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(prefs.getString('fisly_theme_mode'), 'light');
  });
}
