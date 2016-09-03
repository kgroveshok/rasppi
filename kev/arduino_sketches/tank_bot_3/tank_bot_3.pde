// arduino_tank_sketch   version 1.0   J.Luke (RobotBits.co.uk)
//
// A simple sketch to help you get started with the Arduino Tank Kit
// in robotics applications
//
// This example has been written for any mobile robotics platform that uses
// two bi-directional motors controlled by an Arduino and a Motor Shield
//
// This sketch includes a series of functions that perform the different  
// types of movement for your robot including:
//
// forward, reverse, stop, rotate clock-wise, rotate counter clock-wise, 
// turn_left and turn_right 
//
// To program the movement of your robot simply call the functions as needed
// from the main loop
//
// This example loop below moves your robot in a "square" figure or eight
//
// For support, please contact support@robotbits.co.uk
//
// V1.0 - KG 22/4/2010
// Have basic distance and some buggy line follow code
// V1.2 - KG 29/4/2010
// Added more sensors and restructure to ease monitor and servicing of sensors
// V1.3 - KG 02/05/2010
// Changed IR distance to actual distance
// V1.4 - KG 28/12/2010
// Change the beep and LED flash to indicate IR distance
// V1.5 - KG 30/12/2010
// Added Mux sheild and rearrange pins
// Removed LDR for the moment

// Todo
// debug line follow code
// done add sensor toggle switch switch 
// add wheel rev count sensors
//     add map build in memory
// add an lcd display
// add sound sensors
// add temp sensor
// done add light sensor
//     add command control via light level gesture detect
// add tilt sensor
// add bump sensors
// done add buzzer/pizo speaker
// add led matrix for face/expressions
// add gripper
// add some ai
//     as builds map, go explore bits it does not know
//     set things for it to find
//     make use of lcd/leds/buzzers etc to express it's self with a personallity
//     react to people, follow and maybe do tricks ie be a dog 
//      (plastic pal whos fun to be with)
//     play games like chase, ping pong, tag, 
// add RTC
//     get robot to go places, sleep, start or act on a date/time

#define DEBUG 


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

//const int MUX_Dig1 = 2 ;
//const int MUX_Dig2 = 3 ;
//const int MUX_Dig3 = 4 ;
//const int MUX_Dig4 = 5 ;
//const int MUX_An1 = 0 ;
//const int MUX_An2 = 1 ;
//const int MUX_An3 = 2 ;

// define the pins used by the motor shield

const int speedA = 10;          // pin 10 sets the speed of motor A (this is a PWM output)
const int speedB = 11;          // pin 11 sets the speed of motor B (this is a PWM output) 
const int dirA = 12;            // pin 12 sets the direction of motor A
const int dirB = 13;            // pin 13 sets the direction of motor B

boolean movingBot = false;

// define the pins used for sensors

const int irReader = 5;    // the analog input pin for the sharp distance ir reader
const int lineA = 4 ;      // Line following sensors    
const int lineB = 3 ;
//const int ldrSensor = 3 ;  // Light Dependant Resistor

// UI pins

const int pizoSpeaker = 9;

// dig pin 2-8 spare
// ang 3, 4, 5 spare
// dig pin 9 can be used for pwm out (ie pizo)

// Motor speed control

const int moveSpeed=180;
const int turnSpeed=230;

// define the direction of motor rotation - this allows you change the  direction without effecting the hardware
const int fwdA  =  HIGH;         // this sketch assumes that motor A is the right-hand motor of your robot (looking from the back of your robot)
const int revA  =  LOW;        // (note this should ALWAYS be opposite the fwdA)
const int fwdB  =  HIGH;         //
const int revB  =  LOW;        // (note this should ALWAYS be opposite the fwdB)

// define variables used
//int dist;
//int angle;
//int vel;

/* This is a simple code that reads an input from an analog pin on the Arduino and relays it back to the computer */

float irVal;         // stores value from Ir reader
float irVolts;
const float irRange = 25 ;      // value to detect as too close
const float irFar = 100 ;        // threshold distance to aim for when looking for somewhere to go
int InACornerCount=0;      // when in a corner count down for full 180 turn

