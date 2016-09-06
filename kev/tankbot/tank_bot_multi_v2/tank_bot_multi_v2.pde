// based on
// arduino_tank_sketch   version 1.0   J.Luke (RobotBits.co.uk)
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
// V1.6 - KG 1/1/11
// Rebuild the whole code for multi-tasking of processes
// V2.0 - KG 10/05/2012
// Tighten multi-tasking loops and rebuild from ground up due to power drain (possible loss on wasted CPU)
// KG 09/06/2012
// Added LDR code or photophobic run away
// Line follow sensors will avoid high contrast surfaces 
// Added LDR when dark will toggle line follow or distance priority
// KG 11/06/2012
// Added profile changes to adjust motor speeds to be slower whe in line follow mode
// Turned down the LDR dark setting as minor ambient light was causing it to trigger


// Todo
// change switch for line mode to include area avoid or line follow
// add band weapon. gripper to release band. use point motor to open catch when in panic mode. 
// debug wheel rev counter and build map
// add RF transmitter for map building

// debug line follow code
// add wheel rev count sensors
//     add map build in memory
// add an lcd display
// add sound sensors
// add temp sensor
// add tilt sensor
// add bump sensors
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
//#define DEBUG_MOTOR 
//#define DEBUG_SENSOR

//#define TASKWARN
//#define TASKACTUAL

#define TRUE 1
#define FALSE 0


#include "motor.h"
#include "mux.h"
#include "sensor.h"

#define STATE_ROBOT_STOPPED 0
#define STATE_ROBOT_MOVING 1
#define STATE_ROBOT_AVOID 2
#define STATE_ROBOT_SCARED 4

int state_robot = STATE_ROBOT_STOPPED ;

// UI pins

#define pizoSpeaker  9


// dig pin 2-8 spare
// ang 3, 4, 5 spare
// dig pin 9 can be used for pwm out (ie pizo)


// define variables used
//int dist;
//int angle;
//int vel;

//int InACornerCount=0;      // when in a corner count down for full 180 turn

//int avoid_stuck_in_corner = 0 ; // if we are stuck in a corner do a greater rotation to back out

//int irDarkness=600;


//int ldrTransCount =0 ;    // Count for number of gestures over LDR within set period

// robot sensor tracking mode
// 0 = ir distance
// 1 = line follow

//int sensorMode=0;  

//////////////////////////////////////////////////////////////////
/// Multi tasking system
//////////////////////////////////////////////////////////////////

// scheduler will call loop() after setup() does process attachment

// Load up the multi-tasking scheduler

#include "scheduler.h"

#define TASK_PROFILE 0
#define TASK_SENSOR 1
#define TASK_MOTOR_OFF 2
#define TASK_MOTOR_COUNTDOWN 3
#define TASK_IR_DISTANCE 4
#define TASK_WASTE_TIME 5
#define TASK_SOMETHING_IN_WAY 6
#define TASK_NOTHING_IN_WAY 7
#define TASK_SOUND 8
#define TASK_LIGHT_REACT 9
#define TASK_LINE_FOLLOW 10

void attachTask(int index, void (*userFunc)(int), long timeout){
  timeslotFunc[index] = userFunc;
  timeouts[index] = timeout;
  timestamps[index] = millis();
}

