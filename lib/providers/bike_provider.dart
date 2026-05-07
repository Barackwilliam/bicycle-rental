import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/bike_model.dart';
import '../data/repositories/bike_repository.dart';

final bikeRepositoryProvider = Provider<BikeRepository>((ref) {
  return BikeRepository(Supabase.instance.client);
});

final bikesProvider = FutureProvider<List<BikeModel>>((ref) async {
  final repository = ref.watch(bikeRepositoryProvider);
  return repository.getBikes();
});

final bikesByStationProvider = FutureProvider.family<List<BikeModel>, String>((ref, stationId) async {
  final repository = ref.watch(bikeRepositoryProvider);
  return repository.getBikesByStation(stationId);
});

final selectedBikeProvider = StateProvider<BikeModel?>((ref) => null);
