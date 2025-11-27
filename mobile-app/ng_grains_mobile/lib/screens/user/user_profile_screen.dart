import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.getProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<void> _signOut() async {
    await AuthService.signOut();
    // Navigation handled by AuthWrapper
  }

  void _showEditProfile() {
    // TODO: Implement edit profile functionality
    _showComingSoon('Edit Profile');
  }

  void _showSettings() {
    // TODO: Implement settings
    _showComingSoon('Settings');
  }

  void _showHelpSupport() {
    // TODO: Implement help & support
    _showComingSoon('Help & Support');
  }

  void _showAboutApp() {
    // TODO: Implement about app
    _showComingSoon('About App');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF00C853),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
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
                          colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
                        ),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      // FIX: SingleChildScrollView absorbs potential overflow in the header
                      child: SingleChildScrollView( 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Avatar
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: const Icon(
                                Icons.person_outlined,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userProfile?['full_name'] ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userProfile?['email'] ?? 'No email',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
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

                    // User Type Badge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getUserTypeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getUserTypeColor().withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getUserTypeIcon(),
                              color: _getUserTypeColor(),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getUserTypeLabel(),
                              style: TextStyle(
                                color: _getUserTypeColor(),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    _buildQuickActions(),

                    const SizedBox(height: 32),

                    // App Info Section
                    _buildAppInfoSection(),

                    const SizedBox(height: 32),
                  ]),
                ),
              ],
            ),
    );
  }

  Color _getUserTypeColor() {
    final userType = _userProfile?['user_type'] ?? 'user';
    switch (userType) {
      case 'admin':
        return const Color(0xFFF44336);
      case 'validator':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF00C853);
    }
  }

  IconData _getUserTypeIcon() {
    final userType = _userProfile?['user_type'] ?? 'user';
    switch (userType) {
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'validator':
        return Icons.verified_outlined;
      default:
        return Icons.person_outlined;
    }
  }

  String _getUserTypeLabel() {
    final userType = _userProfile?['user_type'] ?? 'user';
    switch (userType) {
      case 'admin':
        return 'Administrator';
      case 'validator':
        return 'Market Validator';
      default:
        return 'Regular User';
    }
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            // FIX: Constrain height to prevent oversized cards
            height: 200, 
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              // FIX: Use a wider aspect ratio to control card height
              childAspectRatio: 1.8,
              children: [
                _buildActionCard(
                  'Edit Profile',
                  Icons.edit_outlined,
                  const Color(0xFF2196F3),
                  _showEditProfile,
                ),
                _buildActionCard(
                  'Settings',
                  Icons.settings_outlined,
                  const Color(0xFFFF9800),
                  _showSettings,
                ),
                _buildActionCard(
                  'Help & Support',
                  Icons.help_outline,
                  const Color(0xFF00C853),
                  _showHelpSupport,
                ),
                _buildActionCard(
                  'About App',
                  Icons.info_outline,
                  const Color(0xFF9C27B0),
                  _showAboutApp,
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
          padding: const EdgeInsets.all(16), // Adjusted padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, // Reduced icon container size
                height: 44, // Reduced icon container size
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22, // Reduced icon size
                ),
              ),
              const SizedBox(height: 10), // Reduced spacing
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 13, // Reduced font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoItem('App Version', '1.0.0', Icons.info_outline),
                  const Divider(),
                  _buildInfoItem('Build Number', '2025.1.0', Icons.build_outlined),
                  const Divider(),
                  _buildInfoItem('Last Updated', 'Nov 2025', Icons.update_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_outlined, size: 20),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[500],
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
} 