import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
    int? marketId,
  }) async {
    try {
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': userType,
        },
      );

      if (authResponse.user != null) {
        // Create profile with proper user type
        await supabase.from('profiles').insert({
          'id': authResponse.user!.id,
          'email': email,
          'full_name': fullName,
          'user_type': userType,
          'market_id': marketId,
        }); // Removed .execute()

        print('User registered as: $userType'); // Debug log

        // If validator, ensure they exist in validators table
        if (userType == 'validator') {
          try {
            // Check if validator already exists
            final existingValidator = await supabase
                .from('validators')
                .select()
                .eq('email', email)
                .maybeSingle();

            if (existingValidator == null) {
              // Create new validator entry
              await supabase.from('validators').insert({
                'name': fullName,
                'email': email,
                'market_id': marketId ?? 1,
                'user_id': authResponse.user!.id,
                'is_active': true,
              }); // Removed .execute()
            } else {
              // Update existing validator with user ID
              await supabase.from('validators').update({
                'user_id': authResponse.user!.id,
              }).eq('email', email); // Removed .execute()
            }
            print('Validator profile updated'); // Debug log
          } catch (e) {
            print('Error updating validator table: $e');
          }
        }
      }

      return authResponse;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  static User? get currentUser {
    return supabase.auth.currentUser;
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  static Stream<AuthState> get authStateChanges {
    return supabase.auth.onAuthStateChange;
  }

  static bool get isLoggedIn {
    return currentUser != null;
  }

  // Additional helper methods
  static Future<String?> getUserType() async {
    final profile = await getProfile();
    return profile?['user_type'];
  }

  static Future<bool> isAdmin() async {
    final userType = await getUserType();
    return userType == 'admin';
  }

  static Future<bool> isValidator() async {
    final userType = await getUserType();
    return userType == 'validator';
  }
}