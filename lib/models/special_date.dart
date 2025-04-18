import 'package:uuid/uuid.dart';

enum SpecialDateType { ANNIVERSARY, BIRTHDAY, SPECIAL_EVENT }

class SpecialDate {
  final String id;
  final String coupleId;
  final DateTime date;
  String title;
  String? description;
  SpecialDateType type;
  final DateTime createdAt;
  DateTime updatedAt;

  SpecialDate({
    String? id,
    required this.coupleId,
    required this.date,
    required this.title,
    this.description,
    this.type = SpecialDateType.SPECIAL_EVENT,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory SpecialDate.fromJson(Map<String, dynamic> json) {
    return SpecialDate(
      id: json['id'],
      coupleId: json['couple_id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
      type: SpecialDateType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SpecialDateType.SPECIAL_EVENT,
      ),
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
      'description': description,
      'type': type.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SpecialDate copyWith({
    String? title,
    String? description,
    SpecialDateType? type,
  }) {
    return SpecialDate(
      id: this.id,
      coupleId: this.coupleId,
      date: this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Calculate days until this special date
  int get daysUntilDate {
    final today = DateTime.now();
    final nextOccurrence = _getNextOccurrence(today);
    final difference = nextOccurrence.difference(today);
    return difference.inDays;
  }

  // Get the next occurrence of this special date
  DateTime _getNextOccurrence(DateTime fromDate) {
    final specialDateThisYear = DateTime(
      fromDate.year,
      date.month,
      date.day,
    );
    
    if (specialDateThisYear.isAfter(fromDate)) {
      return specialDateThisYear;
    } else {
      return DateTime(
        fromDate.year + 1,
        date.month,
        date.day,
      );
    }
  }
}