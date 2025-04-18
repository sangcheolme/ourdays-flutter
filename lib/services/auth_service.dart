import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // Register a new user
  Future<AuthResponse> register(String email, String password, String name) async {
    try {
      final response = await _apiClient.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });

      final authToken = response.data['auth_token'];
      final refreshToken = response.data['refresh_token'];

      // Save auth tokens
      await _apiClient.saveTokens(
        authToken,
        refreshToken,
      );

      // Return the auth response object
      return AuthResponse(
        token: authToken,
        user: User.fromJson(response.data['user']),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final authToken = response.data['auth_token'];
      final refreshToken = response.data['refresh_token'];

      // Save auth tokens
      await _apiClient.saveTokens(
        authToken,
        refreshToken,
      );

      // Return the auth response object
      return AuthResponse(
        token: authToken,
        user: User.fromJson(response.data['user']),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Ignore errors during logout
    } finally {
      // Always clear tokens
      await _apiClient.clearTokens();
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      // Try to get current user
      await _apiClient.get('/users/me');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false;
      }
      rethrow;
    }
  }

  // Request password reset
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiClient.post('/auth/password-reset-request', data: {
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Reset password with token
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiClient.post('/auth/password-reset', data: {
        'token': token,
        'password': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Change password (when logged in)
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiClient.put('/users/me/password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/me');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Refresh token
  Future<AuthResponse> refreshToken() async {
    try {
      final response = await _apiClient.post('/auth/refresh');

      final authToken = response.data['auth_token'];
      final newRefreshToken = response.data['refresh_token'];

      // Save auth tokens
      await _apiClient.saveTokens(
        authToken,
        newRefreshToken,
      );

      // Return the auth response object
      return AuthResponse(
        token: authToken,
        user: User.fromJson(response.data['user']),
      );
    } catch (e) {
      rethrow;
    }
  }
}
