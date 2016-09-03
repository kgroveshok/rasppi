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


// define the pins used by the motor shield
int speedA = 10;          // pin 10 sets the speed of motor A (this is a PWM output)
int speedB = 11;          // pin 11 sets the speed of motor B (this is a PWM output) 
int dirA = 12;            // pin 12 sets the direction of motor A
int dirB = 13;            // pin 13 sets the direction of motor B

int moveSpeed=180;
int turnSpeed=250;

// define the direction of motor rotation - this allows you change the  direction without effecting the hardware
int fwdA  =  HIGH;         // this sketch assumes that motor A is the right-hand motor of your robot (looking from the back of your robot)
int revA  =  LOW;        // (note this should ALWAYS be opposite the fwdA)
int fwdB  =  HIGH;         //
int revB  =  LOW;        // (note this should ALWAYS be opposite the fwdB)

// define variables used
int dist;
int angle;
int vel;

/* This is a simple code that reads an input from an analog pin on the Arduino and relays it back to the computer */

int irReader = 0;    // the analog input pin for the ir reader
int irVal = 255;       // stores value from Ir reader
int irRange=450;
int irDarkness=600;


int lineA=1;
int lineB=2;
int lineAVal=0;
int lineBVal=0;
int lineABase=0;
int lineBBase=0;

// robot sensor tracking mode
// 0 = ir distance
// 1 = line follow

int sensorMode=0;  


void setup() {                             // sets up the pinModes for the pins we are using
  
  pinMode (dirA, OUTPUT);         
  pinMode (dirB, OUTPUT); 
  pinMode (speedA, OUTPUT); 
  pinMode (speedB, OUTPUT); 
  //pinMode (irReader, INPUT); 
  Serial.begin(9600);  


  // get a sample and avg of the current floor colour 
  
  calib_line();
  
  randomSeed(2);
}

void calib_line(){
  int c ;
  // get a sample and avg of the current floor colour 
  
  for( c = 1 ; c < 1000 ; c++) {
    lineAVal = analogRead(lineA);    // read the value from the ir sensor
    lineBVal = analogRead(lineB);    // read the value from the ir sensor
    if( lineAVal > lineABase ) lineABase = lineAVal;
    if( lineBVal > lineBBase ) lineBBase = lineBVal;
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
  digitalWrite (dirA, revA); 
  digitalWrite (dirB, revB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 

do {
  irVal = analogRead(irReader);    // read the value from the ir sensor
delay(50);
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

void rot_cwR ( int angle, int vel) {         // rotate clock-wise: right-hand motor reversed, left-hand motor forward
  digitalWrite (dirA, revA); 
  digitalWrite (dirB, fwdB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 

do {
  irVal = analogRead(irReader);    // read the value from the ir sensor
  delay(50);
//  if( irVal>254) return;
} while( irVal>irRange  );
delay (angle);               // wait for a while (angle in mSeconds)              
}

void rot_ccwR ( int angle, int vel) {        // rotate counter-clock-wise: right-hand motor forward, left-hand motor reversed
  digitalWrite (dirA, fwdA); 
  digitalWrite (dirB, revB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 

do {
  irVal = analogRead(irReader);    // read the value from the ir sensor
delay(50);
//if(irVal>254) return;
} while( irVal>irRange );
delay (angle);               // wait for a while (angle in mSeconds)              
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
do {
  
  irVal = analogRead(irReader);    // read the value from the ir sensor

  lineAVal = lineABase - analogRead(lineA);    // read the value from the ir sensor
  lineBVal = lineBBase - analogRead(lineB);    // read the value from the ir sensor
  
  Serial.print( "Distance, Line A Var, Line B Var:");
  Serial.print( irVal);
  Serial.print( " ");
  Serial.print( lineAVal);
  Serial.print( " ");
  Serial.print( lineBVal);
  Serial.println();

  if( sensorMode == 1 ) return ;

} while( irVal < irRange ) ;

}



int step = 0;
int thisStep=0;
int inRotate=0;
int inRotateCW=0;

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
  
//  if( irVal > irDarkness ) {
//     do {
//    stop();
//    ir_sensor();
//     } while( irVal > irDarkness ) ;
//  }
  
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

      Serial.print( "Run away!");
      Serial.println();

      // BUG: set block on map
    //  reverse(2000, turnSpeed);
      if( random(2) == 1 )   {    
        Serial.print( "ccwR");
        Serial.println();
        rot_ccwR( 250, turnSpeed ) ; // point somewhere else to go
 
//        rot_ccw( 1000, turnSpeed ) ; // point somewhere else to go
 
 
      }
     else {
        Serial.print( "cwR");
        Serial.println();

        rot_cwR( 250, turnSpeed ) ; // point somewhere else to go
      }
  }
 
   
} 





