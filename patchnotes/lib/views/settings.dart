import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/settings_provider.dart';
import 'package:patchnotes/providers/auth_provider.dart';
import 'package:patchnotes/providers/user_provider.dart';
import '../widgets/top_navbar.dart';

class SettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final user = authState.firebaseUser;

    return Scaffold(
      appBar: const Header(title: "Settings"),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: ListView(
                children: [
                  _buildSectionTitle("Account Settings"),
                  _buildSettingsTile("Change Email", Icons.email,
                      () => _navigateToChangeEmail(context)),
                  _buildSettingsTile("Change Password", Icons.lock,
                      () => _navigateToChangePassword(context)),
                  _buildSectionTitle("App Preferences"),
                  _buildSwitchTile(
                    "Dark Mode",
                    Icons.brightness_6,
                    settingsState.darkMode,
                    (value) => settingsNotifier.toggleDarkMode(),
                  ),
                  _buildSwitchTile(
                    "Enable Notifications",
                    Icons.notifications_active,
                    settingsState.notificationsEnabled,
                    (value) => settingsNotifier.toggleNotifications(),
                  ),
                  _buildSectionTitle("Bluetooth & Device Management"),
                  _buildSettingsTile("Pair a New Device", Icons.bluetooth,
                      () => _pairNewDevice(context)),
                  _buildSettingsTile("Forget/Disconnect Device",
                      Icons.bluetooth_disabled, () => _forgetDevice(context)),
                  _buildSectionTitle("Security & Logout"),
                  _buildSettingsTile("Logout", Icons.exit_to_app,
                      () => _confirmLogout(context, ref, authNotifier)),
                  _buildSettingsTile(
                      "Delete Account",
                      Icons.delete_forever,
                      () => _confirmDeleteAccount(
                          context, authNotifier, user?.email ?? "")),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF967BB6)),
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
        title: Text(title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142))),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Color(0xFF967BB6)),
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
        title: Text(title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2D3142))),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// **Confirm Logout**
  void _confirmLogout(
      BuildContext context, WidgetRef ref, AuthNotifier authNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content:
            const Text("Do you want to save your changes before logging out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authNotifier.logout();

              // Reset settings and user data before switching pages
              ref.invalidate(settingsProvider);
              ref.invalidate(userProvider);

              // Ensure full switch to login
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (route) => false);
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// **Confirm Delete Account**
  void _confirmDeleteAccount(
      BuildContext context, AuthNotifier authNotifier, String email) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Delete Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "This action cannot be undone. Please enter your password to confirm."),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.clear();
              Navigator.pop(dialogContext);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String password = passwordController.text.trim();
              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please enter your password."),
                      backgroundColor: Colors.red),
                );
                return;
              }

              Navigator.pop(dialogContext);
              passwordController.clear();

              await authNotifier.reauthenticateAndDelete(email, password);

              Future.delayed(Duration(milliseconds: 500), () {
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/login", (route) => false);
                }
              });
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// **Dummy Navigation Functions (Replace with Actual Navigation)**
  void _navigateToChangeEmail(BuildContext context) {
    print("Navigating to Change Email Screen");
  }

  void _navigateToChangePassword(BuildContext context) {
    print("Navigating to Change Password Screen");
  }

  void _pairNewDevice(BuildContext context) {
    print("Pairing a New Bluetooth Device");
  }

  void _forgetDevice(BuildContext context) {
    print("Forgetting the Bluetooth Device");
  }
}
