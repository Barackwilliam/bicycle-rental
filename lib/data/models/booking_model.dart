// lib/data/models/booking_model.dart

import 'bike_model.dart';
import 'station_model.dart';
import 'user_model.dart';
import '../../../core/constants/app_constants.dart';

class BookingModel {
  final String id;
  final String userId;
  final String bikeId;
  final String stationId;
  final DateTime startTime;
  final DateTime? endTime;
  final int hours;
  final double totalCost;
  final String status; // 'active', 'completed', 'cancelled'

  // Joined
  final BikeModel? bike;
  final StationModel? station;
  final UserModel? user;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.stationId,
    required this.startTime,
    this.endTime,
    required this.hours,
    required this.totalCost,
    required this.status,
    this.bike,
    this.station,
    this.user,
  });

  bool get isActive => status == AppConstants.bookingActive;
  bool get isCompleted => status == AppConstants.bookingCompleted;

  Duration get elapsed => DateTime.now().difference(startTime);

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bikeId: json['bike_id'] as String,
      stationId: json['station_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      hours: json['hours'] as int? ?? 1,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? AppConstants.bookingActive,
      bike: json['bikes'] != null
          ? BikeModel.fromJson(json['bikes'] as Map<String, dynamic>)
          : null,
      station: json['stations'] != null
          ? StationModel.fromJson(json['stations'] as Map<String, dynamic>)
          : null,
      user: json['users'] != null
          ? UserModel.fromJson(json['users'] as Map<String, dynamic>)
          : null,
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
    };
  }
}
