import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;

  Dio get dio => _dio;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
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
  }) async {
    final fullUrl = '${_dio.options.baseUrl}$path';
    print('--> HTTP POST $fullUrl');
    print('Headers: ${_dio.options.headers..addAll(headers ?? {})}');
    print('Body: $data');
    try {
      final response = await _dio.post(
        path,
        data: data,
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

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final fullUrl = '${_dio.options.baseUrl}$path';
    print('--> HTTP GET $fullUrl');
    print('QueryParameters: $queryParameters');
    print('Headers: ${_dio.options.headers..addAll(headers ?? {})}');
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
    print('Headers: ${_dio.options.headers..addAll(headers ?? {})}');
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
