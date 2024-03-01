import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:esw_mobile_app/bluetooth_handler.dart';

class SearchIcon extends StatelessWidget {
  const SearchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log("Starting scan for bluetooth devices!");
        startScan();
      },
      child: Container(
        width: 200.0,
        height: 200.0,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue, boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20.0,
          )
        ]),
        child: const Center(
          child: Icon(
            Icons.search,
            color: Colors.white,
            size: 50.0,
          ),
        ),
      ),
    );
  }
}

class SensorCard extends StatefulWidget {
  const SensorCard({super.key, required this.data, this.selected = false});

  final String data;
  final bool selected;

  @override
  State<SensorCard> createState() => _SensorCardState();
}

class _SensorCardState extends State<SensorCard> {
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
          color: widget.selected ? Colors.lightGreen : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data,
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

class MyListView extends StatefulWidget {
  const MyListView({super.key});

  @override
  State<MyListView> createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  final List<String> sensorData = List.generate(6, (index) {
    return "Sensor $index";
  });

  final List<bool> selected = List.filled(6, false);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 3, // Adjust the number of items as needed
          itemBuilder: (BuildContext context, int index) {
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      selected[2 * index] = !selected[2 * index];
                      setState(() {});
                    },
                    child: SensorCard(
                      data: sensorData[2 * index],
                      selected: selected[2 * index],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      selected[2 * index + 1] = !selected[2 * index + 1];
                      setState(() {});
                    },
                    child: SensorCard(data: sensorData[2 * index + 1], selected: selected[2 * index + 1]),
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
