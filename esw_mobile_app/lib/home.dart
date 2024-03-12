import "dart:developer";
import "package:esw_mobile_app/constants.dart";
import "package:esw_mobile_app/data_screen.dart";
import 'package:esw_mobile_app/scan_device_list.dart';
import "package:esw_mobile_app/utils.dart";
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

  late Service serviceBLE;
  late Uuid currServiceUuid = Uuid([]);
  late Uuid currCharUuid = Uuid([]);

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
              onPressConnect: connectToDevice,
              onPressProceed: startDataScreen,
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
    requestPermissions();
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

      foundService = false;
      foundCharacteristic = false;
    });
  }

  void connectToDevice() {
    setState(() {
      isConnecting = true;
      deviceStates[selectedIdx] = DeviceState.connecting;
    });

    String id = scannedDevices[selectedIdx][1];
    List<Uuid> serviceUuids = scannedDevices[selectedIdx][2];

    log("Connecting to device $id");
    for (Uuid uuid in serviceUuids) {
      if (uuid.toString() == serviceUuid) {
        currServiceUuid = uuid;
        break;
      }
    }

    flutterReactiveBle
        .connectToAdvertisingDevice(
      id: id,
      withServices: [currServiceUuid],
      prescanDuration: const Duration(seconds: 10),
    )
        .listen((ConnectionStateUpdate connectionState) {
      setState(() {
        switch (connectionState.connectionState) {
          case DeviceConnectionState.disconnecting:
            deviceStates[selectedIdx] = DeviceState.error;
            break;
          case DeviceConnectionState.connecting:
            deviceStates[selectedIdx] = DeviceState.connecting;
            break;
          case DeviceConnectionState.connected:
            deviceStates[selectedIdx] = DeviceState.connected;
            break;
          default:
            deviceStates[selectedIdx] = DeviceState.connecting;
        }
      });
    }, onDone: () {
      log("Device $id connected!");

      getServicesAndCharacteristics(selectedIdx);
    }, onError: (dynamic error) {
      log(error.toString());
      deviceStates[selectedIdx] = DeviceState.error;
    });
  }

  Future<void> getServicesAndCharacteristics(int selectedIdx) async {
    log("Getting ser and char from $connectedDeviceName");

    setState(() {
      connectedDeviceName = scannedDevices[selectedIdx][0];
      connectedDeviceId = scannedDevices[selectedIdx][1];
    });
    await flutterReactiveBle.discoverAllServices(connectedDeviceId);
    List<Service> deviceServices = await flutterReactiveBle.getDiscoveredServices(connectedDeviceId);
    foundCharacteristic = true;
    foundService = true;
    if (!foundService || !foundCharacteristic) {
      log("Characteristic not found!");
      return;
    }
    log("Found characteristic!");
    setState(() {
      deviceStates[selectedIdx] = DeviceState.connected;
      isConnected = true;
    });
    // startDataScreen();
  }

  // dynamic fetchDataFromBLEFile(String filePath) async {
  //   if (foundService && foundCharacteristic) {
  //     final characteristic = QualifiedCharacteristic(characteristicId: characteristicUuid as Uuid, serviceId: serviceUuid as Uuid, deviceId: connectedDeviceId);
  //     flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((dataBytes) {
  //       // code to handle incoming data
  //       String data = String.fromCharCodes(dataBytes);
  //       log("Received: $data");
  //     }, onError: (dynamic error) {
  //       // code to handle errors
  //     });
  //     sendNotif(filePath);
  //   }
  // }

  void startDataScreen() async {
    final QualifiedCharacteristic chars = QualifiedCharacteristic(characteristicId: currCharUuid, serviceId: currServiceUuid, deviceId: connectedDeviceId);
    print("qualified ${chars.characteristicId.toString()}");
    var codes = await flutterReactiveBle.readCharacteristic(chars);
    print(String.fromCharCodes(codes));

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DataScreen(
    //       fetchDataFromBLEFile: fetchDataFromBLEFile,
    //       connectedDeviceId: connectedDeviceId,
    //       connectedDeviceName: connectedDeviceName,
    //       connectedDeviceServices: connectedDeviceServices,
    //     ),
    //   ),
    // );
  }

  void deviceOnPressed(int index) {
    if (isConnecting || isConnected) return;
    if (isScanning) {
      stopScan();
    }
    setState(() {
      if (deviceStates[index] == DeviceState.selected) {
        deviceStates[index] = DeviceState.unselected;
        deviceSelected = false;
        selectedIdx = -1;
      } else {
        deviceSelected = true;
        selectedIdx = index;
        for (int i = 0; i < deviceStates.length; i++) {
          deviceStates[i] = i == index ? DeviceState.selected : DeviceState.unselected;
        }
      }
    });
  }
}
