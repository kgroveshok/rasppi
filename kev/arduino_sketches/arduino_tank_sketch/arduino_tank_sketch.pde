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
int turnSpeed=220;

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
int irRange=250;

/* Map */

int roomWidth=20;
int roomLength=20;
byte roomMap[20*20];
/* map flags:

0 = nothing there, not looked yet
1 = been there
2 = been there but it's blocked 
3 = home is set here


*/



void setup() {                             // sets up the pinModes for the pins we are using
  pinMode (dirA, OUTPUT);         
  pinMode (dirB, OUTPUT); 
  pinMode (speedA, OUTPUT); 
  pinMode (speedB, OUTPUT); 
  Serial.begin(9600);  
  randomSeed(2);
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

void rot_cwR ( int angle, int vel) {         // rotate clock-wise: right-hand motor reversed, left-hand motor forward
  digitalWrite (dirA, revA); 
  digitalWrite (dirB, fwdB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 

delay (angle);               // wait for a while (angle in mSeconds)              
}

void rot_ccwR ( int angle, int vel) {        // rotate counter-clock-wise: right-hand motor forward, left-hand motor reversed
  digitalWrite (dirA, fwdA); 
  digitalWrite (dirB, revB);
  analogWrite (speedA, vel);   // both motors set to same speed
  analogWrite (speedB, vel); 

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


/*

Control Id:
1 - forward
2 - turn cw
3 - turn ccw
4 - turn 180
5 - pause 1s
6 - reverse
*/

int track[] = {
1,
2,
1,
2,
1,
2,
1,
2,
5,
1,
3,
1,
3,
1,
3,
1,
3,
5,
0
};

int step = 0;
int thisStep=0;
int inRotate=0;
int inRotateCW=0;

void loop() { 

  
  thisStep=track[step];

  Serial.print("Step: ");
  Serial.print(step);
  Serial.print(" action ");
  Serial.print( thisStep );
  Serial.println();


  switch( thisStep ) {
    case 0:
      step=0;
      break;
    case 1:
      forward (1000, moveSpeed);    // move forward for four seconds (4000 mS) at speed 100 (100/255ths of full speed)
      // BUG: set map location

      break;
    case 2:
      rot_cw (2000, turnSpeed);      // rotate clock-wise for 2000 mS (about 90 deg) at speed 100
      // BUG: set map location

      break;
    case 3:
      rot_ccw (2000, turnSpeed);     // rotate counter clock-wise for 2000 mS at speed 100
      // BUG: set map location

      break;
    case 4:  
      about_turn();
      // BUG: set map location

      break;
    case 5:
      delay(1000);
      break;
    case 6:
      reverse (1000, turnSpeed);    // move forward for four seconds (4000 mS) at speed 100 (100/255ths of full speed)
      // BUG: set map location
stop();
      break;
  }
 stop();                 // stop the robot
 step++;
   
} 





