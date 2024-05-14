import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> requestPermissions() async {}

const List<String> dataTemplate = ["Year", "Month", "Day", "Hour", "Minute", "Second", "Temperature", "Humidity"];
const List<String> dataUnits = ["", "", "", "", "", "", "°C", "%"];

const List<String> dataPlots = ["Temperature", "Humidity"];
const List<String> plotUnits = ["°C", "%"];

List<Map<String, String>> getDataFromRaw(String rawData) {
  List<Map<String, String>> result = [];
  final List<String> rows = rawData.split("\n");
  for (String row in rows) {
    var temp = row.split(",");
    if (temp.length != dataTemplate.length) continue;
    Map<String, String> curr = {};
    for (int i = 0; i < dataTemplate.length; i++) {
      curr[dataTemplate[i]] = temp[i] + dataUnits[i];
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
      series.add(double.parse(data[i][feature]!.substring(0, data[i][feature]!.length - plotUnits[dataPlots.indexOf(feature)].length)));
    }
    result[feature] = series;
  }

  List<double> time = [];
  for (int i = 0; i < data.length; i++) {
    time.add(double.parse(data[i]["Hour"]!) * 10000 + double.parse(data[i]["Minute"]!) * 100 * (100 / 60) + double.parse(data[i]["Second"]!) * (100 / 60));
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
