import 'package:esw_mobile_app/scan_device_list.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    super.key,
    required this.startScan,
    required this.stopScan,
    required this.isScanning,
  });

  final Function() startScan;
  final Function() stopScan;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isScanning) {
          startScan();
        } else {
          stopScan();
        }
      },
      child: Container(
        width: 200.0,
        height: 200.0,
        decoration: BoxDecoration(shape: BoxShape.circle, color: isScanning ? Colors.red : Colors.blue, boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20.0,
          )
        ]),
        child: Center(
          child: Icon(
            isScanning ? Icons.stop : Icons.search,
            color: Colors.white,
            size: 80.0,
          ),
        ),
      ),
    );
  }
}

class ConnectButton extends StatelessWidget {
  const ConnectButton({
    super.key,
    required this.deviceStates,
    required this.onPressConnect,
    required this.onPressProceed,
    required this.allBleConnected,
  });

  final List<DeviceState> deviceStates;
  final Function() onPressConnect;
  final Function() onPressProceed;
  final bool allBleConnected;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: checkSelection() ? 40 : -100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60.0),
        child: GestureDetector(
          onTap: allBleConnected ? onPressProceed : onPressConnect,
          child: Container(
            height: 70,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                allBleConnected ? "Proceed" : "Connect",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool checkSelection() {
    for (var element in deviceStates) {
      if (element == DeviceState.selected || element == DeviceState.connecting || element == DeviceState.connected) return true;
    }
    return false;
  }
}
