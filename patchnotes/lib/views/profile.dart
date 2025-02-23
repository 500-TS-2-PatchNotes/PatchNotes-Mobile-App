import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patchnotes/providers/navigation.dart';
import 'package:patchnotes/providers/user_provider.dart';
import '../widgets/top_navbar.dart';

class ProfileView extends ConsumerStatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  late TextEditingController _bioController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final userState = ref.read(userProvider);
    _bioController = TextEditingController(text: userState.account?.bio ?? "");
    _notesController =
        TextEditingController(text: userState.account?.medNote ?? "");
  }

  @override
  void dispose() {
    _bioController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateProfilePicture(UserNotifier userNotifier) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();

    // Check if the widget is still mounted before proceeding
    if (!mounted) return;

    // Update the state immediately with a temporary placeholder value
    setState(() {
      final currentState = ref.read(userProvider);
      ref.read(userProvider.notifier).state = currentState.copyWith(
        appUser: currentState.appUser?.copyWith(profilePic: "local_temp"),
      );
    });

    // Update Firestore with the new profile picture
    await userNotifier.updateProfilePicture(imageBytes);

    // Check again if mounted before loading updated user data
    if (!mounted) return;

    await ref.read(userProvider.notifier).loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final navigatorKey = ref.read(navigatorKeyProvider);

    final account = userState.account;
    final appUser = userState.appUser;

    return Scaffold(
      appBar: const Header(title: "Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // **Profile Picture**
            // After: Profile Picture rendering in ProfileView with empty image handling
            GestureDetector(
              onTap: () => _updateProfilePicture(userNotifier),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: ClipOval(
                  child: appUser?.profilePic != null &&
                          appUser!.profilePic!.isNotEmpty &&
                          appUser.profilePic! != "local_temp"
                      ? Image.network(
                          "${appUser.profilePic!}?t=${DateTime.now().millisecondsSinceEpoch}", // Force reload
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 100,
                              color: Colors.grey,
                            );
                          },
                        )
                      : const Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              appUser?.fName ?? "User",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              appUser?.email ?? "No Email",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // **Bio Section**
            _buildEditableCard(
              title: "Bio",
              icon: Icons.info,
              controller: _bioController,
              value: account?.bio ?? "No bio available",
              onSave: () {
                userNotifier.updateBio(_bioController.text);
              },
            ),

            const SizedBox(height: 5),
            // **Device Status & Wound Status**
            _buildInfoCard(
                "Device Status", "Connected", Icons.bluetooth_connected),
            const SizedBox(height: 5),
            _buildInfoCard("Wound Status", account?.woundStatus ?? "Unknown",
                Icons.healing),
            const SizedBox(height: 5),

            // **Medical Notes Section**
            _buildEditableCard(
              title: "Medical Notes",
              icon: Icons.notes,
              controller: _notesController,
              value: account?.medNote ?? "No medical notes available",
              onSave: () {
                userNotifier.updateMedicalNotes(_notesController.text);
              },
            ),

            const SizedBox(height: 20),

            // **Settings Button**
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9BD5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                elevation: 5,
              ),
              onPressed: () {
                ref.read(tabIndexProvider.notifier).state = 4;
              },
              icon: const Icon(Icons.settings, color: Colors.white),
              label: const Text('Change Settings',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  /// **Editable Field Card**
  Widget _buildEditableCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required String value,
    required VoidCallback onSave,
  }) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF5B9BD5)),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 5),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter $title...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF5B9BD5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: onSave,
                child: const Text("Save",
                    style: TextStyle(color: Color(0xFF5B9BD5))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Info Display Card**
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5B9BD5)),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w400, color: Colors.black)),
        subtitle: Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
    );
  }
}
