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
    final theme = Theme.of(context);
    final user = authState.firebaseUser;

    return Scaffold(
      appBar: const Header(title: "Settings"),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: ListView(
                children: [
                  _buildSectionTitle("Account Settings", theme),
                  _buildSettingsTile("Change Email", Icons.email,
                      () => _changeEmail(context, authNotifier, ref), theme),
                  const SizedBox(height: 5),
                  _buildSettingsTile("Change Password", Icons.lock,
                      () => _changePassword(context, authNotifier), theme),
                  const SizedBox(height: 15),
                  _buildSectionTitle("App Preferences", theme),
                  _buildSwitchTile(
                    "Dark Mode",
                    Icons.brightness_6,
                    settingsState.darkMode,
                    (value) => settingsNotifier.toggleDarkMode(),
                    theme,
                  ),
                  const SizedBox(height: 5),
                  _buildSwitchTile(
                    "Enable Notifications",
                    Icons.notifications_active,
                    settingsState.notificationsEnabled,
                    (value) => settingsNotifier.toggleNotifications(),
                    theme,
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Security & Logout", theme),
                  _buildSettingsTile("Logout", Icons.exit_to_app,
                      () => _confirmLogout(context, ref, authNotifier), theme),
                  const SizedBox(height: 5),
                  _buildSettingsTile(
                      "Delete Account",
                      Icons.delete_forever,
                      () => _confirmDeleteAccount(
                          context, ref, authNotifier, user?.email ?? ""),
                      theme),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge!.color),
      ),
    );
  }

  Widget _buildSettingsTile(
      String title, IconData icon, VoidCallback onTap, ThemeData theme) {
    return Card(
      color: theme.cardColor,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(title,
            style: TextStyle(
                fontSize: 14, color: theme.textTheme.bodyLarge!.color)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 14, color: theme.iconTheme.color),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value,
      ValueChanged<bool> onChanged, ThemeData theme) {
    return Card(
      color: theme.cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        activeColor: theme.primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        secondary: Icon(icon, color: theme.iconTheme.color),
        title: Text(title,
            style: TextStyle(
                fontSize: 14, color: theme.textTheme.bodyLarge!.color)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Confirms Logout
  void _confirmLogout(
      BuildContext context, WidgetRef ref, AuthNotifier authNotifier) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: theme.iconTheme.color, size: 26),
            const SizedBox(width: 10),
            Text(
              "Logout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF2D3142),
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to log out?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : const Color(0xFF2D3142),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor:
                  isDarkMode ? Colors.white70 : const Color(0xFF2D3142),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authNotifier.logout();

              ref.invalidate(authProvider);
              ref.invalidate(settingsProvider);
              ref.invalidate(userProvider);
              ref.invalidate(firebaseAuthProvider);
              ref.invalidate(firestoreServiceProvider);
              ref.invalidate(firebaseStorageServiceProvider);

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
  void _confirmDeleteAccount(BuildContext context, WidgetRef ref,
      AuthNotifier authNotifier, String email) {
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
                // Ensure password is correct before proceeding
                await authNotifier.reauthenticateUser(password);

                // Get user ID and delete Firestore user data
                final userId = authNotifier.state.firebaseUser?.uid;
                if (userId != null) {
                  await ref.read(userProvider.notifier).deleteUserData(userId);
                }

                // Delete the Firebase account
                await authNotifier.reauthenticateAndDelete(email, password);

                ref.invalidate(authProvider);
                ref.invalidate(settingsProvider);
                ref.invalidate(userProvider);

                // Close dialog and navigate to login
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

  void _changeEmail(
      BuildContext context, AuthNotifier authNotifier, WidgetRef ref) {
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
                  await ref
                      .read(userProvider.notifier)
                      .updateUserEmail(uid, newEmail);
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
