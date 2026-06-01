// lib/presentation/screens/user/my_rides_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/station_provider.dart';
import '../../../data/models/booking_model.dart';

class MyRidesScreen extends ConsumerWidget {
  const MyRidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Rides')),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.history, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                const Text('You have not made any rides yet'),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, i) => _RideCard(booking: bookings[i]),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final BookingModel booking;
  const _RideCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case AppConstants.bookingActive:
        return AppColors.secondary;
      case AppConstants.bookingCompleted:
        return AppColors.primary;
      default:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case AppConstants.bookingActive:
        return 'Active';
      case AppConstants.bookingCompleted:
        return 'Completed';
      default:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.directions_bike, color: _statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(booking.bike?.model ?? 'Bike',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 3),
            Text(booking.station?.name ?? '',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              '${booking.hours} hrs · ${AppConstants.currency} ${booking.totalCost.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_statusLabel,
              style: TextStyle(
                  color: _statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
