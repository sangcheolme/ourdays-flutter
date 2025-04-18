import 'package:uuid/uuid.dart';

enum Emotion { HAPPY, EXCITED, NORMAL, SAD, ANGRY, SURPRISED, LOVED }

class DateRecord {
  final String id;
  final String coupleId;
  final DateTime date;
  String title;
  String memo;
  Emotion emotion;
  final String createdBy;
  final DateTime createdAt;
  DateTime updatedAt;

  DateRecord({
    String? id,
    required this.coupleId,
    required this.date,
    required this.title,
    required this.memo,
    this.emotion = Emotion.HAPPY,
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory DateRecord.fromJson(Map<String, dynamic> json) {
    return DateRecord(
      id: json['id'],
      coupleId: json['couple_id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      memo: json['memo'],
      emotion: Emotion.values.firstWhere(
        (e) => e.toString().split('.').last == json['emotion'],
        orElse: () => Emotion.HAPPY,
      ),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'date': date.toIso8601String(),
      'title': title,
      'memo': memo,
      'emotion': emotion.toString().split('.').last,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DateRecord copyWith({
    String? title,
    String? memo,
    Emotion? emotion,
  }) {
    return DateRecord(
      id: this.id,
      coupleId: this.coupleId,
      date: this.date,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      emotion: emotion ?? this.emotion,
      createdBy: this.createdBy,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}