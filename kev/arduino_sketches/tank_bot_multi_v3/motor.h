// Motor 

// define the pins used by the motor shield

#define speedA  10          // pin 10 sets the speed of motor A (this is a PWM output)
#define speedB  11          // pin 11 sets the speed of motor B (this is a PWM output) 
#define dirA    12            // pin 12 sets the direction of motor A
#define dirB    13            // pin 13 sets the direction of motor B


// Motor speed control

#define normMoveSpeed 180 
#define normTurnSpeed 230 
#define normTurnTime 230 

#define lineMoveSpeed 100
//180
#define lineTurnSpeed 150 
#define lineTurnTime 230 

// define the direction of motor rotation - this allows you change the  direction without effecting the hardware
#define fwdA    HIGH         // this sketch assumes that motor A is the right-hand motor of your robot (looking from the back of your robot)
#define revA    LOW        // (note this should ALWAYS be opposite the fwdA)
#define fwdB    HIGH         //
#define revB    LOW        // (note this should ALWAYS be opposite the fwdB)

//////////////////////////////////////////////////////////////////
// Signal to motor controller what to do
//////////////////////////////////////////////////////////////////

//#define MOTOR_STOPPED 0
//#define MOTOR_STARTED 1
//#define MOTOR_FORWARD 1
//#define MOTOR_STOPPING 2
//#define MOTOR_CW 3
//#define MOTOR_CCW 4

//int motor_state = MOTOR_STOPPED ;  
//long motor_timeout=0;  // used to signal a count down to stop
//long motor_timeout_timestamp = 0L ; 
int motor_turn_speed= normTurnSpeed;
int motor_move_speed= normMoveSpeed;

int motor_running ; // running time for motor 

int rotateLeft = 0; // counters for the rotary sensor
int rotateRight = 0;


