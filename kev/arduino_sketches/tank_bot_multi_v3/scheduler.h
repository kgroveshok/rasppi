#define MAX_NUM_TIMESLOTS 12

static void (*timeslotFunc[MAX_NUM_TIMESLOTS])(int);
long timeouts[MAX_NUM_TIMESLOTS];
long timestamps[MAX_NUM_TIMESLOTS];

long corestamp ;
int usedslots = 0;
int wastetime = 0; 

void attachTask(int, void (*)(void), long);



