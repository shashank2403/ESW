import "dart:convert";
import "dart:developer";
import "dart:io";
import "package:csv/csv.dart";
import "package:esw_mobile_app/csv_display.dart";
import "package:esw_mobile_app/utils.dart";
import "package:file_picker/file_picker.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:html_unescape/html_unescape.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:permission_handler/permission_handler.dart";

class MultiDataScreen extends StatefulWidget {
  const MultiDataScreen({super.key, required this.ipAddress});

  final String ipAddress;

  @override
  State<MultiDataScreen> createState() => _MultiDataScreenState();
}

class _MultiDataScreenState extends State<MultiDataScreen> {
  DateTime startDate = DateTime.now(), endDate = DateTime.now();
  bool isFetching = false;
  bool isFetched = false;
  bool errorStatus = false;
  var unescape = HtmlUnescape();
  String rawData = "";
  Map<String, String> fileData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFetched
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async => saveToCSVWithDirectoryPicker(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.save_alt_rounded,
                  size: 30,
                ),
              ),
            )
          : null,
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
                      "Device IP Address: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.ipAddress,
                    )
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 5.0,
                            ),
                            child: Text("Start date", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                color: const Color.fromARGB(255, 255, 220, 117),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 15.0,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      getFormattedDate(startDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.edit,
                                      size: 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () => selectStartDate(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 5.0,
                            ),
                            child: Text("End date", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                color: const Color.fromARGB(255, 255, 220, 117),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 15.0,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      getFormattedDate(endDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.edit,
                                      size: 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () => selectEndDate(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: fetchData,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        50.0,
                      ),
                      color: const Color.fromARGB(255, 104, 207, 255),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15.0,
                      ),
                      child: Center(
                        child: Text(
                          "Fetch data between range",
                          style: TextStyle(
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: fetchAllData,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        50.0,
                      ),
                      color: const Color.fromARGB(255, 158, 224, 255),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 15.0,
                      ),
                      child: Center(
                        child: Text(
                          "Fetch all data",
                          style: TextStyle(
                            // color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (isFetching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 150.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.workspaces_outline),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Fetching data"),
                      ],
                    ),
                  )
                else if (errorStatus)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 150.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Data not found!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isFetched)
                  SingleChildScrollView(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fileData.keys.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CSVDisplayScreen(title: fileData.keys.toList()[index], text: fileData[fileData.keys.toList()[index]]!)),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(
                                  20.0,
                                ),
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(-3, 3),
                                      blurRadius: 3.0,
                                    )
                                  ],
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(
                                    10.0,
                                  ),
                                  border: Border.all(
                                    width: 2.5,
                                  ),
                                ),
                                child: Text(fileData.keys.toList()[index]),
                              ),
                            ),
                          );
                        }),
                  ),
                // DataPageView(
                //   rawData: rawData,
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: startDate, lastDate: DateTime.now(), firstDate: DateTime(2015, 8));

    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: endDate, lastDate: DateTime.now(), firstDate: startDate);

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void fetchData() async {
    if (endDate.isBefore(startDate)) {
      setState(() {
        DateTime temp = endDate;
        endDate = startDate;
        startDate = temp;
      });
    }
    try {
      setState(() {
        isFetched = false;
        isFetching = true;
        errorStatus = false;
      });
      final response = await http.post(Uri.http(widget.ipAddress, ''), body: "FETCH_RANGE_DATA_${getDateString(startDate)}_${getDateString(endDate)}").timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 || jsonDecode(response.body)["message"].toString() == "NO_DATA_FOUND") {
        throw Exception("Data not found");
      }

      setState(() {
        isFetched = true;
        isFetching = false;
        errorStatus = false;
        rawData = jsonDecode(response.body)["message"].toString();
        fileData = getFilesFromRaw(rawData);
      });
    } catch (e) {
      log("exception ${e.toString()}");
      setState(() {
        isFetching = false;
        errorStatus = true;
        isFetched = false;
      });
    }
  }

  void fetchAllData() async {
    log("Multi request");
    try {
      setState(() {
        isFetched = false;
        isFetching = true;
        errorStatus = false;
      });
      final response =
          await http.post(Uri.http(widget.ipAddress, ''), body: "FETCH_RANGE_DATA_${getDateString(DateTime(2024, 1, 1))}_${getDateString(DateTime.now())}").timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 || jsonDecode(response.body)["message"].toString() == "NO_DATA_FOUND") {
        throw Exception("Data not found");
      }

      setState(() {
        isFetched = true;
        isFetching = false;
        errorStatus = false;
        rawData = jsonDecode(response.body)["message"].toString();
        fileData = getFilesFromRaw(rawData);
      });
    } catch (e) {
      log("exception ${e.toString()}");
      setState(() {
        isFetching = false;
        errorStatus = true;
        isFetched = false;
      });
    }
  }

  Future<void> saveToCSVWithDirectoryPicker() async {
    try {
      await Permission.manageExternalStorage.request();
      final directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath != null) {
        final selectedDirectory = Directory(directoryPath);

        for (var entry in fileData.entries) {
          String fileName = entry.key, processedString = entry.value;
          final file = File('${selectedDirectory.path}/$fileName');
          final csv = [
            [processedString]
          ];

          await file.writeAsString(const ListToCsvConverter().convert(csv));
          log('CSV file saved: $file');
        }
        Fluttertoast.showToast(msg: "Files saved");
      } else {
        log('No directory selected');
      }
    } on PathAccessException {
      Fluttertoast.showToast(msg: "Cannot save in chosen directory!");
    }
  }
}
