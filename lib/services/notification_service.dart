import 'dart:async';
import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TOP-LEVEL background handler (must be outside any class)
// Called when the app is in background/terminated.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by this point.
  dev.log('[NotificationService] Background message: ${message.messageId}');
}

// ─────────────────────────────────────────────────────────────────────────────
// Android notification channel
// ─────────────────────────────────────────────────────────────────────────────
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'chethanafm_channel',           // must match AndroidManifest meta-data
  'Chethana FM',                  // user-visible name
  description: 'Live programme updates and Chethana FM announcements.',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);

/// Singleton service that owns Firebase Messaging + Local Notifications.
///
/// Usage:
///   await NotificationService.instance.initialize(navigatorKey: key);
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Becomes true once [initialize] has completed successfully.
  bool _initialized = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  /// Initialise the notification service.
  ///
  /// Call this **once** from [main()] after [Firebase.initializeApp()].
  /// Pass [navigatorKey] so notification taps can navigate to screens.
  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    if (_initialized) return; // guard against duplicate calls

    try {
      // 1. Register the background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Request permission
      await _requestPermission();

      // 3. Configure local notifications
      await _initLocalNotifications();

      // 4. Create Android notification channel
      await _createNotificationChannel();

      // 5. Subscribe to the all_users topic every session
      await _subscribeToTopics();

      // 6. Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        dev.log('[NotificationService] Foreground message: ${message.messageId}');
        _showLocalNotification(message);
      });

      // 7. Background tap (app opened from background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        dev.log('[NotificationService] Notification opened app (background): ${message.messageId}');
        _handleNotificationTap(message, navigatorKey: navigatorKey);
      });

      // 8. Terminated state tap (app was closed)
      final RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();
      if (initialMessage != null) {
        dev.log('[NotificationService] App opened from terminated via notification: ${initialMessage.messageId}');
        // Delay to allow the navigator to be ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(initialMessage, navigatorKey: navigatorKey);
        });
      }

      _initialized = true;
      dev.log('[NotificationService] Initialized successfully.');
    } catch (e, st) {
      dev.log('[NotificationService] Initialization error: $e', stackTrace: st);
      // Never crash the app on notification init failure.
    }
  }

  /// Returns the current FCM device token (useful for debugging).
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      dev.log('[NotificationService] Failed to get FCM token: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Request notification permission and return the status string.
  Future<void> _requestPermission() async {
    try {
      final NotificationSettings settings =
          await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          dev.log('[NotificationService] Permission granted.');
          break;
        case AuthorizationStatus.provisional:
          dev.log('[NotificationService] Provisional permission granted.');
          break;
        case AuthorizationStatus.denied:
          dev.log(
            '[NotificationService] Permission denied. '
            'Users can enable notifications from device settings.',
          );
          break;
        case AuthorizationStatus.notDetermined:
          dev.log('[NotificationService] Permission not determined.');
          break;
      }
    } catch (e) {
      dev.log('[NotificationService] Permission request error: $e');
    }
  }

  /// Initialize Flutter Local Notifications plugin.
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false, // handled by firebase_messaging
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        dev.log('[NotificationService] Local notification tapped: ${response.payload}');
        // Local notification tap — navigate to Home by default.
      },
    );
  }

  /// Create the high-importance Android notification channel.
  Future<void> _createNotificationChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Subscribe to FCM topics required by the backend.
  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('all_users');
      dev.log('[NotificationService] Subscribed to topic: all_users');
    } catch (e) {
      dev.log('[NotificationService] Topic subscription failed: $e');
    }
  }

  /// Show a local notification when the app is in the foreground.
  void _showLocalNotification(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    if (notification == null) return;

    final String title = notification.title ?? 'Chethana FM';
    final String body = notification.body ?? '';

    try {
      _localNotifications.show(
        notification.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    } catch (e) {
      dev.log('[NotificationService] Failed to show local notification: $e');
    }
  }

  /// Handle notification tap — navigate to the appropriate screen.
  ///
  /// Currently: always opens the app (Home Screen).
  /// Future: read [message.data] to navigate to a specific screen.
  void _handleNotificationTap(
    RemoteMessage message, {
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    dev.log('[NotificationService] Handling notification tap. data: ${message.data}');
    // Future navigation: check message.data['screen'] and push accordingly.
    // For now, the app opening to Home is the default behavior.
  }
}
