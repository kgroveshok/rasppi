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
// V2.0 - KG 1/1/11
// Rebuild the whole code for multi-tasking of processes


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

//#include "WProgram.h"

//#define DEBUG 
//#define TASKWARN
//#define TASKACTUAL

#define MAX_NUM_TIMESLOTS 10
#define TRUE 1
#define FALSE 0


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


// define the pins used by the motor shield

#define speedA  10          // pin 10 sets the speed of motor A (this is a PWM output)
#define speedB  11          // pin 11 sets the speed of motor B (this is a PWM output) 
#define dirA    12            // pin 12 sets the direction of motor A
#define dirB    13            // pin 13 sets the direction of motor B

boolean movingBot = false;

// define the pins used for sensors

#define irReader 5     // the analog input pin for the sharp distance ir reader
#define lineA  4       // Line following sensors    
#define lineB  3 
//const int ldrSensor = 3 ;  // Light Dependant Resistor

// UI pins

#define pizoSpeaker  9

// dig pin 2-8 spare
// ang 3, 4, 5 spare
// dig pin 9 can be used for pwm out (ie pizo)

// Motor speed control

#define moveSpeed 180 
#define turnSpeed 230 

// define the direction of motor rotation - this allows you change the  direction without effecting the hardware
#define fwdA    HIGH         // this sketch assumes that motor A is the right-hand motor of your robot (looking from the back of your robot)
#define revA    LOW        // (note this should ALWAYS be opposite the fwdA)
#define fwdB    HIGH         //
#define revB    LOW        // (note this should ALWAYS be opposite the fwdB)

// define variables used
//int dist;
//int angle;
//int vel;

/* This is a simple code that reads an input from an analog pin on the Arduino and relays it back to the computer */

float irVal;         // stores value from Ir reader
float irVolts;
#define irRange  30       // value to detect as too close
#define irFar  100         // threshold distance to aim for when looking for somewhere to go
int InACornerCount=0;      // when in a corner count down for full 180 turn

int avoid_stuck_in_corner = 0 ; // if we are stuck in a corner do a greater rotation to back out

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

//int tuneTooClose[] = {  
//  C, 16, b, 16, g, 16, C, 8, b, 8, e, 16, R,32, C,16, c,16, g, 16, a, 8, C , 8, -1, -1};

//int tuneMoveBeep[] = { d, 8, -1, -1 };
//int tuneGestureBeep[] = { c, 8, C, 4, -1, -1 };



// Set overall tempo
long sound_tempo = 10000;
// Set length of pause between notes
int sound_pause = 1000;
// Loop variable to increase Rest length
int sound_rest_count = 100; //<-BLETCHEROUS HACK; See NOTES
// Initialize core variables
int sound_mtone = 0;
int sound_beat = 0;

int mux_x=0;
int mux_y=0;

long sound_duration = 0L ;
int sound_tone = 0 ;
long sound_duration_remaining = 0L ;

//////////////////////////////////////////////////////////////////
/// Multi tasking system
//////////////////////////////////////////////////////////////////

static void (*timeslotFunc[MAX_NUM_TIMESLOTS])(void);
long timeouts[MAX_NUM_TIMESLOTS];
long timestamps[MAX_NUM_TIMESLOTS];

//void attachTask(int, void (*)(void), long);

void attachTask(int index, void (*userFunc)(void), long timeout){
  if(index >= 0 && index <= MAX_NUM_TIMESLOTS){
    timeslotFunc[index] = userFunc;
    timeouts[index] = timeout;
    timestamps[index] = millis();
  }
}
void detachTask(int index){
  if(index>=0 && index <= MAX_NUM_TIMESLOTS){
    timeslotFunc[index] = 0;
    timeouts[index] = 0;
    timestamps[index] = 0;
  }
}
void changeTimeout(int index, long newTO){
  if(index>=0 && index <= MAX_NUM_TIMESLOTS){

#ifdef DEBUG
    Serial.print( "Setting a new timeout on task ");
    Serial.print( index ) ;
    Serial.print( " from " );
    Serial.print( timeouts[index]);
    Serial.print( " to " );
    Serial.print( newTO );
    Serial.println();
#endif

    timeouts[index] = newTO;


  }
}

