import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileImage = "https://via.placeholder.com/150";
  String displayName = "Joshua Debele";
  String email = "joshua@example.com";
  String phoneNumber = "(+1) 123-456-7890";
  String bio = "Software Engineer | Flutter Developer";
  bool isEditingBio = false;
  String deviceStatus = "ESP32-CAM Connected";
  String woundStatus = "Current State: Healthy";
  String medicalNotes = "Applied new dressing today.";
  bool isEditingNotes = false;

  final Color primaryColor = Color(0xFF967BB6); // Main purple theme
  final Color accentColor = const Color(0xFF5B9BD5); // Teal/Blue to complement purple
  final Color cardColor = Colors.white; // Light lavender for cards
  final Color textColor = Colors.black; // High contrast text

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController bioController = TextEditingController(text: bio);
    TextEditingController notesController = TextEditingController(text: medicalNotes);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage(profileImage),
              ),
            ),
            SizedBox(height: 10),
            Text(displayName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(phoneNumber, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 16),

            // Bio Section
            _buildEditableCard(
              title: "Bio",
              icon: Icons.info,
              isEditing: isEditingBio,
              controller: bioController,
              value: bio,
              onSave: () {
                setState(() {
                  bio = bioController.text;
                  isEditingBio = false;
                });
              },
              onEdit: () {
                setState(() {
                  isEditingBio = true;
                });
              },
            ),

            // Device Information
            _buildInfoCard("Device Status", deviceStatus, Icons.bluetooth_connected),
            _buildInfoCard("Wound Status", woundStatus, Icons.healing),

            // Medical Notes Section
            _buildEditableCard(
              title: "Medical Notes",
              icon: Icons.notes,
              isEditing: isEditingNotes,
              controller: notesController,
              value: medicalNotes,
              onSave: () {
                setState(() {
                  medicalNotes = notesController.text;
                  isEditingNotes = false;
                });
              },
              onEdit: () {
                setState(() {
                  isEditingNotes = true;
                });
              },
            ),

            SizedBox(height: 20),

            // Settings Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                elevation: 5,
              ),
              onPressed: () {
                // Navigate to Settings Page
              },
              icon: Icon(Icons.settings, color: Colors.white),
              label: Text('Change Settings', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableCard({
    required String title,
    required IconData icon,
    required bool isEditing,
    required TextEditingController controller,
    required String value,
    required VoidCallback onSave,
    required VoidCallback onEdit,
  }) {
    return Card(
      color: cardColor, // Light lavender background
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: accentColor), // Teal/Blue icon
                    SizedBox(width: 10),
                    Text(title, style: TextStyle(fontWeight: FontWeight.w400, color: textColor)),
                  ],
                ),
                SizedBox(height: 5),
                isEditing
                    ? TextField(
                        controller: controller,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Enter $title...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: accentColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      )
                    : Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)), // Bold text inside card
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit, color: accentColor),
                onPressed: isEditing ? onSave : onEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      color: cardColor, // Light lavender background
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: accentColor), // Dark purple icons
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w400, color: textColor)),
        subtitle: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)), // Bold text inside card
      ),
    );
  }
}
