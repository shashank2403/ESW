# Smart Rainfall Sensor System and Flutter Application

This project aims to develop a smart sensor node capable of collecting rainfall and environmental data such as temperature, humidity, etc. through various sensors and providing remote access to the recorded data through a user-friendly mobile application.

## Features

- **Sensor Node**: A hardware device built around the ESP32 microcontroller for data acquisition, storage, and remote access. The node is equipped with environmental sensors (temperature, humidity) and an SD card module for data storage.
- **Data Collection**: Collects sensor data at configurable intervals, timestamped using an RTC module, and stores the data in CSV files on the SD card.
- **Remote Access**: The ESP32 acts as a WiFi access point and an HTTP web server when a button is pressed, allowing nearby devices to connect and retrieve data through HTTP requests.
- **Flutter Application**: A cross-platform mobile application built using Flutter, compatible with Android and iOS. The application connects to the ESP32's WiFi access point, communicates with the web server, and retrieves sensor data in CSV format.
- **Data Visualization**: The application parses the retrieved CSV data and provides graph visualizations for analysis.
- **Data Export**: Users can export the retrieved data to the local phone storage as CSV files.

## Getting Started

1. Clone the repository: `git clone https://github.com/shashank2403/ESW.git`
2. Follow the instructions in the project documentation to set up the hardware components and connect the sensors to the ESP32.
3. Upload the Arduino code to the ESP32 using the Arduino IDE.
4. Install the required dependencies for the Flutter application and run the application on your mobile device or emulator.

## Dependencies

### Flutter Dependencies

- `Flutter SDK`
- `permission_handler`
- `intl`
- `path_provider`
- `csv`
- `file_picker`
- `fluttertoast`
- `html_unescape`
- `http`
- `fl_chart`

### Microcontroller Dependencies

- `AHT20` by dvarrel
- `Adafruit BusIO` by Adafruit
- `ArduinoJson` by Benoit Blanchon
- `RTClib` by Adafruit

## Documentation

Detailed project documentation, including the architecture overview, circuit construction, and application design, can be found in the project repository.