// scheduler

void loop(){
  for(int i=0;i<MAX_NUM_TIMESLOTS;i++){
    if(timeouts[i] > 0){
      if((millis()-timestamps[i]) > timeouts[i]){
        timestamps[i] = millis();
        timeslotFunc[i]();
#ifdef TASKWARN
int actual = millis()-timestamps[i] ;
  if( actual > timeouts[i] ) {
    Serial.print( "*** Scheduler Warning: Function ");
    Serial.print( i);
    Serial.print( " took too long to run! Actual time to run: ");
    Serial.print( actual);
    Serial.println();
  } 
  #ifdef TASKACTUAL
  else {
    Serial.print( "*** Scheduler Function ");
    Serial.print( i);
    Serial.print( " actual time to run: ");
    Serial.print( actual);
    Serial.println();
  }
  #endif
#endif
      }
    }
  }
}

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
// Robot processing core
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////
// Read primary sensor array
//////////////////////////////////////////////////////////////////

void task_sensor_array( void ) {

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

//changeTimeout(3, irVal*50);

}

//////////////////////////////////////////////////////////////////
// Signal to motor controller what to do
//////////////////////////////////////////////////////////////////

#define MOTOR_STOPPED 0
#define MOTOR_FORWARD 1
#define MOTOR_STOPPING 2
#define MOTOR_CW 3
#define MOTOR_CCW 4

int motor_state = MOTOR_STOPPED ;  
long motor_timeout=0;  // used to signal a count down to stop
long motor_timeout_timestamp = 0L ; 
int motor_turn_speed= turnSpeed;
int motor_move_speed= moveSpeed;

void task_motor_drive( void ) {
  
    // if we are running down a count then we had better move quickly as other
    // tasks are possibly waiting on the motor to do something ie colision detection tasks!
    if( motor_timeout ) {

      if( motor_timeout_timestamp == 0L ) {
         motor_timeout_timestamp = millis();  // timeout requested so setup countdown
#ifdef DEBUG
      Serial.print( "Motor active timeout timestamp set at : ");
      Serial.print( motor_timeout_timestamp );
      Serial.println();
#endif
      }
      
#ifdef DEBUG
      Serial.print( "Motor active timeout set at ");
      Serial.print( motor_timeout );
      Serial.print( " time remaining is ");
      Serial.print( motor_timeout-(millis()-motor_timeout_timestamp) );
      Serial.println();
#endif

      if( ( millis() - motor_timeout_timestamp ) > motor_timeout ) {

#ifdef DEBUG
      Serial.print( "Motor timeout requesting stop.");
      Serial.println();
#endif

         digitalWrite (speedA, LOW); 
         digitalWrite (speedB, LOW);
         motor_state = MOTOR_STOPPING ;
         motor_timeout = 0L ;
         motor_timeout_timestamp = 0L ;
      }
    }
    
    
    // Handle motor ON requests
    
    if( motor_state != MOTOR_STOPPED ) {
      switch( motor_state ) {
        case MOTOR_STOPPING :

#ifdef DEBUG
      Serial.print( "Motor stopping.");
      Serial.println();
#endif

         digitalWrite (speedA, LOW); 
         digitalWrite (speedB, LOW);
         motor_state = MOTOR_STOPPED ;
         motor_timeout = 0L ;
         motor_timeout_timestamp = 0L ;
         break;

        case MOTOR_FORWARD :
          
#ifdef DEBUG
      Serial.print( "Moving forward...");
      Serial.println();
#endif
           avoid_stuck_in_corner = 0 ; // now moving forward so out of any sticky bit.
           
            digitalWrite (dirA, fwdA); 
            digitalWrite (dirB, fwdB);
            analogWrite (speedA, motor_move_speed);   // both motors set to same speed
            analogWrite (speedB, motor_move_speed); 
            break ;
          case MOTOR_CW :
#ifdef DEBUG
      Serial.print( "Turning CW...");
      Serial.println();
#endif
            digitalWrite (dirA, revA); 
            digitalWrite (dirB, fwdB);
            analogWrite (speedA, motor_turn_speed);   // both motors set to same speed
            analogWrite (speedB, motor_turn_speed); 
            break ;
          case MOTOR_CCW :
#ifdef DEBUG
      Serial.print( "Turning CCW...");
      Serial.println();
#endif

            digitalWrite (dirA, fwdA); 
            digitalWrite (dirB, revB);
            analogWrite (speedA, motor_turn_speed);   // both motors set to same speed
            analogWrite (speedB, motor_turn_speed); 
            break ;
      }
      
    }
}

