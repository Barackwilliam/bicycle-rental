import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/booking_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking History')),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) return _buildEmptyState(context);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) => _buildBookingCard(context, bookings[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, dynamic booking) {
    final isActive = booking.status == AppConstants.bookingActive;
    final isCompleted = booking.status == AppConstants.bookingCompleted;
    final statusColor = isActive ? Colors.green : (isCompleted ? Colors.blue : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking #${booking.id.substring(0, 8)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                  child: Text(booking.status.toUpperCase(), style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [Icon(Icons.pedal_bike, size: 20, color: theme.colorScheme.primary), const SizedBox(width: 8), Text('${booking.hours} hours', style: theme.textTheme.bodyMedium)]),
            const SizedBox(height: 8),
            Row(children: [Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.primary), const SizedBox(width: 8), Text(DateFormat('dd/MM/yyyy HH:mm').format(booking.startTime), style: theme.textTheme.bodyMedium)]),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: theme.textTheme.titleSmall),
                Text('Tsh ${NumberFormat('#,###').format(booking.totalCost)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No booking history', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
      children: [
          Icon(Icons.pedal_bike, size: 80, color: Colors