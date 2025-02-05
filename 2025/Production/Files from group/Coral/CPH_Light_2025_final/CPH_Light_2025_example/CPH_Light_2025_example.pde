
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
int interval = 10;
int data_index = 0;
float transition_progress = 0.0;
float transition_speed = 0.1;

float data_min = 999999999;
float data_max = -999999999;

void setup() {
    raw_data = loadStrings("global_temps.csv");

    print(raw_data.length);
    for (int i = 1; i < raw_data.length; i++) {
        float data = float(split(raw_data[i], ",")[1]);
        filtered_data.append(data);
        if (data < data_min) data_min = data;
        if (data > data_max) data_max = data;
    }
    println("min", data_min, "max", data_max);
    oscP5 = new OscP5(this, 12000);
    myRemoteLocation = new NetAddress("localhost", 8010);
}

void draw() {
    OscMessage myMessageMadNoise1GlobalSpeed = new OscMessage("/medias/MadNoise-1/Global_Speed");
    OscMessage myMessageMadNoise1Brightness = new OscMessage("/medias/MadNoise-1/Color/Brightness");
    OscMessage myMessageMadNoise2GlobalSpeed = new OscMessage("/medias/MadNoise-2/Global_Speed");
    OscMessage myMessageMadNoise2Brightness = new OscMessage("/medias/MadNoise-2/Color/Brightness");
    OscMessage myMessageMadNoise3GlobalSpeed = new OscMessage("/medias/MadNoise-3/Global_Speed");
    OscMessage myMessageMadNoise3Brightness = new OscMessage("/medias/MadNoise-3/Color/Brightness");
    OscMessage myMessageMadNoise4GlobalSpeed = new OscMessage("/medias/MadNoise-4/Global_Speed");
    OscMessage myMessageMadNoise4Brightness = new OscMessage("/medias/MadNoise-4/Color/Brightness");

    float old_data = map(filtered_data.get((data_index - 1 < 0) ? filtered_data.size() - 1 : data_index - 1), data_min, data_max, 0.0, 2.0);
    float new_data = map(filtered_data.get(data_index), data_min, data_max, 0.0, 2.0);

    float smooth_data = lerp(old_data, new_data, transition_progress);
    float smooth_data_percentage = map(smooth_data, 0.0, 2.0, 0.0, 1.0);

    if (millis() > timer + interval) {
        println(data_index, smooth_data);
        
        myMessageMadNoise1GlobalSpeed.add(smooth_data); 
        myMessageMadNoise1Brightness.add(smooth_data_percentage); 
        myMessageMadNoise2GlobalSpeed.add(smooth_data); 
        myMessageMadNoise2Brightness.add(smooth_data_percentage);         
        myMessageMadNoise3GlobalSpeed.add(smooth_data); 
        myMessageMadNoise3Brightness.add(smooth_data_percentage);         
        myMessageMadNoise4GlobalSpeed.add(smooth_data); 
        myMessageMadNoise4Brightness.add(smooth_data_percentage); 
        
        oscP5.send(myMessageMadNoise1GlobalSpeed, myRemoteLocation); 
        oscP5.send(myMessageMadNoise1Brightness, myRemoteLocation); 
        oscP5.send(myMessageMadNoise2GlobalSpeed, myRemoteLocation); 
        oscP5.send(myMessageMadNoise2Brightness, myRemoteLocation);
        oscP5.send(myMessageMadNoise3GlobalSpeed, myRemoteLocation); 
        oscP5.send(myMessageMadNoise3Brightness, myRemoteLocation);
        oscP5.send(myMessageMadNoise4GlobalSpeed, myRemoteLocation); 
        oscP5.send(myMessageMadNoise4Brightness, myRemoteLocation);

        transition_progress += transition_speed;

        if (transition_progress >= 1.0) {
            transition_progress = 0.0;
            data_index = (data_index + 1 >= filtered_data.size()) ? 0 : data_index + 1;
        }

        timer = millis();
    }
}

void mousePressed() {
    OscMessage myMessage = new OscMessage("");
    myMessage.add(1.4);
    oscP5.send(myMessage, myRemoteLocation);
}
