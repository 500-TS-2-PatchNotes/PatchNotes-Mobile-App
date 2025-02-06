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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profileImage),
              ),
            ),
            SizedBox(height: 10),
            Text(displayName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(phoneNumber,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 1),

            // Bio Section
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blueAccent),
                            SizedBox(width: 10),
                            Text("Bio",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5),
                        isEditingBio
                            ? TextField(
                                controller: bioController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: "Enter your bio...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueAccent),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              )
                            : Text(bio,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(isEditingBio ? Icons.check : Icons.edit,
                            color: Colors.blueAccent),
                        onPressed: () {
                          setState(() {
                            if (isEditingBio) {
                              bio = bioController.text;
                            }
                            isEditingBio = !isEditingBio;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Device Information
            _buildInfoCard(
                "Device Status", deviceStatus, Icons.bluetooth_connected),
            _buildInfoCard("Wound Status", woundStatus, Icons.healing),

            // Medical Notes Section
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes, color: Colors.blueAccent),
                            SizedBox(width: 10),
                            Text("Medical Notes",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 5),
                        isEditingNotes
                            ? TextField(
                                controller: notesController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: "Enter medical notes...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.blueAccent),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              )
                            : Text(medicalNotes,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(isEditingNotes ? Icons.check : Icons.edit,
                            color: Colors.blueAccent),
                        onPressed: () {
                          setState(() {
                            if (isEditingNotes) {
                              medicalNotes = notesController.text;
                            }
                            isEditingNotes = !isEditingNotes;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Settings Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
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
              label: Text('Settings', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(color: Colors.grey[700])),
      ),
    );
  }
}
