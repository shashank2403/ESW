import "package:flutter/material.dart";

class ScanDeviceList extends StatefulWidget {
  const ScanDeviceList({super.key, required this.scannedDevices});

  final List<List<dynamic>> scannedDevices;
  @override
  State<ScanDeviceList> createState() => _ScanDeviceListState();
}

class _ScanDeviceListState extends State<ScanDeviceList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
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
                  child: DeviceCard(
                    deviceName: widget.scannedDevices[index][0],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DeviceCard extends StatefulWidget {
  const DeviceCard({super.key, required this.deviceName});

  final String deviceName;
  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 9.0,
        vertical: 9.0,
      ),
      child: Container(
        height: 100.0,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(
              20.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8.0,
            ),
          ],
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.deviceName,
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
    ;
  }
}
