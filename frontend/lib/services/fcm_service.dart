import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_coach_new/firebase_options.dart';

// Must be top-level — runs in a separate isolate when app is terminated/background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService._showLocalNotification(message);
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // New channel with Importance.max for heads-up / floating notifications.
  // Using a new channel ID so existing installs get the upgraded importance
  // without needing to uninstall (Android caches channel settings on first create).
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'critical_alert_channel',
    'Critical Railway Alerts',
    description: 'Heads-up alerts for brake, odour, hot axle and ACP events.',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    showBadge: true,
  );

  /// Callback invoked when user taps a local (foreground) notification.
  /// Receives the notification type (e.g. 'ODOUR') so the caller can navigate.
  static void Function(String? type)? _onLocalNotificationTap;
  static void setOnLocalNotificationTap(void Function(String? type) cb) =>
      _onLocalNotificationTap = cb;

  static Future<void> initializeFCM() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notification'),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // payload carries the notification type (e.g. 'ODOUR', 'ACP')
        _onLocalNotificationTap?.call(response.payload);
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Background / terminated tap — subscribe in main.dart
  static void listenNotificationTap({
    required void Function(RemoteMessage message) onTap,
  }) {
    FirebaseMessaging.onMessageOpenedApp.listen(onTap);
  }

  /// Returns the notification that launched the app from terminated state.
  static Future<RemoteMessage?> getInitialNotification() async {
    return FirebaseMessaging.instance.getInitialMessage();
  }

  static Future<void> showLocalNotification(RemoteMessage message) => _showLocalNotification(message);

  static Color _accentColorForType(String type) {
    final t = type.toUpperCase();
    if (t.contains('BRAKE') || t.contains('HOT_AXLE') || t.contains('ACP')) {
      return const Color(0xFFD32F2F); // red
    }
    if (t.contains('ODOUR')) return const Color(0xFFE65100); // deep orange
    return const Color(0xFF1565C0); // blue
  }

  static String _groupKeyForType(String type) {
    final t = type.toUpperCase();
    if (t.contains('ODOUR')) return 'group_odour';
    if (t.contains('BRAKE') || t.contains('OVERCHARGE')) return 'group_brake';
    if (t.contains('ACP')) return 'group_acp';
    if (t.contains('HOT_AXLE')) return 'group_hot_axle';
    return 'group_alerts';
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] as String? ?? 'info';
    final title = notification.title ?? 'New Alert';
    final body = notification.body ?? '';
    final groupKey = _groupKeyForType(type);
    final accentColor = _accentColorForType(type);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'critical_alert_channel',
      'Critical Railway Alerts',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@drawable/ic_notification',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: accentColor,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      ticker: title,
      autoCancel: true,
      groupKey: groupKey,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
      vibrationPattern: Int64List.fromList([0, 300, 200, 300]),
    );

    // Show the individual notification with type as payload for tap routing
    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: type,
    );

    // Show/update the group summary notification so Android groups them
    final AndroidNotificationDetails summaryDetails =
        AndroidNotificationDetails(
      'critical_alert_channel',
      'Critical Railway Alerts',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@drawable/ic_notification',
      color: accentColor,
      groupKey: groupKey,
      setAsGroupSummary: true,
      autoCancel: true,
      styleInformation: const InboxStyleInformation(
        [],
        contentTitle: 'SmartCoaches Alerts',
        summaryText: 'Railway monitoring alerts',
      ),
    );

    await _localNotifications.show(
      groupKey.hashCode,
      'SmartCoaches Alerts',
      '',
      NotificationDetails(android: summaryDetails),
    );
  }

  // Called from main.dart after NotificationBloc is ready in the widget tree
  static void listenForeground({
    required void Function(RemoteMessage message) onMessage,
  }) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  static Future<String?> getToken() => _messaging.getToken();

  static void onTokenRefresh(void Function(String token) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}
