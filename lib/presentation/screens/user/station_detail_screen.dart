import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/station_provider.dart';
import '../../../data/models/station_model.dart';
import '../../../data/models/bike_model.dart';
import 'booking_screen.dart';

class StationDetailScreen extends ConsumerWidget {
  final StationModel station;
  const StationDetailScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikesAsync = ref.watch(bikesByStationProvider(station.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(station.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(bikesByStationProvider(station.id)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.location_on,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(station.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(station.location,
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '${station.availableBikes} available · ${station.totalSlots} slots',
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ]),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Available Bikes',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: bikesAsync.when(
              data: (bikes) {
                final available = bikes.where((b) => b.isAvailable).toList();
                final unavailable = bikes.where((b) => !b.isAvailable).toList();
                final all = [...available, ...unavailable];

                if (all.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_bike,
                            size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text('No bikes available at this station'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: all.length,
                  itemBuilder: (context, i) => _BikeCard(
                    bike: all[i],
                    onBook: all[i].isAvailable
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BookingScreen(bike: all[i])),
                            )
                        : null,
                  ),
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BikeCard extends StatelessWidget {
  final BikeModel bike;
  final VoidCallback? onBook;
  const _BikeCard({required this.bike, this.onBook});

  Color get _statusColor {
    switch (bike.status) {
      case AppConstants.bikeAvailable:
        return AppColors.secondary;
      case AppConstants.bikeRented:
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (bike.status) {
      case AppConstants.bikeAvailable:
        return 'Available';
      case AppConstants.bikeRented:
        return 'Rented';
      default:
        return 'Maintenance';
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
            Text(bike.model,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_statusLabel,
                  style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        if (onBook != null)
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Book', style: TextStyle(fontSize: 13)),
          ),
      ]),
    );
  }
}
