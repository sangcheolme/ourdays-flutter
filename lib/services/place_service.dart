import '../models/place.dart';
import 'api_client.dart';

class PlaceService {
  final ApiClient _apiClient;
  
  PlaceService(this._apiClient);
  
  // Add place to date record
  Future<Place> addPlace(Place place) async {
    try {
      final response = await _apiClient.post(
        '/date-records/${place.dateRecordId}/places',
        data: place.toJson(),
      );
      return Place.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get places for a date record
  Future<List<Place>> getPlacesForDateRecord(String dateRecordId) async {
    try {
      final response = await _apiClient.get('/date-records/$dateRecordId/places');
      
      final List<dynamic> data = response.data;
      return data.map((json) => Place.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get place by ID
  Future<Place> getPlace(String id) async {
    try {
      final response = await _apiClient.get('/places/$id');
      return Place.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Update place
  Future<Place> updatePlace(Place place) async {
    try {
      final response = await _apiClient.put(
        '/places/${place.id}',
        data: place.toJson(),
      );
      return Place.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete place
  Future<void> deletePlace(String id) async {
    try {
      await _apiClient.delete('/places/$id');
    } catch (e) {
      rethrow;
    }
  }
  
  // Get frequently visited places
  Future<List<Place>> getFrequentPlaces({int limit = 10}) async {
    try {
      final response = await _apiClient.get('/places/frequent', queryParameters: {
        'limit': limit,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => Place.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Search places by name or address
  Future<List<Place>> searchPlaces(String query) async {
    try {
      final response = await _apiClient.get('/places/search', queryParameters: {
        'query': query,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => Place.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get places by category
  Future<List<Place>> getPlacesByCategory(PlaceCategory category) async {
    try {
      final response = await _apiClient.get('/places/category', queryParameters: {
        'category': category.toString().split('.').last,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => Place.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}