//int irDarkness=600;

// Line tracking sensor checks

int lineAVal=0;      // Blue Right Line track value
int lineBVal=0;      // Yellow Left Lien track value
int lineABase=0;      // Ambient colour level
int lineBBase=0;      // Ambient colour level

int ldrVal = 0 ;        // LDR sensor value
int ldrBase = 2000 ;    // Calib for ambient light level
int ldrBright = 100;
int ldrDark = -100;

int ldrTransCount =0 ;    // Count for number of gestures over LDR within set period

// robot sensor tracking mode
// 0 = ir distance
// 1 = line follow

int sensorMode=0;  

// music

// TONES ==========================================
// Start by defining the relationship between
//       note, period, & frequency.
#define c      3830    // 261 Hz
#define d      3400    // 294 Hz
#define e      3038    // 329 Hz
#define f      2864    // 349 Hz
#define g      2550    // 392 Hz
#define a      2272    // 440 Hz
#define b      2028    // 493 Hz
#define C      1912    // 523 Hz
// Define a special note, 'R', to represent a rest
#define R      0


// MELODY and TIMING =======================================
// melody[] is an array of notes, accompanied by beats[],
// which sets each note's relative length (higher #, longer note)
//int melody[] = { 
//  C, b, g, C, b,        e, R, C, c, g, a, C };
//int beats[] = { 
//  16, 16, 16, 8, 8, 16, 32, 16, 16, 16, 8, 8 };
//int MAX_COUNT = sizeof(melody) / 2; // Melody length, for looping.

int tuneTooClose[] = {  
  C, 16, b, 16, g, 16, C, 8, b, 8, e, 16, R,32, C,16, c,16, g, 16, a, 8, C , 8, -1, -1};

int tuneMoveBeep[] = { d, 8, -1, -1 };
int tuneGestureBeep[] = { c, 8, C, 4, -1, -1 };


int mux_hello[][4] = {
{   1,3, 6,-1},
{  1,3,-1,-1},
{ 1,2,3,6},
{1,3,6,-1},
{1,3,6,-1}
};


// Set overall tempo
long tempo = 10000;
// Set length of pause between notes
int pause = 1000;
// Loop variable to increase Rest length
int rest_count = 100; //<-BLETCHEROUS HACK; See NOTES
// Initialize core variables
int mtone = 0;
int beat = 0;
long duration = 0;

int mux_x=0;
int mux_y=0;

void setup() {                             // sets up the pinModes for the pins we are using

  pinMode (dirA, OUTPUT);         
  pinMode (dirB, OUTPUT); 
  pinMode (speedA, OUTPUT); 
  pinMode (speedB, OUTPUT); 
  pinMode (pizoSpeaker, OUTPUT);


  //Set MUX control pins to output
  pinMode(CONTROL0, OUTPUT);
  pinMode(CONTROL1, OUTPUT);
  pinMode(CONTROL2, OUTPUT);
  pinMode(CONTROL3, OUTPUT);


  //pinMode (irReader, INPUT); 
  Serial.begin(9600);  

  // get a sample and avg of the current floor colour 

  calib_sensors();

  randomSeed(2);

      //Turn on output to digital pin 14 (MUX 0) and turn off the other 2 multiplexer data pins
  pinMode(14, OUTPUT);
  pinMode(15, INPUT);
  pinMode(16, INPUT);

}

// PLAY TONE ==============================================
// Pulse the speaker to play a tone for a particular duration
void playTune( int tune[] ) {
  // format of data structure is:
  // tune = note
  // tune+1 = duration
  int ct=0;
  long elapsed_time = 0;

  while( tune[ct] != -1 ) {
    mtone=tune[ct] ;
    duration = tune[ct+1] * tempo ;

    if (mtone > 0) { // if this isn't a Rest beat, while the tone has
      // played less long than 'duration', pulse speaker HIGH and LOW
      while (elapsed_time < duration) {
        digitalWrite(pizoSpeaker,HIGH);
        delayMicroseconds(mtone / 2);
        // DOWN
        digitalWrite(pizoSpeaker, LOW);
        delayMicroseconds(mtone / 2);
        // Keep track of how long we pulsed
        elapsed_time += (mtone);
      }
    }
    else { // Rest beat; loop times delay
      for (int j = 0; j < rest_count; j++) { // See NOTE on rest_count
        delayMicroseconds(duration);
      }
    }

    // A pause between notes...
    delayMicroseconds(pause);

  tune+=2;
  }


}

