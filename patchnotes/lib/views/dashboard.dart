import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patchnotes/providers/bluetooth_provider.dart';
import '../providers/navigation.dart';
import '../widgets/top_navbar.dart';
import '../bluetooth/scanner.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final String woundStatus = 'Healthy';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildStateIndicator(stateIcon, stateColor, woundStatus),
            const Spacer(),
            _buildActionButtons(context, tabIndexNotifier, bluetoothNotifier,
                isConnected, theme),
            const SizedBox(height: 30),
          ],
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
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
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
        icon: Icon(isConnected ? Icons.bluetooth_disabled : Icons.bluetooth,
            color: Colors.white),
        label: Text(
          isConnected ? "Disconnect" : "Sync Device",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
