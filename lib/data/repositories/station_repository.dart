import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/station_model.dart';

class StationRepository {
  final SupabaseClient _client;
  StationRepository(this._client);

  Future<List<StationModel>> getStations() async {
    final response = await _client.from(SupabaseConstants.stationsTable).select().order('name');
    return (response as List).map((json) => StationModel.fromJson(json)).toList();
  }

  Future<StationModel?> getStationById(String id) async {
    final response = await _client.from(SupabaseConstants.stationsTable).select().eq('id', id).single();
    return StationModel.fromJson(response);
  }

  Future<void> createStation(StationModel station) async {
    await _client.from(SupabaseConstants.stationsTable).insert(station.toJson());
  }

  Future<void> updateStation(StationModel station) async {
    await _client.from(SupabaseConstants.stationsTable).update(station.toJson()).eq('id', station.id);
  }

  Future<void> deleteStation(String id) async {
    await _client.from(SupabaseConstants.stationsTable).delete().eq('id', id);
  }
}
