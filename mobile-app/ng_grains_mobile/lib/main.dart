import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

// User screens
import 'screens/user/user_dashboard.dart';
import 'screens/user/user_profile_screen.dart';

// Main app screens (in root screens directory)
import 'screens/prices_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/markets_screen.dart';

// AI screens
import 'screens/ai/ai_insights_screen.dart';

// Admin & Validator screens
import 'screens/admin/admin_dashboard.dart';
import 'screens/validator/validator_portal.dart';

// Services
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://rqcsndxlvnepvknfqruw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxY3NuZHhsdm5lcHZrbmZxcnV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MzY3OTIsImV4cCI6MjA3OTMxMjc5Mn0.wZxalg3JGB-wCXi8yqpUop2lHLGEk_BOcagf6g8jKbY',
  );
  
  runApp(const NigeriaGrainsApp());
}

class NigeriaGrainsApp extends StatelessWidget {
  const NigeriaGrainsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grain Price Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const UserApp(),
        '/admin': (context) => const AdminDashboard(),
        '/validator': (context) => const ValidatorPortal(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // ADD THESE VARIABLES - they were missing!
  User? _currentUser;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((AuthState authState) {
      final user = authState.session?.user;
      
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        
        if (user != null) {
          _loadUserProfile();
        }
      }
    });

    // Check current auth state
    _currentUser = AuthService.currentUser;
    if (_currentUser != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.getProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking auth
    if (_currentUser != null && _userProfile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Not logged in
    if (_currentUser == null) {
      return const LoginScreen();
    }

    // Route based on user type
    final userType = _userProfile?['user_type'] ?? 'user';
    
    switch (userType) {
      case 'admin':
        return const AdminDashboard();
      case 'validator':
        return const ValidatorPortal();
      default:
        return const UserApp();
    }
  }
}

class UserApp extends StatefulWidget {
  const UserApp({super.key});

  @override
  State<UserApp> createState() => _UserAppState();
}

class _UserAppState extends State<UserApp> {
  int _currentIndex = 0;

  final List<Widget> _userScreens = [
    const UserDashboard(),
    const PricesScreen(),
    const CompareScreen(),
    const MarketsScreen(),
    const AIInsightsScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grain Price Tracker'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: _userScreens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.price_check), label: 'Prices'),
          BottomNavigationBarItem(icon: Icon(Icons.compare), label: 'Compare'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Markets'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}