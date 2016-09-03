#define MAX_NUM_TIMESLOTS 10

volatile static voidFuncPtr timeslotFunc[MAX_NUM_TIMESLOTS];
long timeouts[MAX_NUM_TIMESLOTS];
long timestamps[MAX_NUM_TIMESLOTS];

void attachTask(int, void (*)(void), long);

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
    timeouts[index] = newTO;
  }
}

void loop(){
  for(int i=0;i<MAX_NUM_TIMESLOTS;i++){
    if(timeouts[i] > 0){
      if((millis()-timestamps[i]) > timeouts[i]){
        timestamps[i] = millis();
        timeslotFunc[i]();
      }
    }
  }
}
