import "dart:convert";
import "dart:developer";
import "dart:io";
import "package:csv/csv.dart";
import "package:esw_mobile_app/utils.dart";
import "package:file_picker/file_picker.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:html_unescape/html_unescape.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:permission_handler/permission_handler.dart";
import "package:esw_mobile_app/data_page_view.dart";

class SingleDataScreen extends StatefulWidget {
  const SingleDataScreen({super.key, required this.ipAddress});

  final String ipAddress;

  @override
  State<SingleDataScreen> createState() => _SingleDataScreenState();
}

class _SingleDataScreenState extends State<SingleDataScreen> {
  DateTime selectedDate = DateTime.now();
  bool isFetching = false;
  bool isFetched = false;
  bool errorStatus = false;
  var unescape = HtmlUnescape();
  String rawData = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFetched
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () async => saveToCSVWithDirectoryPicker(rawData),
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
                            getFormattedDate(selectedDate),
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
                          "Fetch data",
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
                  DataPageView(
                    rawData: rawData,
                  )
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

  void fetchData() async {
    try {
      setState(() {
        isFetched = false;
        isFetching = true;
        errorStatus = false;
      });
      final response = await http.post(Uri.http(widget.ipAddress, ''), body: "FETCH_SINGLE_DATA_${getDateString(selectedDate)}").timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 || jsonDecode(response.body)["message"].toString() == "NO_DATA_FOUND") {
        throw Exception("Data not found");
      }

      setState(() {
        isFetched = true;
        isFetching = false;
        errorStatus = false;
        rawData = jsonDecode(response.body)["message"].toString();
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

  Future<void> saveToCSVWithDirectoryPicker(String processedString) async {
    try {
      await Permission.manageExternalStorage.request();
      final directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath != null) {
        final selectedDirectory = Directory(directoryPath);
        final fileName = await _getFileNameFromUser(context);
        if (fileName != null) {
          final file = File('${selectedDirectory.path}/$fileName.csv');
          final csv = [
            [processedString]
          ];

          await file.writeAsString(const ListToCsvConverter().convert(csv));
          log('CSV file saved: $file');
        } else {
          log('No file name provided');
        }
      } else {
        log('No directory selected');
      }
    } on PathAccessException {
      Fluttertoast.showToast(msg: "Cannot save in chosen directory!");
    }
  }

  Future<String?> _getFileNameFromUser(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter File Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'File Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
