#include "FS.h"
#include "SD.h"
#include "SPI.h"
#include "fileFunctions.h"
#include <Wire.h>
#include <AHT20.h>
#include <RTClib.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define LED 2

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"


AHT20 aht20;
RTC_DS3231 rtc;

String entry;
const char* filePath = "/sensor_data.csv";

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
BLEService* pService = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;


void setup()
{
  init();
}

void loop()
{


  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
      delay(500); // give the bluetooth stack the chance to get things ready
      pServer->startAdvertising(); // restart advertising
      pService->start();
      Serial.println("start advertising");
      oldDeviceConnected = deviceConnected;
  }

  if (deviceConnected && !oldDeviceConnected) {
      // do stuff here on connecting
      oldDeviceConnected = deviceConnected;
  }
  delay(1000);
  digitalWrite(LED, HIGH);
  delay(1000);
  digitalWrite(LED, LOW);
  if (aht20.available()) {
    DateTime now = rtc.now();
    float temperature = aht20.getTemperature();
    float humidity = aht20.getHumidity();
    getDataEntry(temperature, humidity, now, entry);
  }
  
}


/************************************************************************/

class ServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer)
  {
    deviceConnected = true;
    BLEDevice::startAdvertising();
  }

  void onDisconnect(BLEServer* pServer)
  {
    deviceConnected = false;
  }
};

class CharacteristicCallbacks: public BLECharacteristicCallbacks {
  void OnWrite(BLECharacteristic *pCharacteristic)
  {
    std::string value = pCharacteristic->getValue();
    for (int i = 0;i<value.length();i++)
      Serial.print(value[i]);
    Serial.println();
  }
};

void init()
{
  //Start LED
  pinMode(LED, OUTPUT);
  //Start Serial
  Serial.begin(115200);
  while (!Serial)
    ;

  //Start SD Card mount
  if (!SD.begin(5))
  {
    Serial.println("Card Mount Failed");
  }

  //Start I2C with sensor
  Wire.begin(); // Join I2C bus
  if (!aht20.begin()) {
    Serial.println("AHT20 not detected. Please check wiring. Freezing.");
  }
  Serial.println("AHT20 acknowledged.");

  //Start RTC 
  if (!rtc.begin()) {
    Serial.println("RTC module is NOT found");
    while (1);
  }
  rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));

  BLEDevice::init("ESP32_Sensor_1");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks);
  pService = pServer->createService(SERVICE_UUID);
  

  pCharacteristic = pService->createCharacteristic(
                                          CHARACTERISTIC_UUID,
                                          BLECharacteristic::PROPERTY_READ |
                                          BLECharacteristic::PROPERTY_WRITE | 
                                          BLECharacteristic::PROPERTY_NOTIFY |
                                          BLECharacteristic::PROPERTY_INDICATE
                                       );

  pCharacteristic->setCallbacks(new CharacteristicCallbacks);

  pCharacteristic->setValue("Hello World says Neil");
  pService->start();
  // BLEAdvertising *pAdvertising = pServer->getAdvertising();  // this still is working for backward compatibility
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Characteristic defined! Now you can read it in your phone!");
}

void transferCSVData(String filePath)
{
  Serial.println("Transferring: filepath");
}