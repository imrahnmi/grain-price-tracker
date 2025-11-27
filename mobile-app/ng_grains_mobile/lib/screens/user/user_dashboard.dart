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
      final prices = await ApiService.getAllPrices();
      final commodities = await ApiService.getCommodities();
      final insight = await AIService.predictPrice(
        commodity: 'Rice',
        market: 'Nigeria',
        days: 1,
      );

      if (mounted) {
        setState(() {
          recentPrices = prices.take(5).toList();
          popularCommodities = commodities.take(4).toList();
          aiInsight = insight;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: isLoading
          ? _buildLoadingShimmer()
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    expandedHeight: 200,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF00C853),
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Track grain prices in real-time',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),

                      // AI Insight Card
                      if (aiInsight != null) _buildAIMarketInsight(),

                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(),

                      const SizedBox(height: 24),

                      // Recent Prices
                      _buildRecentPrices(),

                      const SizedBox(height: 24),

                      // Popular Commodities
                      _buildPopularCommodities(),

                      const SizedBox(height: 32),
                    ]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingShimmer() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 24),
            _buildShimmerCard(),
            const SizedBox(height: 16),
            _buildShimmerCard(),
            const SizedBox(height: 16),
            _buildShimmerCard(),
          ]),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      height: 100,
    );
  }

  Widget _buildAIMarketInsight() {
    final isPositive = aiInsight!['trend'] == 'up';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPositive
                        ? [const Color(0xFF00C853), const Color(0xFF64DD17)]
                        : [const Color(0xFFFF5252), const Color(0xFFFF867F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Market Insight',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rice prices trending ${isPositive ? 'up' : 'down'} by ${aiInsight!['trendPercentage']}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      aiInsight!['recommendation'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            // FIX: Constraint height to prevent oversized cards
            height: 200, 
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // FIX: Use a wider aspect ratio to control card height
              childAspectRatio: 1.8,
              children: [
                _buildActionCard(
                  'Price Comparison',
                  Icons.analytics_outlined,
                  const Color(0xFF536DFE),
                  () {
                    // Navigate to compare
                  },
                ),
                _buildActionCard(
                  'Market Prices',
                  Icons.store_mall_directory_outlined,
                  const Color(0xFF00C853),
                  () {
                    // Navigate to markets
                  },
                ),
                _buildActionCard(
                  'AI Predictions',
                  Icons.auto_awesome_mosaic_outlined,
                  const Color(0xFF9C27B0),
                  () {
                    // Navigate to AI insights
                  },
                ),
                _buildActionCard(
                  'Price Alerts',
                  Icons.notifications_active_outlined,
                  const Color(0xFFFF9800),
                  () {
                    // Navigate to alerts
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, // Slightly reduced icon container size
                height: 44, // Slightly reduced icon container size
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22, // Slightly reduced icon size
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 13, // Slightly reduced font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPrices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Prices',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all prices
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF00C853),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentPrices.isEmpty)
            _buildEmptyState(
              'No price data available',
              Icons.price_change_outlined,
            )
          else
            SizedBox(
              height: 300, // Add fixed height
              child: SingleChildScrollView(
                child: Column(
                  children: recentPrices.map((price) => _buildPriceItem(price)).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(Map<String, dynamic> price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF64DD17)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.attach_money,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          price['markets']?['name'] ?? 'Unknown Market',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          price['commodities']?['name'] ?? 'Unknown Commodity',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₦${(price['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF00C853),
              ),
            ),
            Text(
              'per bag',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCommodities() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Commodities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          if (popularCommodities.isEmpty)
            _buildEmptyState(
              'No commodities available',
              Icons.shopping_basket_outlined,
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: popularCommodities.map((commodity) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00C853).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_basket_outlined,
                      size: 16,
                      color: Color(0xFF00C853),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      commodity['name'],
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}