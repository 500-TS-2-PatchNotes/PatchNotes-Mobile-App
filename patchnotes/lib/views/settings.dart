import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/top_navbar.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
    final authVM = context.read<AuthViewModel>();

    final user = authVM.firebaseUser;

    // Ensures settings are loaded when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null &&
          !settingsVM.isLoaded &&
          ModalRoute.of(context)?.isCurrent == true) {
        settingsVM.loadSettings(user.uid);
      }
    });

    return Scaffold(
      appBar: const Header(title: "Settings"),
      body: settingsVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: ListView(
                children: [
                  _buildSectionTitle("Account Settings"),
                  _buildSettingsTile("Change Email", Icons.email,
                      () => settingsVM.navigateToChangeEmail(context)),
                  _buildSettingsTile("Change Password", Icons.lock,
                      () => settingsVM.navigateToChangePassword(context)),
                  _buildSectionTitle("App Preferences"),
                  _buildSwitchTile(
                    "Dark Mode",
                    Icons.brightness_6,
                    settingsVM.isDarkMode,
                    (value) {
                      if (user != null) {
                        settingsVM.toggleDarkMode(user.uid, value);
                      }
                    },
                  ),
                  _buildSwitchTile(
                    "Enable Notifications",
                    Icons.notifications_active,
                    settingsVM.areNotificationsEnabled,
                    (value) {
                      if (user != null) {
                        settingsVM.toggleNotifications(user.uid, value);
                      }
                    },
                  ),
                  _buildSectionTitle("Bluetooth & Device Management"),
                  _buildSettingsTile("Pair a New Device", Icons.bluetooth,
                      () => settingsVM.pairNewDevice(context)),
                  _buildSettingsTile(
                      "Forget/Disconnect Device",
                      Icons.bluetooth_disabled,
                      () => settingsVM.forgetDevice(context)),
                  _buildSectionTitle("Security & Logout"),
                  _buildSettingsTile("Logout", Icons.exit_to_app,
                      () => _confirmLogout(context)),
                  _buildSettingsTile("Delete Account", Icons.delete_forever,
                      () => _confirmDeleteAccount(context, authVM)),
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

  /// Confirm Logout
  void _confirmLogout(BuildContext context) {
    final settingsVM = context.read<SettingsViewModel>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content:
            const Text("Do you want to save your changes before logging out?"),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext), // ✅ Closes the dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(
                  dialogContext); // ✅ Ensure dialog is closed before logout

              settingsVM.logout(context); // ✅ Calls logout immediately
            },
            child: const Text("Save & Logout",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Confirm Delete Account
void _confirmDeleteAccount(BuildContext context, AuthViewModel authVM) {
  final settingsVM = context.read<SettingsViewModel>();
  final userEmail = authVM.firebaseUser?.email ?? "";

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
            controller: settingsVM.passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            settingsVM.passwordController.clear();
            Navigator.pop(dialogContext);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            String password = settingsVM.passwordController.text.trim();
            if (password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Please enter your password."),
                    backgroundColor: Colors.red),
              );
              return;
            }

            Navigator.pop(dialogContext); // Close dialog
            settingsVM.passwordController.clear();

            // **Now call `deleteAccount` from SettingsViewModel**
            await settingsVM.deleteAccount(context, userEmail, password);
          },
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
