import "dart:convert";
import "dart:developer";
import "package:esw_mobile_app/utils.dart";
import "package:html_unescape/html_unescape.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "data_page_view.dart";

class DataScreen extends StatefulWidget {
  const DataScreen({super.key, required this.ipAddress});

  final String ipAddress;

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
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
              onPressed: () {
                log("Export");
              },
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
                else if (isFetched)
                  DataPageView(
                    rawData: rawData,
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
      final response = await http.post(Uri.http(widget.ipAddress, ''), body: getDateString(selectedDate)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
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
}
