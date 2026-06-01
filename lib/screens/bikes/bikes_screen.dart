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
    final bikesAsync = station != null
        ? ref.watch(bikesByStationProvider(station.id))
        : const AsyncValue.data(<BikeModel>[]);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(station?.name ?? 'Bicycles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (station != null) {
                ref.invalidate(bikesByStationProvider(station.id));
              }
            },
          ),
        ],
      ),
      body: bikesAsync.when(
        data: (bikes) {
          final availableBikes = bikes
              .where((b) => b.status == AppConstants.bikeAvailable)
              .toList();
          final otherBikes = bikes
              .where((b) => b.status != AppConstants.bikeAvailable)
              .toList();
          final allBikes = [...availableBikes, ...otherBikes];

          if (allBikes.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allBikes.length,
            itemBuilder: (context, index) {
              final bike = allBikes[index];
              return _buildBikeCard(context, ref, bike);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('An error occurred: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (station != null) {
                    ref.invalidate(bikesByStationProvider(station.id));
                  }
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBikeCard(BuildContext context, WidgetRef ref, BikeModel bike) {
    final theme = Theme.of(context);
    final isAvailable = bike.status == AppConstants.bikeAvailable;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isAvailable
            ? () {
                ref.read(selectedBikeProvider.notifier).state = bike;
                context.push('/booking');
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pedal_bike,
                  color: isAvailable ? theme.colorScheme.primary : Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.model,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isAvailable ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Rented',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isAvailable ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isAvailable)
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.colorScheme.primary),
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
          Text(
            'No bicycles available at this station',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
