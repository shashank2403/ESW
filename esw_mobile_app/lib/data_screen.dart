import "dart:developer";

import "package:flutter/material.dart";
import "package:flutter_reactive_ble/flutter_reactive_ble.dart";
import "package:intl/intl.dart";

class DataScreen extends StatefulWidget {
  const DataScreen({super.key, required this.fetchDataFromBLEFile, required this.connectedDeviceId, required this.connectedDeviceName, required this.connectedDeviceServices});

  final Function(String) fetchDataFromBLEFile;
  final String connectedDeviceName, connectedDeviceId;

  final List<Uuid> connectedDeviceServices;
  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  //TODO: final, pass from home

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Displaying device data",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    const Text(
                      "Device name: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.connectedDeviceName,
                    )
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Device ID: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.connectedDeviceId,
                    )
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        20.0,
                      ),
                      color: Colors.amber,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            _getFormattedDate(selectedDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.edit,
                            size: 23,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "Select date",
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () => selectDate(context),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.circular(
                          50.0,
                        ),
                        color: Colors.lightBlue,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 15.0,
                        ),
                        child: Center(
                          child: Text(
                            "Fetch data",
                            style: TextStyle(
                              // color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      log("Calling");
                      widget.fetchDataFromBLEFile("Hello");
                      log("Called");
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, lastDate: DateTime.now(), firstDate: DateTime(2015, 8));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _getFormattedDate(DateTime obj) {
    return DateFormat(DateFormat.YEAR_MONTH_DAY).format(obj);
  }

  String _getDatedFileName(DateTime obj) {
    return "";
  }
}
