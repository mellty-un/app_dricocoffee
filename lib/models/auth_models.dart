class UserProfile {
  final String userId;
  final String name;
  final String role; 

  UserProfile({
    required this.userId,
    required this.name,
    required this.role,
  });

  // Untuk insert ke Supabase
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'role': role,
    };
  }
}