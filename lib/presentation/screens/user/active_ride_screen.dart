// lib/presentation/screens/user/active_ride_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/station_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/booking_model.dart';
import 'home_screen.dart';

class ActiveRideScreen extends ConsumerStatefulWidget {
  final BookingModel booking;

  const ActiveRideScreen({
    super.key,
    required this.booking,
  });

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  late Timer _timer;
  late Duration _elapsed;
  bool _returning = false;

  @override
  void initState() {
    super.initState();

    _elapsed = DateTime.now().difference(widget.booking.startTime);

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          _elapsed = DateTime.now().difference(widget.booking.startTime);
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final h = _elapsed.inHours.toString().padLeft(2, '0');

    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');

    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  Future<void> _returnBike() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Return Bike'),
        content: const Text(
          'Are you sure you want to return the bike now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Return'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _returning = true);

    try {
      await ref.read(bookingRepoProvider).returnBike(
            widget.booking.id,
            widget.booking.bikeId,
          );

      ref.refresh(stationsProvider);
      ref.refresh(activeBookingProvider);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (_) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bike returned successfully.'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );

        setState(() => _returning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookedHours = widget.booking.hours;

    final progress =
        (_elapsed.inSeconds / (bookedHours * 3600)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Ride'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Timer card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_bike,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.booking.bike?.model ?? 'Bike',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.booking.station?.name ?? '',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elapsed Time',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      color: progress > 0.9
                          ? AppColors.error
                          : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$bookedHours hours booked',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                children: [
                  _detailRow(
                    'Cost',
                    '${AppConstants.currency} ${widget.booking.totalCost.toStringAsFixed(0)}',
                  ),
                  const Divider(height: 20),
                  _detailRow(
                    'Start Time',
                    _formatTime(
                      widget.booking.startTime,
                    ),
                  ),
                  const Divider(height: 20),
                  _detailRow(
                    'Duration',
                    '$bookedHours hours',
                  ),
                ],
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _returning ? null : _returnBike,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: _returning
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Return Bike',
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
