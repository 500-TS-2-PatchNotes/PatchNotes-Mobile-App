import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'manager.dart';

class ScannerPage extends StatefulWidget {
  final Function(BluetoothDevice?) onDeviceSelected;

  const ScannerPage({super.key, required this.onDeviceSelected});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  BluetoothManager? bluetoothManager;
  List<BluetoothDevice> foundDevices = [];
  bool isScanning = false;
  bool isConnecting = false; // Prevents multiple simultaneous connections

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bluetoothManager ??= Provider.of<BluetoothManager>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startScanning();
    });
  }

  void _startScanning() async {
    if (!mounted || isScanning) return;

    setState(() {
      isScanning = true;
      foundDevices.clear();
    });

    try {
      if (bluetoothManager == null) {
        setState(() => isScanning = false);
        return;
      }

      List<BluetoothDevice> scannedDevices = await bluetoothManager!.scanForDevices();

      if (!mounted) return;

      setState(() {
        foundDevices = scannedDevices;
        isScanning = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
      print("Error scanning: $e");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice? device) async {
    if (bluetoothManager == null) {
      print("BluetoothManager is null. Cannot connect.");
      return;
    }

    if (device == null) {
      print("Device is null. Cannot connect.");
      return;
    }

    if (isConnecting) {
      print("Already connecting to a device. Please wait.");
      return;
    }

    setState(() {
      isConnecting = true;
    });

    try {
      bool connected = await bluetoothManager!.connectToDevice(device);

      if (mounted) {
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
            const SnackBar(content: Text("Connection timed out. Please try again.")),
          );
        }
      }
    } catch (e) {
      print("Failed to connect: $e");
      if (mounted) {
        setState(() {
          isConnecting = false;
        });

        widget.onDeviceSelected(null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        title: Text(device.platformName.isNotEmpty
                            ? device.platformName
                            : "Unknown Device"),
                        subtitle: Text(device.remoteId.toString()),
                        onTap: isConnecting
                            ? null
                            : () {
                                _connectToDevice(device);
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  @override
  void dispose() {
    if (bluetoothManager != null && isScanning) {
      try {
        bluetoothManager!.stopScan();
      } catch (e) {
        print("Error stopping scan: $e");
      }
    }
    super.dispose();
  }
}
