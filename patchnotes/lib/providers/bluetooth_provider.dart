import 'dart:convert';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/bluetooth/ble_uuids.dart';

class AppBluetoothState {
  final bool isScanning;
  final BluetoothDevice? connectedDevice;
  final BluetoothAdapterState adapterState;
  final BluetoothCharacteristic? userEmailChar;
  final BluetoothCharacteristic? wifiIdChar;
  final BluetoothCharacteristic? wifiPasswordChar;

  AppBluetoothState({
    this.isScanning = false,
    this.connectedDevice,
    this.adapterState = BluetoothAdapterState.unknown,
    this.userEmailChar,
    this.wifiIdChar,
    this.wifiPasswordChar,
  });

  AppBluetoothState copyWith(
      {bool? isScanning,
      BluetoothDevice? connectedDevice,
      BluetoothAdapterState? adapterState,
      BluetoothCharacteristic? userEmailChar,
      BluetoothCharacteristic? wifiIdChar,
      BluetoothCharacteristic? wifiPasswordChar}) {
    return AppBluetoothState(
      isScanning: isScanning ?? this.isScanning,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      adapterState: adapterState ?? this.adapterState,
      userEmailChar: userEmailChar ?? this.userEmailChar,
      wifiIdChar: wifiIdChar ?? this.wifiIdChar,
      wifiPasswordChar: wifiPasswordChar ?? this.wifiPasswordChar,
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

      final services = await device.discoverServices();
      BluetoothCharacteristic? emailChar;
      BluetoothCharacteristic? wifiIdChar;
      BluetoothCharacteristic? wifiPassChar;

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic c in service.characteristics) {
          final uuid = c.uuid.toString().toLowerCase();
          if (uuid == userEmailUUID) emailChar = c;
          if (uuid == wifiIdUUID) wifiIdChar = c;
          if (uuid == wifiPasswordUUID) wifiPassChar = c;
        }
      }

      state = state.copyWith(
        userEmailChar: emailChar,
        wifiIdChar: wifiIdChar,
        wifiPasswordChar: wifiPassChar,
      );

      print("Connected to ${device.platformName} + characteristics discovered");
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

  Future<void> writeStringToCharacteristic(
      BluetoothCharacteristic? char, String value) async {
    if (char == null) return;
    await char.write(value.codeUnits, withoutResponse: false);
  }

  Future<void> sendCredentials({
    required BluetoothDevice device,
    required String email,
    required String ssid,
    required String password,
    required String serviceUUID,
  }) async {
    final services = await device.discoverServices();

    final service = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase() == serviceUUID.toLowerCase(),
      orElse: () => throw Exception("Service not found"),
    );

    Future<void> writeChar(String uuid, String value, String label) async {
      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase() == uuid.toLowerCase(),
        orElse: () => throw Exception("Characteristic $uuid not found"),
      );

      if (characteristic.properties.write) {
        await characteristic.write(utf8.encode(value), withoutResponse: false);
        print("✅ Sent $label: $value");
      } else {
        throw Exception("Characteristic $uuid does not support writing.");
      }
    }

    await writeChar(userEmailUUID, email, "Email");
    await writeChar(wifiIdUUID, ssid, "SSID");
    await writeChar(wifiPasswordUUID, password, "Password");
  }
}

final bluetoothProvider =
    StateNotifierProvider<BluetoothNotifier, AppBluetoothState>(
  (ref) => BluetoothNotifier(),
);