//////////////////////////////////////////////////////////////////
// Make sense of the sensors and use them to detect hazards
//////////////////////////////////////////////////////////////////

int detect_object = FALSE ;

void task_col_detection( void ) {
  // lets assume there is no problem in front of us and go forward as normal
  
  if( !motor_timeout ) {
#ifdef DEBUG
    Serial.print( "Looking for trouble!");
    Serial.println();
#endif

    if( !detect_object )     motor_state = MOTOR_FORWARD ;

    detect_object = FALSE ;

  // ir distance tracking mode

    if( irVal < irRange ) {  // something is a bit close so back away
#ifdef DEBUG
    Serial.print( "Something in the way! Need to do something about it");
    Serial.println();
#endif
      detect_object = TRUE ;
      motor_state = MOTOR_STOPPING ;  // in case the avoidance task does not kick-in in time, lets try and stop at least!
    }

 

//if( !detect_object )     motor_state = MOTOR_FORWARD ;
  }
}

//////////////////////////////////////////////////////////////////
// Sound processing
//////////////////////////////////////////////////////////////////

// Queue a beep for the sound processor
// If a sound is playing then return a fail so can use in a loop 

int beep( int tone, long duration ) {
  if( sound_duration_remaining ) {
#ifdef DEBUG
    Serial.print( "A sound is already being processed." );
    Serial.println();
#endif

    return 0 ;
  }
  sound_tone = tone ;
  sound_duration=duration * sound_tempo ;
  sound_duration_remaining = duration * sound_tempo ;

#ifdef DEBUG
    Serial.print( "Queuing a sound for processing ");
    Serial.print( sound_tone ) ;
    Serial.print( " for a duration of ") ;
    Serial.print( sound_duration_remaining );
    Serial.println();
#endif

  
  return 1;
}


void task_sound_processing() {
  // format of data structure is:
  // tune = note
  // tune+1 = duration

if( sound_duration_remaining ) {
// a tone is set so lets process the note

#ifdef DEBUG
    Serial.print( "Processing a sound ");
    Serial.print( sound_tone ) ;
    Serial.print( " for a duration of ") ;
    Serial.print( sound_duration_remaining );
    Serial.println();
#endif

      while (sound_duration_remaining>=0L) {
        digitalWrite(pizoSpeaker,HIGH);
        delayMicroseconds(sound_tone / 2);
        // DOWN
        digitalWrite(pizoSpeaker, LOW);
        delayMicroseconds(sound_tone / 2);
        // Keep track of how long we pulsed
        sound_duration_remaining -= (sound_tone);
      }
      sound_duration_remaining=0L;
    }
}

//////////////////////////////////////////////////////////////////
// Beep in relation to distance to next object
//////////////////////////////////////////////////////////////////

int distance_sounder_count=0;

void task_distance_sounder( void ) {

#ifdef DEBUG
    Serial.print( "Distance sounder count is");
    Serial.print( distance_sounder_count );
    Serial.println();
#endif

  
if( ++distance_sounder_count >= (((irVal-20)*2)/6) ) {
#ifdef DEBUG
    Serial.print( "Sound distance note.");
    Serial.print(irVolts);
    Serial.print(" ");
    Serial.print(irVal);
    Serial.print(" ticks ");
    Serial.print(((irVal-20)*3)/5);
    Serial.println();
#endif

  beep(b,2);
  distance_sounder_count=0; 
}
}

