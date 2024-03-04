import "dart:developer";

import "package:flutter/material.dart";

class ScanDeviceList extends StatefulWidget {
  const ScanDeviceList({super.key, required this.scannedDevices, required this.selectedDevices, required this.deviceOnPressed});

  final List<List<dynamic>> scannedDevices;
  final Function(int) deviceOnPressed;
  final Set<int> selectedDevices;
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
                    log("Pressed ${widget.scannedDevices[index][1]}");
                    widget.deviceOnPressed(index);
                    setState(() {});
                    log(widget.selectedDevices.toString());
                  },
                  child: DeviceCard(
                    deviceName: widget.scannedDevices[index][0],
                    selectionState: widget.selectedDevices.contains(index),
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
  final bool selectionState;
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
          color: selectionState ? Colors.lightGreen : Colors.white,
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
}
