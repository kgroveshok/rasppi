// define the pins used for sensors

#define irReader 5     // the analog input pin for the sharp distance ir reader
#define lineA  4       // Line following sensors    
#define lineB  3 
//const int ldrSensor = 3 ;  // Light Dependant Resistor

/* This is a simple code that reads an input from an analog pin on the Arduino and relays it back to the computer */

float irVal;         // stores value from Ir reader
float irVolts;
#define irRange  30       // value to detect as too close
#define irFar  100         // threshold distance to aim for when looking for somewhere to go

// Line tracking sensor checks

int lineAVal=0;      // Blue Right Line track value
int lineBVal=0;      // Yellow Left Lien track value
int lineABase=0;      // Ambient colour level
int lineBBase=0;      // Ambient colour level
#define lineADiff 150      // Ambient colour level difference to react to
#define lineBDiff 150      // Ambient colour level difference to react to
#define lineFollowPrio 90

// LDR Ambient light sensor
#define LDRpin 2
int ldrVal = 0 ;        // LDR sensor value
int ldrBase = 2000 ;    // Calib for ambient light level
int ldrLight = 50;    // extra photo sensitive during daylight
int ldrDark = 200;

// Track rotation counter sensors

#define rotateLeftPin 0
#define rotateRightPin 1
int rotateLeftVal=0;
int rotateRightVal=0;



