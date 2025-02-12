import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  static bool _isScanning = false; // Track scanning state

  static Future<void> setupBluetooth() async {
    if (!(await FlutterBluePlus.isSupported)) {
      return;
    }
    var adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      return;
    }
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  static Future<List<BluetoothDevice>> scanForDevices() async {
    List<BluetoothDevice> devices = [];
    Set<String> seenDeviceIds = {}; // Prevent duplicates

    var adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      return devices; 
    }

    if (_isScanning) return devices; // Prevent duplicate scans

    _isScanning = true;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!seenDeviceIds.contains(r.device.remoteId.toString())) {
          seenDeviceIds.add(r.device.remoteId.toString());
          devices.add(r.device);
        }
      }
    });

    await Future.delayed(const Duration(seconds: 5));
    await stopScan(); // Stop scanning properly

    return devices;
  }

  static Future<void> stopScan() async {
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      _isScanning = false;
    }
  }

  static Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      print("Connected to ${device.platformName}");
    } catch (e) {
      print("Failed to connect: $e");
    }
  }

  static Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      print("Disconnected from ${device.platformName}");
    } catch (e) {
      print("Failed to disconnect: $e");
    }
  }
}
