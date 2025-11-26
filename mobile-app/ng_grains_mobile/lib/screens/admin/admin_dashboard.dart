import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> recentPrices = [];
  List<dynamic> pendingApprovals = [];
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      // Load recent prices
      final prices = await ApiService.getCommodityPrices(1);
      
      // Load pending approvals (you'll need to add this to API service)
      // final pending = await ApiService.getPendingApprovals();
      
      setState(() {
        recentPrices = prices.take(5).toList();
        // pendingApprovals = pending;
        stats = {
          'totalPrices': prices.length,
          'pendingApprovals': 12, // Mock data
          'activeMarkets': 5,
          'totalValidators': 8,
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red, // Different color for admin
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Overview
                  _buildStatsOverview(),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  _buildRecentActivity(),
                  const SizedBox(height: 24),
                  
                  // Price Trends Chart
                  _buildPriceTrendsChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsOverview() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Prices',
          stats['totalPrices'].toString(),
          Icons.analytics,
          Colors.blue,
        ),
        _buildStatCard(
          'Pending Approvals',
          stats['pendingApprovals'].toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildStatCard(
          'Active Markets',
          stats['activeMarkets'].toString(),
          Icons.store,
          Colors.green,
        ),
        _buildStatCard(
          'Validators',
          stats['totalValidators'].toString(),
          Icons.verified_user,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton('Manage Validators', Icons.people, () {}),
                _buildActionButton('Price Approvals', Icons.approval, () {}),
                _buildActionButton('Market Management', Icons.store, () {}),
                _buildActionButton('Reports', Icons.assessment, () {}),
                _buildActionButton('System Settings', Icons.settings, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Price Submissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentPrices.take(5).map((price) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: const Icon(Icons.price_change, color: Colors.green),
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
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTrendsChart() {
    // Mock data for the chart
    final chartData = [
      {'month': 'Jan', 'price': 45000},
      {'month': 'Feb', 'price': 47000},
      {'month': 'Mar', 'price': 46000},
      {'month': 'Apr', 'price': 48000},
      {'month': 'May', 'price': 49000},
      {'month': 'Jun', 'price': 50000},
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Trends - Rice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                series: <CartesianSeries<Map<String, dynamic>, String>>[
                  LineSeries<Map<String, dynamic>, String>(
                    dataSource: chartData,
                    xValueMapper: (Map<String, dynamic> data, _) => data['month'] as String,
                    yValueMapper: (Map<String, dynamic> data, _) => data['price'] as num,
                    name: 'Price',
                    color: Colors.green,
                    markerSettings: const MarkerSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
  await AuthService.signOut();
  if (mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
}