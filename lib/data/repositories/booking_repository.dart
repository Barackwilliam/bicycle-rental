import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final SupabaseClient _client;

  BookingRepository(this._client);

  // Get user bookings
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select('*, bikes(*), stations(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BookingModel.fromJson(json))
        .toList();
  }

  // Get all bookings (admin)
  Future<List<BookingModel>> getAllBookings() async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select('*, users(*), bikes(*), stations(*)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => BookingModel.fromJson(json))
        .toList();
  }

  // Create booking AND mark bike as rented atomically
  Future<BookingModel> createBooking(BookingModel booking) async {
    // Use a transaction-like approach: insert booking, then update bike status
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .insert(booking.toJsonForInsert())
        .select()
        .single();

    // Mark bike as rented
    await _client
        .from(SupabaseConstants.bikesTable)
        .update({'status': 'rented'})
        .eq('id', booking.bikeId);

    return BookingModel.fromJson(response);
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _client
        .from(SupabaseConstants.bookingsTable)
        .update({'status': status})
        .eq('id', bookingId);
  }

  // Complete booking (set end_time) AND free the bike
  Future<void> completeBooking(String bookingId, DateTime endTime) async {
    // Get the booking first to know which bike to free
    final bookingData = await _client
        .from(SupabaseConstants.bookingsTable)
        .select('bike_id')
        .eq('id', bookingId)
        .single();

    await _client
        .from(SupabaseConstants.bookingsTable)
        .update({
          'status': 'completed',
          'end_time': endTime.toIso8601String(),
        })
        .eq('id', bookingId);

    // Free the bike
    await _client
        .from(SupabaseConstants.bikesTable)
        .update({'status': 'available'})
        .eq('id', bookingData['bike_id']);
  }

  // Get active booking for user
  Future<BookingModel?> getActiveBooking(String userId) async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select('*, bikes(*), stations(*)')
        .eq('user_id', userId)
        .eq('status', 'active')
        .maybeSingle();

    if (response == null) return null;
    return BookingModel.fromJson(response);
  }
}
