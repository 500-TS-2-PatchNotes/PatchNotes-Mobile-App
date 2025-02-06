import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool areNotificationsEnabled = true;

// Color Palette - Purple and Teal/Blue Theme
  final Color primaryColor = Color(0xFF967BB6); // Soft Purple
  final Color accentColor = const Color(0xFF5B9BD5); // Teal Blue
  final Color switchActiveColor = Color(0xFF4A90E2); // Blue for toggles
  final Color textColor =
      Color(0xFF2D3142); // Dark Gray-Blue (Better Readability)
  final Color cardColor = Colors.white; // White for cards (Good Contrast)

  void _navigateToChangeEmail() {}
  void _navigateToChangePassword() {}
  void _pairNewDevice() {}
  void _forgetDevice() {}

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: TextStyle(color: textColor)),
        content: Text("Are you sure you want to log out?",
            style: TextStyle(color: textColor)),
        backgroundColor: cardColor,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: primaryColor))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement Logout Logic
            },
            child: Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account", style: TextStyle(color: textColor)),
        content: Text("This action cannot be undone. Are you sure?",
            style: TextStyle(color: textColor)),
        backgroundColor: cardColor,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: primaryColor))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement Account Deletion Logic
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ListView(
          children: [
            // Account Settings
            _buildSectionTitle("Account Settings"),
            _buildSettingsTile(
                "Change Email", Icons.email, _navigateToChangeEmail),
            _buildSettingsTile(
                "Change Password", Icons.lock, _navigateToChangePassword),

            // App Preferences
            _buildSectionTitle("App Preferences"),
            _buildSwitchTile("Dark Mode", Icons.brightness_6, isDarkMode,
                (value) {
              setState(() {
                isDarkMode = value;
              });
            }),
            _buildSwitchTile("Enable Notifications", Icons.notifications_active,
                areNotificationsEnabled, (value) {
              setState(() {
                areNotificationsEnabled = value;
              });
            }),

            // Bluetooth & Device Management
            _buildSectionTitle("Bluetooth & Device Management"),
            _buildSettingsTile(
                "Pair a New Device", Icons.bluetooth, _pairNewDevice),
            _buildSettingsTile("Forget/Disconnect Device",
                Icons.bluetooth_disabled, _forgetDevice),

            // Security & Logout
            _buildSectionTitle("Security & Logout"),
            _buildSettingsTile("Logout", Icons.exit_to_app, _logout),
            _buildSettingsTile(
                "Delete Account", Icons.delete_forever, _deleteAccount),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: accentColor), // Teal-Blue Icons
        title: Text(title, style: TextStyle(fontSize: 14, color: textColor)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 14, color: primaryColor), // Purple Arrow
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Card(
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        activeColor: switchActiveColor, // Teal Blue Switch
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        secondary: Icon(icon, color: primaryColor), // Purple Icons
        title: Text(title, style: TextStyle(fontSize: 14, color: textColor)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
