import '../models/media.dart';
import 'api_client.dart';

class MediaService {
  final ApiClient _apiClient;
  
  MediaService(this._apiClient);
  
  // Upload media
  Future<Media> uploadMedia(String filePath, String referenceId, ReferenceType referenceType, MediaType type) async {
    try {
      final formData = {
        'reference_id': referenceId,
        'reference_type': referenceType.toString().split('.').last,
        'type': type.toString().split('.').last,
      };
      
      final response = await _apiClient.uploadFile(
        '/media/upload',
        filePath,
        'file',
      );
      
      return Media.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get media for date record
  Future<List<Media>> getMediaForDateRecord(String dateRecordId) async {
    try {
      final response = await _apiClient.get('/date-records/$dateRecordId/media');
      
      final List<dynamic> data = response.data;
      return data.map((json) => Media.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get media for place
  Future<List<Media>> getMediaForPlace(String placeId) async {
    try {
      final response = await _apiClient.get('/places/$placeId/media');
      
      final List<dynamic> data = response.data;
      return data.map((json) => Media.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete media
  Future<void> deleteMedia(String id) async {
    try {
      await _apiClient.delete('/media/$id');
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all media (for gallery)
  Future<List<Media>> getAllMedia({
    int page = 1,
    int limit = 20,
    MediaType? type,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      
      if (type != null) {
        queryParams['type'] = type.toString().split('.').last;
      }
      
      final response = await _apiClient.get('/media', queryParameters: queryParams);
      
      final List<dynamic> data = response.data['data'];
      return data.map((json) => Media.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get media by ID
  Future<Media> getMedia(String id) async {
    try {
      final response = await _apiClient.get('/media/$id');
      return Media.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}