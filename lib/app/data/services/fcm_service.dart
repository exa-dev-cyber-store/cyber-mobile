import 'dart:io';
import 'package:cyber/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:cyber/app/modules/order_history/controllers/order_history_controller.dart';
import 'package:cyber/app/routes/app_pages.dart';
import 'package:cyber/core/constants/api_endpoints.dart';
import 'package:cyber/core/network/api_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('Handling background FCM message: ${message.messageId}');
}

class FcmService {
  static String? _currentToken;

  /// Get currently active FCM registration token
  static String? get token => _currentToken;

  /// Initialize Firebase & FCM
  static Future<void> initialize() async {
    try {
      try {
        await Firebase.initializeApp();
      } catch (err) {
        debugPrint('ℹ️ [FCM] Default initialization failed ($err), using explicit Firebase options.');
        final projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? 'testflutterfirebase-26e7c';
        final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '1043117609248';
        final appId = Platform.isIOS
            ? (dotenv.env['FIREBASE_IOS_APP_ID'] ?? '1:1043117609248:ios:7c58a4340c07cba1fb8745')
            : (dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '1:1043117609248:android:124f4187ebcd74fbfb8745');
        final apiKey = Platform.isIOS
            ? (dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'AIzaSyAnB0fURv42YuQWnK5rXAEll3w9D3sPXns')
            : (dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? 'AIzaSyDBmRqNotWO-U6sypr-Rtj5caaFwycfX2I');

        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
            storageBucket: 'testflutterfirebase-26e7c.firebasestorage.app',
          ),
        );
      }
      debugPrint('✅ [FCM] Firebase Core initialized successfully on mobile.');

      // Background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request notification permissions
      await _requestPermission();

      // Retrieve FCM device token
      await _retrieveToken();

      // Setup listeners
      _setupListeners();
    } catch (e) {
      debugPrint('⚠️ [FCM] Initialization notice: $e');
    }
  }

  static Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 [FCM] Notification authorization status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('⚠️ [FCM] Request permission error: $e');
    }
  }

  static Future<void> _retrieveToken() async {
    if (Get.testMode || Firebase.apps.isEmpty) return;
    try {
      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 6; i++) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (apnsToken == null) {
          debugPrint(
            'ℹ️ [FCM] APNS token not yet available on iOS device/simulator. '
            'FCM token exchange will proceed automatically when APNS is registered.',
          );
          return;
        }
      }

      _currentToken = await FirebaseMessaging.instance.getToken();
      if (_currentToken != null) {
        debugPrint('📱 [FCM] Device Token: $_currentToken');
        await syncTokenWithBackend();
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Could not retrieve FCM token: $e');
    }
  }

  static void _setupListeners() {
    // 1. Listen for Token Refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 [FCM] Token refreshed: $newToken');
      _currentToken = newToken;
      syncTokenWithBackend();
    });

    // 2. Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 [FCM] Foreground push received: ${message.notification?.title}');

      // Refresh in-app notifications if controller active
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().fetchNotifications();
      }

      final title = message.notification?.title ?? message.data['title'] ?? 'Cyber Apple Store';
      final body = message.notification?.body ?? message.data['body'] ?? '';

      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 16,
        icon: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.notifications_active_rounded, color: Color(0xFF38BDF8), size: 28),
        ),
        duration: const Duration(seconds: 4),
        onTap: (snack) {
          _handleNotificationClick(message);
        },
      );
    });

    // 3. Message Opened from Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 [FCM] Notification clicked by user: ${message.data}');
      _handleNotificationClick(message);
    });

    // 4. Message from Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('🚀 [FCM] App opened from terminated state via notification: ${message.data}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationClick(message);
        });
      }
    });
  }

  static void _handleNotificationClick(RemoteMessage message) {
    debugPrint('🔔 [FCM] Notification tapped, refreshing latest notifications...');

    // 1. Immediately refresh in-memory notifications and unread badge count
    if (Get.isRegistered<NotificationsController>()) {
      Get.find<NotificationsController>().fetchNotifications();
    }

    final link = message.data['link']?.toString() ?? '';
    final orderId = message.data['orderId']?.toString();

    if (link.contains('order') || orderId != null) {
      Get.toNamed(Routes.ORDER_HISTORY);
      // Refresh order data after navigation so the view shows latest status
      Future.delayed(const Duration(milliseconds: 300), () {
        if (Get.isRegistered<OrderHistoryController>()) {
          Get.find<OrderHistoryController>().getOrders();
        }
      });
    } else {
      Get.toNamed(Routes.NOTIFICATIONS);
    }
  }

  /// Register/Synchronize current FCM token with backend
  static Future<void> syncTokenWithBackend() async {
    if (Get.testMode) return;
    if (_currentToken == null || _currentToken!.isEmpty) {
      await _retrieveToken();
    }
    if (_currentToken == null || _currentToken!.isEmpty) return;

    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.registerDevice,
        data: {
          'platform': Platform.isIOS ? 'ios' : 'android',
          'fcmToken': _currentToken,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ [FCM] Successfully registered mobile device token with backend.');
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Failed to sync token with backend: $e');
    }
  }
}
