/*
  Adapted by Becky and Gummi for Music Hack Day Iceland
 
 from:
 Nathan Seidle
 SparkFun Electronics 2011
 
 For the data pins, please pay attention to the arrow printed on the strip. You will need to connect to
 the end that is the begining of the arrows (data connection)--->
 
 If you have a 4-pin connection:
 Blue = 5V
 Red = SDI
 Green = CKI
 Black = GND
 
 If you have a split 5-pin connection:
 2-pin Red+Black = 5V/GND
 Green = CKI
 Red = SDI
 */

int SDI = 6; //Red wire (not the red 5V wire!)
int CKI = 7; //Green wire
int ledPin = 13; //On board LED

#define STRIP_LENGTH 448 //32 LEDs per strip and 14 strips
long strip_colors[STRIP_LENGTH];

long inByte = 65280;
long bg = 0x050505;

/**********************************************************
 *  setup
 **********************************************************/
void setup() {
  pinMode(SDI, OUTPUT);
  pinMode(CKI, OUTPUT);
  pinMode(ledPin, OUTPUT);

  //Clear out the array
  for(int x = 0 ; x < STRIP_LENGTH ; x++)
    strip_colors[x] = 0;
   
  post_frame();

  Serial.begin(9600);
  Serial.println("Hello!");
}


/**********************************************************
 *  loop
 **********************************************************/
int i = 0;
int green_line_offset = 0;

void loop() {
  //Pre-fill the color array with known values
  /*for(int i=0; i<STRIP_LENGTH; i++) {
    
      strip_colors[i] = bg; 
  }


  for (int y=green_line_offset; y<STRIP_LENGTH; y=y+32) {
    //strip_colors[mapToLine(y)] = 0x00FF00;
   strip_colors[mapToLine(y)] = inByte; 
  }

  strip_colors[i] = 0x66F084; //Bright Red
  strip_colors[(i+1)%STRIP_LENGTH] = 0x30D154; 
  strip_colors[(i+2)%STRIP_LENGTH] = 0x309CD1; 
  strip_colors[(i+3)%STRIP_LENGTH] = 0xAA33F8; 
  post_frame(); //Push the current color frame to the strip

  i = (i+1)%STRIP_LENGTH;
  green_line_offset = (green_line_offset+1)%32;*/

  delay(1);
}

/**********************************************************
 *  mapToLine
 **********************************************************/
int mapToLine(int unmapped) {
  int mapped = unmapped;
  if( unmapped%64-31 > 0 ) {
    mapped = unmapped/32*64-unmapped+31;
  }
  return mapped;
}

/**********************************************************
 *  serialEvent
 **********************************************************/
void serialEvent() {
  int i = 0;
  while (Serial.available()) {
    
    strip_colors[mapToLine(i)] = Serial.parseInt(); 
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    //if (Serial.read() == '\n') {
      //stringComplete = true;
    //} 
    i = (i+1)%STRIP_LENGTH;
  }
  
  post_frame();
}

/**********************************************************
 *  post_frame
 **********************************************************/
//Takes the current strip color array and pushes it out
void post_frame (void) {
  //Each LED requires 24 bits of data
  //MSB: R7, R6, R5..., G7, G6..., B7, B6... B0 
  //Once the 24 bits have been delivered, the IC immediately relays these bits to its neighbor
  //Pulling the clock low for 500us or more causes the IC to post the data.

  for(int LED_number = 0 ; LED_number < STRIP_LENGTH ; LED_number++) {
    long this_led_color = strip_colors[LED_number]; //24 bits of color data

    for(byte color_bit = 23 ; color_bit != 255 ; color_bit--) {
      //Feed color bit 23 first (red data MSB)

      digitalWrite(CKI, LOW); //Only change data when clock is low

      long mask = 1L << color_bit;
      //The 1'L' forces the 1 to start as a 32 bit number, otherwise it defaults to 16-bit.

      if(this_led_color & mask) 
        digitalWrite(SDI, HIGH);
      else
        digitalWrite(SDI, LOW);

      digitalWrite(CKI, HIGH); //Data is latched when clock goes high
    }
  }

  //Pull clock low to put strip into reset/post mode
  digitalWrite(CKI, LOW);
  delayMicroseconds(500); //Wait for 500us to go into reset
}

