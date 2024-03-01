import "dart:developer";

import "package:flutter_blue_plus/flutter_blue_plus.dart";
import "package:flutter_reactive_ble/flutter_reactive_ble.dart";

void startScan() async {
  log("Pressed");
  final flutterReactiveBle = FlutterReactiveBle();
  flutterReactiveBle.scanForDevices(withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
    //code for handling results
    log(device.name);
  }, onError: (error) {
    //code for handling error
    log(error.toString());
  });
}











// void startScan() async {
//   log("Pressed scan!");

//   if (await FlutterBluePlus.isSupported == false) {
//     log("Bluetooth not supported by this device");
//     return;
//   }
//   var subscription = FlutterBluePlus.onScanResults.listen(
//     (results) async {
//       log("adapter " + FlutterBluePlus.adapterStateNow.toString());
//       log("results changed");

//       log(results.length.toString());
//       log(results.toString());
//       var res = (await FlutterBluePlus.lastScanResults.length);

//       if (results.isNotEmpty) {
//         ScanResult r = results.last; // the most recently found device

//         log('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
//       }
//     },
//     onError: (e) => log(e),
//   );
//   print("1");
//   FlutterBluePlus.cancelWhenScanComplete(subscription);
//   print("2");
//   await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;
//   print("3");
//   await FlutterBluePlus.startScan();

//   subscription = FlutterBluePlus.onScanResults.listen(
//     (results) async {
//       log("results changed");

//       log(results.length.toString());
//       log(results.toString());
//       var res = (await FlutterBluePlus.lastScanResults.length);

//       if (results.isNotEmpty) {
//         ScanResult r = results.last; // the most recently found device

//         log('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
//       }
//     },
//     onError: (e) => log(e),
//   );
//   log(FlutterBluePlus.adapterStateNow.toString());
//   log(FlutterBluePlus.lastScanResults.toString());
//   log(FlutterBluePlus.isScanningNow.toString());
//   print("4");

//   // await FlutterBlue.startScan();
//   // flutterBlue.scanResults.listen((results) {
//   //   for (ScanResult result in results) {
//   //     if (!devices.contains(result.device)) {
//   //       setState(() {
//   //         devices.add(result.device);
//   //       });
//   //     }
//   //   }
//   // });
// }
