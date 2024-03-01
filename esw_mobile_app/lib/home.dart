import "dart:developer";
import 'package:esw_mobile_app/scan_device_list.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import 'search_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> scannedDevices = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(25.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Image.asset(
                    "images/logo-iitd.png",
                    width: 100.0,
                    height: 100.0,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            SearchButton(
              recogDevice: recogDevice,
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text(
              "Search for devices",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 80.0,
            ),
            if (scannedDevices.isNotEmpty) ScanDeviceList(scannedDevices: scannedDevices),
          ],
        ),
      ),
    );
  }

  void recogDevice(List<dynamic> deviceInfo) {
    if (!scannedDevices.any((element) => listEquals(element, deviceInfo))) {
      setState(() {
        scannedDevices.add(deviceInfo);
      });
    }
  }
}
