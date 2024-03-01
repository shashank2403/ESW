#include "FS.h"
#include "SD.h"
#include "SPI.h"
#include "fileFunctions.h"
#include <Wire.h>
#include <AHT20.h>
#include <RTClib.h>

#define LED 2

AHT20 aht20;
RTC_DS3231 rtc;

String entry;
const char* filePath = "/sensor_data.csv";

void setup()
{
  init();
}

void loop()
{
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
}
