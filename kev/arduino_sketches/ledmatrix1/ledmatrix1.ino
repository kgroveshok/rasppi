/*
  Temperature web interface

 This example shows how to serve data from an analog input
 via the Arduino Yún's built-in webserver using the Bridge library.

 The circuit:
 * TMP36 temperature sensor on analog pin A1
 * SD card attached to SD card slot of the Arduino Yún

 Prepare your SD card with an empty folder in the SD root
 named "arduino" and a subfolder of that named "www".
 This will ensure that the Yún will create a link
 to the SD to the "/mnt/sd" path.

 In this sketch folder is a basic webpage and a copy of zepto.js, a
 minimized version of jQuery.  When you upload your sketch, these files
 will be placed in the /arduino/www/TemperatureWebPanel folder on your SD card.

 You can then go to http://arduino.local/sd/TemperatureWebPanel
 to see the output of this sketch.

 You can remove the SD card while the Linux and the
 sketch are running but be careful not to remove it while
 the system is writing to it.

 created  6 July 2013
 by Tom Igoe

 This example code is in the public domain.

 http://arduino.cc/en/Tutorial/TemperatureWebPanel

 */

#include <Bridge.h>
#include <FileIO.h>
#include <YunServer.h>
#include <YunClient.h>

#include <Console.h>

// Listen on default port 5555, the webserver on the Yun
// will forward there all the HTTP requests for us.
//YunServer server;
String startString;
long hits = 0;
int x, y;

char incomingBytex;
char incomingBytey;
 
int cells[8][3]= {
  { LOW, LOW, LOW },
  { LOW, LOW, HIGH },
  { LOW, HIGH, LOW },
  { LOW, HIGH, HIGH },
  { HIGH, LOW, LOW },
  { HIGH, LOW, HIGH },
  { HIGH, HIGH, LOW },
  { HIGH, HIGH, HIGH } };
  
 
byte matrix[8][7]={
{0,0,0,0,0,0,0},
{0,0,0,0,0,0,0},
{0,0,0,0,0,0,0},
{0,0,0,0,0,0,0},
{0,0,0,0,0,0,0},
{0,0,0,0,0,0,0},
{0,0,0,0,0,0,0},
{0,0,0,0,0,0,0}};


int cycle = 0;

void setup() {
  //Serial.begin(9600);

  Bridge.begin();
  Console.begin();  

  while(!Console);
  
  // Bridge startup
 // pinMode(13, OUTPUT);
 // digitalWrite(13, LOW);
//  Bridge.begin();
//  digitalWrite(13, HIGH);

//  FileSystem.begin() ;

// rows

 pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
 pinMode(8, OUTPUT);
 pinMode(9, OUTPUT);
 pinMode(10, OUTPUT);
 pinMode(11, OUTPUT);
 pinMode(12, OUTPUT);

// cols

   pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);

//  digitalWrite(5, LOW);
//  digitalWrite(6, LOW);
//  digitalWrite(7, LOW);

//  digitalWrite(2, LOW);
//  digitalWrite(3, LOW);
//  digitalWrite(4, LOW);
 

  // using A0 and A2 as vcc and gnd for the TMP36 sensor:
//  pinMode(A0, OUTPUT);
//  pinMode(A2, OUTPUT);
//  digitalWrite(A0, HIGH);
//  digitalWrite(A2, LOW);

  // Listen for incoming connection only from localhost
  // (no one from the external network could connect)
//  server.listenOnLocalhost();
//  server.begin();

  // get the time that this sketch started:
//  Process startTime;
//  startTime.runShellCommand("date");
//  while (startTime.available()) {
//    char c = startTime.read();
//    startString += c;
//  }
}

