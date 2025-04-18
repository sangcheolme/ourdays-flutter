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
      dateRecordId: json['dateRecordId'],
      userId: json['userId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateRecordId': dateRecordId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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