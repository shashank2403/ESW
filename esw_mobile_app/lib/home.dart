import "dart:developer";
import "dart:io";
import "package:esw_mobile_app/themes.dart";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final TextEditingController ssidController = TextEditingController(), pwdController = TextEditingController(), ipController = TextEditingController();

  bool isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(25.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Welcome!",
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.asset(
                      "images/logo-iitd.png",
                      width: 100.0,
                      height: 100.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
              SizedBox(
                width: 350,
                child: TextField(
                  decoration: getInputDecoration(
                    "Enter IP Address",
                  ),
                  controller: ipController,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () => checkConnectivity(),
                child: Container(
                  width: 300,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Check connectivity",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void fetchData() async {
    // // var connectivity = Connectivity();
    // var li = await connectivity.checkConnectivity();
    // log(connectivity.toString());
  }

  Future<bool> checkConnectivity(String ipAddress) async {
    try {
      final response = await http.get(ipAddress);

      if (response.statusCode == HttpStatus.ok) {
        print('Connected to $ipAddress');
        return true;
      } else {
        print('Failed to connect to $ipAddress. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }
}
