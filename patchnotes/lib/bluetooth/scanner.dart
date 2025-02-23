import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    // Start scanning after the widget is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });
  }

  Future<void> _startScanning() async {
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    try {
      // Trigger scan; this will update provider's state.
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

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    if (isConnecting) return;
    setState(() {
      isConnecting = true;
    });
    try {
      bool connected = await bluetoothNotifier.connectToDevice(device);
      if (!mounted) return;
      setState(() {
        isConnecting = false;
      });
      if (connected) {
        widget.onDeviceSelected(device);
        Navigator.pop(context);
      } else {
        widget.onDeviceSelected(null);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Connection timed out. Please try again.")),
        );
      }
    } catch (e) {
      print("Failed to connect: $e");
      if (mounted) {
        setState(() {
          isConnecting = false;
        });
        widget.onDeviceSelected(null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Optionally watch the bluetooth state if you need to show adapter state or scanning flag.
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
                        onTap: isConnecting
                            ? null
                            : () => _connectToDevice(device),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: isScanning ? null : _startScanning,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF5B9BD5).withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
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
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
