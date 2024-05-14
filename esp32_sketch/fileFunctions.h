#ifndef FILE_FUNCTIONS_H
#define FILE_FUNCTIONS_H

#include "FS.h"
#include "BluetoothSerial.h"
#include <RTClib.h>


void listDir(fs::FS &fs, const char *dirname, uint8_t levels);
void createDir(fs::FS &fs, const char *path);
void removeDir(fs::FS &fs, const char *path);
String readFile(fs::FS &fs, const char *path);
void appendFile(fs::FS &fs, const char *path, const String& message);
void writeFile(fs::FS &fs, const char *path, const String& message);
void getDataEntry(const float& temperature, const float& humidity, const DateTime& now, String& entry);
const char* getDatedFileName(const String& date);
String getDateString(const DateTime& now);
#endif
