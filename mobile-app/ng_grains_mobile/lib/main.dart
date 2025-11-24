import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
// import 'screens/validator_login_screen.dart'; // Add this import

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
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      // Remove routes for now - we'll use MaterialPageRoute directly
    );
  }
}