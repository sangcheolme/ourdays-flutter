import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient;
  
  UserService(this._apiClient);
  
  // Get current user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/users/me');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user profile
  Future<User> updateProfile(String name, {String? profileImageUrl}) async {
    try {
      final data = {
        'name': name,
      };
      
      if (profileImageUrl != null) {
        data['profile_image'] = profileImageUrl;
      }
      
      final response = await _apiClient.put('/users/me', data: data);
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Upload profile image
  Future<String> uploadProfileImage(String filePath) async {
    try {
      final response = await _apiClient.uploadFile(
        '/users/me/profile-image',
        filePath,
        'image',
      );
      return response.data['url'];
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete('/users/me');
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(User updatedUser) async {
    try {
      final response = await _apiClient.put(
        '/users/${updatedUser.id}',
        data: updatedUser.toJson(),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String currentPassword,
      String newPassword) async {
    try {
      await _apiClient.put('/users/me/password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }
}