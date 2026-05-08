import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bike_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/station_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _hours = 1;

  @override
  Widget build(BuildContext context) {
    final bike = ref.watch(selectedBikeProvider);
    final station = ref.watch(selectedStationProvider);
    final user = ref.watch(currentUserProvider);
    final bookingState = ref.watch(bookingNotifierProvider);
    final theme = Theme.of(context);

    if (bike == null || station == null || user == null) {
      return const Scaffold(body: Center(child: Text('Information not available')));
    }

    final totalCost = _hours * AppConstants.hourlyRate;

    ref.listen(bookingNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bike rented successfully!'), backgroundColor: Colors.green),
          );
          context.go('/home');
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Rent Bike')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.pedal_bike, size: 48, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bike.model, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            Text(station.name, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Select Duration (hours)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _hours > 1 ? () => setState(() => _hours--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 32,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$_hours', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ),
                  IconButton(
                    onPressed: _hours < 24 ? () => setState(() => _hours++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 32,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Tsh ${NumberFormat('#,###').format(AppConstants.hourlyRate)}/hour', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 32),
              Card(
                color: theme.colorScheme.primary.withAlpha(13),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCostRow('Hourly Rate', AppConstants.hourlyRate),
                      const Divider(),
                      _buildCostRow('Hours', _hours.toDouble(), isCount: true),
                      const Divider(),
                      _buildCostRow('Total', totalCost, isTotal: true),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: bookingState.isLoading ? null : () => _confirmBooking(bike.id, station.id, user.id, totalCost),
                  child: bookingState.isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('PAY TSH ${NumberFormat('#,###').format(totalCost)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, double value, {bool isTotal = false, bool isCount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            isCount ? value.toInt().toString() : 'Tsh ${NumberFormat('#,###').format(value)}',
            style: TextStyle(fontSize: isTotal ? 20 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isTotal ? Colors.green[700] : null),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking(String bikeId, String stationId, String userId, double totalCost) async {
    final booking = BookingModel(
      id: '',
      userId: userId,
      bikeId: bikeId,
      stationId: stationId,
      startTime: DateTime.now(),
      hours: _hours,
      totalCost: totalCost,
      status: AppConstants.bookingActive,
    );
    await ref.read(bookingNotifierProvider.notifier).createBooking(booking);
  }
}
