////////////////////////////
// MUX Shield
// Requires digital pins 2,3,4,5 and analog pins 0,1,2 – 48 inputs/outputs for the price of 7 pins

//Mux_Shield_DigitalOut_Example
//http://mayhewlabs.com/arduino-mux-shield

/*
This example shows how to output high or low on all 48 pins.  To use the analog pins as digital, we use
pin numbers 14-16 (instead of analog numbers 0-2). 

*/

//Give convenient names to the control pins
#define CONTROL0 5    //MUX control pin 0 (S3 is connected to Arduino pin 2)
#define CONTROL1 4
#define CONTROL2 3
#define CONTROL3 2

int mux_x=0;
int mux_y=0;

