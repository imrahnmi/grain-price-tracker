import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/admin/admin_dashboard.dart';
import 'services/auth_service.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/auth/wrong_user_type_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://rqcsndxlvnepvknfqruw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxY3NuZHhsdm5lcHZrbmZxcnV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MzY3OTIsImV4cCI6MjA3OTMxMjc5Mn0.wZxalg3JGB-wCXi8yqpUop2lHLGEk_BOcagf6g8jKbY',
  );
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grain Price Tracker - Admin',
      theme: ThemeData(
        primaryColor: Colors.red, // Admin theme
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const AdminAuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminAuthWrapper extends StatefulWidget {
  const AdminAuthWrapper({super.key});

  @override
  State<AdminAuthWrapper> createState() => _AdminAuthWrapperState();
}

class _AdminAuthWrapperState extends State<AdminAuthWrapper> {
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
      return const AdminLoginScreen();
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

        if (userType != 'admin') {
          return const WrongUserTypeScreen(
            message: 'This app is for administrators only.',
          );
        }

        return const AdminDashboard();
      },
    );
  }
}