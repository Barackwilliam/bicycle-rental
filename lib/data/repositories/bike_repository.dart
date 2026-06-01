import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../models/bike_model.dart';

class BikeRepository {
  final SupabaseClient _client;

  BikeRepository(this._client);

  // Get all bikes
  Future<List<BikeModel>> getBikes() async {
    final response = await _client
        .from(SupabaseConstants.bikesTable)
        .select()
        .order('model');

    return (response as List)
        .map((json) => BikeModel.fromJson(json))
        .toList();
  }

  // Get bikes by station
  Future<List<BikeModel>> getBikesByStation(String stationId) async {
    final response = await _client
        .from(SupabaseConstants.bikesTable)
        .select()
        .eq('station_id', stationId)
        .eq('status', 'available')
        .order('model');

    return (response as List)
        .map((json) => BikeModel.fromJson(json))
        .toList();
  }

  // Get bike by id
  Future<BikeModel?> getBikeById(String id) async {
    final response = await _client
        .from(SupabaseConstants.bikesTable)
        .select()
        .eq('id', id)
        .single();

    return BikeModel.fromJson(response);
  }

  // Create bike (admin only)
  Future<void> createBike(BikeModel bike) async {
    await _client
        .from(SupabaseConstants.bikesTable)
        .insert(bike.toJson());
  }

  // Update bike status
  Future<void> updateBikeStatus(String bikeId, String status) async {
    await _client
        .from(SupabaseConstants.bikesTable)
        .update({'status': status})
        .eq('id', bikeId);
  }

  // Update bike (admin only)
  Future<void> updateBike(BikeModel bike) async {
    await _client
        .from(SupabaseConstants.bikesTable)
        .update(bike.toJson())
        .eq('id', bike.id);
  }

  // Delete bike (admin only)
  Future<void> deleteBike(String id) async {
    await _client
        .from(SupabaseConstants.bikesTable)
        .delete()
        .eq('id', id);
  }
}
