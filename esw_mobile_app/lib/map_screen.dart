import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      body: const Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(28.5455, 77.1915), // IIT Delhi coordinates
              zoom: 15.0,
              bearing: 10,
            ),
            zoomControlsEnabled: false,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: MapMenu(),
          ),
        ],
      ),
    );
  }
}

class MapMenu extends StatefulWidget {
  const MapMenu({super.key});

  @override
  State<MapMenu> createState() => _MapMenuState();
}

class _MapMenuState extends State<MapMenu> {
  List<bool> selected = List.filled(10, false);
  bool allSelected = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            height: 200.0,
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selected[index] = !selected[index];
                        allSelected = allSelected && selected[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: selected[index] ? Colors.lightGreen : Colors.white,
                          borderRadius: BorderRadius.circular(
                            20.0,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, blurRadius: 8.0),
                          ]),
                      width: 140.0,
                      height: 180.0,
                      child: Center(
                        child: Text(
                          "Sensor ${index + 1}",
                          style: const TextStyle(
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    allSelected = !allSelected;
                    selected.fillRange(0, 10, allSelected);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                  ),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40.0), boxShadow: const [
                    BoxShadow(color: Colors.black, blurRadius: 8.0),
                  ]),
                  child: const Text(
                    "Select all",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            GestureDetector(
              onTap: () {
                log("Export!");
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                ),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35.0), boxShadow: const [
                  BoxShadow(color: Colors.black, blurRadius: 8.0),
                ]),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.share),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
