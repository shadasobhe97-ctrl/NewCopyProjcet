import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, String>? fieldErrors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.errorCode,
    this.fieldErrors,
  });

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;
    final data = response?.data;
    final serverMessage = extractMessage(data);
    final serverErrorCode = extractErrorCode(data);
    final fieldErrors = extractFieldErrors(data);

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return ApiException(
        serverMessage,
        statusCode: response?.statusCode,
        errorCode: serverErrorCode,
        fieldErrors: fieldErrors,
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

  static Map<String, String>? extractFieldErrors(dynamic data) {
    if (data is! Map) return null;
    final errorsMap = data['errors'];
    final result = <String, String>{};

    if (errorsMap is Map) {
      for (final entry in errorsMap.entries) {
        final key = entry.key.toString().toLowerCase().trim();
        final val = entry.value;
        String? firstMsg;
        if (val is List && val.isNotEmpty) {
          firstMsg = val.first?.toString();
        } else if (val is String) {
          firstMsg = val;
        }

        if (firstMsg != null && firstMsg.trim().isNotEmpty) {
          final cleanMsg = firstMsg.trim();
          if (key.contains('alt') ||
              key.contains('backup') ||
              key.contains('secondary') ||
              key.contains('emergency')) {
            result['alternative_phone'] = cleanMsg;
          } else if (key.contains('phone') ||
              key.contains('mobile') ||
              key.contains('tel')) {
            result['phone'] = cleanMsg;
          } else if (key.contains('email') || key.contains('mail')) {
            if (!_isOtpDeliveryMessage(cleanMsg)) {
              result['email'] = cleanMsg;
            }
          } else if (key.contains('name')) {
            result['name'] = cleanMsg;
          } else if (key.contains('password')) {
            result['password'] = cleanMsg;
          } else {
            result[key] = cleanMsg;
          }
        }
      }
    }

    if (result.isEmpty) {
      final msg = data['message']?.toString().trim() ?? '';
      final lowerMsg = msg.toLowerCase();
      // رسائل تعذر/فشل إرسال رمز التحقق هي رسائل نظام عامة ولا تخص حقل إدخال البريد
      if (!_isOtpDeliveryMessage(msg)) {
        if (msg.contains('احتياطي') ||
            msg.contains('بديل') ||
            lowerMsg.contains('alternative')) {
          result['alternative_phone'] = msg;
        } else if (msg.contains('هاتف') ||
            msg.contains('موبايل') ||
            msg.contains('جوال') ||
            lowerMsg.contains('phone')) {
          result['phone'] = msg;
        } else if (msg.contains('بريد') ||
            msg.contains('الالكتروني') ||
            msg.contains('الإلكتروني') ||
            lowerMsg.contains('email')) {
          result['email'] = msg;
        } else if (msg.contains('اسم') || lowerMsg.contains('name')) {
          result['name'] = msg;
        } else if (msg.contains('كلمة المرور') || lowerMsg.contains('password')) {
          result['password'] = msg;
        }
      }
    }

    return result.isEmpty ? null : result;
  }

  static bool _isOtpDeliveryMessage(String msg) {
    final lower = msg.toLowerCase();
    final hasFailure = msg.contains('تعذر') ||
        msg.contains('فشل') ||
        lower.contains('fail') ||
        lower.contains('unable') ||
        lower.contains('could not');
    final hasSendOrOtp = msg.contains('إرسال') ||
        msg.contains('ارسال') ||
        msg.contains('رمز') ||
        lower.contains('send') ||
        lower.contains('otp');
    return (hasFailure && hasSendOrOtp) ||
        msg.contains('رمز التحقق') ||
        lower.contains('verification code');
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
