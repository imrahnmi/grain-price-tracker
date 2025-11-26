import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

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

// In main.dart - Replace your current theme with this modern version
class NigeriaGrainsApp extends StatelessWidget {
  const NigeriaGrainsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grain Price Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Deep Gold - PRIMARY
          brightness: Brightness.light,
          primary: const Color(0xFFD4AF37),     // Deep Gold (Grain Sheaves)
          secondary: const Color(0xFF228B22),   // Forest Green (Foliage)
          tertiary: const Color(0xFF008080),    // Teal (Market Trend Arrow)
          background: const Color(0xFFFDF6E3),  // Warm Ivory background
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF6E3), // Warm Ivory
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD4AF37), // Deep Gold
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const UserApp(),
        '/admin': (context) => const AdminDashboard(),
        '/validator': (context) => const ValidatorPortal(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // ADD THESE VARIABLES - they were missing!
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((AuthState data) {
      final user = data.session?.user;
      
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
    _currentUser = _supabase.auth.currentUser;
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Home', 0),
                _buildNavItem(Icons.analytics_outlined, 'Prices', 1),
                _buildNavItem(Icons.compare_arrows_outlined, 'Compare', 2),
                _buildNavItem(Icons.store_outlined, 'Markets', 3),
                _buildNavItem(Icons.auto_awesome_outlined, 'AI', 4),
                _buildNavItem(Icons.person_outlined, 'Profile', 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _currentIndex == index
              ? const Color(0xFF00C853).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _currentIndex == index
                  ? const Color(0xFF00C853)
                  : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: _currentIndex == index
                    ? const Color(0xFF00C853)
                    : Colors.grey[600],
                fontWeight:
                    _currentIndex == index ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}