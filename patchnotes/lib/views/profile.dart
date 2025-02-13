import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patchnotes/views/mainscreen.dart';
import '../widgets/top_navbar.dart';
import '../../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);

    TextEditingController bioController =
        TextEditingController(text: profileVM.bio);
    TextEditingController notesController =
        TextEditingController(text: profileVM.medicalNotes);

    return Scaffold(
      appBar: const Header(title: "Profile"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: profileVM.pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileVM.profileImage.isNotEmpty
                    ? FileImage(File(profileVM.profileImage))
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 10),
            Text(profileVM.displayName,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text(profileVM.email,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 16),

            // Bio Section
            _buildEditableCard(
              title: "Bio",
              icon: Icons.info,
              isEditing: profileVM.isEditingBio,
              controller: bioController,
              value: profileVM.bio,
              onSave: () {
                profileVM.updateBio(bioController.text);
                profileVM.toggleBioEditing();
              },
              onEdit: profileVM.toggleBioEditing,
            ),

            SizedBox(height: 5),
            // Device Status & Wound Status
            _buildInfoCard("Device Status", profileVM.deviceStatus,
                Icons.bluetooth_connected),
            SizedBox(height: 5),
            _buildInfoCard(
                "Wound Status", profileVM.woundStatus, Icons.healing),
            SizedBox(height: 5),

            // Medical Notes Section
            _buildEditableCard(
              title: "Medical Notes",
              icon: Icons.notes,
              isEditing: profileVM.isEditingNotes,
              controller: notesController,
              value: profileVM.medicalNotes,
              onSave: () {
                profileVM.updateMedicalNotes(notesController.text);
                profileVM.toggleNotesEditing();
              },
              onEdit: profileVM.toggleNotesEditing,
            ),

            SizedBox(height: 20),

            // Settings Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B9BD5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                elevation: 5,
              ),
              onPressed: () {
                mainScreenKey.currentState?.onTabTapped(4);
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
      color: Colors.white,
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
                    Icon(icon, color: Color(0xFF5B9BD5)),
                    SizedBox(width: 10),
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.black)),
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
                            borderSide: BorderSide(color: Color(0xFF5B9BD5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      )
                    : Text(value,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit,
                    color: Color(0xFF5B9BD5)),
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
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF5B9BD5)),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black)),
        subtitle: Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
    );
  }
}
