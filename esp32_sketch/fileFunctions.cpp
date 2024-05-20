#include "fileFunctions.h"

void listDir(fs::FS &fs, const char *dirname, uint8_t levels)
{
    Serial.printf("Listing directory: %s\n", dirname);

    File root = fs.open(dirname);
    if (!root)
    {
        Serial.println("Failed to open directory");
        return;
    }
    if (!root.isDirectory())
    {
        Serial.println("Not a directory");
        return;
    }

    File file = root.openNextFile();
    while (file)
    {
        if (file.isDirectory())
        {
            Serial.print("  DIR : ");
            Serial.println(file.name());
            if (levels)
            {
                listDir(fs, file.name(), levels - 1);
            }
        }
        else
        {
            Serial.print("  FILE: ");
            Serial.print(file.name());
            Serial.print("  SIZE: ");
            Serial.println(file.size());
        }
        file = root.openNextFile();
    }
}

void createDir(fs::FS &fs, const char *path)
{
    Serial.printf("Creating Dir: %s\n", path);
    if (fs.mkdir(path))
    {
        Serial.println("Dir created");
    }
    else
    {
        Serial.println("mkdir failed");
    }
}

void removeDir(fs::FS &fs, const char *path)
{
    Serial.printf("Removing Dir: %s\n", path);
    if (fs.rmdir(path))
    {
        Serial.println("Dir removed");
    }
    else
    {
        Serial.println("rmdir failed");
    }
}

void appendFile(fs::FS &fs, const char *path, const String& message)
{

  // Check if the file exists
  if (!fs.exists(path)) {
    Serial.printf("File %s doesn't exist, creating it...\n", path);
    File file = fs.open(path, FILE_WRITE);
    if (!file) {
      Serial.println("Failed to create file");
      return;
    }
    file.close();
  }
  File file = fs.open(path, FILE_APPEND);


  if (!file)
  {
    Serial.println("Failed to open file for appending");
    return;
  }
  if (file.print(message))
  {

  }
  else
  {
    Serial.println("Append failed");
  }
  file.close();
}

String readFile(fs::FS &fs, const char *path) {
  String fileData = "";
  Serial.printf("Reading file: %s\n", path);
  File file = fs.open(path);
  if (!file) {
    Serial.println("Failed to open file for reading");
    return "NO_DATA_FOUND";
  }

  Serial.println("Read from file:");
  while (file.available()) {
    String line = file.readStringUntil('\n');
    fileData += line;
    fileData += "\n"; // Add new line character
  }
  file.close();
  return fileData;
}

void getDataEntry(const float& temperature, const float& humidity, const DateTime& now, String& entry)
{
  entry = "";
  entry += String(now.year());
  entry += ',';
  entry += String(now.month());
  entry += ',';
  entry += String(now.day());
  entry += ',';
  entry += String(now.hour());
  entry += ',';
  entry += String(now.minute());
  entry += ',';
  entry += String(now.second());
  entry += ',';
  entry += String(temperature);
  entry += ',';
  entry += String(humidity);
  entry += '\n';
}

char* getDatedFileName(const String& date) 
{
  static char path[32]; // Static buffer to store the file path
  sprintf(path, "/DATAFILE_%s.csv", date.c_str());
  return path;
}

String getDateString(const DateTime& now)
{
  String date = "";
  date += String(now.year());
  date += "_";
  date += String(now.month());
  date += "_";
  date += String(now.day());
  
  return date;
}