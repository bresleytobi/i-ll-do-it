import 'package:equatable/equatable.dart';

/// User model for the app
class User extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? location;
  final List<String> skills;
  final double rating;
  final int completedJobs;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    this.phone,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.location,
    this.skills = const [],
    this.rating = 0,
    this.completedJobs = 0,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? location,
    List<String>? skills,
    double? rating,
    int? completedJobs,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        displayName,
        bio,
        avatarUrl,
        location,
        skills,
        rating,
        completedJobs,
        isVerified,
        createdAt,
        updatedAt,
      ];
}
