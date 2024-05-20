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
#define BUTTON_PIN 15
AHT20 aht20;
RTC_DS3231 rtc;
String entry;

unsigned long previousStamp = 0;
const unsigned long interval = 30000;
unsigned long currentStamp = 0;

bool wifiIsEnabled = false;
bool wifiWasEnabled = false;
const unsigned long wifiInterval = 60000;
unsigned long wifiStartMillis = 0;


WebServer server(80);

void IRAM_ATTR buttonISR() {
  wifiIsEnabled = true;
}

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
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  attachInterrupt(BUTTON_PIN, buttonISR, FALLING);
}


void loop() {

  if (wifiIsEnabled) {

    if (!wifiWasEnabled)
    {
      
      Serial.println("Button pressed");
      wifiWasEnabled = true;
      wifiStartMillis = millis();
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
    else
    {
      server.handleClient();

      if (millis() - wifiStartMillis > wifiInterval) {
        // Turn off WiFi after 30 seconds
        WiFi.softAPdisconnect(true);
        WiFi.mode(WIFI_OFF);
        wifiIsEnabled = false;
        wifiWasEnabled = false;
        Serial.println("WiFi turned off");
        delay(10);
      }
    }
  }

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
    }
  }
  delay(10);
}



void handleRoot() {
  if (server.method() == HTTP_POST)
  {
    String message = server.arg("plain");

    if (message.startsWith("FETCH_SINGLE_DATA_"))
    {
      String fileName = message.substring(18);
      StaticJsonDocument<200> jsonDoc;

      jsonDoc["message"] = readFile(SD, getDatedFileName(fileName));
      String jsonString;
      serializeJson(jsonDoc, jsonString);
      server.send(200, "application/json", jsonString);
    }
    else if (message.startsWith("FETCH_RANGE_DATA_"))
    {
      String dates = message.substring(18);

      int f1 = dates.indexOf('_');
      int f2 = dates.indexOf('_', f1+1);
      int f3 = dates.indexOf('_', f2+1);
      int f4 = dates.indexOf('_', f3+1);
      int f5 = dates.indexOf('_', f4+1);
      int y1 = dates.substring(0, f1).toInt(), m1 = dates.substring(f1+1, f2).toInt(), d1 = dates.substring(f2+1, f3).toInt(), y2 = dates.substring(f3+1, f4).toInt(), m2 = dates.substring(f4+1, f5).toInt(), d2 = dates.substring(f5+1).toInt();
      DateTime startDate = DateTime(y1, m1, d1), endDate = DateTime(y2, m2, d2);

      if (startDate > endDate)
      {
        DateTime temp = startDate;
        startDate = endDate;
        endDate = temp;
      }

      String combinedData;
      for (DateTime d = startDate; d <= endDate; d = d + TimeSpan(1,0,0,0))
      {
        
        char* fileName = getDatedFileName(getDateString(d));
        String fileData = readFile(SD, fileName);
        if (fileData == "NO_DATA_FOUND")
          continue;
        combinedData += "Filename: ";
        combinedData += ((String)fileName).substring(((String)fileName).lastIndexOf('/')+1);
        combinedData += "\n";
        combinedData += readFile(SD, fileName);
        combinedData += "\n";
      }

      StaticJsonDocument<200> jsonDoc;
      jsonDoc["message"] = combinedData;
      String jsonString;
      serializeJson(jsonDoc, jsonString);
      server.send(200, "application/json", jsonString);

    }
  }
  else
  {
    server.send(200, "text/plain", "ESP32_SENSOR_RESPONSE");
  }
  server.client().stop();
  delay(10);
}


