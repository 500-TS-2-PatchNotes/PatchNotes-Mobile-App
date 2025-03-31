import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patchnotes/providers/user_provider.dart';
import 'package:patchnotes/providers/bluetooth_provider.dart';
import '../widgets/top_navbar.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  late TextEditingController _bioController;
  late TextEditingController _notesController;
  late String _profilePicVersion;

  bool _isEditingBio = false;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    final userState = ref.read(userProvider);
    _bioController = TextEditingController(text: userState.account?.bio ?? "");
    _notesController =
        TextEditingController(text: userState.account?.medNote ?? "");
    _profilePicVersion = "0";
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

    if (!mounted) return;

    setState(() {
      final currentState = ref.read(userProvider);
      ref.read(userProvider.notifier).state = currentState.copyWith(
        appUser: currentState.appUser?.copyWith(profilePic: "local_temp"),
      );
    });

    await userNotifier.updateProfilePicture(imageBytes);

    if (!mounted) return;

    await ref.read(userProvider.notifier).loadUserData();

    setState(() {
      _profilePicVersion = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    final account = userState.account;
    final appUser = userState.appUser;

    final bluetoothState = ref.watch(bluetoothProvider);
    final deviceStatus = bluetoothState.connectedDevice != null
        ? "Connected: ${bluetoothState.connectedDevice!.name}"
        : "Not Connected";

    return Scaffold(
      appBar: const Header(title: "Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _updateProfilePicture(userNotifier),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                child: ClipOval(
                  child: (appUser?.profilePic != null &&
                          appUser!.profilePic!.isNotEmpty &&
                          appUser.profilePic! != "local_temp")
                      ? Image.network(
                          appUser.profilePic!,
                          key: ValueKey(
                              appUser.profilePic!), // Important for refresh
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.account_circle,
                                  size: 100, color: Colors.grey),
                        )
                      : const Icon(Icons.person, size: 100, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 5),
            Text(
              "${appUser?.fName ?? "John"} ${appUser?.lName ?? "Doe"}",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),

            Text(
              appUser?.email ?? "johndoe@gmail.com",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            _buildEditableCard(
                title: "Bio",
                icon: Icons.info,
                controller: _bioController,
                value: account?.bio ?? "",
                isEditing: _isEditingBio,
                onToggleEditing: () {
                  setState(() {
                    _isEditingBio = !_isEditingBio;
                  });
                },
                onSave: () {
                  userNotifier.updateBio(_bioController.text);
                },
                defaultText: "No bio available."),

            const SizedBox(height: 5),
            _buildInfoCard(
                "Device Status", deviceStatus, Icons.bluetooth_connected),
            const SizedBox(height: 5),
            _buildInfoCard(
                "Wound Status", "Current State: Healthy", Icons.healing),
            const SizedBox(height: 5),

            // Medical Notes Section**
            _buildEditableCard(
                title: "Medical Notes",
                icon: Icons.notes,
                controller: _notesController,
                value: account?.medNote ?? "",
                isEditing: _isEditingNotes,
                onToggleEditing: () {
                  setState(() {
                    _isEditingNotes = !_isEditingNotes;
                  });
                },
                onSave: () {
                  userNotifier.updateMedicalNotes(_notesController.text);
                },
                defaultText: "No notes available."),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required String value,
    required bool isEditing,
    required VoidCallback onToggleEditing,
    required VoidCallback onSave,
    String defaultText = "No information available",
  }) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: theme.textTheme.bodyLarge!.color),
        ),
        subtitle: isEditing
            ? TextField(
                controller: controller,
                maxLines: 2,
                style: TextStyle(color: theme.textTheme.bodyLarge!.color),
                decoration: InputDecoration(
                  hintText: "Enter $title...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                ),
              )
            : Text(
                value.isNotEmpty ? value : defaultText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
        trailing: IconButton(
          icon: Icon(
            isEditing ? Icons.save : Icons.edit,
            color: isEditing
                ? Colors.green
                : (Theme.of(context).brightness == Brightness.dark
                    ? theme.iconTheme.color
                    : theme.primaryColor),
          ),
          onPressed: () {
            if (isEditing) {
              onSave();
            }
            onToggleEditing();
          },
        ),
      ),
    );
  }

  /// Info Display Card
  Widget _buildInfoCard(String title, String value, IconData icon) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: theme.textTheme.bodyLarge!.color)),
        subtitle: Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge!.color)),
      ),
    );
  }
}
