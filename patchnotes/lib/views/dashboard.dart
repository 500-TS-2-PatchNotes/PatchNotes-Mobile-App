import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patchnotes/bluetooth/ble_uuids.dart';
import 'package:patchnotes/providers/auth_provider.dart';
import 'package:patchnotes/providers/bluetooth_provider.dart';
import 'package:patchnotes/providers/calibration_provider.dart';
import 'package:patchnotes/providers/user_provider.dart';
import 'package:patchnotes/utils/insights_helper.dart';
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
  bool _showOverlay = false;
  BluetoothDevice? _overlayDevice;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(userProvider.notifier).loadUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabIndexNotifier = ref.read(tabIndexProvider.notifier);
    final bluetoothState = ref.watch(bluetoothProvider);
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    final theme = Theme.of(context);

    final wound = ref.watch(userProvider).wound;
    final level = wound?.currentLvl ?? 0.0;
    final calibrationLevels = ref.watch(calibrationStreamProvider).value ?? [];

    final cfu = estimateCFUFromLevel(calibrationLevels, level);

    final woundState = getWoundStateFromCFU(calibrationLevels, cfu);
    final stateColor = _getStateColor(woundState);
    final stateIcon = _getStateIcon(woundState);

    return Stack(
      children: [
        Scaffold(
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
                  Column(
                    children: [
                      _buildCameraButton(theme),
                      const SizedBox(height: 20),
                      _buildSyncDevice(
                        context,
                        tabIndexNotifier,
                        bluetoothNotifier,
                        bluetoothState.connectedDevice != null,
                        theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
        if (_showOverlay)
          Positioned.fill(
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    color: Colors.transparent, // allow blur to work
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.3), // dim background
                ),
                Center(child: _buildOverlayCard(context)), // show overlay card
              ],
            ),
          ),
      ],
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

  Widget _buildSyncDevice(
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
            final selectedDevice = await Navigator.push<BluetoothDevice?>(
              context,
              MaterialPageRoute(
                builder: (context) => ScannerPage(
                  onDeviceSelected: (device) {
                    Navigator.pop(context, device);
                  },
                ),
              ),
            );

            if (selectedDevice != null && mounted) {
              final success =
                  await bluetoothNotifier.connectToDevice(selectedDevice);

              if (!mounted) return;

              if (success) {
                setState(() {
                  _overlayDevice = selectedDevice;
                  _showOverlay = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Device connected successfully!",
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Failed to connect device.",
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            await bluetoothNotifier.disconnectDevice();
            ref.refresh(bluetoothProvider);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Device disconnected.", textAlign: TextAlign.center),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
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

  Widget _buildOverlayCard(BuildContext context) {
    final ssidController = TextEditingController();
    final passwordController = TextEditingController();

    return Center(
      child: Material(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter Wi-Fi Credentials',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: ssidController,
                  decoration: const InputDecoration(labelText: 'Wi-Fi SSID'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Wi-Fi Password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final ssid = ssidController.text.trim();
                    final password = passwordController.text.trim();

                    if (!mounted || _overlayDevice == null) return;

                    final user = ref.read(authProvider).firebaseUser;
                    final email = user?.email ?? "unknown@patchnotes.dev";

                    final bluetoothNotifier =
                        ref.read(bluetoothProvider.notifier);
                    try {
                      await bluetoothNotifier.sendCredentials(
                        device: _overlayDevice!,
                        email: email,
                        ssid: ssid,
                        password: password,
                        serviceUUID: serviceUID,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Failed to send credentials: $e")),
                      );
                    }

                    if (mounted) {
                      setState(() {
                        _showOverlay = false;
                        _overlayDevice = null;
                      });
                    }
                  },
                  child: const Text('Send Credentials'),
                ),
                TextButton(
                  onPressed: () => setState(() => _showOverlay = false),
                  child: const Text('Cancel'),
                )
              ],
            ),
          ),
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
    final user = ref.read(authProvider).firebaseUser;
    final uid = user?.uid;

    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not authenticated."),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isSending = false);
      return;
    }

    try {
      final timestamp = DateTime.now();
      final formattedName =
          "${timestamp.toIso8601String().split('.').first.replaceAll(':', '-').replaceAll('T', '_')}.jpg";

      final fileBytes = await File(_capturedImage!.path).readAsBytes();
      final imageUrl = await storageService.uploadWoundImage(
        uid,
        fileBytes,
        fileName: formattedName,
      );

      if (imageUrl == null) throw Exception("Image upload failed.");
      await firestoreService.addWoundImage(uid, imageUrl);

      final infoDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wound_data')
          .doc('info');

      await infoDocRef.set({
        'woundImages': FieldValue.arrayUnion([imageUrl]),
        'imageTimestamp': Timestamp.now(),
        'lastSynced': Timestamp.now(),
        'insightsMessage': 'Status: Awaiting analysis...',
        'insightsTip': 'Tip: Please wait while the image is analyzed.',
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image uploaded successfully."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _capturedImage = null;
        _selectedColor = null;
        _isSending = false;
      });
    }
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
}
