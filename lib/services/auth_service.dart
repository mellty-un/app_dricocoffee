import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'users';

  Future<String?> signUp({
    required String email,
    required String name,
    required String password,
    String role = 'officer',
  }) async {
    try {
      final existingUser = await _client
          .from(_table)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        return 'Email sudah terdaftar';
      }
      await _client.from(_table).insert({
        'email': email,
        'name': name,
        'password': password,
        'role': role,
      });

      return 'Sign up berhasil';
    } catch (e) {
      return 'Gagal sign up: $e';
    }
  }
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client
          .from(_table)
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (res == null) {
        return null; 
      }
      return res;
    } catch (e) {
      print('Error login: $e');
      return null;
    }
  }
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error logout: $e');
    }
  }
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final data = await _client.from(_table).select();
    return List<Map<String, dynamic>>.from(data);
  }
}
