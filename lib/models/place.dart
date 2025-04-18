import 'package:uuid/uuid.dart';

enum PlaceCategory { RESTAURANT, CAFE, MOVIE, SHOPPING, ATTRACTION, ACTIVITY, ACCOMMODATION, OTHER, TRAVEL }

class Place {
  final String id;
  final String dateRecordId;
  String name;
  String address;
  double latitude;
  double longitude;
  PlaceCategory category;
  int rating;
  String review;
  final DateTime createdAt;
  DateTime updatedAt;

  Place({
    String? id,
    required this.dateRecordId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.category = PlaceCategory.OTHER,
    this.rating = 0,
    required this.review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      dateRecordId: json['dateRecordId'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      category: PlaceCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => PlaceCategory.OTHER,
      ),
      rating: json['rating'] ?? 0,
      review: json['review'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateRecordId': dateRecordId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'category': category.toString().split('.').last,
      'rating': rating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Place copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    PlaceCategory? category,
    int? rating,
    String? review,
  }) {
    return Place(
      id: this.id,
      dateRecordId: this.dateRecordId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}