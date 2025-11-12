import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static late final SupabaseClient _client;

  static Future<void> init() async {
    const supabaseUrl = 'https://sbzwwewovvbtzyvrvpeh.supabase.co'; 
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNiend3ZXdvdnZidHp5dnJ2cGVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5OTY2MTgsImV4cCI6MjA3NjU3MjYxOH0.gMFWTAt6aQmfGetEFin4eoc90kE9E-Ibpnw_0AKo_AI'; 

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  static SupabaseClient get client => _client;
}
