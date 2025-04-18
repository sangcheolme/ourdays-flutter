import 'api_client.dart';

class StatisticsService {
  final ApiClient _apiClient;
  
  StatisticsService(this._apiClient);
  
  // Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStatistics({
    DateTime? date,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (date != null) {
        queryParams['date'] = date.toIso8601String();
      }
      
      final response = await _apiClient.get('/statistics/monthly', queryParameters: queryParams);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get yearly statistics
  Future<Map<String, dynamic>> getYearlyStatistics({
    int? year,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (year != null) {
        queryParams['year'] = year;
      }
      
      final response = await _apiClient.get('/statistics/yearly', queryParameters: queryParams);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get place statistics
  Future<Map<String, dynamic>> getPlaceStatistics() async {
    try {
      final response = await _apiClient.get('/statistics/places');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get emotion statistics
  Future<Map<String, dynamic>> getEmotionStatistics() async {
    try {
      final response = await _apiClient.get('/statistics/emotions');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get date frequency statistics
  Future<Map<String, dynamic>> getDateFrequencyStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      
      final response = await _apiClient.get('/statistics/frequency', queryParameters: queryParams);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get category distribution statistics
  Future<Map<String, dynamic>> getCategoryDistributionStatistics() async {
    try {
      final response = await _apiClient.get('/statistics/categories');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get rating distribution statistics
  Future<Map<String, dynamic>> getRatingDistributionStatistics() async {
    try {
      final response = await _apiClient.get('/statistics/ratings');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get summary statistics
  Future<Map<String, dynamic>> getSummaryStatistics() async {
    try {
      final response = await _apiClient.get('/statistics/summary');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}