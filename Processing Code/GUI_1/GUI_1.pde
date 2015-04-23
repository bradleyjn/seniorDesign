
/*
Osilliscope GUI
ECE 258
Spring 2015
David Kaplan & Bradley Natarian
*/

import controlP5.*;
import processing.serial.*;
import java.lang.Math;

ControlP5 cp5;

float vertPos, horPos;
int timeDiv, voltsDiv;
float vVal, hVal, vcVal;
int trigger, Hslider1, Hslider2, Vslider1, Vslider2;
boolean Tcursor1, Tcursor2, Vcursor1, Vcursor2;
PFont f;
float vScale, tScale;
float v1, v2, dv, t1, t2, dt, freq;
float offset;
String vVal2, hVal2;

Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[] values;

void setup() {
  
  size(1900,950); //size of window
  cp5 = new ControlP5(this); //controll object
  
  cp5.addSlider("vertPos") //vertPos slider
     .setPosition(1250,25)
     .setRange(0,1024)
     .setSize(20,900)
     .setValue(512)
     ;
  
  //sets label at top and no value   
  cp5.getController("vertPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);   
  cp5.getController("vertPos").getValueLabel().setVisible(false);
  
    
  cp5.addSlider("horPos") //horPos slider
     .setPosition(1360,25)
     .setWidth(515)
     .setHeight(20)
     .setRange(0,1024)
     .setValue(512)
     ;
  
  //sets label at top and no value
  cp5.getController("horPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("horPos").getValueLabel().setVisible(false); 
  
  
  cp5.addSlider("voltsDiv") //voltsDiv slider
     .setPosition(1360,175)
     .setWidth(515)
     .setRange(0,255)
     .setValue(153)
     .setHeight(20)
     .setNumberOfTickMarks(6)
     .setSliderMode(Slider.FLEXIBLE)
     ;
     
  //sets label top
  cp5.getController("voltsDiv").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("voltsDiv").getValueLabel().setVisible(false); 
  

  cp5.addSlider("timeDiv") //timeDiv slider
     .setPosition(1360,105)
     .setWidth(515)
     .setHeight(20)
     .setRange(0,255)
     .setValue(148)
     .setNumberOfTickMarks(13)
     .setSliderMode(Slider.FLEXIBLE)
     ;

  //sets lable at top
  cp5.getController("timeDiv").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("timeDiv").getValueLabel().setVisible(false); 
    
  cp5.addSlider("trigger") //trigger slider
     .setPosition(1300,25)
     .setWidth(20)
     .setHeight(900)
     .setRange(925,25)
     .setValue(475)
     ;

  //sets label at top and no value
  cp5.getController("trigger").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("trigger").getValueLabel().setVisible(false);


  cp5.addToggle("Tcursor1") //toggle for time 1
     .setPosition(1470,250)
     .setSize(70,30)
     .setMode(ControlP5.SWITCH)
     ;
    
  cp5.addToggle("Tcursor2") //toggle for time 2
     .setPosition(1570,250)
     .setSize(70,30)
     .setMode(ControlP5.SWITCH)
     ;

  cp5.addToggle("Vcursor1") //toggle for volts 1
     .setPosition(1670,250)
     .setSize(70,30)
     .setMode(ControlP5.SWITCH)
     ;    

  cp5.addToggle("Vcursor2") //toggle for volts 2
     .setPosition(1770,250)
     .setSize(70,30)
     .setMode(ControlP5.SWITCH)
     ;
    
  cp5.addSlider("Vslider1") //slider along with Vcursor1 for volts 1
     .setPosition(1360,400)
     .setWidth(20)
     .setHeight(525)
     .setRange(925,25)
     .setValue(475)
     .setVisible(false)
     ; 

  cp5.getController("Vslider1").getValueLabel().setVisible(false);

  cp5.addSlider("Vslider2") //slider along with Vcursor2 for volts 2 
     .setPosition(1410,400)
     .setWidth(20)
     .setHeight(525)
     .setRange(925,25)
     .setValue(475)
     .setVisible(false)
     ; 
     
  cp5.getController("Vslider2").getValueLabel().setVisible(false);

    
  cp5.addSlider("Hslider1") //slider along with Tcursor1 for time 1
     .setPosition(1460,310)
     .setWidth(400)
     .setHeight(20)
     .setRange(25,1225)
     .setValue(625)
     .setVisible(false)
     ; 

  cp5.getController("Hslider1").getValueLabel().setVisible(false);


  cp5.addSlider("Hslider2") //slider along with Tcursor2 for time 2 
     .setPosition(1460,350)
     .setWidth(400)
     .setHeight(20)
     .setRange(25,1225)
     .setValue(625)
     .setVisible(false)
     ;     
 
  cp5.getController("Hslider2").getValueLabel().setVisible(false);
   

  
  cp5.addBang("ZeroH",1360,52,25,25); //bang for zero the horPos
  
  cp5.addBang("ZeroV",1360,330,25,25); //bang for zero the vertPos
  cp5.getController("ZeroV").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0); //lable at top
  
  cp5.addBang("Reset",1360,270,25,25);//bang for trigger reset
  cp5.getController("Reset").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0); //label at top
    
  
  f = createFont("Arial",16,true); //creates font class
  
  //serial link setup
  port = new Serial(this, "COM30", 115200);
  values = new int[1200];
  smooth();
  
} //end setup


