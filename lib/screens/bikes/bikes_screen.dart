import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/bike_model.dart';
import '../../providers/bike_provider.dart';
import '../../providers/station_provider.dart';

class BikesScreen extends ConsumerWidget {
  const BikesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final station = ref.watch(selectedStationProvider);
    final bikesAsync = station != null ? ref.watch(bikesByStationProvider(station.id)) : const AsyncValue.data(<BikeModel>[]);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(station?.name ?? 'Bikes')),
      body: bikesAsync.when(
        data: (bikes) {
          if (bikes.isEmpty) return _buildEmptyState(context);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bikes.length,
            itemBuilder: (context, index) => _buildBikeCard(context, ref, bikes[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildBikeCard(BuildContext context, WidgetRef ref, BikeModel bike) {
    final theme = Theme.of(context);
    final isAvailable = bike.status == AppConstants.bikeAvailable;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isAvailable ? () {
          ref.read(selectedBikeProvider.notifier).state = bike;
          context.push('/booking');
        } : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: isAvailable ? theme.colorScheme.primary.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pedal_bike, color: isAvailable ? theme.colorScheme.primary : Colors.grey, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bike.model, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Rented',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isAvailable ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isAvailable) const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pedal_bike, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No bikes available', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
