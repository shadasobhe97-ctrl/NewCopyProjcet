import 'package:flutter/material.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'package:kids_transport/features/parent/trips/data/repositories/trips_repository.dart';
import 'package:kids_transport/main.dart' show navigatorKey;
import 'app_router.dart';

class NotificationNavigationHandler {
  static Map<String, dynamic>? _pendingNotification;

  static Map<String, dynamic>? get pendingNotification => _pendingNotification;

  static void clearPending() {
    _pendingNotification = null;
  }

  static bool canNavigate(Map<String, dynamic> data) {
    final String screen = (data['screen']?.toString() ?? '').trim().toUpperCase();
    final String entityIdStr = data['entity_id']?.toString() ??
        data['trip_id']?.toString() ??
        data['subscription_id']?.toString() ??
        data['id']?.toString() ??
        '';
    final int? entityId = int.tryParse(entityIdStr);
    final String entityType = (data['entity_type']?.toString() ?? data['type']?.toString() ?? '').toUpperCase();
    final String title = data['title']?.toString() ?? '';

    // إشعارات التنبيهات العامة أو الإرشادية غير قابلة للنقر
    if (title.contains('تنبيه') || entityType.contains('WARNING') || entityType.contains('ALERT')) {
      if (screen.isEmpty || screen == 'NONE' || screen == 'HOME' || screen == 'DRIVER_HOME' || screen == 'PARENT_HOME') {
        return false;
      }
    }

    if (screen.isEmpty || screen == 'NONE' || screen == 'HOME') {
      return false;
    }

    if (screen.contains('EMERGENCY') || entityType.contains('EMERGENCY_DISPATCH')) {
      return true;
    }

    switch (screen) {
      case 'TRIP_LIVE':
      case 'TRIP_DETAILS':
      case 'TRIP_TRACKING':
      case 'DRIVER_TRIP_DETAILS':
      case 'DRIVER_LIVE_TRIP':
      case 'LIVE_TRIP':
        return entityId != null && entityId > 0;

      case 'INVOICE_DETAILS':
        return entityId != null && entityId > 0;

      case 'WALLET':
        return true;

      case 'SUBSCRIPTION_DETAILS':
      case 'DRIVER_SUBSCRIPTION_DETAILS':
        return entityId != null && entityId > 0;

      case 'DRIVER_LEGAL_DOCUMENTS':
      case 'LEGAL_DOCUMENTS':
      case 'DOCUMENTS':
      case 'VEHICLE_DOCUMENTS':
      case 'DRIVER_VEHICLE':
        return true;

      default:
        return false;
    }
  }

  static void handleNotificationTap(Map<String, dynamic> data) {
    if (!canNavigate(data)) {
      debugPrint('ℹ️ [NotificationNavigationHandler]: Notification is not navigable.');
      return;
    }

    final context = navigatorKey.currentContext;
    final state = navigatorKey.currentState;

    if (state == null || context == null) {
      _pendingNotification = data;
      return;
    }

    final sessionRepo = getIt<SessionRepository>();
    if (!sessionRepo.hasValidSession()) {
      _pendingNotification = data;
      return;
    }

    _pendingNotification = null;
    _executeNavigation(state, data, sessionRepo.getRoleName());
  }

  static void handlePendingNotification() {
    final state = navigatorKey.currentState;
    if (state == null || _pendingNotification == null) return;

    final sessionRepo = getIt<SessionRepository>();
    if (!sessionRepo.hasValidSession()) return;

    final data = _pendingNotification!;
    _pendingNotification = null;

    if (!canNavigate(data)) return;

    _executeNavigation(state, data, sessionRepo.getRoleName());
  }

