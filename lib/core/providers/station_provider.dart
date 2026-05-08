// lib/core/providers/station_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/station_model.dart';
import '../../data/models/bike_model.dart';
import '../../data/repositories/station_repository.dart';
import '../../data/repositories/bike_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking_model.dart';
import 'auth_provider.dart' as auth;

// Repos
final stationRepoProvider = Provider((ref) =>
    StationRepository(Supabase.instance.client));

final bikeRepoProvider = Provider((ref) =>
    BikeRepository(Supabase.instance.client));

final bookingRepoProvider = Provider((ref) =>
    BookingRepository(Supabase.instance.client));

// Stations list
final stationsProvider = FutureProvider<List<StationModel>>((ref) async {
  return ref.read(stationRepoProvider).getStations();
});

// Bikes by station
final bikesByStationProvider =
    FutureProvider.family<List<BikeModel>, String>((ref, stationId) async {
  return ref.read(bikeRepoProvider).getBikesByStation(stationId);
});

// All bikes (admin)
final allBikesProvider = FutureProvider<List<BikeModel>>((ref) async {
  return ref.read(bikeRepoProvider).getAllBikes();
});

// All bookings (admin)
final allBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  return ref.read(bookingRepoProvider).getAllBookings();
});

// Active booking for current user
final activeBookingProvider = FutureProvider<BookingModel?>((ref) async {
  final user = ref.watch(auth.authProvider).user;
  if (user == null) return null;
  return ref.read(bookingRepoProvider).getActiveBooking(user.id);
});

// User bookings history
final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final user = ref.watch(auth.authProvider).user;
  if (user == null) return [];
  return ref.read(bookingRepoProvider).getUserBookings(user.id);
});
