import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/dashboard/dashboard_provider.dart';
import '../../features/subscriptions/subscriptions_provider.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    await initialize();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      case TargetPlatform.iOS:
        await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      case TargetPlatform.macOS:
        await _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return;
    }
  }

  Future<void> syncDashboardNotifications(
    DashboardData data, {
    bool isTurkish = false,
  }) async {
    if (kIsWeb) return;
    await requestPermissions();
    await _showBudgetAlertsOncePerDay(data.alerts, isTurkish: isTurkish);
    await _scheduleSubscriptionReminders(
      data.upcomingSubscriptions,
      isTurkish: isTurkish,
    );
  }

  Future<void> _showBudgetAlertsOncePerDay(
    List<DashboardAlert> alerts, {
    required bool isTurkish,
  }) async {
    final budgetAlerts = alerts.where(
      (alert) => alert.level == 'danger' || alert.level == 'warn',
    );
    if (budgetAlerts.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    for (final alert in budgetAlerts) {
      final key = 'notification_budget_${alert.level}_${alert.title}_$dayKey';
      if (prefs.getBool(key) == true) continue;
      await _plugin.show(
        id: _stableId('budget:${alert.level}:${alert.title}'),
        title: alert.title,
        body: alert.message,
        notificationDetails: _details(
          channelId: 'budget_alerts',
          channelName: isTurkish ? 'Bütçe uyarıları' : 'Budget alerts',
          isTurkish: isTurkish,
        ),
        payload: alert.route,
      );
      await prefs.setBool(key, true);
    }
  }

  Future<void> _scheduleSubscriptionReminders(
    List<Subscription> subscriptions, {
    required bool isTurkish,
  }) async {
    final now = DateTime.now();
    for (final sub in subscriptions) {
      final due = DateTime.tryParse(sub.nextBillingDate);
      if (due == null) continue;

      final reminderAt = DateTime(due.year, due.month, due.day, 9);
      if (reminderAt.isBefore(now)) continue;

      final id = _stableId('subscription:${sub.id}:${sub.nextBillingDate}');
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
        notificationDetails: _details(
          channelId: 'subscription_reminders',
          channelName: isTurkish
              ? 'Abonelik hatırlatmaları'
              : 'Subscription reminders',
          isTurkish: isTurkish,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: isTurkish
            ? '${sub.name} ödeme hatırlatması'
            : '${sub.name} payment reminder',
        body: isTurkish
            ? '${_fmtTRY(sub.amount)} ödeme tarihi yaklaşıyor.'
            : '${_fmtTRY(sub.amount)} payment date is coming up.',
        payload: '/subscriptions',
      );
    }
  }

  NotificationDetails _details({
    required String channelId,
    required String channelName,
    required bool isTurkish,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: isTurkish
            ? 'Fişly bildirimleri'
            : 'Fisly notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
  }

  int _stableId(String value) => value.hashCode & 0x7fffffff;

  String _fmtTRY(double v) => '₺${v.toStringAsFixed(2).replaceAll('.', ',')}';
}