void loop() {
  if (Console.available() > 0) {
    incomingBytex = Console.read();
    incomingBytey = Console.read();
  //  Console.println(incomingByte);
    if( incomingBytex == '-' ) {
    Console.println("Clear buffer");
for(int x=0;x<8;x++)
  for(int y=0;y<7;y++)
    matrix[x][y]=0;
    
    } else { 
if( (incomingBytex-'0') >=0 && (incomingBytex-'0') <10) {  
      matrix[incomingBytex-'0'][incomingBytey-'0']=
      !matrix[incomingBytex-'0'][incomingBytey-'0'];
    Console.println("New pixel");
    Console.print(incomingBytex);
    Console.print(",");
    Console.print(incomingBytey);
      Console.println("Current pattern");
  Console.println("    Y0123456");
    for( int x=0; x<8;x++) {
      Console.print("X ");
      Console.print(x);
      Console.print(": ");
    for( int y=0; y<7;y++) 
      Console.print(matrix[x][y] ? 'X':'-'); 
    Console.println("");
    }
    }
    }
  }
  
  // Get clients coming from server
  //YunClient client = server.accept();

//  File matrixlog = FileSystem.open("/tmp/ledmatrix", FILE_WRITE) ;

//  matrixlog.print("A new line");
//  matrixlog.close();
  
  // There is a new client?
//  if (client) {
//    // read the command
//    String command = client.readString();
//    command.trim();        //kill whitespace
//    Serial.println(command);
//    // is "temperature" command?
//    if (command == "temperature") {
//
//      // get the time from the server:
//      Process time;
//      time.runShellCommand("date");
//      String timeString = "";
//      while (time.available()) {
//        char c = time.read();
//        timeString += c;
//      }
//      Serial.println(timeString);
//      int sensorValue = 0;
//      //analogRead(A1);
//      // convert the reading to millivolts:
//      float voltage = sensorValue *  (5000 / 1024);
//      // convert the millivolts to temperature celsius:
//      float temperature = (voltage - 500) / 10;
//      // print the temperature:
//      client.print("Current time on the Yún: ");
//      client.println(timeString);
//      client.print("<br>Current temperature: ");
//      client.print(temperature);
//      client.print(" degrees C");
//      client.print("<br>This sketch has been running since ");
//      client.print(startString);
//      client.print("<br>Hits so far: ");
//      client.print(hits);
//    }
//
//    // Close connection and free resources.
//    client.stop();
//    hits++;
//  }
//
//  delay(50); // Poll every 50ms

//  digitalWrite(5, LOW);
//  digitalWrite(6, LOW);
//  digitalWrite(7, LOW);

//  delay(1000);
//
//  digitalWrite(5, HIGH);
//  digitalWrite(6, LOW);
//  digitalWrite(7, LOW);
//
//  digitalWrite(2, HIGH);
//  digitalWrite(3, LOW);
//  digitalWrite(4, LOW);
//
//
////  delay(1000);
////  digitalWrite(5, LOW);
////  digitalWrite(6, LOW);
// // digitalWrite(7, LOW);
//
//  delay(1000);
//
//  digitalWrite(5, LOW);
//  digitalWrite(6, HIGH);
//  digitalWrite(7, LOW);
//
//  delay(1000);
//
//  digitalWrite(5, HIGH);
//  digitalWrite(6, HIGH);
//  digitalWrite(7, LOW);
//
//
////  delay(1000);
////  digitalWrite(5, LOW);
////  digitalWrite(6, LOW);
////  digitalWrite(7, LOW);
//
//
//  delay(1000);
//
//  digitalWrite(5, LOW);
//  digitalWrite(6, LOW);
//  digitalWrite(7, HIGH);
//
//  digitalWrite(2, LOW);
//  digitalWrite(3, HIGH);
//  digitalWrite(4, LOW);
//
//  delay(1000);
//
//  digitalWrite(5, HIGH);
//  digitalWrite(6, LOW);
//  digitalWrite(7, HIGH);
//
//  delay(1000);
//
//  digitalWrite(5, LOW);
//  digitalWrite(6, HIGH);
//  digitalWrite(7, HIGH);
//
//  delay(1000);
//
//  digitalWrite(5, HIGH);
//  digitalWrite(6, HIGH);
//  digitalWrite(7, HIGH);
//
//  digitalWrite(2, LOW);
//  digitalWrite(3, LOW);
//  digitalWrite(4, HIGH);
//
//
//  delay(1000);
//  digitalWrite(5, LOW);
//  digitalWrite(6, LOW);
//  digitalWrite(7, LOW);
//
//
//
//
//
//  delay(1000);

//for( x= 0 ; x < 8 ; x++ ) {
//  for( y = 0 ; y < 8 ; y++ ) {

//  x= random(0, 7);
//  y= random(0, 7);
  
    for( int y=0; y<7;y++) {
digitalWrite(2, cells[y][0]);
  digitalWrite(3, cells[y][1]);
  digitalWrite(4, cells[y][2]);


    for( int x=0; x<8;x++) 

  digitalWrite(5+x, matrix[x][y]);
    }
    
//  digitalWrite(5, cells[x][0]);
//  digitalWrite(6, cells[x][1]);
//  digitalWrite(7, cells[x][2]);

//  digitalWrite(2, cells[y][0]);
//  digitalWrite(3, cells[y][1]);
//  digitalWrite(4, cells[y][2]);


//  delay(50);
    
//  }
//}


}



