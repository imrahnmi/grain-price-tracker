import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ValidatorPortal extends StatefulWidget {
  const ValidatorPortal({super.key});

  @override
  State<ValidatorPortal> createState() => _ValidatorPortalState();
}

class _ValidatorPortalState extends State<ValidatorPortal> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadValidatorProfile();
  }

  Future<void> loadValidatorProfile() async {
    final profile = await AuthService.getProfile();
    if (mounted) {
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validator Portal'),
        backgroundColor: Colors.orange, // Different color to distinguish
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Validator Welcome Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.verified_user, size: 64, color: Colors.orange),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome, Validator!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            userProfile?['full_name'] ?? 'Validator',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            userProfile?['email'] ?? '',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
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
                  ),
                  const SizedBox(height: 24),

                  // Validator Features
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: [
                        _buildValidatorFeature('Submit Prices', Icons.add_chart, Colors.green),
                        _buildValidatorFeature('My Submissions', Icons.history, Colors.blue),
                        _buildValidatorFeature('Market Data', Icons.analytics, Colors.purple),
                        _buildValidatorFeature('Price Approval', Icons.approval, Colors.orange),
                      ],
                    ),
                  ),

                  // Quick Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Validator Responsibilities',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Submit daily market prices\n• Verify price accuracy\n• Maintain data quality',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to price submission
                            },
                            child: const Text('Start Submitting Prices'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildValidatorFeature(String title, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          // Handle feature tap
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
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
}