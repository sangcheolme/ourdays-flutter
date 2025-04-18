import '../models/comment.dart';
import 'api_client.dart';

class CommentService {
  final ApiClient _apiClient;
  
  CommentService(this._apiClient);
  
  // Add comment to date record
  Future<Comment> addComment(Comment comment) async {
    try {
      final response = await _apiClient.post(
        '/date-records/${comment.dateRecordId}/comments',
        data: comment.toJson(),
      );
      return Comment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get comments for a date record
  Future<List<Comment>> getCommentsForDateRecord(String dateRecordId) async {
    try {
      final response = await _apiClient.get('/date-records/$dateRecordId/comments');
      
      final List<dynamic> data = response.data;
      return data.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  // Update comment
  Future<Comment> updateComment(Comment comment) async {
    try {
      final response = await _apiClient.put(
        '/comments/${comment.id}',
        data: comment.toJson(),
      );
      return Comment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete comment
  Future<void> deleteComment(String id) async {
    try {
      await _apiClient.delete('/comments/$id');
    } catch (e) {
      rethrow;
    }
  }
  
  // Get comment by ID
  Future<Comment> getComment(String id) async {
    try {
      final response = await _apiClient.get('/comments/$id');
      return Comment.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get recent comments
  Future<List<Comment>> getRecentComments({int limit = 10}) async {
    try {
      final response = await _apiClient.get('/comments/recent', queryParameters: {
        'limit': limit,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}