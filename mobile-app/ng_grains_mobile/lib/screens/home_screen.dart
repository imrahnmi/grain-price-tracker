import 'package:flutter/material.dart';
import 'prices_screen.dart';
import 'compare_screen.dart';
import 'markets_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PricesScreen(),
    const CompareScreen(),
    const MarketsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grain Price Tracker'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Prices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare),
            label: 'Compare',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Markets',
          ),
        ],
      ),
    );
  }
}