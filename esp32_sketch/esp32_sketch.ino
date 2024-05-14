#include "FS.h"
#include "SD.h"
#include "SPI.h"
#include "fileFunctions.h"
#include <Wire.h>
#include <AHT20.h>
#include <RTClib.h>
#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

#define LED 2
AHT20 aht20;
RTC_DS3231 rtc;
String entry;
const char* filePath = "/sensor_data.csv";

unsigned long previousStamp = 0;
const unsigned long interval = 30000;
unsigned long currentStamp = 0;

WebServer server(80);

void setup() {
  // Start LED
  pinMode(LED, OUTPUT);

  // Start Serial
  Serial.begin(115200);
  while (!Serial);

  // Start SD Card mount
  if (!SD.begin(5)) {
    Serial.println("Card Mount Failed");
  }

  // Start I2C with sensor
  Wire.begin();
  // Join I2C bus
  if (!aht20.begin()) {
    Serial.println("AHT20 not detected. Please check wiring. Freezing.");
  }
  Serial.println("AHT20 acknowledged.");

  // Start RTC
  if (!rtc.begin()) {
    Serial.println("RTC module is NOT found");
    while (1);
  }
  rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));

  // Start WiFi in AP mode
  WiFi.mode(WIFI_AP);
  WiFi.softAP("ESP32_AP", "12345678");
  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP);

  // Start web server
  server.on("/", handleRoot);
  server.begin();
  Serial.println("Server started");
}


void loop() {
  server.handleClient();

  currentStamp = millis();
  if (currentStamp - previousStamp >= interval)
  {
    previousStamp = currentStamp;

    if (aht20.available()) {
      DateTime now = rtc.now();
      float temperature = aht20.getTemperature();
      float humidity = aht20.getHumidity();
      getDataEntry(temperature, humidity, now, entry);
      appendFile(SD, getDatedFileName(getDateString(now)), entry);
      Serial.println(entry);
      listDir(SD, "/", 2);
    }
  }
}

void handleRoot() {
  Serial.println("Request");
  if (server.method() == HTTP_POST)
  {
    String fileName = server.arg("plain");
    StaticJsonDocument<200> jsonDoc;
    
    jsonDoc["message"] = readFile(SD, getDatedFileName(fileName));
    String jsonString;
    serializeJson(jsonDoc, jsonString);
    server.send(200, "application/json", jsonString);
  }
  else
  {
    server.send(200, "text/plain", "Invalid request");
  }
}


