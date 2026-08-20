import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const ApiException(this.message, {this.statusCode, this.errorCode});

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;
    final data = response?.data;
    final serverMessage = extractMessage(data);
    final serverErrorCode = extractErrorCode(data);

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return ApiException(
        serverMessage,
        statusCode: response?.statusCode,
        errorCode: serverErrorCode,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType
          .transformTimeout: // تم إضافة هذا السطر هنا لحل المشكلة
        return ApiException(
          'انتهت مهلة الاتصال بالخادم، يرجى المحاولة مرة أخرى.',
          statusCode: response?.statusCode,
        );
      case DioExceptionType.badResponse:
        if (response?.statusCode == 403) {
          return ApiException(
            serverMessage ??
                'الحساب قيد المراجعة بانتظار موافقة الإدارة، لا يمكنك الدخول حالياً.',
            statusCode: 403,
            errorCode: serverErrorCode,
          );
        }
        return ApiException(
          serverMessage ??
              'تعذر إكمال الطلب، يرجى التأكد من البيانات والمحاولة مرة أخرى.',
          statusCode: response?.statusCode,
          errorCode: serverErrorCode,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'لا يوجد اتصال مستقر بالخادم، يرجى التحقق من الإنترنت.',
        );
      case DioExceptionType.cancel:
        return const ApiException('تم إلغاء الطلب.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ApiException('حدث خطأ غير متوقع أثناء الاتصال بالخادم.');
    }
  }

  static String? extractErrorCode(dynamic data) {
    if (data is Map && data['error_code'] != null) {
      return data['error_code'].toString();
    }
    return null;
  }

  static String? extractMessage(dynamic data) {
    final messages = _collectMessages(data);
    if (messages.isEmpty) return null;
    return messages.join('\n');
  }

  static List<String> _collectMessages(dynamic value) {
    if (value == null) return const [];

    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? const [] : [trimmed];
    }

    if (value is Iterable) {
      return value.expand(_collectMessages).toList();
    }

    if (value is Map) {
      final errors = value['errors'];
      final message = value['message'];
      final error = value['error'];

      final collected = <String>[
        ..._collectMessages(errors),
        ..._collectMessages(message),
        ..._collectMessages(error),
      ];

      if (collected.isNotEmpty) {
        return collected.toSet().toList();
      }

      return value.values.expand(_collectMessages).toSet().toList();
    }

    final fallback = value.toString().trim();
    return fallback.isEmpty ? const [] : [fallback];
  }

  @override
  String toString() => message;
}
