import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/bike_model.dart';

class BikeRepository {
  final SupabaseClient _client;
  BikeRepository(this._client);

  Future<List<BikeModel>> getBikes() async {
    final response = await _client.from(SupabaseConstants.bikesTable).select().order('model');
    return (response as List).map((json) => BikeModel.fromJson(json)).toList();
  }

  Future<List<BikeModel>> getBikesByStation(String stationId) async {
    final response = await _client
        .from(SupabaseConstants.bikesTable)
        .select()
        .eq('station_id', stationId)
        .eq('status', 'available')
        .order('model');
    return (response as List).map((json) => BikeModel.fromJson(json)).toList();
  }

  Future<BikeModel?> getBikeById(String id) async {
    final response = await _client.from(SupabaseConstants.bikesTable).select().eq('id', id).single();
    return BikeModel.fromJson(response);
  }

  Future<void> createBike(BikeModel bike) async {
    await _client.from(SupabaseConstants.bikesTable).insert(bike.toJson());
  }

  Future<void> updateBikeStatus(String bikeId, String status) async {
    await _client.from(SupabaseConstants.bikesTable).update({'status': status}).eq('id', bikeId);
  }

  Future<void> updateBike(BikeModel bike) async {
    await _client.from(SupabaseConstants.bikesTable).update(bike.toJson()).eq('id', bike.id);
  }

  Future<void> deleteBike(String id) async {
    await _client.from(SupabaseConstants.bikesTable).delete().eq('id', id);
  }
}
