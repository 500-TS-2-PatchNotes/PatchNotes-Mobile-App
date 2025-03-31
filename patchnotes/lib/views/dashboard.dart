import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patchnotes/models/calibration_level.dart';
import 'package:patchnotes/providers/auth_provider.dart';
import 'package:patchnotes/providers/bluetooth_provider.dart';
import 'package:patchnotes/providers/calibration_provider.dart';
import 'package:patchnotes/providers/user_provider.dart';
import 'package:patchnotes/widgets/camera_capture.dart';
import '../providers/navigation.dart';
import '../widgets/top_navbar.dart';
import '../bluetooth/scanner.dart';
import 'package:camera/camera.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final String woundStatus = 'Healthy';
  XFile? _capturedImage;
  String? _selectedColor;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final tabIndexNotifier = ref.read(tabIndexProvider.notifier);
    final bluetoothState = ref.watch(bluetoothProvider);
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    final theme = Theme.of(context);
    final isConnected = bluetoothState.connectedDevice != null;

    final wound = ref.watch(userProvider).wound;
    final cfu = wound?.cfu ?? 0.0;
    final calibrationLevels = ref.watch(calibrationStreamProvider).value ?? [];

    final woundState = _getWoundStateFromLevel(calibrationLevels, cfu);
    final stateColor = _getStateColor(woundState);
    final stateIcon = _getStateIcon(woundState);

    return Scaffold(
      appBar: const Header(title: "Dashboard"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildStateIndicator(stateIcon, stateColor, woundState),
              const SizedBox(height: 50),
              _buildImagePreview(theme),
              const SizedBox(height: 40),
              _buildCameraButton(theme),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateIndicator(IconData icon, Color color, String stateText) {
    return Column(
      children: [
        Icon(icon, size: 60, color: color),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            stateText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    StateController<int> tabIndexNotifier,
    BluetoothNotifier bluetoothNotifier,
    bool isConnected,
    ThemeData theme,
  ) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isConnected ? Colors.red : theme.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          elevation: 5,
        ),
        onPressed: () async {
          if (!isConnected) {
            final selectedDevice = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScannerPage(
                  onDeviceSelected: (device) async {
                    if (device != null) {
                      bool success =
                          await bluetoothNotifier.connectToDevice(device);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "Device connected successfully!"
                                : "Failed to connect device.",
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
            if (selectedDevice != null) ref.refresh(bluetoothProvider);
          } else {
            await bluetoothNotifier.disconnectDevice();
            ref.refresh(bluetoothProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text("Device disconnected.", textAlign: TextAlign.center),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        icon: Icon(
          isConnected ? Icons.bluetooth_disabled : Icons.bluetooth,
          color: Colors.white,
        ),
        label: Text(
          isConnected ? "Disconnect" : "Sync Device",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCameraButton(ThemeData theme) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          elevation: 5,
        ),
        onPressed: () async {
          final image = await Navigator.push<XFile?>(
            context,
            MaterialPageRoute(builder: (context) => const CameraCapturePage()),
          );
          if (image != null) {
            setState(() {
              _capturedImage = image;
              _selectedColor = null;
            });
          }
        },
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          "Take Picture",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    return Column(
      children: [
        _capturedImage != null
            ? Image.file(
                File(_capturedImage!.path),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
            : Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Center(
                  child: Text(
                    "No image captured yet",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
        const SizedBox(height: 10),
        if (_capturedImage != null) ...[
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Select Wound Color (Optional)",
              filled: true,
              fillColor: Colors.white70,
            ),
            value: _selectedColor,
            onChanged: (value) => setState(() => _selectedColor = value),
            items: ['Blue', 'Yellow', 'Green']
                .map((color) =>
                    DropdownMenuItem(value: color, child: Text(color)))
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isSending ? null : _sendImage,
                child: _isSending
                    ? const CircularProgressIndicator()
                    : const Text("Send"),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _capturedImage = null;
                  _selectedColor = null;
                }),
                child: const Text("Cancel"),
              )
            ],
          ),
        ]
      ],
    );
  }

  Future<void> _sendImage() async {
    if (_capturedImage == null) return;
    setState(() => _isSending = true);

    final storageService = ref.read(firebaseStorageServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final calibrationLevels = ref.read(calibrationStreamProvider).value ?? [];
    final user = ref.read(authProvider).firebaseUser;
    final uid = user?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User not authenticated."),
            backgroundColor: Colors.red),
      );
      setState(() => _isSending = false);
      return;
    }

    try {
      final fileBytes = await File(_capturedImage!.path).readAsBytes();
      final imageUrl = await storageService.uploadWoundImage(uid, fileBytes);

      if (imageUrl != null) {
        await firestoreService.addWoundImage(uid, imageUrl);

        double? finalCfu;
        String finalState = 'Unknown';
        String? selectedColorHex;

        // Map selected color to calibration data
        if (_selectedColor != null) {
          final mapping = {
            'Blue': Color(0xFF016BC8),
            'Green': Color(0xFF91A55E),
            'Yellow': Color(0xFFF1BB00),
          };

          final colorCode = mapping[_selectedColor!];

          // Find the matching calibration level
          final match = calibrationLevels.firstWhere(
            (level) => level.color == colorCode,
            orElse: () => calibrationLevels.first,
          );

          finalCfu = match.cfu;
          finalState = match.healthState;
          selectedColorHex =
              '#${match.color.value.toRadixString(16).substring(2).toUpperCase()}';
        } else {
          // Simulate a predicted value
          final predictedLevel = 1.0 + (DateTime.now().second % 6);
          finalCfu = predictedLevel;
          finalState =
              _getWoundStateFromLevel(calibrationLevels, predictedLevel);
        }

        final String message = _getStatusMessage(finalState);
        final String tip = _getTip(finalState);

        final infoDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('wound_data')
            .doc('info');

        await infoDocRef.update({
          'woundImages': FieldValue.arrayUnion([imageUrl]),
          'cfu': finalCfu,
          'woundStatus': finalState,
          'message': message,
          'tip': tip,
          'insightsMessage': message,
          'insightsTip': tip,
          'colour': _selectedColor ?? "Green",
          'imageTimestamp': Timestamp.now(),
          'lastSynced': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Image and wound status updated!"),
              backgroundColor: Colors.green),
        );
      } else {
        throw Exception("Image upload failed.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _capturedImage = null;
        _selectedColor = null;
        _isSending = false;
      });
    }
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'Healthy':
        return Colors.green;
      case 'Unhealthy':
        return Colors.red;
      case 'Monitor Needed':
      default:
        return Colors.amber;
    }
  }

  IconData _getStateIcon(String state) {
    switch (state) {
      case 'Healthy':
        return Icons.check_circle;
      case 'Unhealthy':
        return Icons.error;
      case 'Monitor Needed':
      default:
        return Icons.info;
    }
  }

  String _getStatusMessage(String state) {
    switch (state) {
      case 'Healthy':
        return 'Status: Your wound is healing well. Keep it up!';
      case 'Monitor Needed':
        return 'Status: Monitor your wound. Follow care instructions.';
      case 'Unhealthy':
        return 'Status: Wound condition is serious. Seek medical attention.';
      default:
        return 'Status: Unknown wound status.';
    }
  }

  String _getTip(String state) {
    switch (state) {
      case 'Healthy':
        return 'Tip: Keep the wound clean and covered to prevent infection.';
      case 'Monitor Needed':
        return 'Tip: Change bandages regularly and monitor for any changes.';
      case 'Unhealthy':
        return 'Tip: Contact your healthcare provider for professional treatment.';
      default:
        return 'Tip: No specific advice available.';
    }
  }

  String _getWoundStateFromLevel(List<CalibrationLevel> levels, double level) {
    if (levels.isEmpty) return 'Unknown'; // <-- handle empty levels safely
    for (int i = 0; i < levels.length; i++) {
      if (level <= levels[i].cfu) return levels[i].healthState;
    }
    return levels.last.healthState;
  }
}