void changeTimeout(int index, long newTO){

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


void loop( void ){
  corestamp = millis();
  for(int i=0;i<MAX_NUM_TIMESLOTS;i++){
    if(timeouts[i] > 0){
      if((corestamp-timestamps[i]) > timeouts[i]){
        timestamps[i] = corestamp;
        timeslotFunc[i](timeouts[i]);

#ifdef TASKWARN
        int actual = corestamp-timestamps[i] ;
        if( actual > timeouts[i] ) {
          Serial.print( "*** Scheduler Warning: Function ");
          Serial.print( i);
          Serial.print( " took too long to run! Actual time to run: ");
          Serial.print( actual);
          Serial.println();
        } 
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

#include "sound.h"

#define PROFILE_MOVING 1
#define PROFILE_NORMAL 2
#define PROFILE_LINE_FOLLOW 3

int profile_switch_to ;
int profile_current = PROFILE_NORMAL ;

void select_profile( int slice ) {

  if( profile_switch_to ) {
    switch( profile_current = profile_switch_to ) {
    case PROFILE_MOVING :
      break ;
    case PROFILE_NORMAL :
      motor_turn_speed= normTurnSpeed;
      motor_move_speed= normMoveSpeed;

      changeTimeout( TASK_LINE_FOLLOW, 0 ); // effectivly not used now
      beep( TONE_C, 2 );
      break ; 
    case PROFILE_LINE_FOLLOW :
      motor_turn_speed= lineTurnSpeed;  // slow the motors down for fine control
      motor_move_speed= lineMoveSpeed;

      changeTimeout( TASK_LINE_FOLLOW, lineFollowPrio );  // lets concentrate on high contrast floor
      beep( TONE_D, 2 );
      break ; 
    }

    profile_switch_to = 0 ;
  }
}

// Countdown any system wide delay

void task_waste_time( int slice ) {
  if( wastetime ) {
    if( ( wastetime -= slice ) < 0 ) {
      wastetime = 0 ;
      beep( TONE_D, 2 );

    }
  } 
}


//////////////////////////////////////////////////////////////////
// Read primary sensor array
//////////////////////////////////////////////////////////////////

void task_sensor_array( int slice ) {

  irVolts = analogRead(irReader)*0.0048828125;   // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3
  irVal= 65*pow(irVolts, -1.10);          // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk

  //  ldrVal = ldrBase - analogRead( ldrSensor ) ;

//  lineAVal = analogRead(lineA);    // read the value from the ir sensor
//  lineBVal = analogRead(lineB);    // read the value from the ir sensor
  lineAVal = abs(lineABase - analogRead(lineA));    // read the value from the ir sensor
  lineBVal = abs(lineBBase - analogRead(lineB));    // read the value from the ir sensor

  // Read ambient light level
  
  ldrVal = analogRead( LDRpin ) ;

  // Read rotary counter sensors
  
  rotateLeftVal = analogRead( rotateLeftPin ) ;
  rotateRightVal = analogRead( rotateRightPin ) ;

#ifdef DEBUG_SENSOR  
  Serial.print( "State: ");
  Serial.print( state_robot, DEC );
  Serial.print( "Distance: ");
  Serial.print( irVal, DEC );
  Serial.print( " Line (Right Blue): ");
  Serial.print( lineAVal, DEC );
  Serial.print( " Line (Left Yellow): ");
  Serial.print( lineBVal, DEC );
  Serial.print( " LDR: ");
  Serial.print( ldrVal, DEC );
  Serial.print( " Rot L: ");
  Serial.print( rotateLeftVal, DEC );
  Serial.print( " Rot R: ");
  Serial.print( rotateRightVal, DEC );
  Serial.println();
#endif

  // if( ldrVal > ldrBright ) return;

  //if( sensorMode == 1 ) return ;

  // wait for an event by the sensors
  //} while( irVal < irRange ) ;

  //changeTimeout(3, irVal*50);

}

//////////////////////////////////////////////////////////////////
// Sensor line follow checks - at the moment we are going to avoid sudden change
//////////////////////////////////////////////////////////////////

void task_line_follow( int slice ){

    if( lineAVal >= lineADiff ) {  // change in surface reflection avoid
#ifdef DEBUG_SENSOR
    Serial.print( "A - Avoid something on the floor.");
    Serial.println();
#endif

    state_robot = STATE_ROBOT_AVOID ;

  }

    if( lineBVal >= lineBDiff ) {  // change in surface reflection avoid
#ifdef DEBUG_SENSOR
    Serial.print( "B - Avoid something on the floor.");
    Serial.println();
#endif

    state_robot = STATE_ROBOT_AVOID ;

  }

}

//////////////////////////////////////////////////////////////////
// Sensor checks to decide on action
//////////////////////////////////////////////////////////////////

void task_ir_distance( int slice ){

  // ir distance tracking mode

    if( irVal < irRange ) {  // something is a bit close so back away
#ifdef DEBUG_SENSOR
    Serial.print( "Avoid something ahead.");
    Serial.println();
#endif

    state_robot = STATE_ROBOT_AVOID ;

  }
  else {
    if( state_robot != STATE_ROBOT_AVOID )
      state_robot = STATE_ROBOT_MOVING ;
  }
}

// Something could be in the way so lets spin ourself around until we are happy

void task_something_in_way( int slice ){

  // ldr reactaction
  
  if( state_robot == STATE_ROBOT_SCARED ) { // If the robot is scared lets back up 
#ifdef DEBUG_SENSOR
    Serial.print( "I am scared so I'm backing up.");
    Serial.println();
#endif
    beep( TONE_C, 2 );

#ifdef DEBUG_MOTOR
    Serial.print( "Start motors in reverse");
    Serial.println();
#endif
if( !wastetime) {
    digitalWrite (dirA, revA); 
    digitalWrite (dirB, revB);
    //      }

    wastetime=1000;
    analogWrite (speedA, motor_turn_speed);   // both motors set to same speed
    analogWrite (speedB, motor_turn_speed); 
    }

  }
  
  
  // ir distance tracking mode

    if( state_robot == STATE_ROBOT_AVOID ) {  // something is a bit close so back away
#ifdef DEBUG_SENSOR
    Serial.print( "Something in the way so lets spin around to find a gap.");
    Serial.println();
#endif

    beep( TONE_B, 2 );

    //        if( random(2) == 1 )   {    
    //#ifdef DEBUG_MOTOR
    //        Serial.print( "Decided avoid via ccwR");
    //        Serial.println();
    //#endif

    //      digitalWrite (dirA, fwdA); 
    //      digitalWrite (dirB, revB);
    //      }
    //      else {
#ifdef DEBUG_MOTOR
    Serial.print( "Decided avoid via cwR");
    Serial.println();
#endif
if( !wastetime) {
    digitalWrite (dirA, revA); 
    digitalWrite (dirB, fwdB);
    //      }

// if we are doing line follow sensors then we need to react quicker to motor control

wastetime= ( profile_current == PROFILE_LINE_FOLLOW ) ? 90 : 250;

    analogWrite (speedA, motor_turn_speed);   // both motors set to same speed
    analogWrite (speedB, motor_turn_speed); 
state_robot = STATE_ROBOT_MOVING;
    }
  }
}

// Nothing ahead of us so lets go there.

void task_nothing_in_way( int slice ){

  // ir distance tracking mode

    if( state_robot == STATE_ROBOT_MOVING ) {  // all clear ahead
//if( state_robot != STATE_ROBOT_AVOID ) {
#ifdef DEBUG_SENSOR
    Serial.print( "Can't see anything head so lets go forward until we do.");
    Serial.println();
#endif

    beep( TONE_HC, 2 );

#ifdef DEBUG_MOTOR
    Serial.print( "Nothing ahead so we can go forward...");
    Serial.println();
#endif
if( !wastetime) {
wastetime=250;

  digitalWrite (dirA, fwdA); 
    digitalWrite (dirB, fwdB);
    analogWrite (speedA, motor_move_speed);   // both motors set to same speed
    analogWrite (speedB, motor_move_speed); 
  }
    }
}

//////////////////////////////////////////////////////////////////
// Sensor checks for light level
//////////////////////////////////////////////////////////////////

void task_light_react( int slice ){

    if( ldrVal <= (ldrBase - ldrDark ) ) {  // Its dark so lets stop
#ifdef DEBUG_SENSOR
    Serial.print( "Light has gone out. Lets stop and toggle mode.");
    Serial.println();
#endif

    state_robot = STATE_ROBOT_STOPPED ;
//    task_motor_off( 0 ); // stop now!
//     calib_sensors();    
    profile_switch_to = ( profile_current == PROFILE_NORMAL ) ? PROFILE_LINE_FOLLOW : PROFILE_NORMAL ;


  }

    if( ldrVal >= (ldrBase + ldrLight) ) {  // Its bright in here lets run away!
#ifdef DEBUG_SENSOR
    Serial.print( "Its bright. I need to run away.");
    Serial.println();
#endif

    state_robot = STATE_ROBOT_SCARED ;

  }

}

//////////////////////////////////////////////////////////////////
// Signal to motor controller what to do
//////////////////////////////////////////////////////////////////

// Stop motors

void task_motor_off( int slice ){

  if( state_robot == STATE_ROBOT_STOPPED ) {
#ifdef DEBUG_MOTOR
    Serial.print( "Motor requesting stop.");
    Serial.println();
#endif
    wastetime=2000;
    digitalWrite (speedA, LOW); 
    digitalWrite (speedB, LOW); 
  }

}

// Countdown any motor running times

//void task_motor_countdown( int slice ) {

 // if( motor_running ) {
 //   motor_running -= slice ;
//    if( motor_running<0L) { 
//      motor_running=0L;

//      beep( TONE_C, 2 );
//    }

//#ifdef DEBUG_MOTOR
//    Serial.print( "Motor timeout countdown...");
//    Serial.print(motor_running);
//    Serial.println();
//#endif//
//
//
//  }
//
//}




// Robot setup

void setup() {                            

  profile_switch_to  = PROFILE_LINE_FOLLOW ; // set default sensor mode
  
  // clear the scheduler
  for( int i = 0 ; i < MAX_NUM_TIMESLOTS  ; i++ ) timeouts[i]=0;

  // sets up the pinModes for the pins we are using

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

  attachTask( TASK_PROFILE, select_profile, 400 ) ;
  attachTask( TASK_SENSOR, task_sensor_array, 50 ) ;
  attachTask( TASK_MOTOR_OFF, task_motor_off, 60 ) ;
  //  attachTask( TASK_MOTOR_COUNTDOWN, task_motor_countdown, 100 ) ;
  attachTask( TASK_IR_DISTANCE, task_ir_distance, 150 ) ;
  attachTask( TASK_WASTE_TIME, task_waste_time, 55 ) ;
  attachTask( TASK_NOTHING_IN_WAY, task_nothing_in_way, 200 );
  attachTask( TASK_SOMETHING_IN_WAY, task_something_in_way, 70 );
  attachTask( TASK_SOUND, task_sound_processing, 500 ) ;
  attachTask( TASK_LIGHT_REACT, task_light_react, 130 ) ;
  attachTask( TASK_LINE_FOLLOW, task_line_follow, 120 ) ;

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
    
    ldrVal = analogRead(LDRpin);
    if( ldrVal < ldrBase ) ldrBase = ldrVal;
  }

  // once ambient light level need to signal by tone that we want a sample
  // of the bright light trigger level
  // bug to do  

}



// EOF


