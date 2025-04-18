import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/bluetooth/ble_uuids.dart';
import 'package:patchnotes/providers/bluetooth_provider.dart';

class ScannerPage extends ConsumerStatefulWidget {
  final Function(BluetoothDevice?) onDeviceSelected;

  const ScannerPage({Key? key, required this.onDeviceSelected})
      : super(key: key);

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  List<BluetoothDevice> foundDevices = [];
  bool isConnecting = false;

  final emailController = TextEditingController();
  final wifiIdController = TextEditingController();
  final wifiPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    wifiIdController.dispose();
    wifiPassController.dispose();
    super.dispose();
  }

  Future<void> _startScanning() async {
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    try {
      final devices = await bluetoothNotifier.scanForDevices();
      if (mounted) {
        setState(() {
          foundDevices = devices;
        });
      }
    } catch (e) {
      print("Error scanning: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothState = ref.watch(bluetoothProvider);
    final isScanning = bluetoothState.isScanning;

    return Scaffold(
      appBar: AppBar(title: const Text("Scan for Devices")),
      body: Column(
        children: [
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text("Scanning...", style: TextStyle(fontSize: 16)),
            ),
          Expanded(
            child: foundDevices.isEmpty
                ? const Center(child: Text("No devices found"))
                : ListView.builder(
                    itemCount: foundDevices.length,
                    itemBuilder: (context, index) {
                      final device = foundDevices[index];
                      return ListTile(
                        title: Text(
                          device.name.isNotEmpty
                              ? device.name
                              : "Unknown Device",
                        ),
                        subtitle: Text(device.remoteId.toString()),
                        onTap: () {
                          Navigator.pop(context, device);
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: isScanning ? null : _startScanning,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9BD5).withOpacity(0.8),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isScanning)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  const Icon(Icons.refresh, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    "Refresh Scan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
