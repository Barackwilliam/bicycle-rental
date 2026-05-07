class BookingModel {
  final String id;
  final String userId;
  final String bikeId;
  final String stationId;
  final DateTime startTime;
  final DateTime? endTime;
  final int hours;
  final double totalCost;
  final String status;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.stationId,
    required this.startTime,
    this.endTime,
    this.hours = 1,
    this.totalCost = 0.0,
    this.status = 'active',
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bikeId: json['bike_id'] ?? '',
      stationId: json['station_id'] ?? '',
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      hours: json['hours'] ?? 1,
      totalCost: (json['total_cost'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bike_id': bikeId,
      'station_id': stationId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'hours': hours,
      'total_cost': totalCost,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
