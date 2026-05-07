import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/station_model.dart';
import '../data/repositories/station_repository.dart';

final stationRepositoryProvider = Provider<StationRepository>((ref) {
  return StationRepository(Supabase.instance.client);
});

final stationsProvider = FutureProvider<List<StationModel>>((ref) async {
  final repository = ref.watch(stationRepositoryProvider);
  return repository.getStations();
});

final selectedStationProvider = StateProvider<StationModel?>((ref) => null);