//getY method
int getY(int val) {
  int y = Math.round(-112.5f*((-10/vScale)*(.0078431373f*val-1)) + 475.5);
  return y;
}


//events for zero vertPos bang
public void ZeroV(int theValue) {
  println("event from ZeroV");
  cp5.controller("vertPos").setValue(512);
}

//events for reset trigger bang
public void Reset(int theValue) {
  println("event from reset");
  cp5.controller("trigger").setValue(475);
}

//events for zero horPos bang
public void ZeroH(int theValue) {
  println("event from ZeroH");
  cp5.controller("horPos").setValue(512);
}

//events for vertPos slider
public void vertPos(int theValue) {
  println("event from verPos");
}

//evets for voltsDiv
public void voltsDiv(int theValue) {
  switch (theValue) {
    case 0:
      vScale = .1;
      break;
    case 51:
      vScale = .2;
      break;
    case 102:
      vScale = .5;
      break;
    case 153:
      vScale = 1;
      break;
    case 204:
      vScale = 2;
      break;
    case 255:
      vScale = 5;
      break;
  }
}

//events for timeDiv
public void timeDiv(int theValue) {
  switch (theValue) {
    case 0:
      tScale = .005;
      break;
    case 21:
      tScale = .01;
      break;
    case 42:
      tScale = .02;
      break;
    case 63:
      tScale = .05;
      break;
    case 85:
      tScale = .1;
      break;
    case 106:
      tScale = .2;
      break;
    case 127:
      tScale = .5;
      break;
    case 148:
      tScale = 1;
      break;
    case 170:
      tScale = 2;
      break;
    case 191:
      tScale = 5;
      break;
    case 212:
      tScale = 10;
      break;
    case 233:
      tScale = 20;
      break;
    case 255:
      tScale = 50;
      break;
  }
}

//events for volts 1 toggle
public void Vcursor1(boolean flag) {
  if (flag == true) {
    cp5.controller("Vslider1").setVisible(true);
    Vcursor1 = true;
  } else {
    cp5.controller("Vslider1").setVisible(false);
    Vcursor1 = false;
  }
}

//events for volts 2 toggle
public void Vcursor2(boolean flag) {
  if (flag == true) {
    cp5.controller("Vslider2").setVisible(true);
    Vcursor2 = true;
  } else {
    cp5.controller("Vslider2").setVisible(false);
    Vcursor2 = false;
  }
}

//events for time 1 toggle
public void Tcursor1(boolean flag) {
  if (flag == true) {
    cp5.controller("Hslider1").setVisible(true);
    Tcursor1 = true;
  } else {
    cp5.controller("Hslider1").setVisible(false);
    Tcursor1 = false;
  }
}

//events for time 2 toggle
public void Tcursor2(boolean flag) {
  if (flag == true) {
    cp5.controller("Hslider2").setVisible(true);
    Tcursor2 = true;
  } else {
    cp5.controller("Hslider2").setVisible(false);
    Tcursor2 = false;
  }
}

