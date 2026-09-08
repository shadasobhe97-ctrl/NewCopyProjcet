import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/parent/children/data/models/logistics_model.dart';
import '../models/child_model.dart';
import '../models/school_model.dart';

class ChildrenRemoteDataSource {
  final ApiClient _client;

  ChildrenRemoteDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  Future<List<ChildModel>> getChildren() async {
    debugPrint('getChildren()');
    final response = await _client.get(
      ApiEndpoints.parentChildren,
      headers: _authHeader,
    );
    final data = response.data;
    debugPrint('getChildren API response: $data');
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر جلب قائمة الأطفال.');
      }
    }
    dynamic rawList;
    if (data is Map) {
      if (data['data'] is List) {
        rawList = data['data'];
      } else if (data['children'] is List) {
        rawList = data['children'];
      } else if (data['data'] is Map) {
        final innerMap = data['data'] as Map;
        if (innerMap['children'] is List) {
          rawList = innerMap['children'];
        } else if (innerMap['data'] is List) {
          rawList = innerMap['data'];
        }
      }
    } else if (data is List) {
      rawList = data;
    }

    if (rawList is List) {
      final children = rawList
          .map((e) => ChildModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      debugPrint('getChildren parsed ${children.length} children');
      for (final child in children) {
        debugPrint(
          '  child id=${child.id} name=${child.fullName} photoUrl=${child.photoUrl} hasRealPhoto=${child.hasRealPhoto}',
        );
      }
      return children;
    }
    return [];
  }

  Future<ChildModel> getChildDetails(String id) async {
    final response = await _client.get(
      ApiEndpoints.parentChildById(id),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر جلب بيانات الطفل.');
      }
    }
    final childData = data['data'] ?? data;
    return ChildModel.fromJson(childData as Map<String, dynamic>);
  }

  Future<LogisticsModel> getChildSubscription(String id) async {
    try {
      final response = await _client.get(
        ApiEndpoints.parentChildById(id),
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final serverMessage = ApiException.extractMessage(data);
          throw ApiException(serverMessage ?? 'تعذر جلب بيانات الاشتراك.');
        }
      }
      final childData = data['data'] ?? data;
      if (childData is Map<String, dynamic>) {
        if (childData['logistics'] is Map) {
          return LogisticsModel.fromJson(
            childData['logistics'] as Map<String, dynamic>,
          );
        }
        final child = ChildModel.fromJson(childData);
        if (child.logistics != null) {
          return child.logistics!;
        }
        return LogisticsModel.fromJson(childData);
      }
    } catch (e) {
      debugPrint('⚠️ getChildSubscription error: $e');
    }
    return LogisticsModel.empty();
  }

  Future<File> _imageFileFromPath(String path) async {
    final file = File(path);
    if (file.existsSync()) return file;
    return file;
  }

  bool _isLocalImagePath(String? path) {
    if (path == null || path.isEmpty) return false;
    if (path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('//')) {
      return false;
    }
    return true;
  }

  String _formatTimeToHHMM24(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    final cleaned = timeStr.trim();

    final isPM = cleaned.toUpperCase().contains('PM') || cleaned.contains('م');
    final isAM = cleaned.toUpperCase().contains('AM') || cleaned.contains('ص');

    final timeOnly = cleaned.replaceAll(RegExp(r'[^\d:]'), '').trim();

    final parts = timeOnly.split(':');
    if (parts.length >= 2) {
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;

      if (isPM && hour < 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }

      final hh = hour.toString().padLeft(2, '0');
      final mm = minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    return timeOnly;
  }

  /// POST /api/parent/children
  Future<(ChildModel, String)> addChild(
    ChildModel child,
    String? localImagePath, {
    Uint8List? imageBytes,
  }) async {
    final hasLocalImage = _isLocalImagePath(localImagePath) || (imageBytes != null && imageBytes.isNotEmpty);
    debugPrint('📤 [addChild] localImagePath: $localImagePath, imageBytes length: ${imageBytes?.length}');

    dynamic requestData;

    final startDateStr =
        (child.logistics?.startDate ?? child.transportPref.startDate)
            .toIso8601String()
            .split('T')
            .first;
    final endDateRaw = child.logistics?.endDate ?? child.transportPref.endDate;
    final endDateStr = endDateRaw != null
        ? endDateRaw.toIso8601String().split('T').first
        : startDateStr;

    final rawPickup =
        child.logistics?.pickupTime ?? child.transportPref.schoolStartTime;
    final rawDropoff =
        child.logistics?.dropoffTime ?? child.transportPref.schoolEndTime;
    final pickupTimeStr = _formatTimeToHHMM24(rawPickup);
    final dropoffTimeStr = _formatTimeToHHMM24(rawDropoff);

    final flatPayload = <String, dynamic>{
      'school_id': child.schoolId,
      'address_id': int.tryParse(child.addressId) ?? child.addressId,
      'full_name': child.fullName,
      'gender': child.gender,
      'birth_date': child.birthDate.toIso8601String().split('T').first,
      'grade': int.tryParse(child.grade) ?? child.gradeLevel,
      'preferred_time_slot':
          child.logistics?.preferredTimeSlot ?? child.transportPref.period,
      'trip_direction':
          child.logistics?.tripDirection ?? child.transportPref.serviceType,
      'start_date': startDateStr,
      'end_date': endDateStr,
      'subscription_type':
          child.logistics?.subscriptionType ??
          child.transportPref.subscriptionType,
      if (child.medicalNotes != null && child.medicalNotes!.isNotEmpty)
        'medical_notes': child.medicalNotes,
      'notification_radius': child.notificationRadius?.toInt() ?? 500,
      if (pickupTimeStr.isNotEmpty) 'pickup_time': pickupTimeStr,
      if (dropoffTimeStr.isNotEmpty) 'dropoff_time': dropoffTimeStr,
      if (child.photoUrl != null && !_isLocalImagePath(child.photoUrl))
        'photo_url': child.photoUrl,
    };

    if (imageBytes != null && imageBytes.isNotEmpty) {
      final fileName = (localImagePath != null && localImagePath.isNotEmpty)
          ? localImagePath.split('/').last.split('\\').last
          : 'child_photo.jpg';
      requestData = FormData.fromMap({
        ...flatPayload,
        'photo': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        ),
      });
    } else if (hasLocalImage && localImagePath != null) {
      try {
        final file = await _imageFileFromPath(localImagePath);
        final bytes = await file.readAsBytes();
        requestData = FormData.fromMap({
          ...flatPayload,
          'photo': MultipartFile.fromBytes(
            bytes,
            filename: localImagePath.split('/').last.split('\\').last,
          ),
        });
      } catch (e) {
        debugPrint('⚠️ [addChild] Failed to read image file: $e');
        requestData = flatPayload;
      }
    } else {
      debugPrint('📤 [addChild] No local image to send');
      requestData = flatPayload;
    }

    debugPrint('==================================================');
    debugPrint('➕ [ADD_CHILD_API] Calling Endpoint: POST /api/${ApiEndpoints.parentChildren}');
    debugPrint('➕ [ADD_CHILD_API] Payload: $flatPayload');
    debugPrint('==================================================');

    final timeout = hasLocalImage
        ? const Duration(seconds: 120)
        : const Duration(seconds: 30);

    final response = await _client.post(
      ApiEndpoints.parentChildren,
      data: requestData,
      headers: _authHeader,
      receiveTimeout: timeout,
    );

    final data = response.data;
    debugPrint('📥 [addChild] API response: $data');
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر إضافة الطفل.');
      }
    }
    final childData = data['data'] ?? data;
    debugPrint('📥 [addChild] childData: $childData');
    final childModel = ChildModel.fromJson(childData as Map<String, dynamic>);
    debugPrint('📥 [addChild] parsed child photoUrl: ${childModel.photoUrl}');
    final message = (data['message'] as String?) ?? 'تم إضافة الطفل بنجاح';
    return (childModel, message);
  }

  /// POST /api/parent/children/{id} (تحديث كافة البيانات عند الإضافة والتحديث العام)
  Future<(ChildModel, String)> updateChild(
    ChildModel child,
    String? localImagePath, {
    Uint8List? imageBytes,
  }) async {
    return updateChildPersonalData(child, localImagePath, imageBytes: imageBytes);
  }

  /// POST /api/parent/children/{id} (تحديث البيانات الشخصية للطفل فقط)
  Future<(ChildModel, String)> updateChildPersonalData(
    ChildModel child,
    String? localImagePath, {
    Uint8List? imageBytes,
  }) async {
    final hasLocalImage = _isLocalImagePath(localImagePath) || (imageBytes != null && imageBytes.isNotEmpty);

    dynamic requestData;

    final flatPayload = <String, dynamic>{
      'full_name': child.fullName,
      'gender': child.gender,
      'birth_date': child.birthDate.toIso8601String().split('T').first,
      'grade': int.tryParse(child.grade) ?? child.gradeLevel,
      if (child.medicalNotes != null && child.medicalNotes!.isNotEmpty)
        'medical_notes': child.medicalNotes,
      if (child.photoUrl != null && !_isLocalImagePath(child.photoUrl))
        'photo_url': child.photoUrl,
    };

    if (imageBytes != null && imageBytes.isNotEmpty) {
      final fileName = (localImagePath != null && localImagePath.isNotEmpty)
          ? localImagePath.split('/').last.split('\\').last
          : 'child_photo.jpg';
      requestData = FormData.fromMap({
        ...flatPayload,
        'photo': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        ),
      });
    } else if (hasLocalImage && localImagePath != null) {
      try {
        final file = await _imageFileFromPath(localImagePath);
        final bytes = await file.readAsBytes();
        requestData = FormData.fromMap({
          ...flatPayload,
          'photo': MultipartFile.fromBytes(
            bytes,
            filename: localImagePath.split('/').last.split('\\').last,
          ),
        });
      } catch (_) {
        requestData = flatPayload;
      }
    } else {
      requestData = flatPayload;
    }

    final timeout = hasLocalImage
        ? const Duration(seconds: 120)
        : const Duration(seconds: 30);

    final endpointUrl = ApiEndpoints.parentChildById(child.id.toString());
    debugPrint('==================================================');
    debugPrint('✏️ [UPDATE_PERSONAL_DATA_API] Calling Endpoint: POST /api/$endpointUrl');
    debugPrint('✏️ [UPDATE_PERSONAL_DATA_API] Child ID: ${child.id}');
    debugPrint('✏️ [UPDATE_PERSONAL_DATA_API] Payload: $flatPayload');
    debugPrint('==================================================');

    final response = await _client.post(
      endpointUrl,
      data: requestData,
      headers: _authHeader,
      receiveTimeout: timeout,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر تحديث بيانات الطفل.');
      }
    }
    final childData = data['data'] ?? data;
    final childModel = ChildModel.fromJson(childData as Map<String, dynamic>);
    final message =
        (data['message'] as String?) ?? 'تم تحديث بيانات الطفل بنجاح';
    return (childModel, message);
  }

  /// POST /api/parent/children/{id} (تحديث بيانات النقل والاشتراك فقط)
  Future<(ChildModel, String)> updateChildTransportData({
    required String childId,
    required int schoolId,
    required dynamic addressId,
    required String preferredTimeSlot,
    required String tripDirection,
    required DateTime startDate,
    DateTime? endDate,
    required String subscriptionType,
    int? notificationRadius,
    String? pickupTime,
    String? dropoffTime,
  }) async {
    final startDateStr = startDate.toIso8601String().split('T').first;
    final endDateStr = endDate != null
        ? endDate.toIso8601String().split('T').first
        : startDateStr;

    final pickupTimeStr = _formatTimeToHHMM24(pickupTime);
    final dropoffTimeStr = _formatTimeToHHMM24(dropoffTime);

    final flatPayload = <String, dynamic>{
      'school_id': schoolId,
      'address_id': int.tryParse(addressId.toString()) ?? addressId,
      'preferred_time_slot': preferredTimeSlot,
      'trip_direction': tripDirection,
      'start_date': startDateStr,
      'end_date': endDateStr,
      'subscription_type': subscriptionType,
      'notification_radius': notificationRadius ?? 500,
      if (pickupTimeStr.isNotEmpty) 'pickup_time': pickupTimeStr,
      if (dropoffTimeStr.isNotEmpty) 'dropoff_time': dropoffTimeStr,
    };

    final endpointUrl = ApiEndpoints.parentChildById(childId);
    debugPrint('==================================================');
    debugPrint('✏️ [UPDATE_TRANSPORT_DATA_API] Calling Endpoint: POST /api/$endpointUrl');
    debugPrint('✏️ [UPDATE_TRANSPORT_DATA_API] Child ID: $childId');
    debugPrint('✏️ [UPDATE_TRANSPORT_DATA_API] Payload: $flatPayload');
    debugPrint('==================================================');

    final response = await _client.post(
      endpointUrl,
      data: flatPayload,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر تحديث بيانات النقل.');
      }
    }
    final childData = data['data'] ?? data;
    final childModel = ChildModel.fromJson(childData as Map<String, dynamic>);
    final message =
        (data['message'] as String?) ?? 'تم تحديث بيانات النقل بنجاح';
    return (childModel, message);
  }

  /// DELETE /api/parent/children/{id}
  Future<String> deleteChild(String id) async {
    final response = await _client.delete(
      ApiEndpoints.parentChildById(id),
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر حذف الطفل.');
      }
    }
    return (data['message'] as String?) ?? 'تم حذف الطفل بنجاح';
  }

  /// GET /api/parent/schools
  Future<List<SchoolModel>> getSchools() async {
    final response = await _client.get(
      ApiEndpoints.parentSchools,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر جلب قائمة المدارس.');
      }
    }
    final rawList = data['data'] ?? data;
    if (rawList is List) {
      return rawList
          .map((e) => SchoolModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
