import "dart:developer";
import "package:esw_mobile_app/constants.dart";
import "package:esw_mobile_app/data_screen.dart";
import 'package:esw_mobile_app/scan_device_list.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_reactive_ble/flutter_reactive_ble.dart";
import "package:permission_handler/permission_handler.dart";
import 'function_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  List<List<dynamic>> scannedDevices = [];
  List<DeviceState> deviceStates = [];
  bool isScanning = false;
  bool isConnecting = false;
  bool isConnected = false;

  bool deviceSelected = false;
  int selectedIdx = -1;
  String connectedDeviceName = "";
  String connectedDeviceId = "";
  List<Uuid> connectedDeviceServices = [];

  List<Service> deviceBLEServices = [];
  late Service serviceBLE;
  late Characteristic characteristicBLE;
  bool foundService = false;
  bool foundCharacteristic = false;

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
                  onTap: () => resetBLE(),
                  child: Container(
                    color: Colors.amber,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Text(
                        "Reset",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40.0,
                ),
                ScanDeviceList(
                  scannedDevices: scannedDevices,
                  deviceOnPressed: deviceOnPressed,
                  deviceStates: isScanning ? List<DeviceState>.filled(scannedDevices.length, DeviceState.unselected) : deviceStates,
                ),
              ],
            ),
            ConnectButton(
              deviceStates: deviceStates,
              onPressConnect: startConnecting,
              onPressProceed: onPressProceed,
              isConnected: isConnected,
            ),
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
    log("Starting scan for bluetooth devices!");
    _requestPermissions();
    flutterReactiveBle.initialize();
    flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
      if (!device.name.startsWith("ESP32_Sensor")) return;
      recogDevice([
        device.name,
        device.id,
        device.serviceUuids,
      ]);
    }, onError: (error) {
      //code for handling error
      log(error.toString());
    });
    setState(() {
      isScanning = true;
    });
  }

  void stopScan() {
    setState(() {
      isScanning = false;
      deviceStates = List.filled(scannedDevices.length, DeviceState.unselected);
    });
  }

  void resetBLE() {
    setState(() {
      flutterReactiveBle.deinitialize();

      scannedDevices = [];
      deviceStates = [];
      isScanning = false;
      isConnecting = false;
      isConnected = false;
      selectedIdx = -1;
      connectedDeviceId = "";
      connectedDeviceName = "";
      connectedDeviceServices = [];
      deviceBLEServices = [];
      foundService = false;
      foundCharacteristic = false;
    });
  }

  void startConnecting() {
    setState(() {
      isConnecting = true;
      for (int idx = 0; idx < deviceStates.length; idx++) {
        if (deviceStates[idx] == DeviceState.selected) {
          deviceStates[idx] = DeviceState.connecting;
          connectToDevice(scannedDevices[idx][1], scannedDevices[idx][2], idx);
          break;
        }
      }
    });
  }

  Future<void> onPressProceed() async {
    log("Proceeding to fetch from $connectedDeviceName");
    await flutterReactiveBle.discoverAllServices(connectedDeviceId);
    deviceBLEServices = await flutterReactiveBle.getDiscoveredServices(connectedDeviceId);
    for (var ser in deviceBLEServices) {
      if (ser.id.toString() == serviceUuid) {
        serviceBLE = ser;
        foundService = true;
        for (var char in ser.characteristics) {
          if (char.id.toString() == characteristicUuid) {
            foundCharacteristic = true;
            characteristicBLE = char;
            break;
          }
        }
        break;
      }
    }
    if (!foundService || !foundCharacteristic) {
      log("Characteristic not found!");
      return;
    }
    log("Found characteristic!");
    startDataScreen();
  }

  void startDataScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataScreen(
          fetchDataFromBLEFile: fetchDataFromBLEFile,
          connectedDeviceId: connectedDeviceId,
          connectedDeviceName: connectedDeviceName,
          connectedDeviceServices: connectedDeviceServices,
        ),
      ),
    );
  }

  dynamic fetchDataFromBLEFile(String filePath) async {
    log("Hello ji");
    if (foundService && foundCharacteristic) {
      final characteristic = QualifiedCharacteristic(characteristicId: characteristicBLE.id, serviceId: serviceBLE.id, deviceId: connectedDeviceId);
      flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((dataBytes) {
        // code to handle incoming data
        String data = String.fromCharCodes(dataBytes);
        log("Received: $data");
      }, onError: (dynamic error) {
        // code to handle errors
      });
      sendNotif(filePath);
    }
  }

  void sendNotif(String data) async {
    log("Sending $data");
    List<int> bytes = 'a'.codeUnits;

    final characteristic = QualifiedCharacteristic(characteristicId: characteristicBLE.id, serviceId: serviceBLE.id, deviceId: connectedDeviceId);
    await flutterReactiveBle.writeCharacteristicWithoutResponse(characteristic, value: bytes);
  }

  void connectToDevice(String id, List<Uuid> serviceUuids, int deviceIndex) {
    log("Connecting to device $id");
    flutterReactiveBle
        .connectToAdvertisingDevice(
      id: id,
      withServices: serviceUuids,
      prescanDuration: const Duration(seconds: 10),
    )
        .listen((ConnectionStateUpdate connectionState) {
      log(connectionState.connectionState.toString());
      setState(() {
        switch (connectionState.connectionState) {
          case DeviceConnectionState.disconnecting:
            deviceStates[deviceIndex] = DeviceState.error;
            break;
          case DeviceConnectionState.connecting:
            deviceStates[deviceIndex] = DeviceState.connecting;
            break;
          case DeviceConnectionState.connected:
            deviceStates[deviceIndex] = DeviceState.connected;
            break;
          default:
            deviceStates[deviceIndex] = DeviceState.connecting;
        }
      });
    }, onDone: () {
      log("Device $id connected!");
      setState(() {
        deviceStates[deviceIndex] = DeviceState.connected;
        isConnected = true;
        connectedDeviceName = scannedDevices[deviceIndex][0];
        connectedDeviceId = scannedDevices[deviceIndex][1];
        connectedDeviceServices = scannedDevices[deviceIndex][2];
      });
    }, onError: (dynamic error) {
      log(error.toString());
      deviceStates[deviceIndex] = DeviceState.error;
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
    if (isScanning || isConnecting) return;
    setState(() {
      if (deviceStates[index] == DeviceState.selected) {
        deviceStates[index] = DeviceState.unselected;
        deviceSelected = false;
      } else {
        deviceSelected = true;
        for (int i = 0; i < deviceStates.length; i++) {
          deviceStates[i] = i == index ? DeviceState.selected : DeviceState.unselected;
        }
      }
    });
  }
}
