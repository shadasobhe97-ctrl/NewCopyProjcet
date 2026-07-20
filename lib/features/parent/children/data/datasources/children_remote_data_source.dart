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
            // بعض APIs تحط البيانات داخل مفتاح 'user'
            final data = (payload['user'] is Map)
                ? Map<String, dynamic>.from(payload['user'] as Map)
                : payload;
            parentId = _parseParentId(data);
            if (parentId != null && parentId > 0) {
              StorageService.saveParentId(parentId);
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ _resolveParentId error: $e');
      }
    }
    if (parentId == null || parentId == 0) {
      throw const ApiException('لم يتم العثور على معرف ولي الأمر.');
    }
    return parentId;
  }

  int? _parseParentId(Map<String, dynamic> data) {
    // يدعم كل الصيغ الممكنة من الباك إند
    final raw = data['parent_id'] ?? data['id'] ?? data['id_user'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }

  Future<List<ChildModel>> getChildren() async {
    debugPrint('getChildren()');
    final parentId = await _resolveParentId();
    debugPrint('parentId: $parentId');
    final response = await _client.get(
      '${ApiEndpoints.parentChildren}?parent_id=$parentId',
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
    final rawList = data['data'] ?? data;
    if (rawList is List) {
      final children = rawList
          .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
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
    final response = await _client.get(
      '${ApiEndpoints.parentChildById(id)}/subscription',
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
    return LogisticsModel.fromJson(childData as Map<String, dynamic>);
  }

  Future<File> _imageFileFromPath(String path) async {
    final file = File(path);
    if (file.existsSync()) return file;
    return file;
  }

  bool _isLocalImagePath(String? path) {
    if (path == null || path.isEmpty) return false;
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('//')) return false;
    return true;
  }

  /// POST /api/parent/children
  Future<(ChildModel, String)> addChild(
    ChildModel child,
    String? localImagePath,
  ) async {
    final parentId = await _resolveParentId();
    final hasLocalImage = _isLocalImagePath(localImagePath);
    debugPrint('📤 [addChild] localImagePath: $localImagePath');
    debugPrint('📤 [addChild] hasLocalImage: $hasLocalImage');
    debugPrint('📤 [addChild] child.photoUrl: ${child.photoUrl}');

    dynamic requestData;

    final flatPayload = <String, dynamic>{
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
      if (child.photoUrl != null && !_isLocalImagePath(child.photoUrl))
        'photo_url': child.photoUrl,
    };

    if (hasLocalImage) {
      try {
        final file = await _imageFileFromPath(localImagePath!);
        final bytes = await file.readAsBytes();
        debugPrint('📤 [addChild] Sending photo file: ${localImagePath.split('/').last.split('\\').last} (${bytes.length} bytes)');
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

    debugPrint('📤 [addChild] flatPayload keys: ${flatPayload.keys.join(', ')}');
    debugPrint('📤 [addChild] requestData type: ${requestData.runtimeType}');

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

  /// POST /api/parent/children/{id}
  Future<(ChildModel, String)> updateChild(
    ChildModel child,
    String? localImagePath,
  ) async {
    final parentId = await _resolveParentId();
    final hasLocalImage = _isLocalImagePath(localImagePath);

    dynamic requestData;

    final flatPayload = <String, dynamic>{
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
      if (child.photoUrl != null && !_isLocalImagePath(child.photoUrl))
        'photo_url': child.photoUrl,
    };

    if (hasLocalImage) {
      try {
        final file = await _imageFileFromPath(localImagePath!);
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

    final response = await _client.post(
      ApiEndpoints.parentChildById(child.id.toString()),
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
    debugPrint('📥 [updateChild] response childData: $childData');
    final childModel = ChildModel.fromJson(childData as Map<String, dynamic>);
    debugPrint('📥 [updateChild] parsed photoUrl: ${childModel.photoUrl}');
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
