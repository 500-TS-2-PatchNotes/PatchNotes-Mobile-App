import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patchnotes/providers/bluetooth_provider.dart';
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

    final stateColor = _getStateColor(woundStatus);
    final stateIcon = _getStateIcon(woundStatus);

    return Scaffold(
      appBar: const Header(title: "Dashboard"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              _buildStateIndicator(stateIcon, stateColor, woundStatus),
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
            items: ['Red', 'Yellow', 'Green']
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
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _capturedImage = null;
      _selectedColor = null;
      _isSending = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Image sent!"),
        backgroundColor: Colors.green,
      ),
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
