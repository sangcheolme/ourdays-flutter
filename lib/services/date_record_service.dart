import '../models/date_record.dart';
import 'api_client.dart';

class DateRecordService {
  final ApiClient _apiClient;
  
  DateRecordService(this._apiClient);
  
  // Create date record
  Future<DateRecord> createDateRecord(DateRecord dateRecord) async {
    try {
      final response = await _apiClient.post('/date-records', data: dateRecord.toJson());
      return DateRecord.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get date record by ID
  Future<DateRecord> getDateRecord(String id) async {
    try {
      final response = await _apiClient.get('/date-records/$id');
      return DateRecord.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get date records list with pagination and filtering
  Future<List<DateRecord>> getDateRecords({
    int page = 1,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
    Emotion? emotion,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      
      if (emotion != null) {
        queryParams['emotion'] = emotion.toString().split('.').last;
      }
      
      final response = await _apiClient.get('/date-records', queryParameters: queryParams);
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DateRecord.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get date records for calendar view
  Future<Map<DateTime, List<DateRecord>>> getCalendarDateRecords(
    DateTime month,
  ) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      
      final response = await _apiClient.get('/date-records/calendar', queryParameters: {
        'start_date': firstDay.toIso8601String(),
        'end_date': lastDay.toIso8601String(),
      });
      
      final Map<String, dynamic> data = response.data;
      final Map<DateTime, List<DateRecord>> result = {};
      
      data.forEach((dateString, records) {
        final date = DateTime.parse(dateString);
        final List<dynamic> recordsList = records;
        result[date] = recordsList.map((json) => DateRecord.fromJson(json)).toList();
      });
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update date record
  Future<DateRecord> updateDateRecord(DateRecord dateRecord) async {
    try {
      final response = await _apiClient.put(
        '/date-records/${dateRecord.id}',
        data: dateRecord.toJson(),
      );
      return DateRecord.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete date record
  Future<void> deleteDateRecord(String id) async {
    try {
      await _apiClient.delete('/date-records/$id');
    } catch (e) {
      rethrow;
    }
  }
  
  // Get recent date records
  Future<List<DateRecord>> getRecentDateRecords({int limit = 5}) async {
    try {
      final response = await _apiClient.get('/date-records', queryParameters: {
        'page': 1,
        'limit': limit,
        'sort': 'date:desc',
      });
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => DateRecord.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DateRecord>> getCalendarRecords({
    required int year,
    required int month,
  }) async {
    try {
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      final response = await _apiClient.get(
          '/date-records/calendar', queryParameters: {
        'start_date': firstDay.toIso8601String(),
        'end_date': lastDay.toIso8601String(),
      });

      final List<dynamic> data = response.data;
      return data.map((json) => DateRecord.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}