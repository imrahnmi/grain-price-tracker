import 'package:flutter/material.dart';
import 'prices_screen.dart';
import 'compare_screen.dart';
import 'markets_screen.dart';
import '../services/api_service.dart';
import '../screens/user/user_profile_screen.dart';
import '../screens/ai/ai_insights_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> recentPrices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecentPrices();
  }

  Future<void> loadRecentPrices() async {
    try {
      final prices = await ApiService.getCommodityPrices(1);
      if (mounted) {
        setState(() {
          recentPrices = prices.take(3).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recent prices: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // CORRECTED ORDER: Dashboard, Prices, Compare, Markets, Trends, Favorites
  final List<Widget> _screens = [
    const _DashboardScreen(),
    const PricesScreen(),
    const CompareScreen(),
    const MarketsScreen(),    // Markets should come before Trends
    const AIInsightsScreen(),
    const UserProfileScreen(),  // Favorites stays at position 5
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grain Price Tracker'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadRecentPrices,
            tooltip: 'Refresh Prices',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.price_check),
          label: 'Prices',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare),
          label: 'Compare',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),        // Markets icon
          label: 'Markets',               // Markets label
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),  // Trends icon
          label: 'AI',                // Trends label
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),     // profile 
          label: 'Profile',             // Favorites label
        ),
      ],
    );
  }
}

// ... rest of your _DashboardScreen code remains the same ...
class _DashboardScreen extends StatefulWidget {
  const _DashboardScreen();

  @override
  __DashboardScreenState createState() => __DashboardScreenState();
}

class __DashboardScreenState extends State<_DashboardScreen> {
  List<dynamic> recentPrices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentPrices();
  }

  Future<void> _loadRecentPrices() async {
    try {
      final prices = await ApiService.getCommodityPrices(1);
      setState(() {
        recentPrices = prices.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading recent prices: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Welcome Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Real-time grain prices across Nigeria markets',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Quick Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatCard(context, '5', 'Markets', Icons.store),
              const SizedBox(width: 12),
              _buildStatCard(context, '5', 'Grains', Icons.shopping_basket),
              const SizedBox(width: 12),
              _buildStatCard(context, '25+', 'Prices', Icons.analytics),
            ],
          ),
        ),

        // Recent Price Updates
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Recent Price Updates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recentPrices.isEmpty
                      ? const Center(
                          child: Text(
                            'No recent price data',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: recentPrices.length,
                            itemBuilder: (context, index) {
                              final price = recentPrices[index];
                              return _buildPriceUpdateCard(context, price);
                            },
                          ),
                        ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceUpdateCard(BuildContext context, Map<String, dynamic> price) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.attach_money, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          price['markets']?['name'] ?? 'Unknown Market',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          price['commodities']?['name'] ?? 'Unknown Grain',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₦${(price['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Text(
              'per bag',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}