import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConstants {
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'https://vfjmutafisnrgbvpfacg.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmam11dGFmaXNucmdidnBmYWNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNjE2ODMsImV4cCI6MjA5MzczNzY4M30.9E2TFbj1h2_vnW7TswT9RfH7IiR8Tvw8nE-Zq10OovY';

  // Table names
  static const String usersTable = 'users';
  static const String stationsTable = 'stations';
  static const String bikesTable = 'bikes';
  static const String bookingsTable = 'bookings';
}

// Helper extension
extension SupabaseClientExtension on SupabaseClient {
  dynamic get usersTable => from(SupabaseConstants.usersTable);
  dynamic get stationsTable => from(SupabaseConstants.stationsTable);
  dynamic get bikesTable => from(SupabaseConstants.bikesTable);
  dynamic get bookingsTable => from(SupabaseConstants.bookingsTable);
}
