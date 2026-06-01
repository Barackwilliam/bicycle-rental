import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/booking_model.dart';
import '../data/repositories/booking_repository.dart';
import 'auth_provider.dart';

// Repository provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(Supabase.instance.client);
});

// User bookings provider
final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repository.getUserBookings(user.id);
});

// All bookings provider (admin)
final allBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getAllBookings();
});

// Active booking provider
final activeBookingProvider = FutureProvider<BookingModel?>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return repository.getActiveBooking(user.id);
});

// Booking hours provider
final bookingHoursProvider = StateProvider<int>((ref) => 1);

// Create booking notifier
class BookingNotifier extends StateNotifier<AsyncValue<void>> {
  final BookingRepository _repository;
  final Ref _ref;

  BookingNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> createBooking(BookingModel booking) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createBooking(booking);
      // Invalidate relevant providers so UI refreshes
      _ref.invalidate(userBookingsProvider);
      _ref.invalidate(activeBookingProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeBooking(String bookingId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.completeBooking(bookingId, DateTime.now());
      _ref.invalidate(userBookingsProvider);
      _ref.invalidate(activeBookingProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository, ref);
});
