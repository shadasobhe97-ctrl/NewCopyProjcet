import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;

  Dio get dio => _dio;

  ApiClient()
    : _dio =         Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'bypass-tunnel-reminder': 'true',
          },
        ),
      );

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
    Duration? receiveTimeout,
  }) async {
    final fullUrl = '${_dio.options.baseUrl}$path';
    debugPrint('\n================= API CLIENT POST =================');
    debugPrint('>>> METHOD: HTTP POST');
    debugPrint('>>> URL: $fullUrl');
    debugPrint('>>> Effective Headers:');
    final mergedHeaders = {..._dio.options.headers, ...?headers};
    mergedHeaders.forEach((k, v) => debugPrint('  $k: $v'));
    debugPrint('>>> Body: $data');
    debugPrint('===================================================\n');
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
      );
      debugPrint('\n<<< RESPONSE:');
      debugPrint('  Status Code: ${response.statusCode}');
      debugPrint('  Headers: ${response.headers.map}');
      debugPrint('  Body: ${response.data}');
      debugPrint('<<< END RESPONSE\n');
      return response;
    } on DioException catch (error) {
      debugPrint('\n!!!!!!!!!!!!!! DIO EXCEPTION !!!!!!!!!!!!!!');
      debugPrint('Exception Type: DioException');
      debugPrint('Exception Message: ${error.message}');
      debugPrint('requestOptions.path: ${error.requestOptions.path}');
      debugPrint('requestOptions.baseUrl: ${error.requestOptions.baseUrl}');
      debugPrint('requestOptions.data: ${error.requestOptions.data}');
      debugPrint('requestOptions.headers: ${error.requestOptions.headers}');
      debugPrint('requestOptions.method: ${error.requestOptions.method}');
      if (error.response != null) {
        debugPrint('response.statusCode: ${error.response?.statusCode}');
        debugPrint('response.headers: ${error.response?.headers.map}');
        debugPrint('response.data: ${error.response?.data}');
      } else {
        debugPrint('response: null (no response from server)');
      }
      debugPrint('Stack Trace: ${error.stackTrace}');
      debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
      throw ApiException.fromDioException(error);
    } catch (e, stackTrace) {
      debugPrint('\n!!!!!!!!!!!!!! UNEXPECTED EXCEPTION !!!!!!!!!!!!!!');
      debugPrint('Exception Type: ${e.runtimeType}');
      debugPrint('Exception Message: $e');
      debugPrint('Stack Trace: $stackTrace');
      debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
      rethrow;
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final fullUrl = '${_dio.options.baseUrl}$path';
    print('--> HTTP GET $fullUrl');
    print('QueryParameters: $queryParameters');
    final mergedHeaders = {..._dio.options.headers, ...?headers};
    print('Headers: $mergedHeaders');
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      print('<-- STATUS ${response.statusCode} ($path)');
      print('Response Body: ${response.data}');
      return response;
    } on DioException catch (error) {
      print('<!- ERROR ($path): ${error.message}');
      if (error.response != null) {
        print('Error Status: ${error.response?.statusCode}');
        print('Error Response Body: ${error.response?.data}');
      }
      throw ApiException.fromDioException(error);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    Map<String, dynamic>? headers,
  }) async {
    final fullUrl = '${_dio.options.baseUrl}$path';
    print('--> HTTP DELETE $fullUrl');
    final mergedHeaders = {..._dio.options.headers, ...?headers};
    print('Headers: $mergedHeaders');
    try {
      final response = await _dio.delete(path, options: Options(headers: headers));
      print('<-- STATUS ${response.statusCode} ($path)');
      print('Response Body: ${response.data}');
      return response;
    } on DioException catch (error) {
      print('<!- ERROR ($path): ${error.message}');
      if (error.response != null) {
        print('Error Status: ${error.response?.statusCode}');
        print('Error Response Body: ${error.response?.data}');
      }
      throw ApiException.fromDioException(error);
    }
  }
}
