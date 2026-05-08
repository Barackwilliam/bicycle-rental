// lib/data/repositories/bike_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bike_model.dart';
import '../../core/constants/supabase_constants.dart';

class BikeRepository {
  final SupabaseClient _client;
  BikeRepository(this._client);

  Future<List<BikeModel>> getBikesByStation(String stationId) async {
    final response = await _client
        .from(SupabaseConstants.bikesTable)
        .select('*, stations(*)')
        .eq('station_id', stationId)
        .order('status');
    return (response as List).map((j) => BikeModel.fromJson(j)).toList();
  }

  Future<List<BikeModel>> getAllBikes() async {
    final response = await _client
        .from(SupabaseConstants.bikesTable)
        .select('*, stations(*)')
        .order('created_at', ascending: false);
    return (response as List).map((j) => BikeModel.fromJson(j)).toList();
  }

  Future<BikeModel> createBike({
    required String stationId,
    required String model,
  }) async {
    final response = await _client
        .from(SupabaseConstants.bikesTable)
        .insert({'station_id': stationId, 'model': model, 'status': 'available'})
        .select('*, stations(*)')
        .single();
    return BikeModel.fromJson(response);
  }

  Future<void> updateBikeStatus(String bikeId, String status) async {
    await _client
        .from(SupabaseConstants.bikesTable)
        .update({'status': status})
        .eq('id', bikeId);
  }

  Future<void> deleteBike(String id) async {
    await _client.from(SupabaseConstants.bikesTable).delete().eq('id', id);
  }
}
