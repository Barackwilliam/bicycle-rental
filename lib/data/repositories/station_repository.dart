import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/station_model.dart';

class StationRepository {
  final SupabaseClient _client;

  StationRepository(this._client);

  // Get all stations
  Future<List<StationModel>> getStations() async {
    final response = await _client
        .from(SupabaseConstants.stationsTable)
        .select()
        .order('name');

    return (response as List)
        .map((json) => StationModel.fromJson(json))
        .toList();
  }

  // Get station by id
  Future<StationModel?> getStationById(String id) async {
    final response = await _client
        .from(SupabaseConstants.stationsTable)
        .select()
        .eq('id', id)
        .single();

    return StationModel.fromJson(response);
  }

  // Create station (admin only)
  Future<void> createStation(StationModel station) async {
    await _client
        .from(SupabaseConstants.stationsTable)
        .insert(station.toJson());
  }

  // Update station (admin only)
  Future<void> updateStation(StationModel station) async {
    await _client
        .from(SupabaseConstants.stationsTable)
        .update(station.toJson())
        .eq('id', station.id);
  }

  // Delete station (admin only)
  Future<void> deleteStation(String id) async {
    await _client
        .from(SupabaseConstants.stationsTable)
        .delete()
        .eq('id', id);
  }
}
