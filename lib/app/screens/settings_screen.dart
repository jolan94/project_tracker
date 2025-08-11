import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/app_controller.dart';
import '../controllers/theme_controller.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = GetStorage();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _themeController = Get.find<ThemeController>();
  
  bool _notificationsEnabled = true;
  bool _analyticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _nameController.text = _storage.read('user_name') ?? 'John Doe';
    _emailController.text = _storage.read('user_email') ?? 'john@example.com';
    _titleController.text = _storage.read('user_title') ?? 'Indie Hacker';
    _notificationsEnabled = _storage.read('notifications_enabled') ?? true;
    _analyticsEnabled = _storage.read('analytics_enabled') ?? true;
  }

  void _saveSettings() {
    _storage.write('user_name', _nameController.text);
    _storage.write('user_email', _emailController.text);
    _storage.write('user_title', _titleController.text);
    _storage.write('notifications_enabled', _notificationsEnabled);
    _storage.write('analytics_enabled', _analyticsEnabled);
    
    Get.snackbar(
      'Settings Saved',
      'Your preferences have been updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  void _resetOnboarding() {
    _storage.remove('onboarding_completed');
    Get.offAll(() => const OnboardingScreen());
  }

  void _clearAllData() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B), // Updated to match new theme
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete all your ideas, projects, and tasks. This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear all data logic would go here
              Get.back();
              Get.snackbar(
                'Data Cleared',
                'All data has been permanently deleted',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionHeader('Profile', Icons.person),
            const SizedBox(height: 16),
            _buildProfileCard(),
            const SizedBox(height: 32),
            
            // Preferences Section
            _buildSectionHeader('Preferences', Icons.tune),
            const SizedBox(height: 16),
            _buildPreferencesCard(),
            const SizedBox(height: 32),
            
            // Data & Privacy Section
            _buildSectionHeader('Data & Privacy', Icons.security),
            const SizedBox(height: 16),
            _buildDataPrivacyCard(),
            const SizedBox(height: 32),
            
            // About Section
            _buildSectionHeader('About', Icons.info),
            const SizedBox(height: 16),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(Get.context!).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(Get.context!).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(Get.context!).colorScheme.primary,
            child: Text(
              _nameController.text.isNotEmpty 
                  ? _nameController.text[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(Get.context!).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Name Field
          TextField(
            controller: _nameController,
            style: TextStyle(color: Theme.of(Get.context!).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: TextStyle(color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.7)),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(Get.context!).colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(Get.context!).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Email Field
          TextField(
            controller: _emailController,
            style: TextStyle(color: Theme.of(Get.context!).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.7)),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(Get.context!).colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(Get.context!).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title Field
          TextField(
            controller: _titleController,
            style: TextStyle(color: Theme.of(Get.context!).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Title/Role',
              labelStyle: TextStyle(color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.7)),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(Get.context!).colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(Get.context!).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            'Push Notifications',
            'Receive notifications for deadlines and updates',
            Icons.notifications,
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
          ),
          Divider(color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.3)),
          Obx(() => _buildSwitchTile(
            'Dark Theme',
            'Switch between light and dark theme',
            Icons.dark_mode,
            _themeController.isDarkMode,
            (value) {
              if (value) {
                _themeController.setDarkTheme();
              } else {
                _themeController.setLightTheme();
              }
            },
          )),
          Divider(color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.3)),
          _buildSwitchTile(
            'Analytics',
            'Help improve the app by sharing usage data',
            Icons.analytics,
            _analyticsEnabled,
            (value) => setState(() => _analyticsEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildActionTile(
            'Reset Onboarding',
            'Show the welcome screens again',
            Icons.refresh,
            _resetOnboarding,
          ),
          Divider(color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.3)),
          _buildActionTile(
            'Clear All Data',
            'Permanently delete all your data',
            Icons.delete_forever,
            _clearAllData,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildInfoTile('Version', '1.0.0', Icons.info),
          Divider(color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.3)),
          _buildInfoTile('Build', '1', Icons.build),
          Divider(color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.3)),
          _buildActionTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            () {
              // Open privacy policy
            },
          ),
          Divider(color: Theme.of(Get.context!).colorScheme.outline.withOpacity(0.3)),
          _buildActionTile(
            'Terms of Service',
            'Read our terms of service',
            Icons.description,
            () {
              // Open terms of service
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(Get.context!).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Theme.of(Get.context!).colorScheme.primary,
              activeTrackColor: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.3),
              inactiveThumbColor: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.5),
              inactiveTrackColor: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Theme.of(Get.context!).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : Theme.of(Get.context!).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.chevron_right,
              color: Theme.of(Get.context!).colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(Get.context!).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}