import '../models/couple.dart';
import 'api_client.dart';

class CoupleService {
  final ApiClient _apiClient;
  
  CoupleService(this._apiClient);
  
  // Create invite code
  Future<String> createInviteCode() async {
    try {
      final response = await _apiClient.post('/couples/invite');
      return response.data['invite_code'];
    } catch (e) {
      rethrow;
    }
  }
  
  // Accept invite
  Future<Couple> acceptInvite(String inviteCode, DateTime anniversaryDate) async {
    try {
      final response = await _apiClient.post('/couples/accept', data: {
        'inviteCode': inviteCode,
        'anniversaryDate': anniversaryDate.toIso8601String(),
      });
      return Couple.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get current couple
  Future<Couple> getCurrentCouple() async {
    try {
      final response = await _apiClient.get('/couples/me');
      return Couple.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Update couple info
  Future<Couple> updateCouple(DateTime anniversaryDate) async {
    try {
      final response = await _apiClient.put('/couples/me', data: {
        'anniversary_date': anniversaryDate.toIso8601String(),
      });
      return Couple.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Disconnect couple
  Future<void> disconnectCouple() async {
    try {
      await _apiClient.delete('/couples/me');
    } catch (e) {
      rethrow;
    }
  }
  
  // Check if user has a couple
  Future<bool> hasCouple() async {
    try {
      await getCurrentCouple();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get partner info
  Future<Map<String, dynamic>> getPartnerInfo() async {
    try {
      final response = await _apiClient.get('/couples/me/partner');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createInvite(DateTime anniversaryDate) async {
    try {
      final response = await _apiClient.post('/couples/invite', data: {
        'anniversary_date': anniversaryDate.toIso8601String(),
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCouple() async {
    try {
      await _apiClient.delete('/couples/me');
    } catch (e) {
      rethrow;
    }
  }
}