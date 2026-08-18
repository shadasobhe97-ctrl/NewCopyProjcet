import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kids_transport/firebase_options.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/network/notification_repository.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';

/// الدالة المعزولة للتعامل مع الإشعارات أثناء إغلاق التطبيق كلياً (Terminated State)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    debugPrint('📱 [Background/Terminated FCM Message]: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel', // id القناة
    'الإشعارات الهامة', // اسم القناة
    description: 'قناة إشعارات تطبيق دربي المدارس عالية الأهمية',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static void Function(Map<String, dynamic> data)? _onNotificationTapCallback;

  /// تسجيل دالة Callback لمعالجة حدث النقر على الإشعار للتنقل لشاشة الشات أو الإشعارات مستقبلاً
  static void setNotificationTapCallback(
      void Function(Map<String, dynamic> data) callback) {
    _onNotificationTapCallback = callback;
  }

  /// تهيئة جميع خدمات الإشعارات والـ Permissions والمستمعات لجميع الحالات
  static Future<void> init() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. طلب صلاحيات الإشعارات من المستخدم
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
        debugPrint(
            'Notification permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting notification permission: $e');
      }
    }

    // 2. تهيئة الإشعارات المحلية والقناة لـ Android
    await _initLocalNotifications();

    // 3. جلب الـ FCM token وحفظه محلياً
    try {
      final token = await getFcmToken();
      if (token != null) {
        final sessionRepo = getIt<SessionRepository>();
        await sessionRepo.saveFcmToken(token);
        if (kDebugMode) {
          debugPrint('✅ Initialized FCM Token: $token');
        }
        if (sessionRepo.hasValidSession()) {
          await syncDeviceTokenWithBackend();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching initial FCM token: $e');
      }
    }

    // 4. الاستماع لتحديثات الـ FCM Token
    messaging.onTokenRefresh.listen((newToken) async {
      try {
        final sessionRepo = getIt<SessionRepository>();
        await sessionRepo.saveFcmToken(newToken);
        if (kDebugMode) {
          debugPrint('🔄 FCM Token Refreshed: $newToken');
        }
        if (sessionRepo.hasValidSession()) {
          await syncDeviceTokenWithBackend();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error saving refreshed FCM Token: $e');
        }
      }
    });

    // 5. حالة التطبيق مفتوح (Foreground State): عرض الإشعار كـ Heads-up Banner مع الصوت والاهتزاز
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('🔔 [Foreground FCM Message]: ${message.messageId}');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
      }
      _showLocalNotification(message);
    });

    // 6. حالة التطبيق في الخلفية (Background State): معالجة الضغط على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('👉 [Background Tap MessageOpenedApp]: ${message.messageId}');
        debugPrint('Data: ${message.data}');
      }
      _handleNotificationTap(message.data);
    });

    // 7. حالة التطبيق مغلق تماماً (Terminated State): معالجة الإشعار الذي تسبب بفتح التطبيق
    try {
      final RemoteMessage? initialMessage =
          await messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          debugPrint(
              '🚀 [Terminated Launch InitialMessage]: ${initialMessage.messageId}');
          debugPrint('Data: ${initialMessage.data}');
        }
        _handleNotificationTap(initialMessage.data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting initial FCM message: $e');
      }
    }
  }

  /// Saves current device's FCM Token into Firestore under users/{userId} document
  static Future<void> saveTokenToFirestore(String userId) async {
    if (userId.isEmpty) return;
    try {
      final String? token = await getFcmToken();
      if (token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {'fcm_token': token},
          SetOptions(merge: true),
        );
        if (kDebugMode) {
          debugPrint('✅ Saved FCM Token to Firestore users/$userId: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error saving FCM token to Firestore users/$userId: $e');
      }
    }
  }

  /// Sends Client-to-Client Push Notification using FCM HTTP v1 API & service_account.json
  static Future<void> sendPushNotification({
    required String receiverToken,
    required String title,
    required String body,
    required String chatRoomId,
  }) async {
    if (receiverToken.isEmpty) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/service_account.json');
      final Map<String, dynamic> serviceAccount =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final ServiceAccountCredentials credentials =
          ServiceAccountCredentials.fromJson(serviceAccount);
      const List<String> scopes = [
        'https://www.googleapis.com/auth/firebase.messaging',
      ];

      final AuthClient client =
          await clientViaServiceAccount(credentials, scopes);

      final String projectId =
          serviceAccount['project_id']?.toString() ?? 'darpy-a247d';
      final Uri url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

      final Map<String, dynamic> payload = {
        'message': {
          'token': receiverToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'type': 'chat_message',
            'chat_room_id': chatRoomId,
          },
        },
      };

      final http.Response response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        debugPrint(
            '🚀 [FCM HTTP v1 Push Sent]: status=${response.statusCode}, body=${response.body}');
      }

      client.close();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending FCM HTTP v1 push notification: $e');
      }
    }
  }

  /// تهيئة حزمة flutter_local_notifications وإنشاء Android Notification Channel
  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          debugPrint('🔔 [Local Notification Clicked]: ${response.payload}');
        }
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data =
                jsonDecode(response.payload!) as Map<String, dynamic>;
            _handleNotificationTap(data);
          } catch (_) {
            _handleNotificationTap({'payload': response.payload});
          }
        }
      },
    );

    // إنشاء القناة عالية الأهمية لـ Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  /// عرض إشعار محلي منبثق (Heads-up Notification) بصوت واهتزاز في حالة الـ Foreground
  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final String payload = jsonEncode(message.data);

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
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
      payload: payload,
    );
  }

  /// استدعاء الـ Callback الخاص بالنقر على الإشعارات
  static void _handleNotificationTap(Map<String, dynamic> data) {
    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(data);
    }
  }

  /// Syncs the FCM token and device details with the Laravel Backend
  static Future<void> syncDeviceTokenWithBackend() async {
    try {
      final sessionRepo = getIt<SessionRepository>();
      if (!sessionRepo.hasValidSession()) {
        if (kDebugMode) {
          debugPrint('⚠️ [FCM Token Sync]: User not authenticated. Skipping.');
        }
        return;
      }

      final String? token = await getFcmToken();
      if (token == null || token.isEmpty) return;

      // Persist token in local storage first
      await sessionRepo.saveFcmToken(token);

      // Get Device ID
      String? deviceId = StorageService.getDeviceId();
      String deviceName = 'Unknown Device';
      
      final deviceInfo = DeviceInfoPlugin();
      if (deviceId == null || deviceId.isEmpty) {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id; // Unique hardware ID
          deviceName = '${androidInfo.brand} ${androidInfo.model}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor; // Unique iOS identifier
          deviceName = iosInfo.name;
        } else {
          deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
        }
        if (deviceId != null) {
          await StorageService.saveDeviceId(deviceId);
        }
      } else {
        // Just fetch device name
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceName = '${androidInfo.brand} ${androidInfo.model}';
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceName = iosInfo.name;
        }
      }

      // Get App Version
      final packageInfo = await PackageInfo.fromPlatform();
      final String appVersion = packageInfo.version;

      final String platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');

      final body = {
        'fcm_token': token,
        'device_id': deviceId ?? 'unknown',
        'device_name': deviceName,
        'platform': platform,
        'app_version': appVersion,
      };

      if (kDebugMode) {
        debugPrint('🚀 [FCM Token Sync]: Sending details to Laravel backend: $body');
      }

      final notificationRepo = getIt<NotificationRepository>();
      await notificationRepo.registerDeviceToken(body);

      // Save to Firestore too if userId is available
      final String? userId = sessionRepo.getUserId();
      if (userId != null && userId.isNotEmpty) {
        await saveTokenToFirestore(userId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FCM Token Sync Error]: $e');
      }
    }
  }

  /// Remove device token on logout
  static Future<void> removeDeviceTokenFromBackend() async {
    try {
      final String? deviceId = StorageService.getDeviceId();
      if (deviceId != null && deviceId.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('🗑️ [FCM Token Sync]: Removing device token for device: $deviceId');
        }
        final notificationRepo = getIt<NotificationRepository>();
        await notificationRepo.removeDeviceToken(deviceId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FCM Token Remove Error]: $e');
      }
    }
  }

  /// جلب الـ FCM token الحالي للجهاز
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
