import 'package:flutter/material.dart';

//Screen to display CSV file data after import
class CSVDisplayScreen extends StatelessWidget {
  const CSVDisplayScreen({super.key, required this.title, required this.text});

  final String text, title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(text),
            ],
          ),
        ),
      )),
      appBar: AppBar(),
    );
  }
}
