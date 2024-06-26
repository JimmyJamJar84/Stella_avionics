/*
  Visualizing the MLX90640 Sensor Data using Processing
  By: Nick Poole
  SparkFun Electronics
  Date: June 5th, 2018
  
  MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this 
  software and associated documentation files (the "Software"), to deal in the Software without 
  restriction, including without limitation the rights to use, copy, modify, merge, publish, 
  distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
  Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or 
  substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
  Feel like supporting our work? Buy a board from SparkFun!
  https://www.sparkfun.com/products/14568
  
  This example is intended as a companion sketch to the Arduino sketch found in the same folder.
  Once the accompanying code is running on your hardware, run this Processing sketch. 
  This Processing sketch will receive the comma separated values generated by the Arduino code and
  use them to generate a thermal image. 
  
  IF this example code generates ArrayOutOfBounds exceptions, double check that you are running
  the correct Teensy example code and try again.
  
  Hardware Connections:
  Attach the Sensor to your Teensy 3.2 or later using
  a Qwiic breadboard cable
*/

import processing.serial.*;

String myString = null;
Serial myPort;  // The serial port

float[][] temps = new float[768][768];
String splitString[] = new String[1000];
float maxTemp = 0;
float minTemp = 500;
float circuitVoltage = 0;
char letters[] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
int loopCount = 0;
String status;
PrintWriter f;

// The statements in the setup() function execute once when the program begins
void setup() {
  size(480, 400);  // Size must be the first statement
  noStroke();
  frameRate(30);
  
  // Print a list of connected serial devices in the console
  printArray(Serial.list());
  // Depending on where your sensor falls on this list, you
  // may need to change Serial.list()[0] to a different number
  myPort = new Serial(this, Serial.list()[0], 115200);
  myPort.clear();
  // Throw out the first chunk in case we caught it in the 
  // middle of a frame
  myString = myPort.readStringUntil(13);
  myString = null;
  // change to HSB color mode, this will make it easier to color
  // code the temperature data
  colorMode(HSB, 360, 100, 100);
  
  f = createWriter("data1.txt");
  f.println("Location\tTemperature\tStatus");
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() { 
  // When there is a sizeable amount of data on the serial port read everything up to the first linefeed
  if(myPort.available() > 5000){
  myString = myPort.readStringUntil(13);
  // Limit the size of this array so that it doesn't throw OutOfBounds later when calling "splitTokens"
  if(myString.length() > 4608){
  myString = myString.substring(0, 4612);}
  // generate an array of strings that contains each of the commaseparated values
  splitString = splitTokens(myString, ",");

  // Reset our min and max temperatures per frame
  maxTemp = 0;
  minTemp = 500;
  // For each floating point value, double check that we've acquired a number,
  // then determine the min and max temperature values for this frame
  for(int q = 0; q < 768; q++){
    if(!Float.isNaN(float(splitString[q])) && float(splitString[q]) > maxTemp){
      maxTemp = float(splitString[q]);
    }else if (!Float.isNaN(float(splitString[q])) && float(splitString[q]) < minTemp){
      minTemp = float(splitString[q]);
    }
  }  
  if (myString.length() > 4608){
  if(!Float.isNaN(float(splitString[splitString.length-1]))){
      circuitVoltage = float(splitString[splitString.length-1]);
  }}
  // for each of the 768 values, map the temperatures between min and max to the blue through red portion of the color space
  for(int q = 0; q < 768; q++){
    if(!Float.isNaN(float(splitString[q]))){
    temps[q][0] = constrain(map(float(splitString[q]), minTemp, maxTemp, 180, 360),160,360);
    temps[q][1] = float(splitString[q]);
  }
    else{
    temps[q][0] = 0;
    temps[q][1] = 0;
    }
  }
  }
  // Prepare variables needed to draw our heatmap
  int x = 0;
  int y = 0;
  int i = 0;
  background(0);   // Clear the screen with a black background
 int xcount = 0;
 int ycount = 0;
 int j = 0;
 int k = 0;
 int newi = 0;
 float sum = 0;
 float[] sqrs = new float[1000];
  while(y < 360){
    // for each increment in the y direction, draw 8 boxes in the x direction, creating a 64 pixel matrix
    ycount++;
    while(x < 480){
      // before drawing each pixel, set our paintcan color to the appropriate mapped color value
      //fill(temps[i], 100, 100);
      //rect(x,y,15,15);
      xcount++;
      if (xcount < 23 && xcount > 1 && ycount < 23 && ycount > 1) {
          fill(temps[i][0], 100, 100);
          rect(x,y,15,15);
        if ((xcount % 4 == 0) && (ycount % 4 == 0)){
          for (j = 0; j < 4; j++){
            sqrs[k+j] = temps[i + j][1];
            sqrs[k+j+4] = temps[i + 20 + j][1];
            sqrs[k+j+8] = temps[i + 40 + j][1];
            sqrs[k+j+12] = temps[i + 60 + j][1];
          }
          k = k+16;
          if (newi == 0){
          newi = i;}
          }
      }
      i++;
      x = x + 15;
    }
    y = y + 15;
    x = 0;
    xcount = 0;
  }
  k = 0;

  for (i = 0; i < 25; i++) {  
    sum = 0;
    if ((i)%5 == 0){
    print("\n");}
    for (j = 0; j< 16; j++){
      sum = sum + sqrs[k + j];
    }
    if (sum/16 < 30){
      status = "Safe   ";
    } else if (sum/16 > 60){status = "On Fire";}
    else {status = "Warning";}
    print("\t",letters[i], ": ", nf(sum/16, 0, 2), '(', status, ')');
    if (loopCount>500){
      f.println("\t"+letters[i]+ "\t\t"+ nf(sum/16, 0, 2)+"\t\t"+ status);
      if (i == 24){
        print("\n**SAVING**\n");
        f.println("");
        f.close();
        loopCount = 0;
        exit();
    }
}
    k = k+16;
  }
  print("\nVoltage: ", circuitVoltage, "\n\n");
  loopCount++;

  //for (i = newi; i< newi + 80; i++){
  //  if ((i+1)%20 == 0){
  //  print("\n");}
  //  print(temps[i][1]);
  //  print(", ");}
  //print("\n\n");
 //for (i = 0; i< 60; i++){
 //    if (i%20 == 0){
 //       print("\n");}
 //     print(sqrs[i]);
 //     print(",, ");}
 // print("End\n\n");
 // if (temps[1] > 1){
 //   exit();}
    
    
  // Add a gaussian blur to the canvas in order to create a rough visual interpolation between pixels.
  //filter(BLUR,7);
  // Generate the legend on the bottom of the screen
  textSize(32);
  // Find the difference between the max and min temperatures in this frame
  float tempDif = maxTemp - minTemp; 
  // Find 5 intervals between the max and min
  int legendInterval = round(tempDif / 5); 
  // Set the first legend key to the min temp
  int legendTemp = round(minTemp);
  // Print each interval temperature in its corresponding heatmap color
  for(int intervals = 0; intervals < 6; intervals++){
  fill(constrain(map(legendTemp, minTemp, maxTemp, 180, 360),160,360), 100, 100);
  text(legendTemp+"°", 70*intervals, 390);
  legendTemp += legendInterval;
  }
  
} 
