import '../models/special_date.dart';
import 'api_client.dart';

class SpecialDateService {
  final ApiClient _apiClient;
  
  SpecialDateService(this._apiClient);
  
  // Add special date
  Future<SpecialDate> addSpecialDate(SpecialDate specialDate) async {
    try {
      final response = await _apiClient.post(
        '/special-dates',
        data: specialDate.toJson(),
      );
      return SpecialDate.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get special dates
  Future<List<SpecialDate>> getSpecialDates() async {
    try {
      final response = await _apiClient.get('/special-dates');
      
      final List<dynamic> data = response.data;
      return data.map((json) => SpecialDate.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get special date by ID
  Future<SpecialDate> getSpecialDate(String id) async {
    try {
      final response = await _apiClient.get('/special-dates/$id');
      return SpecialDate.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Update special date
  Future<SpecialDate> updateSpecialDate(SpecialDate specialDate) async {
    try {
      final response = await _apiClient.put(
        '/special-dates/${specialDate.id}',
        data: specialDate.toJson(),
      );
      return SpecialDate.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete special date
  Future<void> deleteSpecialDate(String id) async {
    try {
      await _apiClient.delete('/special-dates/$id');
    } catch (e) {
      rethrow;
    }
  }
  
  // Get upcoming special dates
  Future<List<SpecialDate>> getUpcomingSpecialDates({int limit = 5}) async {
    try {
      final response = await _apiClient.get('/special-dates/upcoming', queryParameters: {
        'limit': limit,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => SpecialDate.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get special dates by type
  Future<List<SpecialDate>> getSpecialDatesByType(SpecialDateType type) async {
    try {
      final response = await _apiClient.get('/special-dates/type', queryParameters: {
        'type': type.toString().split('.').last,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => SpecialDate.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get special dates by date range
  Future<List<SpecialDate>> getSpecialDatesByRange(DateTime start, DateTime end) async {
    try {
      final response = await _apiClient.get('/special-dates/range', queryParameters: {
        'start_date': start.toIso8601String(),
        'end_date': end.toIso8601String(),
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => SpecialDate.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}