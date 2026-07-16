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

  Future<int> _resolveParentId() async {
    int? parentId = StorageService.getParentId();
    if (parentId == null || parentId == 0) {
      try {
        final profileResponse = await _client.get(
          ApiEndpoints.parentProfile,
          headers: _authHeader,
        );
        final profileData = profileResponse.data;
        if (profileData is Map) {
          final payload = profileData['data'] ?? profileData;
          if (payload is Map<String, dynamic>) {
            parentId = int.tryParse(
              (payload['id'] ?? payload['parent_id'] ?? '').toString(),
            );
            if (parentId != null && parentId != 0) {
              await StorageService.saveParentId(parentId);
            }
          }
        }
      } catch (_) {}
    }
    return parentId ?? StorageService.getUserId() ?? 0;
  }

  /// GET /api/parent/children
  Future<List<ChildModel>> getChildren() async {
    final headers = _authHeader;
    debugPrint('🌐 [GET /parent/children] Request started...');
    debugPrint('🔑 Authorization Token sent: ${headers['Authorization']}');

    try {
      final response = await _client.get(
        ApiEndpoints.parentChildren,
        headers: headers,
      );
      final data = response.data;

      debugPrint('📥 [GET /parent/children] API Response Data: $data');

      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final serverMessage = ApiException.extractMessage(data);
          throw ApiException(serverMessage ?? 'تعذر تحميل بيانات الأطفال.');
        }
      }
      final list = data['data'] as List<dynamic>? ?? [];

      try {
        final children = list
            .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Parsed Children Count => ${children.length}');
        for (final child in children) {
          debugPrint('--- Parsed Child Details ---');
          debugPrint('ID => ${child.id}');
          debugPrint('Name => ${child.fullName}');
          debugPrint('Grade => ${child.grade}');
          debugPrint('Photo => ${child.photoUrl}');
          debugPrint('QR => ${child.qrCodeToken}');
        }

        return children;
      } catch (parsingError, stackTrace) {
        debugPrint('❌ [GET /parent/children] JSON PARSING ERROR: $parsingError');
        debugPrint('Stacktrace: $stackTrace');
        rethrow;
      }
    } catch (e) {
      debugPrint('❌ [GET /parent/children] Network or Server Error: $e');
      rethrow;
    }
  }


  /// GET /api/parent/children/{id}
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
        throw ApiException(serverMessage ?? 'تعذر تحميل تفاصيل الطفل.');
      }
    }
    final childData = data['data'] ?? data;
    return ChildModel.fromJson(childData as Map<String, dynamic>);
  }

  /// POST /api/parent/children
  Future<(ChildModel, String)> addChild(
    ChildModel child,
    String? localImagePath,
  ) async {
    final parentId = await _resolveParentId();
    final hasLocalImage =
        localImagePath != null &&
        localImagePath.isNotEmpty &&
        !localImagePath.startsWith('http') &&
        File(localImagePath).existsSync();

    dynamic requestData;

    final flatPayload = {
      'parent_id': parentId,
      'school_id': child.schoolId,
      'address_id': int.tryParse(child.addressId) ?? child.addressId,
      'full_name': child.fullName,
      'gender': child.gender,
      'birth_date': child.birthDate.toIso8601String().split('T').first,
      'grade': child.gradeLevel,
      'preferred_time_slot':
          child.logistics?.preferredTimeSlot ?? child.transportPref.period,
      'trip_direction':
          child.logistics?.tripDirection ?? child.transportPref.serviceType,
      'start_date':
          (child.logistics?.startDate ?? child.transportPref.startDate)
              .toIso8601String()
              .split('T')
              .first,
      'end_date':
          (child.logistics?.endDate ?? child.transportPref.endDate)
              ?.toIso8601String()
              .split('T')
              .first ??
          '',
      'subscription_type':
          child.logistics?.subscriptionType ??
          child.transportPref.subscriptionType,
      if (child.medicalNotes != null && child.medicalNotes!.isNotEmpty)
        'medical_notes': child.medicalNotes,
      if (child.notificationRadius != null)
        'notification_radius': child.notificationRadius,
      'pickup_time':
          child.logistics?.pickupTime ?? child.transportPref.schoolStartTime,
      'dropoff_time':
          child.logistics?.dropoffTime ?? child.transportPref.schoolEndTime,
    };

    if (hasLocalImage) {
      final file = File(localImagePath);
      requestData = FormData.fromMap({
        ...flatPayload,
        'photo': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
    } else {
      requestData = flatPayload;
    }

    final response = await _client.post(
      ApiEndpoints.parentChildren,
      data: requestData,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final serverMessage = ApiException.extractMessage(data);
        throw ApiException(serverMessage ?? 'تعذر إضافة الطفل.');
      }
    }
    final childData = data['data'] ?? data;
    final childModel = ChildModel.fromJson(childData as Map<String, dynamic>);
    final message = (data['message'] as String?) ?? 'تم إضافة الطفل بنجاح';
    return (childModel, message);
  }

  /// POST /api/parent/children/{id}
  Future<(ChildModel, String)> updateChild(
    ChildModel child,
    String? localImagePath,
  ) async {
    final parentId = await _resolveParentId();
    final hasLocalImage =
        localImagePath != null &&
        localImagePath.isNotEmpty &&
        !localImagePath.startsWith('http') &&
        File(localImagePath).existsSync();

    dynamic requestData;

    final flatPayload = {
      'parent_id': parentId,
      'school_id': child.schoolId,
      'address_id': int.tryParse(child.addressId) ?? child.addressId,
      'full_name': child.fullName,
      'gender': child.gender,
      'birth_date': child.birthDate.toIso8601String().split('T').first,
      'grade': child.gradeLevel,
      'preferred_time_slot':
          child.logistics?.preferredTimeSlot ?? child.transportPref.period,
      'trip_direction':
          child.logistics?.tripDirection ?? child.transportPref.serviceType,
      'start_date':
          (child.logistics?.startDate ?? child.transportPref.startDate)
              .toIso8601String()
              .split('T')
              .first,
      'end_date':
          (child.logistics?.endDate ?? child.transportPref.endDate)
              ?.toIso8601String()
              .split('T')
              .first ??
          '',
      'subscription_type':
          child.logistics?.subscriptionType ??
          child.transportPref.subscriptionType,
      if (child.medicalNotes != null && child.medicalNotes!.isNotEmpty)
        'medical_notes': child.medicalNotes,
      if (child.notificationRadius != null)
        'notification_radius': child.notificationRadius,
      'pickup_time':
          child.logistics?.pickupTime ?? child.transportPref.schoolStartTime,
      'dropoff_time':
          child.logistics?.dropoffTime ?? child.transportPref.schoolEndTime,
    };

    if (hasLocalImage) {
      final file = File(localImagePath);
      requestData = FormData.fromMap({
        ...flatPayload,
        'photo': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });
    } else {
      requestData = flatPayload;
    }

    final response = await _client.post(
      ApiEndpoints.parentChildById(child.id.toString()),
      data: requestData,
      headers: _authHeader,
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
        throw ApiException(serverMessage ?? 'تعذر تحميل قائمة المدارس.');
      }
    }
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => SchoolModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/parent/children/{id}/subscription
  Future<LogisticsModel?> getChildSubscription(String id) async {
    try {
      final response = await _client.get(
        ApiEndpoints.parentChildSubscription(id),
        headers: _authHeader,
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'];
        if (success == false) {
          final serverMessage = ApiException.extractMessage(data);
          throw ApiException(serverMessage ?? 'تعذر تحميل بيانات الاشتراك.');
        }
        final subData = data['data'];
        if (subData != null) {
          return LogisticsModel.fromJson(subData as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
