import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';

class NotificationService {
  /// Initializes Firebase Cloud Messaging service, requests permissions, and setups refresh token listeners.
  static Future<void> init() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Request notification permissions from the user
    try {
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        debugPrint('Notification permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting notification permission: $e');
      }
    }

    // 2. Fetch and store the initial FCM token
    try {
      final token = await getFcmToken();
      if (token != null) {
        final sessionRepo = getIt<SessionRepository>();
        await sessionRepo.saveFcmToken(token);
        if (kDebugMode) {
          debugPrint('✅ Initialized FCM Token: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching initial FCM token: $e');
      }
    }

    // 3. Monitor token updates and store the new token locally
    messaging.onTokenRefresh.listen((newToken) async {
      try {
        final sessionRepo = getIt<SessionRepository>();
        await sessionRepo.saveFcmToken(newToken);
        if (kDebugMode) {
          debugPrint('🔄 FCM Token Refreshed: $newToken');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error saving refreshed FCM Token: $e');
        }
      }
    });
  }

  /// Retrieves the current device FCM token.
  static Future<String?> getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting FCM token: $e');
      }
      return null;
    }
  }
}
