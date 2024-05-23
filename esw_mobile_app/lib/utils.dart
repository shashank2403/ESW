import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:esw_mobile_app/constants.dart";

Future<void> requestPermissions() async {}

List<Map<String, String>> getDataFromRaw(String rawData) {
  List<Map<String, String>> result = [];
  final List<String> rows = rawData.split("\n");
  for (String row in rows) {
    var temp = row.split(",");
    if (temp.length != dataTemplate.length) continue;
    Map<String, String> curr = {};
    for (int i = 0; i < dataTemplate.length; i++) {
      curr[dataTemplate[i]] = temp[i] + (dataUnits[dataTemplate[i]] ?? "");
    }
    result.add(curr);
  }
  return result;
}

RichText getLatestDisplay(List<Map<String, String>> data) {
  List<TextSpan> textSpans = [];

  data.last.forEach((heading, value) {
    textSpans.add(
      TextSpan(
        text: '$heading: ',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    textSpans.add(
      TextSpan(
        text: '$value\n',
        style: const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  });

  return RichText(
    text: TextSpan(
      style: const TextStyle(
        fontSize: 13.0,
        color: Colors.black,
        height: 2,
      ),
      children: textSpans,
    ),
  );
}

Map<String, List<double>> getSeries(List<Map<String, String>> data) {
  Map<String, List<double>> result = {};
  for (var feature in dataPlots) {
    List<double> series = [];
    for (int i = 0; i < data.length; i++) {
      try {
        series.add(double.parse(data[i][feature]!.substring(0, data[i][feature]!.length - (dataUnits[feature] ?? "").length)));
      } on FormatException {
        continue;
      }
    }
    result[feature] = series;
  }

  List<double> time = [];
  for (int i = 0; i < data.length; i++) {
    try {
      time.add(double.parse(data[i]["Hour"]!) * 10000 + double.parse(data[i]["Minute"]!) * 100 * (100 / 60) + double.parse(data[i]["Second"]!) * (100 / 60));
    } on FormatException {
      continue;
    }
  }
  result["Time"] = time;
  return result;
}

String getDateString(DateTime dateTime) {
  return "${dateTime.year}_${dateTime.month}_${dateTime.day}";
}

String getFormattedDate(DateTime obj) {
  return DateFormat(DateFormat.YEAR_MONTH_DAY).format(obj);
}

Map<String, String> getFilesFromRaw(String rawData) {
  Map<String, String> result = {};

  int pos = 0;
  while (pos < rawData.length) {
    int fnstart = rawData.indexOf("Filename: ", pos);
    if (fnstart == -1) break;
    fnstart += 10;
    int fnend = rawData.indexOf('\n', fnstart);
    if (fnend == -1) {
      break; // Malformed input
    }

    // Extract the filename
    String filename = rawData.substring(fnstart, fnend);
    int dataStart = fnend + 1;

    // Find the start of the next filename
    int nextFileNameStart = rawData.indexOf("Filename: ", dataStart);
    if (nextFileNameStart == -1) {
      nextFileNameStart = rawData.length; // No more filenames, read until the end
    }

    // Extract the data
    String data = rawData.substring(dataStart, nextFileNameStart).trim();

    // Insert the filename and data into the map
    result[filename] = data;

    // Update the position
    pos = nextFileNameStart;
  }

  return result;
}
