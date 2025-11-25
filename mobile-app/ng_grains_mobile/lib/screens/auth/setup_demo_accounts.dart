import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

class SetupDemoAccounts extends StatefulWidget {
  const SetupDemoAccounts({super.key});

  @override
  _SetupDemoAccountsState createState() => _SetupDemoAccountsState();
}

class _SetupDemoAccountsState extends State<SetupDemoAccounts> {
  bool _isLoading = false;
  int _currentStep = 0;
  final List<String> _createdAccounts = [];

  final List<Map<String, dynamic>> _demoAccounts = [
    {
      'email': 'admin@grainprices.com',
      'password': 'admin123',
      'fullName': 'System Administrator',
      'userType': 'admin',
      'marketId': null,
    },
    {
      'email': 'validator@da6emarket.com',
      'password': 'validator123', 
      'fullName': 'Ahmed Musa - Da6e Market',
      'userType': 'validator',
      'marketId': 1,
    },
    {
      'email': 'user@example.com',
      'password': 'user123',
      'fullName': 'Demo User',
      'userType': 'user',
      'marketId': null,
    },
  ];

  Future<void> _createDemoAccounts() async {
    setState(() {
      _isLoading = true;
      _createdAccounts.clear();
    });

    for (final account in _demoAccounts) {
      try {
        setState(() {
          _currentStep = _demoAccounts.indexOf(account) + 1;
        });

        print('Creating account: ${account['email']}');

        // Sign up the user (this creates them in auth.users)
        final authResponse = await AuthService.signUp(
          email: account['email']!,
          password: account['password']!,
          fullName: account['fullName']!,
          userType: account['userType']!,
          marketId: account['marketId'],
        );

        if (authResponse.user != null) {
          _createdAccounts.add(account['email']!);
          print('Successfully created: ${account['email']}');
        }

        // Wait between creations to avoid rate limiting
        await Future.delayed(const Duration(seconds: 2));

      } on AuthException catch (e) {
        if (e.message.contains('already registered') || e.message.contains('user already exists')) {
          print('Account ${account['email']} already exists');
          _createdAccounts.add(account['email']!);
        } else {
          print('Error creating ${account['email']}: ${e.message}');
          _showError('Failed to create ${account['email']}: ${e.message}');
        }
      } catch (e) {
        print('Unexpected error for ${account['email']}: $e');
        _showError('Unexpected error for ${account['email']}: $e');
      }
    }

    setState(() => _isLoading = false);
    
    if (_createdAccounts.isNotEmpty) {
      _showSuccessDialog();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demo Accounts Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The following demo accounts have been created:'),
            const SizedBox(height: 16),
            ..._createdAccounts.map((email) => Text('• $email')).toList(),
            const SizedBox(height: 16),
            const Text('You can now login with these accounts.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Demo Accounts'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Setup Demo Accounts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will create demo accounts for testing the application.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Demo Accounts List
            ..._demoAccounts.map((account) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  _getUserTypeIcon(account['userType']!),
                  color: _getUserTypeColor(account['userType']!),
                ),
                title: Text(account['fullName']!),
                subtitle: Text('${account['email']} / ${account['password']}'),
                trailing: _createdAccounts.contains(account['email'])
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : _currentStep == _demoAccounts.indexOf(account) + 1
                        ? const CircularProgressIndicator()
                        : null,
              ),
            )),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createDemoAccounts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Demo Accounts'),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Skip and Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'validator':
        return Icons.verified_user;
      default:
        return Icons.person;
    }
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'admin':
        return Colors.red;
      case 'validator':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}