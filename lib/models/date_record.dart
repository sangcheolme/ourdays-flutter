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
      coupleId: json['coupleId'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      memo: json['memo'],
      emotion: Emotion.values.firstWhere(
        (e) => e.toString().split('.').last == json['emotion'],
        orElse: () => Emotion.HAPPY,
      ),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'date': date.toIso8601String(),
      'title': title,
      'memo': memo,
      'emotion': emotion.toString().split('.').last,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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