// lib/data/repositories/station_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/station_model.dart';
import '../../core/constants/supabase_constants.dart';

class StationRepository {
  final SupabaseClient _client;
  StationRepository(this._client);

  Future<List<StationModel>> getStations() async {
    final response = await _client
        .from(SupabaseConstants.stationsTable)
        .select('*, bikes(id, status)')
        .order('name');

    return (response as List).map((json) {
      final bikes = json['bikes'] as List? ?? [];
      final available = bikes.where((b) => b['status'] == 'available').length;
      return StationModel.fromJson({...json, 'available_bikes': available});
    }).toList();
  }

  Future<StationModel> createStation({
    required String name,
    required String location,
    required int totalSlots,
  }) async {
    final response = await _client
        .from(SupabaseConstants.stationsTable)
        .insert({'name': name, 'location': location, 'total_slots': totalSlots})
        .select()
        .single();
    return StationModel.fromJson(response);
  }

  Future<void> deleteStation(String id) async {
    await _client.from(SupabaseConstants.stationsTable).delete().eq('id', id);
  }
}
