import processing.serial.*;
import com.echonest.api.v4.EchoNestAPI;
import com.echonest.api.v4.EchoNestException;
import com.echonest.api.v4.Params;
import com.echonest.api.v4.Artist;
import java.util.List;


import controlP5.*;
ControlP5 controlP5;
boolean drawTextbox = true;

String textValue = "";
Textfield myTextfield;

// The Echo Nest things
String api_key = "get your own";
EchoNestAPI en;
boolean trace = false;

List<com.echonest.api.v4.Image> artistImages;
Iterator<com.echonest.api.v4.Image> imageIterator;


// The serial port:
Serial myPort;


int [] pixelsArray;  
int pixelsLength = 448;

color c;

PImage pict;


/**********************************************************
 *  setup
 **********************************************************/
void setup() {

  size(500, 700);
  // List all the available serial ports:
  println(Serial.list());

  // You may need to change the number in [ ] to match 
  // the correct port for your system
  myPort = new Serial(this, Serial.list()[0], 9600);

  pixelsArray = new int[pixelsLength];

  background(color(0x59DB0F));

  for ( int i=0; i<pixelsLength-1; i++) {
    pixelsArray[i] = 0;
  }


  // The EN
  en = new EchoNestAPI(api_key);
  en.setTraceSends(trace);
  en.setTraceRecvs(trace);
  en.setMinCommandTime(0);


  /*String name = "Bjork";
   int results = 3;
   Params p = new Params();
   p.add("name", name);
   p.add("results", 1);
   
   try {
   List<Artist> artists = en.searchArtists(p);
   
   println("Images of " + artists.get(0).getName());
   
   List<com.echonest.api.v4.Image> artistImages = artists.get(0).getImages();
   imageIterator = artistImages.iterator();    // create an iterator over the elements
   } 
   catch (EchoNestException e) {
   println("error, oops");
   e.printStackTrace();
   }*/



  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);
  myTextfield = controlP5.addTextfield("enter artist", 100, 260, 200, 20);
  myTextfield.setFocus(true);

  // change the image mode so that images are placed according to their center
  imageMode(CENTER); 
  background(102);
  fill(204);
  text("Press spacebar to choose image and enter to upload to wall...", 55, 200);
}

/**********************************************************
 *  draw
 **********************************************************/
void draw() {
  if (drawTextbox) {
    controlP5.draw();
  }
}

/**********************************************************
 *  setImage
 **********************************************************/
void setImage() {
  int i = 0;
  for (int w=width-1; w>0; w-=width/13) {
    for ( int h = height-1; h>0; h-=height/31) {
      pixelsArray[i] = convertColor(get( w, h ));
      i++;
      //println(pixelsArray[i-1]);
    }
  }
}

/**********************************************************
 *  convertColor
 **********************************************************/
int convertColor(color inputColor) {
  int convertedColor = (inputColor ) & 0x00FFFFFF;
  return convertedColor;
}


/**********************************************************
 *  mouseClicked
 **********************************************************/
void mouseClicked() {
}

/**********************************************************
 *  keyPressed
 **********************************************************/
void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT || keyCode == RIGHT) {
      {
        drawNextImage();
      }
    }


    if (keyCode == UP) 
    {
      setImage();
      for ( int i=0; i<pixelsLength; i++) {
        String s = str(pixelsArray[i]);
        myPort.write(s); 
        myPort.write(',');
      }


      println("pushed data");
    }
  }
}

/**********************************************************
 *  controlEvent
 **********************************************************/
void controlEvent(ControlEvent theEvent) {
  println("controlEvent: accessing a string from controller '"+theEvent.controller().name()+"': "+theEvent.controller().stringValue());
  String name = theEvent.controller().stringValue();

  //String name = "Bjork";
  int results = 3;
  Params p = new Params();
  p.add("name", name);
  p.add("results", 1);

  try {
    List<Artist> artists = en.searchArtists(p);

    println("Images of " + artists.get(0).getName());

    List<com.echonest.api.v4.Image> artistImages = artists.get(0).getImages();
    imageIterator = artistImages.iterator();    // create an iterator over the elements
  } 
  catch (EchoNestException e) {
    println("error, oops");
    e.printStackTrace();
  }

  drawNextImage();
  drawTextbox = false;
}

/**********************************************************
 *  drawNextImage
 **********************************************************/
void drawNextImage() {
  background(102);  // clear the window and set the background to a nice grey

  PImage picture;  // declare a PImage to hold album covers
  com.echonest.api.v4.Image currentImage;

  if (imageIterator.hasNext())
  {
    currentImage = imageIterator.next();  // get the next image from the iterator and store it in 'a'

    // retrieve the image and store it in currentImage
    picture = loadImage(currentImage.getURL());

    // display the picture in the center of the window
    image(picture, width/2, height/2);
  }
}

