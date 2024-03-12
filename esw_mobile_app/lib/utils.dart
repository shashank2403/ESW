import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
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
