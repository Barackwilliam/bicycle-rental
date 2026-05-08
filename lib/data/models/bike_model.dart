// lib/data/models/bike_model.dart

import 'station_model.dart';

class BikeModel {
  final String id;
  final String stationId;
  final String status; // 'available', 'rented', 'maintenance'
  final String model;
  final StationModel? station; // joined
  final DateTime createdAt;

  const BikeModel({
    required this.id,
    required this.stationId,
    required this.status,
    required this.model,
    this.station,
    required this.createdAt,
  });

  bool get isAvailable => status == 'available';

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'] as String,
      stationId: json['station_id'] as String,
      status: json['status'] as String? ?? 'available',
      model: json['model'] as String? ?? 'Standard Bike',
      station: json['stations'] != null
          ? StationModel.fromJson(json['stations'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_id': stationId,
      'status': status,
      'model': model,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BikeModel copyWith({
    String? id,
    String? stationId,
    String? status,
    String? model,
    StationModel? station,
    DateTime? createdAt,
  }) {
    return BikeModel(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      status: status ?? this.status,
      model: model ?? this.model,
      station: station ?? this.station,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
