import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

long timer;
int interval = 16;//400;
int data_index = 0;
int row = 0;
int column = 0;

float data_min = Float.MAX_VALUE;
float data_max = Float.MIN_VALUE;

float trees_sum = 0;
float trees_total_sum = 0;
float scaled_sum;

//String[] raw_data; 
//float[] processed_data; 

// Change variable here to manipulate different parameter in MadMapper
String messageChannel = "/medias/Deviled_Egg-1/Egg/Size";

String messageChannel_y = "/medias/Deviled_Egg-1/UV/Shift/y";
String messageChannel_x = "/medias/Deviled_Egg-1/UV/Shift/x";

float target_min = 0.0;
float target_max = 2.0;
///medias/Deviled_Egg/UV/Shift/xy /medias/Deviled_Egg/UV/Shift/x /medias/Deviled_Egg/UV/Shift/y

// Gradual scale factor
//float scale_factor = 0.0; // Starts at 0
//float scale_increment = 0.01; // Increment to control how fast the scale grows
boolean debug = true;

// noise movement
float xoff = 0.0;
float yoff = 0.5;


void setup() {
  println("numbersa [x][]", numbers.length);
  println("numbersa [][x]", numbers[0].length);
  //raw_data = loadStrings("tree.csv");
  //String[] data_strings = split(raw_data[0], ",");
  //processed_data = new float[data_strings.length];
  
  
  for (int r = 0; r < 23; r++){
    for(int c = 0; c < 365; c++){
      if (numbers[r][c] < data_min) data_min = numbers[r][c];
      if (numbers[r][c] > data_max) data_max = numbers[r][c];
      trees_total_sum += numbers[r][c];
    }
  }
  
  println("total sum", trees_total_sum);
  
  /*
  for (int i = 0; i < data_strings.length; i++) {
    processed_data[i] = float(data_strings[i]);
    if (processed_data[i] < data_min) data_min = processed_data[i];
    if (processed_data[i] > data_max) data_max = processed_data[i];
  }
  */
  
  
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("localhost", 8010);
  
  println("Data min: " + data_min + ", Data max: " + data_max);
  //println("Processed data loaded: " + processed_data.length + " entries.");
}

void draw() {
  println(frameRate);
  if (millis() > timer + interval) {
    timer = millis();
    
    println(millis());
    
    OscMessage myMessage = new OscMessage(messageChannel);
    trees_sum += numbers[row][column];
    // Calculate mapped value and apply scale factor - MODIFIED
    float data = map(trees_sum, 0, trees_total_sum, target_max, target_min);
    //float data = map(processed_data[data_index], data_min, data_max, target_min, target_max);
    //float scaled_data = constrain(data * scale_factor, target_min, target_max); // Ensure it stays in range
    
    //myMessage.add(scaled_data);
    myMessage.add(data);
    oscP5.send(myMessage, myRemoteLocation);
    
    // Calculate mapped value and apply scale factor - MODIFIED
    //data = map(numbers[row][column], data_min, data_max, target_min, target_max);
    //float data = map(processed_data[data_index], data_min, data_max, target_min, target_max);
    //scaled_data = constrain(data * scale_factor, target_min, target_max); // Ensure it stays in range
    
    //if (debug) println("Sending data index: " + data_index + ", value: " + scaled_data, data, scale_factor, "year (row)", row, "day (col)", column);
    if (debug) println("Sending data index: " + data_index + ", value: " + data, trees_sum, trees_total_sum, "year (row)", row, "day (col)", column);
    //myMessage.add(scaled_data);
    //oscP5.send(myMessage, myRemoteLocation);
    
    //text("Data Index: " + data_index + " Value: " + scaled_data, width / 2, height / 2);
    
    column++;
    //data_index++;
    if (column >= 365) {
      column = 0;
      row++;
      if (row >= 23) {
        row = 0;
        trees_sum = 0; // reset total trees cut sum
        delay(3000); // wait until restart of animation
      }
    }
    
    xoff = xoff + .005;
    yoff = yoff + .005;
    float nx = noise(xoff);
    float ny = noise(yoff);
    
    OscMessage myMessage_x = new OscMessage(messageChannel_x);
    myMessage_x.add(map(nx, 0, 1, -1.5, 1.5));
    oscP5.send(myMessage_x, myRemoteLocation);
    
    OscMessage myMessage_y = new OscMessage(messageChannel_y);
    myMessage_y.add(map(ny, 0, 1, -1.5, 1.5));
    oscP5.send(myMessage_y, myRemoteLocation);
    
    }
    /*
    if (data_index >= processed_data.length) {
      data_index = 0;
    }
    */
    
    // Gradually increase the scale factor up to 1.0
    /*
    if (scale_factor < 1.5) {
      scale_factor += scale_increment;
    }
    */
    
    
  }

void mousePressed() {
  OscMessage myMessage = new OscMessage("/medias/Sphere/Noise/Speed");
  myMessage.add(1.4);
  oscP5.send(myMessage, myRemoteLocation); 
}