void calib_sensors(){
  int cc ;
  // get a sample and avg of the current floor colour 

  for( cc = 1 ; cc < 100 ; cc++) {
    delay(50);
    lineAVal = analogRead(lineA);    // read the value from the ir sensor
    lineBVal = analogRead(lineB);    // read the value from the ir sensor
    if( lineAVal > lineABase ) lineABase = lineAVal;
    if( lineBVal > lineBBase ) lineBBase = lineBVal;


    // sample ambient light level
//    ldrVal = analogRead(ldrSensor);
//    if( ldrVal < ldrBase ) ldrBase = ldrVal;
  }


  // once ambient light level need to signal by tone that we want a sample
  // of the bright light trigger level

    // bug to do  


}

void stop() {                              // stop: force both motor speeds to 0 (low)
  digitalWrite (speedA, LOW); 
  digitalWrite (speedB, LOW);
  movingBot = false;

}

void forward(int dist, int vel) {          // forward: both motors set to forward direction
  digitalWrite (dirA, fwdA); 
  digitalWrite (dirB, fwdB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 
  delay (dist);                // wait for a while (dist in mSeconds)
}

void reverse(int dist, int vel) {          // reverse: both motors set to reverse direction
  int aa;

  digitalWrite (dirA, revA); 
  digitalWrite (dirB, revB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 

  delay (dist);                // wait for a while (dist in mSeconds)              
}    

void rot_cw (int angle, int vel) {         // rotate clock-wise: right-hand motor reversed, left-hand motor forward
  digitalWrite (dirA, revA); 
  digitalWrite (dirB, fwdB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 
  delay (angle);               // wait for a while (angle in mSeconds)              
}

void rot_ccw (int angle, int vel) {        // rotate counter-clock-wise: right-hand motor forward, left-hand motor reversed
  digitalWrite (dirA, fwdA); 
  digitalWrite (dirB, revB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 
  delay (angle);               // wait for a while (angle in mSeconds)              
}

void rot_cwR ( int vel) {         // rotate clock-wise: right-hand motor reversed, left-hand motor forward
  digitalWrite (dirA, revA); 
  digitalWrite (dirB, fwdB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 
}

void rot_ccwR ( int vel) {        // rotate counter-clock-wise: right-hand motor forward, left-hand motor reversed
  digitalWrite (dirA, fwdA); 
  digitalWrite (dirB, revB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 

}

void turn_right (int angle, int vel) {     // turn right: right-hand motor stopped, left-hand motor forward
  digitalWrite (dirA, revA); 
  digitalWrite (dirB, fwdB);
  digitalWrite (speedA, LOW);  // right-hand motor speed set to zero
  analogWrite (speedB, vel); 
  delay (angle);               // wait for a while (angle in mSeconds)              
}

void turn_left (int angle, int vel) {      // turn left: left-hand motor stopped, right-hand motor forward
  digitalWrite (dirA, fwdA); 
  digitalWrite (dirB, revB);
  analogWrite (speedA, vel);
  digitalWrite (speedB, LOW);  // left-hand motor speed set to zero
  delay (angle);               // wait for a while (angle in mSeconds)              
}


void about_turn() {
  rot_cw (2000, turnSpeed);      // rotate clock-wise for 2000 mS (about 90 deg) at speed 100
  rot_cw (2000, turnSpeed);      // rotate clock-wise for 2000 mS (about 90 deg) at speed 100
}

void sensor_array() {
  //  do {

  //  irVal = analogRead(irReader);    // read the value from the ir sensor

  irVolts = analogRead(irReader)*0.0048828125;   // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3
  irVal= 65*pow(irVolts, -1.10);          // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk

//  ldrVal = ldrBase - analogRead( ldrSensor ) ;

  lineAVal = lineABase - analogRead(lineA);    // read the value from the ir sensor
  lineBVal = lineBBase - analogRead(lineB);    // read the value from the ir sensor

#ifdef DEBUG  
  Serial.print( "Distance: ");
  Serial.print( irVal);
  Serial.print( " Line (Right Blue): ");
  Serial.print( lineAVal);
  Serial.print( " Line (Left Yellow): ");
  Serial.print( lineBVal);
//  Serial.print( " LDR: ");
//  Serial.print( ldrVal);
  Serial.println();
#endif

  // if( ldrVal > ldrBright ) return;

  //if( sensorMode == 1 ) return ;

  // wait for an event by the sensors
  //} while( irVal < irRange ) ;

}

int aa=0;

void loop() { 



  if( !movingBot ) {
    if( sensorMode == 0 ) {

#ifdef DEBUG
      Serial.print( "Moving forward until an event");
#endif

      digitalWrite (dirA, fwdA); 
      digitalWrite (dirB, fwdB);
      analogWrite (speedA, moveSpeed);   // both motors set to same speed
      analogWrite (speedB, moveSpeed); 
    }
    else
    {
      forward(150,moveSpeed);
    }
    movingBot=true;
  }

  sensor_array() ;

  // LDR trigger

//  if( ldrVal > ldrBright ) {
//    rot_cw(500,turnSpeed);
//    forward(500,moveSpeed);
//    stop();
//  }

//  if( ldrVal < ldrDark ) {
//    stop();
//    do {
//      sensor_array();
//    } 
//    while( ldrVal < ldrDark ) ;

    //sensorMode  = sensorMode ? 0 : 1 ; 
 //   ldrTransCount++;  // Gesture made
 //   playTune( tuneGestureBeep );
//  }

  // Line or distence checks 

  if( sensorMode == 1 ) {
    if( lineBVal < -50 ) {
      // Left sensor detects darkness, therefore veered to right
      turn_left( 50, turnSpeed );
      movingBot = false;

    }
    if( lineAVal < -50 ) {
      // Right sensor detects darkness, therefore veered to left
      turn_right( 50, turnSpeed );
      movingBot = false;

    }
  }

  else 
    // ir distance tracking mode

    if( irVal <irRange ) {  // something is a bit close so back away
    stop();
    mux_hi();
#ifdef DEBUG
    Serial.print( "Run away!");
    Serial.println();
#endif

    playTune( tuneTooClose );

if( InACornerCount <= 0 )
  InACornerCount = 5;  // Count down for 180 deg turn if we cant get out easily

    // BUG: set block on map

    if( random(2) == 1 )   {    
#ifdef DEBUG
      Serial.print( "ccwR");
      Serial.println();
#endif
      rot_ccwR( turnSpeed ) ; // point somewhere else to go 
    }
    else {
#ifdef DEBUG
      Serial.print( "cwR");
      Serial.println();
#endif
      rot_cwR( turnSpeed ) ; // point somewhere else to go
    }

    // Look for somewhere far away to go

    do {
      sensor_array();

#ifdef DEBUG
      Serial.print( "Looking to go: ");
      Serial.print( irVal);
      Serial.println();
#endif
      delay(50);
    } 
    while( irVal>irFar );
    delay (250);               // wait for a while (angle in mSeconds)              
    stop();

#ifdef DEBUG
    Serial.print( "InACornerCount: ");
    Serial.print( InACornerCount);
    Serial.println();
#endif


  if( --InACornerCount <= 0) {
//  about_turn();  

#ifdef DEBUG
    Serial.print( "InACornerCount: Try escape plan!");
    Serial.println();
#endif
mux_hi();

      rot_ccwR( turnSpeed ) ; // point somewhere else to go 
      delay(3000);
  stop();
//reverse(2000,1000);
  }


  }

#ifdef DEBUG
  Serial.print( aa);
  Serial.println();
#endif


// randomly set a new direction when we feel like it
//BUG: add code to follow or avoid something? Or think that its not been somewhere before.

if( random(100) ==1 ) {

      mtone = d;
    beat = 8;
    duration = beat * tempo; // Set up timing
    playTune(tuneMoveBeep);
    mtone = c;
    beat = 8;
    duration = beat * tempo; // Set up timing
    playTune(tuneMoveBeep);
    mtone = f;
    beat = 8;
    duration = beat * tempo; // Set up timing
    playTune(tuneMoveBeep);

    // BUG: set block on map

    if( random(2) == 1 )   {    
#ifdef DEBUG
      Serial.print( "ccwR");
      Serial.println();
#endif
      rot_ccwR( turnSpeed ) ; // point somewhere else to go 
    }
    else {
#ifdef DEBUG
      Serial.print( "cwR");
      Serial.println();
#endif
      rot_cwR( turnSpeed ) ; // point somewhere else to go
    }

      delay(random(2000));

    // Look for somewhere far away to go

    do {
      sensor_array();

#ifdef DEBUG
      Serial.print( "Looking to go: ");
      Serial.print( irVal);
      Serial.println();
#endif
      delay(50);
    } 
    while( irVal>irFar );
    delay (250);               // wait for a while (angle in mSeconds)              
    stop();
}


  if( aa > irVal ) {
    mtone = d;
    beat = 8;
    duration = beat * tempo; // Set up timing
    playTune(tuneMoveBeep);
    aa=0;

    // Gesture processing

    switch( ldrTransCount ) {
    case 1 :  // One gesture stops for 10s
      stop();
      delay(10000);    
      break;
    case 2 :  // Two gesture toggles line vs distance mode
      sensorMode  = sensorMode ? 0 : 1 ; 
      break;
    }

    ldrTransCount=0;  // Reset gesture count

  }

  aa++;

#ifdef DEBUG
//  delay (1000);               // wait for a while (angle in mSeconds)              
#endif

muxloop();
} 



void muxloop()
{

  //Since all 3 multiplexers have the same control pins, the one multiplexer data line we want to 
  //talk to should be set to output and the other two multiplexer lines should be be 'bypassed' by 
  //setting the pins to input
    

if( mux_x == 0 ) {
   digitalWrite(CONTROL0, 1); //S3
    digitalWrite(CONTROL1, 1);  //S2
    digitalWrite(CONTROL2, 1);  //S1
    digitalWrite(CONTROL3, 1);     //S0
 mux_y=0;
    digitalWrite(14, LOW);
    digitalWrite(14, HIGH);
}

   digitalWrite(CONTROL0, (mux_x&15)>>3); //S3
    digitalWrite(CONTROL1, (mux_x&7)>>2);  //S2
    digitalWrite(CONTROL2, (mux_x&3)>>1);  //S1
    digitalWrite(CONTROL3, (mux_x&1));     //S0
    
    digitalWrite(14, LOW);
//    delay(0.5);
    digitalWrite(14, HIGH);
//delay(100);
//    digitalWrite(14, HIGH);
  
if( ++mux_x>8)mux_x=0;
}

void mux_hi() {
//int cc,r,c;
  //Since all 3 multiplexers have the same control pins, the one multiplexer data line we want to 
  //talk to should be set to output and the other two multiplexer lines should be be 'bypassed' by 
  //setting the pins to input
    
for( int cc=0;cc<10;cc++){
for(  int r=0;r<6;r++) {
   digitalWrite(CONTROL0, 1); //S3
    digitalWrite(CONTROL1, 1);  //S2
    digitalWrite(CONTROL2, 1);  //S1
    digitalWrite(CONTROL3, 1);     //S0
    digitalWrite(14, LOW);
    digitalWrite(14, HIGH);

  for( int c1=0 ; mux_hello[r][c1]!=-1;c1++){

   digitalWrite(CONTROL0, (mux_hello[r][c1]&15)>>3); //S3
    digitalWrite(CONTROL1, (mux_hello[r][c1]&7)>>2);  //S2
    digitalWrite(CONTROL2, (mux_hello[r][c1]&3)>>1);  //S1
    digitalWrite(CONTROL3, (mux_hello[r][c1]&1));     //S0
    
    digitalWrite(14, LOW);
    digitalWrite(14, HIGH);
  }
}
}
  
}
