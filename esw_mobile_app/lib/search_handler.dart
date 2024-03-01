import 'dart:developer';
import 'package:esw_mobile_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key, required this.recogDevice});

  final Function(List<dynamic>) recogDevice;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        startScan();
      },
      child: Container(
        width: 200.0,
        height: 200.0,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue, boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20.0,
          )
        ]),
        child: const Center(
          child: Icon(
            Icons.search,
            color: Colors.white,
            size: 50.0,
          ),
        ),
      ),
    );
  }

  void startScan() async {
    log("Starting scan for bluetooth devices!");
    _requestPermissions();
    flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (!device.name.startsWith("ESP32_Sensor")) return;

      recogDevice([device.name, device.id]);
    }, onError: (error) {
      //code for handling error
      log(error.toString());
    });
  }

  Future<void> _requestPermissions() async {
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();

    // Check permissions status
    if (statuses[Permission.bluetoothScan]!.isGranted && statuses[Permission.bluetoothConnect]!.isGranted && statuses[Permission.location]!.isGranted) {
      // All permissions granted, proceed with your app logic
      print('All permissions granted');
    } else {
      // Handle permission denied scenarios
      print('Some permissions were not granted');
    }
  }
}
