// music

// TONES ==========================================
// Start by defining the relationship between
//       note, period, & frequency.
#define TONE_C      3830    // 261 Hz
#define TONE_D      3400    // 294 Hz
#define TONE_E      3038    // 329 Hz
#define TONE_F      2864    // 349 Hz
#define TONE_G      2550    // 392 Hz
#define TONE_A      2272    // 440 Hz
#define TONE_B      2028    // 493 Hz
#define TONE_HC      1912    // 523 Hz
// Define a special note, 'R', to represent a rest
#define TONE_REST      0


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


long sound_duration = 0L ;
int sound_tone = 0 ;
long sound_duration_remaining = 0L ;

// PLAY TONE ==============================================
// Pulse the speaker to play a tone for a particular duration

long tone_elapsed_time = 0;
int tone_ct=0;

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


void task_sound_processing(int slice ) {
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




