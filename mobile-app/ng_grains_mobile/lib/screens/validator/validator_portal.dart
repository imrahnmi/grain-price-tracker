import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class ValidatorPortal extends StatefulWidget {
  const ValidatorPortal({super.key});

  @override
  State<ValidatorPortal> createState() => _ValidatorPortalState();
}

class _ValidatorPortalState extends State<ValidatorPortal> {
  Map<String, dynamic>? userProfile;
  List<dynamic> commodities = [];
  List<dynamic> mySubmissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadValidatorData();
  }

  Future<void> loadValidatorData() async {
    try {
      final results = await Future.wait([
        AuthService.getProfile(),
        ApiService.getCommodities(),
      ]);
      final Map<String, dynamic>? profile = results[0] as Map<String, dynamic>?;
      final List<dynamic> commoditiesData = results[1] as List<dynamic>;

      if (mounted) {
        setState(() {
          userProfile = profile;
          commodities = commoditiesData;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading validator data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Validator Portal'),
          backgroundColor: Colors.orange,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.add_chart), text: 'Submit Prices'),
              Tab(icon: Icon(Icons.history), text: 'My Submissions'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildDashboardTab(),
                  _buildSubmitPricesTab(),
                  _buildSubmissionsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Validator Info Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, size: 48, color: Colors.orange),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile?['full_name'] ?? 'Validator',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(userProfile?['email'] ?? ''),
                        const SizedBox(height: 8),
                        const Chip(
                          label: Text(
                            'VALIDATOR',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Stats
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard('Today', '0/5', Icons.today, 'Submissions'),
              _buildStatCard('Pending', '0', Icons.pending, 'Approvals'),
              _buildStatCard('Approved', '0', Icons.verified, 'Prices'),
              _buildStatCard('Accuracy', '100%', Icons.analytics, 'Score'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.orange),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitPricesTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.add_chart, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Price Submission',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Submit daily market prices for your assigned market',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Start Submitting Prices'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.history, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'Submission History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'View and manage your previous price submissions',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}