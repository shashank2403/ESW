import 'dart:developer';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key, required this.startScan, required this.stopScan, required this.isScanning});

  final Function() startScan;
  final Function() stopScan;
  final bool isScanning;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isScanning) {
          startScan();
        } else {
          stopScan();
        }
      },
      child: Container(
        width: 200.0,
        height: 200.0,
        decoration: BoxDecoration(shape: BoxShape.circle, color: isScanning ? Colors.red : Colors.blue, boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20.0,
          )
        ]),
        child: Center(
          child: Icon(
            isScanning ? Icons.stop : Icons.search,
            color: Colors.white,
            size: 80.0,
          ),
        ),
      ),
    );
  }
}