//////////////////////////////////////////////////////////////////
// Handle avoidance tatics
//////////////////////////////////////////////////////////////////


void task_col_avoidance( void ) {

  if( !motor_timeout ) {
  if( detect_object ) {
#ifdef DEBUG
    Serial.print( "Run away!");
    Serial.println();
#endif

    motor_timeout = 700L+random(1000) ; // set wait long enough to move before resample of sensor array

    if( ++avoid_stuck_in_corner >= 5+random(4) ) {
      // tried a few times to go forward but can't so lets turn around

#ifdef DEBUG
    Serial.print( "Stuck in a corner so turn around.");
    Serial.println();
#endif

      motor_timeout = 2000L+random(2000) ; // set wait long enough to move before resample of sensor array
    }
    
    if( random(2) == 1 )   {    
#ifdef DEBUG
      Serial.print( "Decided avoid via ccwR");
      Serial.println();
#endif
      motor_state = MOTOR_CCW ;
    }
    else {
#ifdef DEBUG
      Serial.print( "Decided avoid via cwR");
      Serial.println();
#endif
      motor_state = MOTOR_CW ;
    }

task_motor_drive() ;

  }
  }

}

//////////////////////////////////////////////////////////////////
// LED Matrix display update
//////////////////////////////////////////////////////////////////


int mux_hello[][6] = {
{   0,3, 6,-1,0,0},
{ 0,3,6,-1,0,0},
{  0,3,-1,-1,0,0},
{ 0,1,2,3,6,-1},
{0,3,6,-1,0,0},
{0,3,6,-1,0,0},
{0,3,6,-1,0,0}
};

int matrix_r=0;
int matrix_c=0;

void task_led_matrix( void ) {
#ifdef DEBUG
    Serial.print( "Updating matrix");
    Serial.println();
#endif

#ifdef AA
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
#endif  


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
  
if( ++mux_x>7)mux_x=0;
  
}


// Robot setup
// Slot     Timeout   Module   
//
// 0         50ms    Primary sensor array scan
// 1         100ms    Motor drive signals
// 2         100ms    Colision detection 
// 3         500ms    Audible distance sounder
// 4         200ms    Colision avoidance
// 7         100ms    Music playback
// 8         500ms    LED Matrix update

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

// setup tasks

attachTask( 0, task_sensor_array, 150 );
attachTask( 1, task_motor_drive, 150 );
attachTask( 2, task_col_detection, 200 );
attachTask( 3, task_distance_sounder, 250 );
attachTask( 4, task_col_avoidance, 200 );

//attachTask( 8, task_led_matrix, 1000 );
attachTask( 9, task_sound_processing, 500 ) ;


}

// PLAY TONE ==============================================
// Pulse the speaker to play a tone for a particular duration

long tone_elapsed_time = 0;
int tone_ct=0;


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

