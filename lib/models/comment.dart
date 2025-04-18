import 'package:uuid/uuid.dart';

class Comment {
  final String id;
  final String dateRecordId;
  final String userId;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;

  Comment({
    String? id,
    required this.dateRecordId,
    required this.userId,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      dateRecordId: json['date_record_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_record_id': dateRecordId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Comment copyWith({
    String? content,
  }) {
    return Comment(
      id: this.id,
      dateRecordId: this.dateRecordId,
      userId: this.userId,
      content: content ?? this.content,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}