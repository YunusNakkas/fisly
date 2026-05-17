import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;
  const MainShell({super.key, required this.child, required this.location});

  static const _tabPaths = [
    '/dashboard',
    '/expenses',
    '/reports',
    '/subscriptions',
    '/settings',
  ];

  static const _tabIcons = [
    Icons.dashboard_outlined,
    Icons.receipt_long,
    Icons.bar_chart,
    Icons.repeat,
    Icons.settings,
  ];

  int _indexFor(String location) {
    for (var i = 0; i < _tabPaths.length; i++) {
      if (location == _tabPaths[i] || location.startsWith('${_tabPaths[i]}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final labels = [
      t.navDashboard,
      t.navExpenses,
      t.navReports,
      t.navSubscriptions,
      t.navSettings,
    ];
    final idx = _indexFor(location);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_scan',
        onPressed: () => context.push('/scan'),
        tooltip: t.scanTitle,
        child: const Icon(Icons.document_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabPaths[i]),
        destinations: [
          for (var i = 0; i < _tabPaths.length; i++)
            NavigationDestination(icon: Icon(_tabIcons[i]), label: labels[i]),
        ],
      ),
    );
  }
}
