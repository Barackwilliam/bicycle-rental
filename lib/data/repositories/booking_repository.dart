// lib/data/repositories/booking_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/constants/app_constants.dart';

class BookingRepository {
  final SupabaseClient _client;
  BookingRepository(this._client);

  Future<BookingModel> createBooking({
    required String userId,
    required String bikeId,
    required String stationId,
    required int hours,
  }) async {
    final totalCost = hours * AppConstants.pricePerHour;

    // Create booking
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .insert({
          'user_id': userId,
          'bike_id': bikeId,
          'station_id': stationId,
          'hours': hours,
          'total_cost': totalCost,
          'status': AppConstants.bookingActive,
          'start_time': DateTime.now().toIso8601String(),
        })
        .select('*, bikes(*, stations(*)), stations(*)')
        .single();

    // Mark bike as rented
    await _client
        .from(SupabaseConstants.bikesTable)
        .update({'status': AppConstants.bikeRented})
        .eq('id', bikeId);

    return BookingModel.fromJson(response);
  }

  Future<BookingModel?> getActiveBooking(String userId) async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select('*, bikes(*, stations(*)), stations(*)')
        .eq('user_id', userId)
        .eq('status', AppConstants.bookingActive)
        .maybeSingle();

    if (response == null) return null;
    return BookingModel.fromJson(response);
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select('*, bikes(*, stations(*)), stations(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((j) => BookingModel.fromJson(j)).toList();
  }

  Future<List<BookingModel>> getAllBookings() async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select('*, bikes(*), stations(*), users(*)')
        .order('created_at', ascending: false);
    return (response as List).map((j) => BookingModel.fromJson(j)).toList();
  }

  Future<void> returnBike(String bookingId, String bikeId) async {
    await _client
        .from(SupabaseConstants.bookingsTable)
        .update({
          'status': AppConstants.bookingCompleted,
          'end_time': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);

    await _client
        .from(SupabaseConstants.bikesTable)
        .update({'status': AppConstants.bikeAvailable})
        .eq('id', bikeId);
  }
}
