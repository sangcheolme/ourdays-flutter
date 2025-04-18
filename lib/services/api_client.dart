import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://api.ourdays.app/api/v1';
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to request if available
          final token = await _secureStorage.read(key: authTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle 401 Unauthorized error (token expired)
          if (error.response?.statusCode == 401) {
            // Try to refresh the token
            if (await _refreshToken()) {
              // Retry the request with the new token
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // Upload file
  Future<Response> uploadFile(String path, String filePath, String fieldName) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
      });
      return await _dio.post(path, data: formData);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  
  // Save tokens
  Future<void> saveTokens(String authToken, String refreshToken) async {
    await _secureStorage.write(key: authTokenKey, value: authToken);
    await _secureStorage.write(key: refreshTokenKey, value: refreshToken);
  }
  
  // Clear tokens (logout)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: authTokenKey);
    await _secureStorage.delete(key: refreshTokenKey);
  }
  
  // Refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: refreshTokenKey);
      if (refreshToken == null) {
        return false;
      }
      
      final response = await Dio().post(
        '$baseUrl/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        await saveTokens(
          response.data['auth_token'],
          response.data['refresh_token'],
        );
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Retry request with new token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  // Handle common errors
  void _handleError(DioException error) {
    // Log error or handle specific error cases
    print('API Error: ${error.message}');
    print('Status code: ${error.response?.statusCode}');
    print('Response data: ${error.response?.data}');
  }
}