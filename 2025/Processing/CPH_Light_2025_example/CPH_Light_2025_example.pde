
// Process
//
// Get 'csv' datafile
// Refine data in 'csv' file
// Setup filtering in Processing code (individual depending on the datafile)
// Adjust simulation (e.g speed, jumps in timeline)
// Choose background visuals in MAdMapper
// Find the needed OSC addresses from MadMapper
// Find the input scale from MadMapper
// Adjust code with OSC address, and correct mapping of datavalue to fit MadMapper scale



import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

String [] raw_data;
FloatList filtered_data = new FloatList();

long timer;
int interval = 100;
int data_index;

float data_min = 999999999;
float data_max = -999999999;


void setup() {
  raw_data = loadStrings("carbon-monitor-data.csv");
  for (int i = 4; i < raw_data.length; i+=6){ // '4' is the first row with relevant data (international aviation) '+=6' is because there only is relevant data on every 6th row in the data file
    float data = float(split(raw_data[i], ";")[3]);
    filtered_data.append(data); // '[3]' is the position of the relevant data after 'split()' returns a row as an array
    if (data < data_min) data_min = data;
    if (data > data_max) data_max = data;
  }
  println("min", data_min, "max", data_max);
  oscP5 = new OscP5(this,12000); // creating the OSC object
  myRemoteLocation = new NetAddress("localhost", 8010); // setting up the receiver (MadMapper) IP and Port info
  
  /*
  //Used to validate the filtering was correct by comparing to values in datafile
  println(0, filtered_data.get(0));
  println(1, filtered_data.get(1));
  println(2, filtered_data.get(2));
  println(filtered_data.size()-2, filtered_data.get(filtered_data.size()-2));
  println(filtered_data.size()-1, filtered_data.get(filtered_data.size()-1));
  */
}

void draw() {
  
  if (millis() > timer + interval){ // timer
    timer = millis();
    
    OscMessage myMessage = new OscMessage("/medias/Sphere/Noise/Speed");
    float data = map(filtered_data.get(data_index), data_min, data_max, 0.0, 2); // mapping from dataset scale to MadMapper controller scale
    println(data_index, data);
    myMessage.add(data); // add data to the OSC message
    oscP5.send(myMessage, myRemoteLocation); 
    
    // do this as the last thing in the timer
    data_index += 1; // '+=1' increments with one row in the filtered_data array
    if (data_index > filtered_data.size()-1) data_index = 0; // reste to first data row
  }
}

void mousePressed() {
  OscMessage myMessage = new OscMessage("/medias/Sphere/Noise/Speed");
  myMessage.add(1.4);
  oscP5.send(myMessage, myRemoteLocation); 
}
