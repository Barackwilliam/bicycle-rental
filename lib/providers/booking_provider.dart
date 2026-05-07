import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/booking_model.dart';
import '../data/repositories/booking_repository.dart';
import 'auth_provider.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(Supabase.instance.client);
});

final userBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repository.getUserBookings(user.id);
});

final allBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getAllBookings();
});

final activeBookingProvider = FutureProvider<BookingModel?>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return repository.getActiveBooking(user.id);
});

final bookingHoursProvider = StateProvider<int>((ref) => 1);

class BookingNotifier extends StateNotifier<AsyncValue<void>> {
  final BookingRepository _repository;
  BookingNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createBooking(BookingModel booking) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createBooking(booking);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeBooking(String bookingId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.completeBooking(bookingId, DateTime.now());
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final bookingNotifierProvider = StateNotifierProvider<BookingNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository);
});
