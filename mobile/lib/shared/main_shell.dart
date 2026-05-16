import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;
  const MainShell({super.key, required this.child, required this.location});

  static const _tabs = [
    (path: '/expenses', icon: Icons.receipt_long, label: 'Harcamalar'),
    (path: '/reports', icon: Icons.bar_chart, label: 'Özet'),
    (path: '/subscriptions', icon: Icons.repeat, label: 'Abonelikler'),
    (path: '/settings', icon: Icons.settings, label: 'Ayarlar'),
  ];

  int _indexFor(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path || location.startsWith('${_tabs[i].path}/')) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexFor(location);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_scan',
        onPressed: () => context.push('/scan'),
        tooltip: 'Fiş Tara',
        child: const Icon(Icons.document_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}
