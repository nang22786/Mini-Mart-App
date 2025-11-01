// lib/services/fcm_service.dart

import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mini_mart/config/storage_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('✅ FCM: User granted permission');
      } else {
        log('⚠️ FCM: User declined permission');
        return;
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      log('📱 FCM Token: $_fcmToken');

      // ✅ Save token to storage
      if (_fcmToken != null) {
        await StorageService.saveFCMToken(_fcmToken!);
        log('✅ FCM Token saved to storage');
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Handle notification when app opened from terminated state
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }

      log('✅ FCM Service initialized successfully');
    } catch (e) {
      log('❌ FCM initialization error: $e');
    }
  }

  /// Initialize local notifications for Android
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'mini_mart_channel',
      'Mini Mart Notifications',
      description: 'Order and payment notifications',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Handle foreground messages (app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    log('📩 Foreground message received');
    log('   Title: ${message.notification?.title}');
    log('   Body: ${message.notification?.body}');
    log('   Data: ${message.data}');

    // Show local notification
    _showLocalNotification(message);
  }

  /// Handle background messages (app is in background or terminated)
  void _handleBackgroundMessage(RemoteMessage message) {
    log('📩 Background message opened');
    log('   Title: ${message.notification?.title}');
    log('   Body: ${message.notification?.body}');
    log('   Data: ${message.data}');

    // Navigate based on notification type
    _handleNotificationNavigation(message.data);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mini_mart_channel',
          'Mini Mart Notifications',
          channelDescription: 'Order and payment notifications',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Mini Mart',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    log('🔔 Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    String? type = data['type'];
    String? orderId = data['orderId'];

    log('🧭 Navigation: type=$type, orderId=$orderId');

    // TODO: Navigate based on type
    // - 'order_created' → Go to payment screen
    // - 'payment_confirmed' → Go to order details
  }

  /// Send notification manually (for testing or local use)
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'mini_mart_channel',
          'Mini Mart Notifications',
          channelDescription: 'Order and payment notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: data?.toString(),
    );

    log('📤 Local notification sent: $title');
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    log('✅ Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    log('✅ Unsubscribed from topic: $topic');
  }
}
