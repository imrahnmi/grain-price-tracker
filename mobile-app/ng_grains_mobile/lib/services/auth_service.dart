import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

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
          'is_active': true,
        });

        debugPrint('User registered as: $userType');

        // If validator, ensure they exist in validators table
        if (userType == 'validator') {
          try {
            await supabase.from('validators').insert({
              'name': fullName,
              'email': email,
              'market_id': marketId ?? 1,
              'user_id': authResponse.user!.id,
              'is_active': true,
            });
            debugPrint('Validator profile updated');
          } catch (e) {
            debugPrint('Error updating validator table: $e');
          }
        }
      }

      return authResponse;
    } catch (e) {
      debugPrint('Signup error: $e');
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
          .maybeSingle(); // Use maybeSingle instead of single

      if (response == null) {
        debugPrint('No profile found for user: ${user.email}');
        // Create a default profile if none exists
        return await _createDefaultProfile(user);
      }

      return response;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // Create default profile on error
      return await _createDefaultProfile(user);
    }
  }

  static Future<Map<String, dynamic>?> _createDefaultProfile(User user) async {
    try {
      debugPrint('Creating default profile for user: ${user.email}');
      
      final defaultProfile = {
        'id': user.id,
        'email': user.email,
        'full_name': user.email?.split('@').first ?? 'User',
        'user_type': 'user', // Default to regular user
        'is_active': true,
      };

      await supabase.from('profiles').insert(defaultProfile);
      return defaultProfile;
    } catch (e) {
      debugPrint('Error creating default profile: $e');
      return null;
    }
  }

  static Stream<AuthState> get authStateChanges {
    return supabase.auth.onAuthStateChange;
  }

  static bool get isLoggedIn {
    return currentUser != null;
  }

  // Enhanced helper methods with better error handling
  static Future<String?> getUserType() async {
    try {
      final profile = await getProfile();
      return profile?['user_type'];
    } catch (e) {
      debugPrint('Error getting user type: $e');
      return 'user'; // Default fallback
    }
  }

  static Future<bool> isAdmin() async {
    final userType = await getUserType();
    return userType == 'admin';
  }

  static Future<bool> isValidator() async {
    final userType = await getUserType();
    return userType == 'validator';
  }

  // Debug method to check current auth state
  static Future<void> debugAuthState() async {
    final user = currentUser;
    final profile = await getProfile();
    
    debugPrint('=== AUTH DEBUG ===');
    debugPrint('Logged in: $isLoggedIn');
    debugPrint('User: ${user?.email}');
    debugPrint('User ID: ${user?.id}');
    debugPrint('Profile exists: ${profile != null}');
    debugPrint('User Type: ${profile?['user_type']}');
    debugPrint('==================');
  }
}