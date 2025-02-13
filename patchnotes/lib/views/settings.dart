import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/top_navbar.dart';
import '../../viewmodels/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsVM = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      appBar: const Header(title: "Settings"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ListView(
          children: [
            // Account Settings
            _buildSectionTitle("Account Settings"),
            _buildSettingsTile("Change Email", Icons.email,
                () => settingsVM.navigateToChangeEmail(context)),
            _buildSettingsTile("Change Password", Icons.lock,
                () => settingsVM.navigateToChangePassword(context)),

            // App Preferences
            _buildSectionTitle("App Preferences"),
            _buildSwitchTile(
              "Dark Mode",
              Icons.brightness_6,
              settingsVM.isDarkMode,
              (value) => settingsVM.toggleDarkMode(value),
            ),
            _buildSwitchTile(
              "Enable Notifications",
              Icons.notifications_active,
              settingsVM.areNotificationsEnabled,
              (value) => settingsVM.toggleNotifications(value),
            ),

            // Bluetooth & Device Management
            _buildSectionTitle("Bluetooth & Device Management"),
            _buildSettingsTile(
                "Pair a New Device", Icons.bluetooth, () => settingsVM.pairNewDevice(context)),
            _buildSettingsTile(
                "Forget/Disconnect Device", Icons.bluetooth_disabled, () => settingsVM.forgetDevice(context)),

            // Security & Logout
            _buildSectionTitle("Security & Logout"),
            _buildSettingsTile("Logout", Icons.exit_to_app,
                () => settingsVM.logout(context)),
            _buildSettingsTile("Delete Account", Icons.delete_forever,
                () => settingsVM.deleteAccount(context)),
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
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF967BB6)),
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5B9BD5)),
        title: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF967BB6)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        activeColor: const Color(0xFF4A90E2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        secondary: Icon(icon, color: const Color(0xFF967BB6)),
        title: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142))),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
