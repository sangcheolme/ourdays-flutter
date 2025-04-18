import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  UserProvider(this._userService);
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  
  // Update provider state based on authentication
  void update(bool isAuthenticated, String? token) {
    if (isAuthenticated && token != null && !_isInitialized) {
      _fetchUserProfile();
    } else if (!isAuthenticated) {
      _user = null;
      _isInitialized = false;
      notifyListeners();
    }
  }
  
  // Fetch user profile
  Future<void> _fetchUserProfile() async {
    _setLoading(true);
    
    try {
      final user = await _userService.getCurrentUser();
      _user = user;
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to load user profile: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user profile
  Future<bool> updateProfile(User updatedUser) async {
    _setLoading(true);
    
    try {
      final user = await _userService.updateUser(updatedUser);
      _user = user;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    
    try {
      await _userService.updatePassword(currentPassword, newPassword);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to update password: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Upload profile image
  Future<bool> uploadProfileImage(String imagePath) async {
    _setLoading(true);
    
    try {
      final user = await _userService.uploadProfileImage(imagePath);
      _user = user as User?;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to upload profile image: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Refresh user profile
  Future<void> refreshProfile() async {
    await _fetchUserProfile();
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}