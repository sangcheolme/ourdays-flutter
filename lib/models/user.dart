import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String email;
  String name;
  String? profileImageUrl;
  final DateTime createdAt;
  DateTime updatedAt;

  User({
    String? id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt, required profileImage,
  }) : 
    this.id = id ?? const Uuid().v4(),
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profileImageUrl: json['profile_image'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profileImage: null,
    );
  }

  get profileImage => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? profileImageUrl,
  }) {
    return User(
      id: this.id,
      email: this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(), profileImage: null,
    );
  }
}