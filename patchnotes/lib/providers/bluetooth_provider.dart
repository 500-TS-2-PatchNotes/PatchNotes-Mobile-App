import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBluetoothState {
  final bool isScanning;
  final BluetoothDevice? connectedDevice;
  final BluetoothAdapterState adapterState;

  AppBluetoothState({
    this.isScanning = false,
    this.connectedDevice,
    this.adapterState = BluetoothAdapterState.unknown,
  });

  AppBluetoothState copyWith({
    bool? isScanning,
    BluetoothDevice? connectedDevice,
    BluetoothAdapterState? adapterState,
  }) {
    return AppBluetoothState(
      isScanning: isScanning ?? this.isScanning,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      adapterState: adapterState ?? this.adapterState,
    );
  }
}

class BluetoothNotifier extends StateNotifier<AppBluetoothState> {
  BluetoothNotifier() : super(AppBluetoothState()) {
    _listenToAdapterState();
  }

  void _listenToAdapterState() {
    FlutterBluePlus.adapterState.listen((newState) {
      state = state.copyWith(adapterState: newState);
    });
  }

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
    if (adapterState != BluetoothAdapterState.on) return devices;
    if (state.isScanning) return devices;

    // Update state: scanning started.
    state = state.copyWith(isScanning: true);
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen to scan results.
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!seenDeviceIds.contains(r.device.remoteId.toString())) {
          seenDeviceIds.add(r.device.remoteId.toString());
          devices.add(r.device);
        }
      }
    });

    // Wait for the scan duration and then stop scanning.
    await Future.delayed(const Duration(seconds: 5));
    await stopScan();
    return devices;
  }

  Future<void> stopScan() async {
    if (state.isScanning) {
      await FlutterBluePlus.stopScan();
      // Update state: scanning stopped.
      state = state.copyWith(isScanning: false);
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 3));
      state = state.copyWith(connectedDevice: device);
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
  if (state.connectedDevice != null) {
    try {
      await state.connectedDevice!.disconnect(); 
      state = state.copyWith(connectedDevice: null);
      print("Fully disconnected from device");
    } catch (e) {
      print("Failed to disconnect: $e");
    }
  }
}


}

final bluetoothProvider = StateNotifierProvider<BluetoothNotifier, AppBluetoothState>(
  (ref) => BluetoothNotifier(),
);
