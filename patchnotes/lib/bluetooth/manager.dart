import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  static Future<void> setupBluetooth() async {
    if (!(await FlutterBluePlus.isSupported)) {
      return;
    }
    var adapaterState = await FlutterBluePlus.adapterState.first;
    if (adapaterState != BluetoothAdapterState.on) {
      return; // This is an empty list.
    }
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  static Future<List<BluetoothDevice>> scanForDevices() async {
    List<BluetoothDevice> devices = [];
    Set<String> seenDeviceIds = {}; // Prevent duplicates

    //This makes sure that Bluetooth is enabled prior to scanning for devices
    var adapaterState = await FlutterBluePlus.adapterState.first;
    if (adapaterState != BluetoothAdapterState.on) {
      return devices; // This is an empty list.
    }

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
    await FlutterBluePlus.stopScan();

    return devices;
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