void draw() {
  
  background(120); //light grey backgroung
 
  strokeWeight(1);
  stroke(0);
  rect(1460,400,400,525); //white info box in bottom right
  
  //text for volts and time div position info
  textFont(f,12);
  fill(255);
  text("100mV",1352,217);
  text("200mV",1450,217);
  text("500mV",1548,217);
  text("1V",1660,217);
  text("2V",1762,217);
  text("5V",1864,217);
  
  textFont(f,12);
  fill(255);
  text("5us",1353,147);
  text("10us",1392,147);
  text("20us",1440,147);
  text("50us",1485,147);
  text("100us",1522,147);
  text("200us",1564,147);
  text("500us",1603,147);
  text("1ms",1648,147);
  text("2ms",1689,147);
  text("5ms",1731,147);
  text("10ms",1771,147);
  text("20ms",1812,147);
  text("50ms",1854,147);

  //gets values from sliders
  trigger = Math.round(cp5.getController("trigger").getValue());
  vertPos = cp5.getController("vertPos").getValue();
  horPos = cp5.getController("horPos").getValue();
  voltsDiv = Math.round(cp5.getController("voltsDiv").getValue());
  timeDiv = Math.round(cp5.getController("timeDiv").getValue());
  Hslider1 = Math.round(cp5.getController("Hslider1").getValue());
  Hslider2 = Math.round(cp5.getController("Hslider2").getValue());
  Vslider1 = Math.round(cp5.getController("Vslider1").getValue());
  Vslider2 = Math.round(cp5.getController("Vslider2").getValue());  
  
  //math for offset and delay
  hVal = ((horPos*.009765625) - 5)*tScale;
  vVal = ((vertPos*.0078125) - 4)*vScale;
  
  offset = ((vertPos*.87890625)+25);
  
  vcVal = (vertPos*.87890625) - 450;
  
  //draw screen in colors of sliders
  fill(128,150,140);
  rect(25,25,1200,900);
  
  //black axes 
  stroke(0);
  strokeWeight(1.5);
  line(25,475,1225,475); // x-axis
  line(625,25,625,925); // y-axis
  
  //grey gridlines
  stroke(100);
  strokeWeight(1);
  line(25,137.5,1225,137.5);
  line(25,250,1225,250);
  line(25,362.5,1225,362.5);
  line(25,587.5,1225,587.5);
  line(25,700,1225,700);
  line(25,812.5,1225,812.5);
  
  line(145,25,145,925);
  line(265,25,265,925);
  line(385,25,385,925);
  line(505,25,505,925);
  line(745,25,745,925);
  line(865,25,865,925);
  line(985,25,985,925);
  line(1105,25,1105,925);
  
  //black trigger line
  stroke(0);
  strokeWeight(1.5);
  line(25,trigger,1225,trigger); //draws trigger line at vert position of trigger
  
  stroke(245,245,40); //bright yellow for cursor lines
  textFont(f,16);
  fill(0);
  
  //logic for trigger lines and text and such
  if (Tcursor1==true) {
    line(Hslider1,25,Hslider1,925);
    t1 = ((.0083333333)*(Hslider1-25) - 5)*tScale;
    String t1_1 = String.format("%.3f", t1);
    text("Time 1 = "+t1_1+" ms",1490,440);
  }
  
  if (Tcursor2==true) {
    line(Hslider2,25,Hslider2,925);
    t2 = ((.0083333333)*(Hslider2-25) - 5)*tScale;
    String t2_2 = String.format("%.3f", t2);
    text("Time 2 = "+t2_2+" ms",1490,470);
  }  

  if ((Tcursor1==true) && (Tcursor2==true)) {
    dt = Math.abs(t1-t2);
    freq = (1/dt)*1000;
    String dt_1 = String.format("%.3f", dt);
    String freq_1 = String.format("%.2f", freq);
    text("\u0394 Time = "+dt_1+" ms",1490,500);
    text("Freq = "+(freq_1)+" Hz",1490,530);
  }

  if (Vcursor1==true) {
    float y1 = Vslider1 - vcVal;
    float y2 = Vslider1 - vcVal;
    y1 = constrain(y1, 26, 924);
    y2 = constrain(y2, 26, 924);
    line(25,y1,1225,y2);
    v1 = ((-.0088888888)*(Vslider1-25) + 4)*vScale;
    String v1_1 = String.format("%.3f", v1);
    text("Voltage 1 = "+v1_1+" V",1650,440);
  }
  
  if (Vcursor2==true) {
    float y1 = Vslider2 - vcVal;
    float y2 = Vslider2 - vcVal;
    y1 = constrain(y1, 26, 924);
    y2 = constrain(y2, 26, 924);
    line(25,y1,1225,y2);
    v2 = ((-.0088888888)*(Vslider2-25) + 4)*vScale;
    String v2_2 = String.format("%.3f", v2);
    text("Voltage 2 = "+v2_2+" V",1650,470);
  } 

  if ((Vcursor1==true) && (Vcursor2==true)) {
    dv = Math.abs(v1-v2);
    String dv_1 = String.format("%.3f", dv);
    text("\u0394 Voltage = "+dv_1+" V",1650,500);
  }
  
  //text for offset and delay
  textFont(f,14);
  vVal2 = String.format("%.3f", vVal);
  fill(255);
  text("Offset = "+vVal2+" V",1335,370);

  hVal2 = String.format("%.3f", hVal);
  text("Delay = "+hVal2,1400,70);
  
  
//draw signal
  
  while (port.available() >= 2) {
    if (port.read() == 0xff) {
      val = port.read();
      //println(val);
    }
  }
  for (int i=0; i<1200-1; i++)
    values[i] = values[i+1];
  values[1200-1] = val;
  stroke(180, 30, 30);
  strokeWeight(2);
  for (int x=1; x<1200-1; x++) {
    int x1 = 1200-x+25;
    int x2 = 1200-1-x+25;
    int y1 = 900+50-getY(values[x-1])+(475-Math.round(offset));
    int y2 = 900+50-getY(values[x])+(475-Math.round(offset));
    x1 = constrain(x1,26,1224);
    x2 = constrain(x2,26,1224);
    y1 = constrain(y1,26,924);
    y2 = constrain(y2,26,924);
    line(x1,y1,x2,y2);
  }

} //end draw