#ifdef OLDCODE
void playTune( int tune[] ) {
  // format of data structure is:
  // tune = note
  // tune+1 = duration

if( tune[tone_ct] != -1 ) {
  if( tone_elapsed_time >= duratio) {
    mtone=tune[tone_ct] ;
    duration = tune[tone_ct+1] * tempo ;
  }
  
    if (mtone > 0) { // if this isn't a Rest beat, while the tone has
      // played less long than 'duration', pulse speaker HIGH and LOW
      while (tone_elapsed_time < duration) {
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

//void forward(int dist, int vel) {          // forward: both motors set to forward direction
 // digitalWrite (dirA, fwdA); 
//  digitalWrite (dirB, fwdB);
//  analogWrite (speedA, vel);   // both motors set to same speed
//  analogWrite (speedB, vel); 
//  delay (dist);                // wait for a while (dist in mSeconds)
//}

//void reverse(int dist, int vel) {          // reverse: both motors set to reverse direction
//  int aa;

//  digitalWrite (dirA, revA); 
//  digitalWrite (dirB, revB);
//  analogWrite (speedA, vel);   // both motors set to same speed
//  analogWrite (speedB, vel); 

 // delay (dist);                // wait for a while (dist in mSeconds)              
//}    

//void rot_cw (int angle, int vel) {         // rotate clock-wise: right-hand motor reversed, left-hand motor forward
//  delay (angle);               // wait for a while (angle in mSeconds)              
//}

//void rot_ccw (int angle, int vel) {        // rotate counter-clock-wise: right-hand motor forward, left-hand motor reversed
//  digitalWrite (dirA, fwdA); 
//  digitalWrite (dirB, revB);
//  analogWrite (speedA, vel);   // both motors set to same speed
//  analogWrite (speedB, vel); 
//  delay (angle);               // wait for a while (angle in mSeconds)              /
//}

//void rot_cwR ( int vel) {         // rotate clock-wise: right-hand motor reversed, left-hand motor forward
//}

//void rot_ccwR ( int vel) {        // rotate counter-clock-wise: right-hand motor forward, left-hand motor reversed
//
//}

//void turn_right (int angle, int vel) {     // turn right: right-hand motor stopped, left-hand motor forward
//  digitalWrite (dirA, revA); 
//  digitalWrite (dirB, fwdB);
//  digitalWrite (speedA, LOW);  // right-hand motor speed set to zero
//  analogWrite (speedB, vel); 
//  delay (angle);               // wait for a while (angle in mSeconds)              /
//}

//void turn_left (int angle, int vel) {      // turn left: left-hand motor stopped, right-hand motor forward
//  digitalWrite (dirA, fwdA); 
//  digitalWrite (dirB, revB);
//  analogWrite (speedA, vel);
//  digitalWrite (speedB, LOW);  // left-hand motor speed set to zero
//  delay (angle);               // wait for a while (angle in mSeconds)              /
//}


//void about_turn() {
//  rot_cw (2000, turnSpeed);      // rotate clock-wise for 2000 mS (about 90 deg) at speed 100
//  rot_cw (2000, turnSpeed);      // rotate clock-wise for 2000 mS (about 90 deg) at speed 100
//}


int aa=0;

void loop2() { 



  if( !movingBot ) {
    if( sensorMode == 0 ) {

    }
    else
    {
//      forward(150,moveSpeed);
    }
    movingBot=true;
  }

//  sensor_array() ;

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
//      turn_left( 50, turnSpeed );
      movingBot = false;

    }
    if( lineAVal < -50 ) {
      // Right sensor detects darkness, therefore veered to left
  //    turn_right( 50, turnSpeed );
      movingBot = false;

    }
  }

  else 
    // ir distance tracking mode

    if( irVal <irRange ) {  // something is a bit close so back away
//    stop();
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
//      rot_ccwR( turnSpeed ) ; // point somewhere else to go 
    }
    else {
#ifdef DEBUG
      Serial.print( "cwR");
      Serial.println();
#endif
  //    rot_cwR( turnSpeed ) ; // point somewhere else to go
    }

    // Look for somewhere far away to go

    do {
//      sensor_array();

#ifdef DEBUG
      Serial.print( "Looking to go: ");
      Serial.print( irVal);
      Serial.println();
#endif
      delay(50);
    } 
    while( irVal>irFar );
    delay (250);               // wait for a while (angle in mSeconds)              
//    stop();

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

//      rot_ccwR( turnSpeed ) ; // point somewhere else to go 
      delay(3000);
 // stop();
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
//      rot_ccwR( turnSpeed ) ; // point somewhere else to go 
    }
    else {
#ifdef DEBUG
      Serial.print( "cwR");
      Serial.println();
#endif
//      rot_cwR( turnSpeed ) ; // point somewhere else to go
    }

      delay(random(2000));

    // Look for somewhere far away to go

    do {
//      sensor_array();

#ifdef DEBUG
      Serial.print( "Looking to go: ");
      Serial.print( irVal);
      Serial.println();
#endif
      delay(50);
    } 
    while( irVal>irFar );
    delay (250);               // wait for a while (angle in mSeconds)              
//    stop();
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
//      stop();
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

#endif


// EOF
