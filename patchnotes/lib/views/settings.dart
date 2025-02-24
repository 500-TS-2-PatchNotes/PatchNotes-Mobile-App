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
                      () => _changeEmail(context, authNotifier, ref)),
                  const SizedBox(height: 5),
                  _buildSettingsTile("Change Password", Icons.lock,
                      () => _changePassword(context, authNotifier)),
                  const SizedBox(height: 15),
                  _buildSectionTitle("App Preferences"),
                  _buildSwitchTile(
                    "Dark Mode",
                    Icons.brightness_6,
                    settingsState.darkMode,
                    (value) => settingsNotifier.toggleDarkMode(),
                  ),
                  const SizedBox(height: 5),
                  _buildSwitchTile(
                    "Enable Notifications",
                    Icons.notifications_active,
                    settingsState.notificationsEnabled,
                    (value) => settingsNotifier.toggleNotifications(),
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Security & Logout"),
                  _buildSettingsTile("Logout", Icons.exit_to_app,
                      () => _confirmLogout(context, ref, authNotifier)),
                  const SizedBox(height: 5),
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

  // Widget Helpers
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
      elevation: 5,
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

  /// Confirms Logout
  void _confirmLogout(
      BuildContext context, WidgetRef ref, AuthNotifier authNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.logout, color: Color(0xFF5B9BD5), size: 26),
            SizedBox(width: 10),
            Text(
              "Logout",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to log out?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF2D3142)),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF2D3142),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF5B9BD5), // Blue like other buttons
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  /// Confirms Delete Account
  void _confirmDeleteAccount(
      BuildContext context, AuthNotifier authNotifier, String email) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Delete Account",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "This action cannot be undone. Please enter your password to confirm account deletion.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock, color: Colors.red),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () {
              passwordController.clear();
              Navigator.pop(dialogContext);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
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

              try {
                await authNotifier.reauthenticateAndDelete(email, password);

                Navigator.pop(dialogContext);

                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (route) => false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _changeEmail(BuildContext context, AuthNotifier authNotifier, WidgetRef ref) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.email_outlined, color: Color(0xFF5B9BD5), size: 26),
            SizedBox(width: 10),
            Text("Change Email", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your new email address below.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "New Email",
                prefixIcon:
                    const Icon(Icons.alternate_email, color: Color(0xFF5B9BD5)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF5B9BD5)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              emailController.clear();
              Navigator.pop(dialogContext);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9BD5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              String newEmail = emailController.text.trim();
              if (newEmail.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please enter a new email."),
                      backgroundColor: Colors.red),
                );
                return;
              }

              try {
              await authNotifier.updateEmail(newEmail);

              final uid = authNotifier.state.firebaseUser?.uid;
              if (uid != null) {
                await ref.read(userProvider.notifier).updateUserEmail(uid, newEmail);
              }

              await ref.read(userProvider.notifier).loadUserData();


                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Email updated successfully."),
                      backgroundColor: Colors.green),
                );
                Navigator.pop(dialogContext);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context, AuthNotifier authNotifier) {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: Color(0xFF5B9BD5), size: 26),
            SizedBox(width: 10),
            Text("Change Password",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your new password below.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF5B9BD5)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF5B9BD5)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF5B9BD5)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF5B9BD5)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.clear();
              confirmPasswordController.clear();
              Navigator.pop(dialogContext);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9BD5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              String newPassword = passwordController.text.trim();
              String confirmPassword = confirmPasswordController.text.trim();

              if (newPassword.isEmpty || newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Password must be at least 6 characters."),
                      backgroundColor: Colors.red),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Passwords do not match."),
                      backgroundColor: Colors.red),
                );
                return;
              }

              try {
                await authNotifier.updatePassword(newPassword);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Password updated successfully."),
                      backgroundColor: Colors.green),
                );
                Navigator.pop(dialogContext);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
