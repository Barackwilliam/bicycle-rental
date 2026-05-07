import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final SupabaseClient _client;
  BookingRepository(this._client);

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => BookingModel.fromJson(json)).toList();
  }

  Future<List<BookingModel>> getAllBookings() async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((json) => BookingModel.fromJson(json)).toList();
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .insert(booking.toJson())
        .select()
        .single();
    return BookingModel.fromJson(response);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _client.from(SupabaseConstants.bookingsTable).update({'status': status}).eq('id', bookingId);
  }

  Future<void> completeBooking(String bookingId, DateTime endTime) async {
    await _client.from(SupabaseConstants.bookingsTable).update({
      'status': 'completed',
      'end_time': endTime.toIso8601String(),
    }).eq('id', bookingId);
  }

  Future<BookingModel?> getActiveBooking(String userId) async {
    final response = await _client
        .from(SupabaseConstants.bookingsTable)
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .maybeSingle();
    if (response == null) return null;
    return BookingModel.fromJson(response);
  }
}
