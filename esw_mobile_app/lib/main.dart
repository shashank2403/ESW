import 'package:esw_mobile_app/home.dart';
import 'package:flutter/material.dart';
// import 'package:sensor_app/map_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(148, 43, 114, 1),
        ),
      ),
    );
  }
}
