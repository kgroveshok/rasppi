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


// Todo
// debug line follow code
// add sensor toggle switch switch 
// add wheel rev count sensors
//     add map build in memory
// add an lcd display
// add sound sensors
// add temp sensor
// add light sensor
// add tilt sensor
// add bump sensors
// add buzzer/pizo speaker
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

int DEBUG = 1;

// define the pins used by the motor shield

const int speedA = 10;          // pin 10 sets the speed of motor A (this is a PWM output)
const int speedB = 11;          // pin 11 sets the speed of motor B (this is a PWM output) 
const int dirA = 12;            // pin 12 sets the direction of motor A
const int dirB = 13;            // pin 13 sets the direction of motor B

// define the pins used for sensors

const int irReader = 0;    // the analog input pin for the sharp distance ir reader
const int lineA = 1 ;      // Line following sensors    
const int lineB = 2 ;
const int ldrSensor = 3 ;  // Light Dependant Resistor

// UI pins

const int pizoSpeaker = 9;

// dig pin 2-7 spare
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
int dist;
int angle;
int vel;

/* This is a simple code that reads an input from an analog pin on the Arduino and relays it back to the computer */

int irVal = 255;         // stores value from Ir reader
const int irRange = 450 ;      // value to detect as too close
const int irFar = 150 ;        // threshold distance to aim for when looking for somewhere to go

//int irDarkness=600;

// Line tracking sensor checks

int lineAVal=0;
int lineBVal=0;
int lineABase=0;
int lineBBase=0;

int ldrVal = 0 ;
int ldrBase = 2000 ;

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
int melody[] = { C, b, g, C, b,        e, R, C, c, g, a, C };
int beats[] = { 16, 16, 16, 8, 8, 16, 32, 16, 16, 16, 8, 8 };
int MAX_COUNT = sizeof(melody) / 2; // Melody length, for looping.

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


void setup() {                             // sets up the pinModes for the pins we are using
  
  pinMode (dirA, OUTPUT);         
  pinMode (dirB, OUTPUT); 
  pinMode (speedA, OUTPUT); 
  pinMode (speedB, OUTPUT); 
  pinMode (pizoSpeaker, OUTPUT);
  
  //pinMode (irReader, INPUT); 
  Serial.begin(9600);  

  // get a sample and avg of the current floor colour 
  
  calib_line();
  
  randomSeed(2);
}

// PLAY TONE ==============================================
// Pulse the speaker to play a tone for a particular duration
void playTone() {
  long elapsed_time = 0;
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
}

void calib_line(){
  int cc ;
  // get a sample and avg of the current floor colour 
  
  for( cc = 1 ; cc < 1000 ; cc++) {
    lineAVal = analogRead(lineA);    // read the value from the ir sensor
    lineBVal = analogRead(lineB);    // read the value from the ir sensor
    if( lineAVal > lineABase ) lineABase = lineAVal;
    if( lineBVal > lineBBase ) lineBBase = lineBVal;

    ldrVal = analogRead(ldrSensor);
    if( ldrVal < ldrBase ) ldrBase = ldrVal;
  }

}

void stop() {                              // stop: force both motor speeds to 0 (low)
  digitalWrite (speedA, LOW); 
  digitalWrite (speedB, LOW);
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
aa=1;

do {
  irVal = analogRead(irReader);    // read the value from the ir sensor
delay(50);

  if( aa > 10 ) {
  mtone = d;
  beat = 8;
  duration = beat * tempo; // Set up timing
  playTone();
  aa=0;
  }
aa++;


//if(irVal>254) return;
} while( irVal<irRange );

//  delay (dist);                // wait for a while (dist in mSeconds)              
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

void ir_sensor() {
int aa=0;
  do {
  
  irVal = analogRead(irReader);    // read the value from the ir sensor
  ldrVal = ldrBase - analogRead( ldrSensor ) ;
  
  lineAVal = lineABase - analogRead(lineA);    // read the value from the ir sensor
  lineBVal = lineBBase - analogRead(lineB);    // read the value from the ir sensor
  
  Serial.print( "Distance, Line A Var, Line B Var, LDR:");
  Serial.print( irVal);
  Serial.print( " ");
  Serial.print( lineAVal);
  Serial.print( " ");
  Serial.print( lineBVal);
  Serial.print( " ");
  Serial.print( ldrVal);
  Serial.println();


  if( aa > 10 ) {
  mtone = C;
  beat = 8;
  duration = beat * tempo; // Set up timing
  playTone();
  aa=0;
  }
aa++;


  if( ldrVal >200 ) return;
  
  if( sensorMode == 1 ) return ;

  // wait for an event by the sensors
} while( irVal < irRange ) ;

}



//int step = 0;
//int thisStep=0;
//int inRotate=0;
//int inRotateCW=0;

void loop() { 


  if( sensorMode == 0 ) {
    Serial.print( "Moving forward:");

    digitalWrite (dirA, revA); 
    digitalWrite (dirB, revB);
    analogWrite (speedA, moveSpeed);   // both motors set to same speed
    analogWrite (speedB, moveSpeed); 
  }
  else
  {
    forward(150,moveSpeed);
  }
  
  ir_sensor() ;

  if( ldrVal > 200 ) {
    rot_cw(500,turnSpeed);
    forward(500,moveSpeed);
  }
  
  if( sensorMode == 1 ) {
      if( lineAVal > 50 ) {
        // Left sensor detects darkness, therefore veered to right
        turn_left( 50, turnSpeed );
             
      }
      if( lineBVal > 50 ) {
        // Right sensor detects darkness, therefore veered to left
        turn_right( 50, turnSpeed );

      }
  }
  
  else 
  // ir distance tracking mode
  
  if( irVal >irRange ) {  // something is a bit close so back away
stop();
      Serial.print( "Run away!");
      Serial.println();

// Set up a counter to pull from melody[] and beats[]
for (int i=0; i<MAX_COUNT; i++) {
  mtone = melody[i];
  beat = beats[i];
  duration = beat * tempo; // Set up timing
  playTone();
  // A pause between notes...
  delayMicroseconds(pause);
  if (DEBUG) { // If debugging, report loop, tone, beat, and duration
    Serial.print(i);
    Serial.print(":");
    Serial.print(beat);
    Serial.print(" ");
    Serial.print(mtone);
    Serial.print(" ");
    Serial.println(duration);
  }
}

      // BUG: set block on map

      if( random(2) == 1 )   {    
        Serial.print( "ccwR");
        Serial.println();
        rot_ccwR( turnSpeed ) ; // point somewhere else to go 
      }
     else {
        Serial.print( "cwR");
        Serial.println();

        rot_cwR( turnSpeed ) ; // point somewhere else to go
      }

    do {
       irVal = analogRead(irReader);    // read the value from the ir sensor
       Serial.print( "Looking to go: ");
       Serial.print( irVal);
       Serial.println();
       delay(50);
    } while( irVal>irFar );
    delay (250);               // wait for a while (angle in mSeconds)              
    stop();
  }
 
   
} 





