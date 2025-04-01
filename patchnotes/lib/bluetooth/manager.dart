import 'dart:convert';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import "ble_uuids.dart";

class BluetoothManager {
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;

  bool get isScanning => _isScanning;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  Stream<BluetoothAdapterState> get adapterStateStream =>
      FlutterBluePlus.adapterState;

  Future<void> setupBluetooth() async {
    if (!(await FlutterBluePlus.isSupported)) return;

    var adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) return;

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<List<BluetoothDevice>> scanForDevices() async {
    List<BluetoothDevice> devices = [];
    Set<String> seenDeviceIds = {};

    var adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      return devices;
    }
    if (_isScanning) return devices;

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
    await stopScan();
    return devices;
  }

  Future<void> stopScan() async {
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      _isScanning = false;
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 3));
      _connectedDevice = device;
      print("Connected to ${device.platformName}");
      return true;
    } on FlutterBluePlusException catch (e) {
      if (e.code == 1) {
        print("Failed to connect: Timeout");
      } else if (e.code == 12) {
        print("Failed to connect: Device is invalid");
      }
      return false;
    } catch (e) {
      print("Failed to connect: $e");
      return false;
    }
  }

  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        print("Fully disconnected from device");
      } catch (e) {
        print("Failed to disconnect: $e");
      }
    }
  }
}
