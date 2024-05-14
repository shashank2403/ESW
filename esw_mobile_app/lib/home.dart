import "dart:developer";
import "dart:io";
import "package:esw_mobile_app/data_screen.dart";
import "package:esw_mobile_app/themes.dart";
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController ipController = TextEditingController(text: "192.168.4.1");

  bool isConnected = false;
  bool isChecking = false;
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
                onTap: () async {
                  checkConnectivity(ipController.text);
                },
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
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isChecking
                            ? Colors.white
                            : isConnected
                                ? Colors.green
                                : Colors.red),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        isChecking
                            ? Icons.workspaces_outline
                            : (isConnected)
                                ? Icons.done
                                : Icons.close,
                        weight: 40,
                        color: isChecking ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(isChecking ? "Checking" : (isConnected ? "Connected" : "Not connected")),
                ],
              ),
              const SizedBox(height: 20),
              if (isConnected)
                InkWell(
                  onTap: () async {
                    await checkConnectivity(ipController.text);
                    if (isConnected) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DataScreen(ipAddress: ipController.text)),
                      );
                    }
                  },
                  child: Container(
                    width: 300,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Start fetching data",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
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

  Future<void> checkConnectivity(String ipAddress) async {
    try {
      setState(() {
        isChecking = true;
      });
      log("Checking $ipAddress");
      final response = await http.get(Uri.http(ipAddress, "")).timeout(const Duration(seconds: 10));

      if (response.statusCode == HttpStatus.ok) {
        log('Connected to $ipAddress');
        setState(() {
          isChecking = false;
          isConnected = true;
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() {
        isChecking = false;
        isConnected = false;
      });
    }
  }
}
