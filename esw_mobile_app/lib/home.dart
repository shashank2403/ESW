import "dart:developer";
import 'package:esw_mobile_app/scan_device_list.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_reactive_ble/flutter_reactive_ble.dart";
import "package:permission_handler/permission_handler.dart";
import 'search_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  List<List<dynamic>> scannedDevices = [];
  Set<int> selectedDevices = {};
  bool isScanning = false;
  // bool isConnected = false;
  // bool isConnecting = false;
  // bool isDisconnecting = false;
  // bool isDisconnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                  startScan: startScan,
                  stopScan: stopScan,
                  isScanning: isScanning,
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  !isScanning ? "Search for devices" : "Scanning...",
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 35.0,
                ),
                GestureDetector(
                  onTap: () => reset(),
                  child: Container(
                    width: 100,
                    height: 30,
                    color: Colors.amber,
                    child: const Text(
                      "Reset",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40.0,
                ),
                if (isScanning)
                  ScanDeviceList(
                    scannedDevices: scannedDevices,
                    selectedDevices: selectedDevices,
                    deviceOnPressed: deviceOnPressed,
                  ),
              ],
            ),
            ConnectButton(selectedDevices: selectedDevices),
          ],
        ),
      ),
    );
  }

  void recogDevice(List<dynamic> deviceInfo) {
    bool deviceExists = scannedDevices.any((element) => element[1] == deviceInfo[1]);
    if (!deviceExists) {
      if (scannedDevices.isNotEmpty) log(listEquals(scannedDevices[0], deviceInfo).toString());
      setState(() {
        scannedDevices.add(List.from(deviceInfo)); // Create a new list to avoid mutations
      });
    }
  }

  void startScan() async {
    setState(() {
      isScanning = true;
    });
    log("Starting scan for bluetooth devices!");
    _requestPermissions();
    flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (!device.name.startsWith("ESP32_Sensor")) return;

      recogDevice([device.name, device.id, device.serviceUuids]);
    }, onError: (error) {
      //code for handling error
      log(error.toString());
    });
  }

  void stopScan() {
    setState(() {
      isScanning = false;
    });
  }

  void reset() {
    setState(() {
      scannedDevices.clear();
      selectedDevices.clear();
      flutterReactiveBle.deinitialize();
      isScanning = false;
    });
  }
  // void startConnecting() {
  //   for (var idx in selectedDevices) {
  //     connectToDevice(scannedDevices, serviceUuids)
  //   }
  // }

  void connectToDevice(String id, List<Uuid> serviceUuids) {
    log("Connecting to device $id");
    flutterReactiveBle
        .connectToAdvertisingDevice(
      id: id,
      withServices: serviceUuids,
      prescanDuration: const Duration(seconds: 10),
    )
        .listen((ConnectionStateUpdate connectionState) {
      log(connectionState.connectionState.toString());
    });
  }

  Future<void> _requestPermissions() async {
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();

    // Check permissions status
    if (statuses[Permission.bluetoothScan]!.isGranted && statuses[Permission.bluetoothConnect]!.isGranted && statuses[Permission.location]!.isGranted) {
      // All permissions granted, proceed with your app logic
      log('All permissions granted');
    } else {
      // Handle permission denied scenarios
      log('Some permissions were not granted');
    }
  }

  void deviceOnPressed(int index) {
    if (isScanning) return;
    setState(() {
      if (selectedDevices.contains(index)) {
        selectedDevices.remove(index);
      } else {
        selectedDevices.add(index);
      }
    });
  }
}

class ConnectButton extends StatelessWidget {
  const ConnectButton({
    super.key,
    required this.selectedDevices,
  });

  final Set<int> selectedDevices;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: selectedDevices.isEmpty ? -100 : 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60.0),
        child: Container(
          height: 70,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              "Connect",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
