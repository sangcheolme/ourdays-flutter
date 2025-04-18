import 'package:uuid/uuid.dart';

enum ReferenceType { DATE_RECORD, PLACE }
enum MediaType { IMAGE, VIDEO }

class Media {
  final String id;
  final String referenceId;
  final ReferenceType referenceType;
  final MediaType type;
  final String url;
  final String thumbnailUrl;
  final DateTime createdAt;
  DateTime updatedAt;

  Media({
    String? id,
    required this.referenceId,
    required this.referenceType,
    required this.type,
    required this.url,
    required this.thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      referenceId: json['referenceId'],
      referenceType: ReferenceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['referenceType'],
        orElse: () => ReferenceType.DATE_RECORD,
      ),
      type: MediaType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MediaType.IMAGE,
      ),
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceId': referenceId,
      'referenceType': referenceType.toString().split('.').last,
      'type': type.toString().split('.').last,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}