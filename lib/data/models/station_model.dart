// lib/data/models/station_model.dart

class StationModel {
  final String id;
  final String name;
  final String location;
  final int totalSlots;
  final int availableBikes; // computed / joined
  final DateTime createdAt;

  const StationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.totalSlots,
    this.availableBikes = 0,
    required this.createdAt,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      totalSlots: json['total_slots'] as int? ?? 0,
      availableBikes: json['available_bikes'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'total_slots': totalSlots,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StationModel copyWith({
    String? id,
    String? name,
    String? location,
    int? totalSlots,
    int? availableBikes,
    DateTime? createdAt,
  }) {
    return StationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      totalSlots: totalSlots ?? this.totalSlots,
      availableBikes: availableBikes ?? this.availableBikes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