  static void _executeNavigation(NavigatorState state, Map<String, dynamic> data, String? role) {
    if (!canNavigate(data)) return;

    final String screen = (data['screen']?.toString() ?? '').toUpperCase();
    final String entityIdStr = data['entity_id']?.toString() ??
        data['trip_id']?.toString() ??
        data['subscription_id']?.toString() ??
        data['id']?.toString() ??
        '';
    final int? entityId = int.tryParse(entityIdStr);

    final bool isDriver = role?.toLowerCase() == 'driver';
    final bool isParent = !isDriver;

    if (isParent) {
      switch (screen) {
        // تعيين سائق بديل: entity_id هو رحلة البديل — نفتحوا تتبعها الحي
        case 'TRIP_LIVE':
          if (entityId != null) _openParentLiveTrip(state, entityId);
          break;
        case 'TRIP_DETAILS':
        case 'TRIP_TRACKING':
          if (entityId != null) {
            state.pushNamed(
              AppRoutes.parentTripDetails,
              arguments: entityId,
            );
          }
          break;

        case 'INVOICE_DETAILS':
          if (entityId != null) {
            state.pushNamed(AppRoutes.parentInvoiceDetails, arguments: entityId);
          }
          break;
        case 'WALLET':
          state.pushNamed(AppRoutes.parentWallet);
          break;
        case 'SUBSCRIPTION_DETAILS':
          if (entityId != null) {
            state.pushNamed(AppRoutes.subscriptionDetails, arguments: entityId);
          }
          break;
        default:
          break;
      }
    } else if (isDriver) {
      switch (screen) {
        case 'DRIVER_TRIP_DETAILS':
        case 'TRIP_DETAILS':
          if (entityId != null) {
            state.pushNamed(AppRoutes.driverTripDetails, arguments: entityId);
          }
          break;
        case 'DRIVER_LIVE_TRIP':
        case 'LIVE_TRIP':
          if (entityId != null) {
            state.pushNamed(AppRoutes.driverLiveTrip, arguments: entityId);
          }
          break;
        case 'DRIVER_SUBSCRIPTION_DETAILS':
        case 'SUBSCRIPTION_DETAILS':
          if (entityId != null) {
            state.pushNamed(AppRoutes.driverSubscriptionDetails, arguments: entityId);
          }
          break;
        // نداء إنقاذ لسائق بديل: entity_id هو رقم المهمة (dispatch_id)
        case 'EMERGENCY_DISPATCH':
        case 'EMERGENCY_DISPATCH_DETAILS':
        case 'DRIVER_EMERGENCY_DISPATCH_DETAILS':
          final dispatchId = int.tryParse(data['dispatch_id']?.toString() ?? '') ??
              (data['entity_type']?.toString().toUpperCase() == 'EMERGENCY_DISPATCH' ? entityId : null) ??
              int.tryParse(data['id']?.toString() ?? '');
          if (dispatchId != null && dispatchId > 0) {
            StorageService.saveLatestEmergencyDispatchId(dispatchId);
            state.pushNamed(AppRoutes.driverEmergencyDispatchDetails, arguments: dispatchId);
          } else {
            state.pushNamed(AppRoutes.driverEmergencyDispatches);
          }
          break;
        case 'EMERGENCY_DISPATCHES':
        case 'DRIVER_EMERGENCY_DISPATCHES':
        case 'EMERGENCY':
          state.pushNamed(AppRoutes.driverEmergencyDispatches);
          break;
        case 'DRIVER_LEGAL_DOCUMENTS':
        case 'LEGAL_DOCUMENTS':
        case 'DOCUMENTS':
        case 'VEHICLE_DOCUMENTS':
          state.pushNamed(
            AppRoutes.driverPrimaryVehicle,
            arguments: 1, // التبويب الثاني: الوثائق الرسمية
          );
          break;
        case 'DRIVER_VEHICLE':
          state.pushNamed(
            AppRoutes.driverPrimaryVehicle,
            arguments: 0, // التبويب الأول: بيانات المركبة
          );
          break;
        default:
          final entityType = (data['entity_type']?.toString() ?? data['type']?.toString() ?? '').toUpperCase();
          if (entityType.contains('EMERGENCY_DISPATCH')) {
            final dispatchId = int.tryParse(data['dispatch_id']?.toString() ?? '') ??
                entityId ??
                int.tryParse(data['id']?.toString() ?? '');
            if (dispatchId != null && dispatchId > 0) {
              StorageService.saveLatestEmergencyDispatchId(dispatchId);
              state.pushNamed(AppRoutes.driverEmergencyDispatchDetails, arguments: dispatchId);
            } else {
              state.pushNamed(AppRoutes.driverEmergencyDispatches);
            }
          }
          break;
      }
    }
  }

  /// شاشة التتبع تحتاج الرحلة كاملة (ActiveTripModel)، فنجيبوها من trips/active.
  /// لو الرحلة مش نشطة (خلصت مثلاً) نفتحوا تفاصيلها بدل التتبع
  static Future<void> _openParentLiveTrip(NavigatorState state, int tripId) async {
    try {
      if (getIt.isRegistered<TripsRepository>()) {
        final trips = await getIt<TripsRepository>().getActiveTrips();
        final matches = trips.where((t) => t.tripId == tripId);
        if (matches.isNotEmpty) {
          state.pushNamed(
            AppRoutes.parentTripTracking,
            arguments: {'trip': matches.first, 'allTrips': trips},
          );
          return;
        }
      }
    } catch (_) {
      // نكمّلوا لتفاصيل الرحلة
    }
    state.pushNamed(AppRoutes.parentTripDetails, arguments: tripId);
  }
}
