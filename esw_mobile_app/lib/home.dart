import "dart:developer";
import "dart:io";
import "package:esw_mobile_app/constants.dart";
import 'package:esw_mobile_app/scan_device_list.dart';
import "package:esw_mobile_app/utils.dart";
import "package:flutter/material.dart";
import "package:flutter_blue_plus/flutter_blue_plus.dart";
import 'function_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ScanResult> scannedDevices = [];
  List<DeviceState> deviceStates = [];
  bool isScanning = false;
  bool isConnecting = false;
  bool isConnected = false;
  bool deviceSelected = false;
  int selectedIdx = -1;

  bool foundService = false;
  bool foundCharacteristic = false;

  BluetoothDevice connectedDevice = BluetoothDevice(remoteId: const DeviceIdentifier(""));

  late BluetoothCharacteristic characteristic;
  late BluetoothService service;
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
              onPressProceed: deviceProceed,
              isConnected: isConnected,
            ),
          ],
        ),
      ),
    );
  }

  void startScan() async {
    log("Starting scan for bluetooth devices!");
    requestPermissions();

    log("fbp started");
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          if (!r.advertisementData.advName.startsWith("ESP32_Sensor")) return;
          log('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
          recogDevice(r);
        }
      },
      onError: (e) => log(e),
    );
    FlutterBluePlus.cancelWhenScanComplete(subscription);
    setState(() {
      isScanning = true;
    });
    await FlutterBluePlus.startScan(withServices: [servUuid]);
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

  void recogDevice(ScanResult deviceInfo) {
    bool deviceExists = scannedDevices.any((element) => element.device.remoteId == deviceInfo.device.remoteId);
    if (!deviceExists) {
      setState(() {
        scannedDevices.add(deviceInfo); // Create a new list to avoid mutations
      });
    }
  }

  void stopScan() {
    setState(() {
      isScanning = false;
      deviceStates = List.filled(scannedDevices.length, DeviceState.unselected);
    });
  }

  void resetBLE() {
    setState(() {
      FlutterBluePlus.stopScan();

      scannedDevices = [];
      deviceStates = [];
      isScanning = false;
      isConnecting = false;
      isConnected = false;
      log("Disconnecting ${connectedDevice.remoteId.toString()}");
      connectedDevice.disconnect();
      connectedDevice = BluetoothDevice(remoteId: const DeviceIdentifier(""));
      foundService = false;
      foundCharacteristic = false;
      selectedIdx = -1;
    });
  }

  void connectToDevice() async {
    setState(() {
      isConnecting = true;
      deviceStates[selectedIdx] = DeviceState.connecting;
    });

    final device = scannedDevices[selectedIdx].device;
    log("Connecting to device ${device.remoteId}: ${device.advName}");

    var subscription = device.connectionState.listen(
      (BluetoothConnectionState state) {
        setState(
          () {
            switch (state) {
              case BluetoothConnectionState.connected:
                deviceStates[selectedIdx] = DeviceState.connected;
                connectedDevice = device;
                isConnected = true;
                isConnecting = false;

                break;
              case BluetoothConnectionState.disconnected:
                try {
                  connectedDevice.connect();

                  break;
                } catch (e) {
                  log(e.toString());
                }
                deviceStates[selectedIdx] = DeviceState.error;
                connectedDevice = BluetoothDevice(remoteId: const DeviceIdentifier(""));
                isConnected = false;
                isConnecting = false;
                break;
              default:
                deviceStates[selectedIdx] = DeviceState.connecting;
                isConnecting = true;
                isConnected = false;
            }
          },
        );
      },
      onError: (error) {
        log(error.toString());
        deviceStates[selectedIdx] = DeviceState.error;
        connectedDevice = BluetoothDevice(remoteId: const DeviceIdentifier(""));
      },
      cancelOnError: true,
      onDone: () {
        log("Device ${device.remoteId} connected!");
        setState(() {
          connectedDevice = device;
          isConnected = true;
          isConnecting = false;
        });

        //getcharandserv
      },
    );

    device.cancelWhenDisconnected(subscription, delayed: true, next: true);
    try {
      await device.connect();
    } catch (e) {
      log("ERROR IN CONNECTING");
      log(e.toString());
    }
    log(device.isConnected.toString());
  }

  void deviceProceed() async {
    log("Proceeding");
    log("Connected device ID: ${connectedDevice.remoteId.toString()}");
    log("FBP says: ${FlutterBluePlus.connectedDevices.toString()}");
    var device = FlutterBluePlus.connectedDevices[0];
    await device.discoverServices();
    log(device.servicesList.toString());
    var serv = device.servicesList;
    for (int i = 0; i < serv.length; i++) {
      var element = serv[i];
      if (element.serviceUuid.toString() != servUuid.toString()) continue;
      print("SERVICE");
      print(element.characteristics.toString());
      print("CHARACTERISTIC");
      var ch = element.characteristics[0];
      print(ch.characteristicUuid.toString());
      print(ch.properties.read);
      print("NOTIFY: ${ch.isNotifying.toString()}");
      await ch.setNotifyValue(true);
      print("NOW NOTIFY: ${ch.isNotifying.toString()}");
      var subscription = ch.lastValueStream.listen((event) {
        log("VALUE! ${String.fromCharCodes(event)} ${event.length}");
      });
      device.cancelWhenDisconnected(subscription);
      break;
    }
  }
}
