import 'package:uuid/uuid.dart';

enum CoupleStatus { PENDING, ACTIVE, INACTIVE }

class Couple {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime anniversaryDate;
  CoupleStatus status;
  final DateTime createdAt;
  DateTime updatedAt;

  Couple({
    String? id,
    required this.user1Id,
    required this.user2Id,
    required this.anniversaryDate,
    this.status = CoupleStatus.PENDING,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory Couple.fromJson(Map<String, dynamic> json) {
    return Couple(
      id: json['id'],
      user1Id: json['user1Id'],
      user2Id: json['user2Id'],
      anniversaryDate: DateTime.parse(json['anniversaryDate']),
      status: CoupleStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => CoupleStatus.PENDING,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'anniversary_date': anniversaryDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Couple copyWith({
    CoupleStatus? status,
  }) {
    return Couple(
      id: this.id,
      user1Id: this.user1Id,
      user2Id: this.user2Id,
      anniversaryDate: this.anniversaryDate,
      status: status ?? this.status,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Calculate days since anniversary
  int get daysSinceAnniversary {
    final today = DateTime.now();
    final difference = today.difference(anniversaryDate);
    return difference.inDays;
  }

  // Calculate next anniversary date
  DateTime get nextAnniversaryDate {
    final today = DateTime.now();
    final anniversaryThisYear = DateTime(
      today.year,
      anniversaryDate.month,
      anniversaryDate.day,
    );
    
    if (anniversaryThisYear.isAfter(today)) {
      return anniversaryThisYear;
    } else {
      return DateTime(
        today.year + 1,
        anniversaryDate.month,
        anniversaryDate.day,
      );
    }
  }

  // Calculate days until next anniversary
  int get daysUntilNextAnniversary {
    final today = DateTime.now();
    final difference = nextAnniversaryDate.difference(today);
    return difference.inDays;
  }

  String? get inviteCode => null;
}