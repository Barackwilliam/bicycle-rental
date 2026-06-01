// lib/presentation/screens/admin/admin_bikes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/station_provider.dart';
import '../../../core/theme/app_theme.dart';

class AdminBikesScreen extends ConsumerWidget {
  const AdminBikesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikesAsync = ref.watch(allBikesProvider);
    final stationsAsync = ref.watch(stationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Bikes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(allBikesProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Bike',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _showAddBikeDialog(
          context,
          ref,
          stationsAsync.value ?? [],
        ),
      ),
      body: bikesAsync.when(
        data: (bikes) => bikes.isEmpty
            ? const Center(
                child: Text('No bikes available'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bikes.length,
                itemBuilder: (context, i) {
                  final bike = bikes[i];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_bike,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bike.model,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                bike.station?.name ?? '',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusChip(bike.status),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () async {
                            await ref
                                .read(bikeRepoProvider)
                                .deleteBike(bike.id);

                            ref.refresh(allBikesProvider);
                            ref.refresh(stationsProvider);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e'),
        ),
      ),
    );
  }

  void _showAddBikeDialog(
    BuildContext context,
    WidgetRef ref,
    List stations,
  ) {
    final modelCtrl = TextEditingController();
    String? selectedStation;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Bike'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: modelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bike Model',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Station',
                ),
                value: selectedStation,
                items: stations
                    .map<DropdownMenuItem<String>>(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedStation = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (modelCtrl.text.isEmpty || selectedStation == null) {
                  return;
                }

                await ref.read(bikeRepoProvider).createBike(
                      stationId: selectedStation!,
                      model: modelCtrl.text.trim(),
                    );

                ref.refresh(allBikesProvider);
                ref.refresh(stationsProvider);

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'available':
        color = AppColors.secondary;
        label = 'Available';
        break;

      case 'rented':
        color = AppColors.warning;
        label = 'Rented';
        break;

      default:
        color = AppColors.error;
        label = 'Maintenance';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
