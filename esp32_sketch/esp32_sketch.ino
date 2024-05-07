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

static BLEUUID serviceUUID(SERVICE_UUID);
static BLEUUID charUUID(CHARACTERISTIC_UUID);

static BLECharacteristic* pCharacteristic = NULL;

BLEServer* pServer = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;


void setup()
{
  init();
}

int a = 0;
void loop()
{

  Serial.println(deviceConnected);
  Serial.println(oldDeviceConnected);
  Serial.println();

  pCharacteristic->setValue("Hello World says Neil");
  pCharacteristic->notify();
  pCharacteristic->notify(false);

 
  // pCharacteristic->setValue("Hello world says voldemort");
  // pCharacteristic->notify(true);
  // pCharacteristic->notify(false);

  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
      delay(500); // give the bluetooth stack the chance to get things ready
      pServer->startAdvertising(); // restart advertising
      Serial.println("disconnected start advertising");
      oldDeviceConnected = deviceConnected;
  }

  if (deviceConnected && !oldDeviceConnected) {
      // do stuff here on connecting
      oldDeviceConnected = deviceConnected;
      Serial.println("start connecting");
      pCharacteristic->setValue("AVADA KEDAVRA");
      pCharacteristic->notify();
      delay(10);
      pCharacteristic->notify(false);
  }

 
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
    Serial.println("CONNECT CALLED");
    deviceConnected = true;
    digitalWrite(LED, HIGH);
  

  }

  void onDisconnect(BLEServer* pServer)
  {
    Serial.println("DISCONNECTED CALLED");
    deviceConnected = false;
    digitalWrite(LED, LOW);
  }
};

class CharacteristicCallbacks: public BLECharacteristicCallbacks {
  void OnWrite(BLECharacteristic *pCharacteristic)
  {
    std::string value = pCharacteristic->getValue();
    Serial.println("WRITE CALLED");
    for (int i = 0;i<value.length();i++)
      Serial.print(value[i]);
    Serial.println();
    
  }

  void OnRead(BLECharacteristic *pCharacteristic)
  {
    Serial.println("READ CALLED");
  }
};

void init()
{
  // Start LED
  pinMode(LED, OUTPUT);
  // Start Serial
  Serial.begin(115200);
  while (!Serial)
    ;

  // Start SD Card mount
  if (!SD.begin(5))
  {
    Serial.println("Card Mount Failed");
  }

  // Start I2C with sensor
  Wire.begin(); // Join I2C bus
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

  BLEDevice::init("ESP32_Sensor_1");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());
  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_NOTIFY | 
    BLECharacteristic::PROPERTY_INDICATE
  );

  // Add CCCD descriptor
  BLEDescriptor* pDescriptor = new BLEDescriptor(BLEUUID((uint16_t)0x2902));
  pDescriptor->setValue("Notify/Indicate");
  pCharacteristic->addDescriptor(pDescriptor);

  // pCharacteristic->setCallbacks(new CharacteristicCallbacks());
  pService->start();
 
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("Characteristic defined! Now you can read it in your phone!");
}
