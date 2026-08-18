# Frontend Notification System Integration Guide

This document describes the implementation architecture, token lifecycle, message state processing, and integration procedures with the Laravel Backend and Firebase Cloud Messaging (FCM).

---

## 1. System Architecture

The notifications subsystem utilizes a unified core pattern to support both **Parent** and **Driver** modules simultaneously:

```
[Laravel / FCM Push Server] 
           ↓
[NotificationService] (Receives / Registers)
           ↓
[NotificationNavigationHandler] (Directs payload parameters to target screens)
           ↓
[NotificationRemoteDataSource / NotificationRepository] (REST Calls)
           ↓
[NotificationCubit] (Manages unread notifications inbox / badges)
           ↓
[NotificationsScreen] (Shared Inbox View)
```

---

## 2. API Endpoint Mapping

The following endpoints are mapped inside `ApiEndpoints` and consumed by `NotificationRemoteDataSource`:

*   `POST: user/device-token` - Register user FCM token and hardware details.
*   `DELETE: user/device-token` - Remove device association on standard logout.
*   `POST: user/device-token/logout-all` - Revoke all active user devices.
*   `GET: notifications` - Retrieve notifications feed (paginated).
*   `GET: notifications/unread-count` - Unread badge count.
*   `PATCH: notifications/{id}/read` - Mark single notification as read.
*   `POST: notifications/read-all` - Mark all notifications as read.
*   `DELETE: notifications/{id}` - Delete notification.

---

## 3. Token Lifecycle & Authentication Hooks

### A. Device registration
Fired automatically on successful login or session restoration at startup:
```json
{
  "fcm_token": "...",
  "device_id": "...",
  "device_name": "...",
  "platform": "android|ios",
  "app_version": "1.0.0"
}
```
*   `device_id` is fetched dynamically using `device_info_plus` and persisted inside `StorageService`.
*   `app_version` is retrieved using `package_info_plus`.

### B. Token Refresh
Listens to `onTokenRefresh` events. If the user session is active, automatically sends the updated token payload to the backend server.

### C. Standard Logout Cleanup
Triggers `DELETE: user/device-token` passing `{"device_id": "..."}` prior to clearing local session variables. If the network call fails, session cleanup executes gracefully to avoid locking the user out.

---

## 4. Push State Handling

### Foreground (`onMessage`)
Parses payload details and displays a system-level Heads-Up Banner using `flutter_local_notifications`.

### Background Tap (`onMessageOpenedApp`)
Triggers redirection to `NotificationNavigationHandler` immediately.

### Terminated Tap (`getInitialMessage`)
Deferred routing execution. Saves payload parameters and launches routing after verification of session state and Navigator readiness.

---

## 5. Navigation & Target Routes

The routing is **Backend-Driven** using the following order of precedence:
1. `screen`
2. `action`
3. `entity_type`
4. `entity_id`

### Parent Routes Mapped:
*   `TRIP_DETAILS` -> Opens `AppRoutes.parentTripDetails` passing `tripId`.
*   `TRIP_TRACKING` -> Opens `AppRoutes.parentTripTracking` passing `tripId`.
*   `INVOICE_DETAILS` -> Opens `AppRoutes.parentInvoiceDetails` passing `id`.
*   `WALLET` -> Opens `AppRoutes.parentWallet`.
*   `SUBSCRIPTION_DETAILS` -> Opens `AppRoutes.subscriptionDetails` passing `subscriptionId`.

### Driver Routes Mapped:
*   `TRIP_DETAILS` -> Opens `AppRoutes.driverTripDetails` passing `tripId`.
*   `LIVE_TRIP` -> Opens `AppRoutes.driverLiveTrip` passing `tripId`.
*   `SUBSCRIPTION_DETAILS` -> Opens `AppRoutes.driverSubscriptionDetails` passing `subscriptionId`.

---

## 6. Manual Setup Required (iOS)

To enable push notifications on iOS:
1.  **Xcode Capabilities**: Enable "Push Notifications" and "Background Modes" (with "Background Fetch" and "Remote Notifications").
2.  **Config**: Place `GoogleService-Info.plist` inside `ios/Runner` folder.
3.  **APNs**: Configure Apple Developer APNs Keys and associate them with Firebase Project Settings.
