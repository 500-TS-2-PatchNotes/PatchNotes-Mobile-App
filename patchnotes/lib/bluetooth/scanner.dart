import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'manager.dart'; // Import Bluetooth logic

class ScannerPage extends StatefulWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  const ScannerPage({super.key, required this.onDeviceSelected});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<BluetoothDevice> foundDevices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() async {
    setState(() {
      isScanning = true;
      foundDevices.clear(); // Clear previous scan results
    });

    foundDevices = await BluetoothManager.scanForDevices();
    
    setState(() {
      isScanning = false;
    });
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
                        onTap: () async {
                          await BluetoothManager.connectToDevice(device);
                          widget.onDeviceSelected(device);
                          Navigator.pop(context); // Returns to the dashboard page
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: _startScanning,
              child: const Text("Refresh Scan"),
            ),
          ),
        ],
      ),
    );
  }
}
