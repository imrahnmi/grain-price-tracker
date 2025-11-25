import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/ai_service.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<dynamic> recentPrices = [];
  List<dynamic> popularCommodities = [];
  Map<String, dynamic>? aiInsight;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final prices = await ApiService.getCommodityPrices(1); // Rice prices
      final commodities = await ApiService.getCommodities();
      
      // Get AI insight for today
      final insight = await AIService.predictPrice(
        commodity: 'Rice',
        market: 'Bauchi',
        days: 1,
      );

      if (mounted) {
        setState(() {
          recentPrices = prices.take(3).toList();
          popularCommodities = commodities.take(4).toList();
          aiInsight = insight;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    
                    // AI Market Insight
                    if (aiInsight != null) _buildAIMarketInsight(),
                    const SizedBox(height: 24),
                    
                    // Quick Access
                    _buildQuickAccess(),
                    const SizedBox(height: 24),
                    
                    // Recent Prices
                    _buildRecentPrices(),
                    const SizedBox(height: 24),
                    
                    // Popular Commodities
                    _buildPopularCommodities(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track grain prices across Bauchi markets',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildStatChip('5 Markets', Icons.store),
                      _buildStatChip('5 Grains', Icons.shopping_basket),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 16),
      backgroundColor: Colors.green[50],
    );
  }

  Widget _buildAIMarketInsight() {
    final isPositive = aiInsight!['trend'] == 'up';
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'AI Market Insight',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rice prices trending ${isPositive ? 'up' : 'down'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${aiInsight!['trendPercentage']}% ${isPositive ? 'increase' : 'decrease'} predicted',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildQuickAccessCard('Price Comparison', Icons.compare, Colors.blue, '/compare'),
            _buildQuickAccessCard('Market Prices', Icons.store, Colors.green, '/markets'),
            _buildQuickAccessCard('AI Predictions', Icons.auto_awesome, Colors.purple, '/ai-insights'),
            _buildQuickAccessCard('Price Alerts', Icons.notifications, Colors.orange, '/alerts'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to respective screen
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPrices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Price Updates',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...recentPrices.map((price) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.attach_money, color: Colors.green),
            ),
            title: Text(price['markets']?['name'] ?? 'Unknown Market'),
            subtitle: Text(price['commodities']?['name'] ?? 'Unknown Commodity'),
            trailing: Text(
              '₦${(price['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPopularCommodities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Commodities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularCommodities.map((commodity) => Chip(
            label: Text(commodity['name']),
            backgroundColor: Colors.blue[50],
            avatar: const Icon(Icons.shopping_basket, size: 16),
          )).toList(),
        ),
      ],
    );
  }
}