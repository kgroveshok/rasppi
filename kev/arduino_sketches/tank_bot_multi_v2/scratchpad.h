
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

////// v2
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

  // if we are not waiting

  if( !wastetime ) {
      // lets stop and give us a few seconds to work a way out of the problem...

#ifdef DEBUG_MOTOR
      Serial.print( "Something in the way! Stop moving and then think about it.");
      Serial.println();
#endif

      motor_running = 0;
      wastetime = 2000L ;
  }
}
}

// Something could be in the way so lets spin ourself around until we are happy

void task_something_in_way( int slice ){

  // ir distance tracking mode

    if( ( irVal < irRange ) && !wastetime && !motor_running ) {  // something is a bit close so back away
#ifdef DEBUG_SENSOR
      Serial.print( "Something in the way and we've stopped so lets spin around to find a gap.");
      Serial.println();
#endif

      beep( TONE_B, 2 );
      
        if( random(2) == 1 )   {    
#ifdef DEBUG_MOTOR
        Serial.print( "Decided avoid via ccwR");
        Serial.println();
#endif

      digitalWrite (dirA, fwdA); 
      digitalWrite (dirB, revB);
      }
      else {
#ifdef DEBUG_MOTOR
        Serial.print( "Decided avoid via cwR");
        Serial.println();
#endif
      digitalWrite (dirA, revA); 
      digitalWrite (dirB, fwdB);
      }


      analogWrite (speedA, motor_turn_speed);   // both motors set to same speed
      analogWrite (speedB, motor_turn_speed); 
            wastetime=6000L; // make us wait a bit longer after we've spun, just in case the problem goes away!
            motor_running=5000L;

    }
}

// Nothing ahead of us so lets go there.

void task_nothing_in_way( int slice ){

  // ir distance tracking mode

    if( ( irVal > irRange ) ) {  // all clear ahead
    
#ifdef DEBUG_SENSOR
      Serial.print( "Can't see anything head so lets go forward until we do.");
      Serial.println();
#endif

      beep( TONE_HC, 2 );

#ifdef DEBUG_MOTOR
      Serial.print( "Nothing ahead so we can go forward...");
      Serial.print( wastetime );
      Serial.print( motor_running );
      Serial.println();
#endif
      wastetime=0;
      motor_running=5000L;
      digitalWrite (dirA, fwdA); 
      digitalWrite (dirB, fwdB);
      analogWrite (speedA, motor_move_speed);   // both motors set to same speed
      analogWrite (speedB, motor_move_speed); 
}
}

//////////////////////////////////////////////////////////////////
// Signal to motor controller what to do
//////////////////////////////////////////////////////////////////

// Stop motors

void task_motor_off( int slice ){

  if( motor_running == 0 ) {
#ifdef DEBUG_MOTOR
      Serial.print( "Motor timeout requesting stop.");
      Serial.println();
#endif

    digitalWrite (speedA, LOW); 
    digitalWrite (speedB, LOW); 
  }

}

// Countdown any motor running times

void task_motor_countdown( int slice ) {

  if( motor_running ) {
      motor_running -= slice ;
      if( motor_running<0L) { 
        motor_running=0L;

        beep( TONE_C, 2 );
      }
    
#ifdef DEBUG_MOTOR
      Serial.print( "Motor timeout countdown...");
      Serial.print(motor_running);
      Serial.println();
#endif


  }
  
}




// Robot setup

void setup() {                            

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

  attachTask( TASK_PROFILE, select_profile, 800 ) ;
  attachTask( TASK_SENSOR, task_sensor_array, 50 ) ;
  attachTask( TASK_MOTOR_OFF, task_motor_off, 60 ) ;
  attachTask( TASK_MOTOR_COUNTDOWN, task_motor_countdown, 100 ) ;
  attachTask( TASK_IR_DISTANCE, task_ir_distance, 150 ) ;
  attachTask( TASK_WASTE_TIME, task_waste_time, 55 ) ;
  attachTask( TASK_NOTHING_IN_WAY, task_nothing_in_way, 200 );
  attachTask( TASK_SOMETHING_IN_WAY, task_something_in_way, 70 );
  attachTask( TASK_SOUND, task_sound_processing, 500 ) ;
  
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



// EOF


