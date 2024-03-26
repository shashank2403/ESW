import "dart:developer";

import "package:flutter/material.dart";
import "package:flutter_blue_plus/flutter_blue_plus.dart";

class ScanDeviceList extends StatefulWidget {
  const ScanDeviceList({
    super.key,
    required this.scannedDevices,
    required this.deviceOnPressed,
    required this.deviceStates,
  });

  final List<ScanResult> scannedDevices;
  final List<DeviceState> deviceStates;
  final Function(int) deviceOnPressed;
  @override
  State<ScanDeviceList> createState() => _ScanDeviceListState();
}

class _ScanDeviceListState extends State<ScanDeviceList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.scannedDevices.length,
        itemBuilder: (context, index) {
          return Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.deviceOnPressed(index);
                    });
                    log("Pressed ${widget.scannedDevices[index].device.remoteId}");
                  },
                  child: DeviceCard(
                    deviceName: widget.scannedDevices[index].device.advName,
                    selectionState: widget.deviceStates[index],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.deviceName, required this.selectionState});

  final String deviceName;
  final DeviceState selectionState;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 9.0,
        vertical: 9.0,
      ),
      child: Container(
        height: 100.0,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(
              20.0,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8.0,
            ),
          ],
          color: getStateColor(selectionState),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
              const SizedBox(
                height: 7.0,
              ),
              const Icon(Icons.apple),
            ],
          ),
        ),
      ),
    );
  }

  Color getStateColor(DeviceState state) {
    switch (state) {
      case DeviceState.unselected:
        return Colors.white;
      case DeviceState.selected:
        return Colors.lightBlue;
      case DeviceState.error:
        return Colors.red;
      case DeviceState.connecting:
        return Colors.amber;
      case DeviceState.connected:
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}

enum DeviceState {
  unselected,
  selected,
  connecting,
  connected,
  error,
}
