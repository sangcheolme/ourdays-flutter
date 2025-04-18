import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ourdays/models/auth_response.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;
  
  bool _isAuthenticated = false;
  String? _token;
  User? _currentUser;
  
  AuthProvider(this._authService, this._secureStorage) {
    _loadToken();
  }
  
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get currentUser => _currentUser;
  
  // Load token from secure storage
  Future<void> _loadToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        _token = token;
        _isAuthenticated = true;
        
        // Load current user
        await _loadCurrentUser();
        
        notifyListeners();
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading token: $e');
    }
  }
  
  // Load current user
  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      // Handle error
      debugPrint('Error loading current user: $e');
      await logout();
    }
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    try {
      /*final response = await _authService.login(email, password);*/

      var user = User(id: '1', email: 'tkdcjf38@naver.com', name: '박상철', createdAt: DateTime.timestamp(), updatedAt: DateTime.timestamp(), profileImage: '123', profileImageUrl: '123');
      AuthResponse response = AuthResponse(token: 'xxx', user: user);
      
      // Save token
      await _secureStorage.write(key: 'auth_token', value: response.token);
      
      _token = response.token;
      _currentUser = response.user;
      _isAuthenticated = true;
      
      notifyListeners();
      return true;
    } catch (e) {
      // Handle error
      debugPrint('Login error: $e');
      return false;
    }
  }
  
  // Register
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _authService.register(name, email, password);
      
      // Save token
      await _secureStorage.write(key: 'auth_token', value: response.token);
      
      _token = response.token;
      _currentUser = response.user;
      _isAuthenticated = true;
      
      notifyListeners();
      return true;
    } catch (e) {
      // Handle error
      debugPrint('Register error: $e');
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Handle error
      debugPrint('Logout error: $e');
    } finally {
      // Clear token
      await _secureStorage.delete(key: 'auth_token');
      
      _token = null;
      _currentUser = null;
      _isAuthenticated = false;
      
      notifyListeners();
    }
  }
  
  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      
      // Save token
      await _secureStorage.write(key: 'auth_token', value: response.token);
      
      _token = response.token;
      
      notifyListeners();
      return true;
    } catch (e) {
      // Handle error
      debugPrint('Refresh token error: $e');
      await logout();
      return false;
    }
  }
}