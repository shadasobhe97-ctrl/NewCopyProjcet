import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException error) {
    print("SERVER ERROR DATA: ${error.response?.data}"); 
    print("STATUS CODE: ${error.response?.statusCode}");
    final response = error.response;
    final data = response?.data;
    final serverMessage = _extractMessage(data);
    

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return ApiException(serverMessage, statusCode: response?.statusCode);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'انتهت مهلة الاتصال بالخادم، يرجى المحاولة مرة أخرى.',
          statusCode: response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          'تعذر إكمال الطلب، يرجى التأكد من البيانات والمحاولة مرة أخرى.',
          statusCode: response?.statusCode,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'لا يوجد اتصال مستقر بالخادم، يرجى التحقق من الإنترنت.',
        );
      case DioExceptionType.cancel:
        return const ApiException('تم إلغاء الطلب.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ApiException(
          'حدث خطأ غير متوقع أثناء الاتصال بالخادم.',
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;

      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }
        return firstValue.toString();
      }
    }

    return null;
  }

  @override
  String toString() => message;
}
