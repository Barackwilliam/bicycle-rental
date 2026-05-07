class BikeModel {
  final String id;
  final String stationId;
  final String model;
  final String status;
  final DateTime? createdAt;

  const BikeModel({
    required this.id,
    required this.stationId,
    this.model = 'Standard Bike',
    this.status = 'available',
    this.createdAt,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'] ?? '',
      stationId: json['station_id'] ?? '',
      model: json['model'] ?? 'Standard Bike',
      status: json['status'] ?? 'available',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_id': stationId,
      'model': model,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
