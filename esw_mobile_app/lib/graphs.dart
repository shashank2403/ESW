import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key, required this.displayData, required this.timeData, required this.dataTitle, required this.dataUnit});

  final List<double> displayData;
  final List<double> timeData;
  final String dataTitle;
  final String dataUnit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(37, 35, 95, 1),
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 24.0,
          top: 30.0,
          bottom: 20.0,
        ),
        child: LineChart(
          chartData(displayData),
          duration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }

  LineChartData chartData(List<double> displayData) => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData(displayData),
        borderData: borderData,
        lineBarsData: lineBarsData(displayData),
        minX: 0,
        maxX: 24,
        maxY: displayData.reduce(max).ceilToDouble() + 1,
        minY: displayData.reduce(min).floor() - 1,
        backgroundColor: Colors.transparent,
      );

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlGridData get gridData => const FlGridData(show: true);

  List<LineChartBarData> lineBarsData(List<double> data) => [
        LineChartBarData(
          isCurved: false,
          color: Colors.white,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: data.asMap().entries.map((entry) {
            return FlSpot(timeData[entry.key] / 10000, entry.value);
          }).toList(),
        ),
      ];

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color.fromRGBO(185, 192, 255, 0.435), width: 4),
          left: BorderSide(color: Color.fromRGBO(185, 192, 255, 0.435), width: 4),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  FlTitlesData titlesData(List<double> data) => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameWidget: const Text(
            "Time (Hour of day)",
            style: TextStyle(color: Colors.white60),
          ),
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          axisNameWidget: Text(
            dataTitle,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          sideTitles: leftTitles(),
        ),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.white,
    );

    return Text('${value.toInt()}$dataUnit', style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 55,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.white,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text((value).toInt().toString(), style: style),
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 39,
        interval: 5,
        getTitlesWidget: bottomTitleWidgets,
      );
}
