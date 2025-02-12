import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patchnotes/widgets/bottom_navbar.dart';
import 'package:patchnotes/pages/settings.dart';

import 'dashboard.dart';
import '../widgets/top_navbar.dart';
import 'mainscreen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileImage = "";
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
  final Color accentColor =
      const Color(0xFF5B9BD5); // Teal/Blue to complement purple
  final Color cardColor = Colors.white; // Light lavender for cards
  final Color textColor = Colors.black;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController bioController = TextEditingController(text: bio);
    TextEditingController notesController =
        TextEditingController(text: medicalNotes);

    return Scaffold(
      appBar: const Header(title: "Profile"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // The User's Profile Picture which is located at the top
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImage.isNotEmpty
                    ? FileImage(File(profileImage))
                    : AssetImage('assets/default_avatar.png')
                        as ImageProvider, // We use the default avatar image if user does not upload a profile picture.
              ),
            ),
            SizedBox(height: 10),
            Text(displayName,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(phoneNumber,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 16),

            // Bio Section. Allows the user to write a little bio about themselves.
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

            // Device Information - informs the user what kind of device they are connected to or whether they are connected
            _buildInfoCard(
                "Device Status", deviceStatus, Icons.bluetooth_connected),
            _buildInfoCard("Wound Status", woundStatus, Icons.healing),

            // Medical Notes Section - a medical note a user can write about their current health status.
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

            SizedBox(height: 10),

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
  mainScreenKey.currentState?.onTabTapped(4); // Switch to Settings Page
},

              icon: Icon(Icons.settings, color: Colors.white),
              label: Text('Change Settings',
                  style: TextStyle(color: Colors.white)),
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
      color: cardColor,
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
                    Icon(icon, color: accentColor),
                    SizedBox(width: 10),
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, color: textColor)),
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
                    : Text(value,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit,
                    color: accentColor),
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
      color: cardColor,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: accentColor),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.w400, color: textColor)),
        subtitle: Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
      ),
    );
  }
}
