import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/validator/validator_portal.dart';
import 'services/auth_service.dart';
import 'screens/validator/validator_login_screen.dart';
import 'screens/auth/wrong_user_type_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://rqcsndxlvnepvknfqruw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxY3NuZHhsdm5lcHZrbmZxcnV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MzY3OTIsImV4cCI6MjA3OTMxMjc5Mn0.wZxalg3JGB-wCXi8yqpUop2lHLGEk_BOcagf6g8jKbY',
  );
}
class ValidatorApp extends StatelessWidget {
  const ValidatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grain Price Tracker - Validator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF228B22), // Forest Green for Validator (Foliage)
          brightness: Brightness.light,
          primary: const Color(0xFF228B22),     // Forest Green
          secondary: const Color(0xFFD4AF37),   // Gold accent
          tertiary: const Color(0xFF008080),    // Teal
          background: const Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF228B22), // Forest Green
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const ValidatorAuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class ValidatorAuthWrapper extends StatefulWidget {
  const ValidatorAuthWrapper({super.key});

  @override
  State<ValidatorAuthWrapper> createState() => _ValidatorAuthWrapperState();
}

class _ValidatorAuthWrapperState extends State<ValidatorAuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    AuthService.authStateChanges.listen((AuthState data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      return const ValidatorLoginScreen();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthService.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data;
        final userType = profile?['user_type'] ?? 'user';

        if (userType != 'validator') {
          return const WrongUserTypeScreen(
            message: 'This app is for validators only. Please use the main app.',
          );
        }

        return const ValidatorPortal();
      },
    );
  }
}