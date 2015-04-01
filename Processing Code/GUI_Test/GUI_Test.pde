
/**
 * ControlP5 Slider. Horizontal and vertical sliders, 
 * with and without tick marks and snap-to-tick behavior.
 * by andreas schlegel, 2010
 */

/**
* ControlP5 Slider
*
* Horizontal and vertical sliders, 
* With and without tick marks and snap-to-tick behavior.
*
* find a list of public methods available for the Slider Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/

import controlP5.*;
import processing.serial.*;

ControlP5 cp5;
int myColor = color(0,0,0);

float vertPos = 100;
int voltsDiv = 100;
int timeDiv = 30;
float horPos = 128;
float vVal = 128;
float hVal = 128;
float trigger, Hslider1, Hslider2, Vslider1, Vslider2;
boolean Tcursor1, Tcursor2, Vcursor1, Vcursor2;
PFont f;
String vVal2, hVal2;
Slider abc;

Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[] values;

void setup() {
  size(1900,950);
  noStroke();
  cp5 = new ControlP5(this);
  
  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("vertPos")
     .setPosition(1250,25)
     .setRange(0,1024)
     .setSize(20,900)
     .setValue(512)
     ;
     
  cp5.getController("vertPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);   
  cp5.getController("vertPos").getValueLabel().setVisible(false);
  
  // create another slider with tick marks, now without
  // default value, the initial value will be set according to
  // the value of variable sliderTicks2 then.
  cp5.addSlider("voltsDiv")
     .setPosition(1360,175)
     .setWidth(515)
     .setRange(0,255)
     .setValue(128)
     .setHeight(20)
     .setNumberOfTickMarks(6)
     .setSliderMode(Slider.FLEXIBLE)
     ;
     
     
  // reposition the Label for controller 'slider'
  cp5.getController("voltsDiv").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  

  cp5.addSlider("timeDiv")
     .setPosition(1360,105)
     .setWidth(515)
     .setHeight(20)
     .setRange(0,255) // values can range from big to small as well
     .setValue(128)
     .setNumberOfTickMarks(10)
     .setSliderMode(Slider.FLEXIBLE)
     ;
  // use Slider.FIX or Slider.FLEXIBLE to change the slider handle
  // by default it is Slider.FIX
  
  cp5.addSlider("horPos")
     .setPosition(1360,25)
     .setWidth(515)
     .setHeight(20)
     .setRange(0,1024)
     .setValue(512)
     ;
    
  cp5.addSlider("trigger")
     .setPosition(1300,25)
     .setWidth(20)
     .setHeight(900)
     .setRange(925,25)
     .setValue(475)
     ;

  cp5.addToggle("Tcursor1")
     .setPosition(1470,250)
     .setSize(70,30)
     .setMode(ControlP5.SWITCH)
     ;
    
  cp5.addToggle("Tcursor2")
     .setPosition(1570,250)
     .setSize(70,30)
     .setMode(ControlP5.SWITCH)
     ;

  cp5.addToggle("Vcursor1")
     .setPosition(1670,250)
     .setSize(70,30)
     .setMode(ControlP5.SWITCH)
     ;    

  cp5.addToggle("Vcursor2")
     .setPosition(1770,250)
     .setSize(70,30)
     .setMode(ControlP5.SWITCH)
     ;
    
  cp5.addSlider("Vslider1")
     .setPosition(1360,400)
     .setWidth(20)
     .setHeight(525)
     .setRange(925,25)
     .setValue(475)
     .setVisible(false)
     ; 

  cp5.addSlider("Vslider2")
     .setPosition(1410,400)
     .setWidth(20)
     .setHeight(525)
     .setRange(925,25)
     .setValue(475)
     .setVisible(false)
     ; 
    
  cp5.addSlider("Hslider1")
     .setPosition(1460,310)
     .setWidth(400)
     .setHeight(20)
     .setRange(25,1225)
     .setValue(625)
     .setVisible(false)
     ; 

  cp5.addSlider("Hslider2")
     .setPosition(1460,350)
     .setWidth(400)
     .setHeight(20)
     .setRange(25,1225)
     .setValue(625)
     .setVisible(false)
     ;     
    
  cp5.getController("horPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("horPos").getValueLabel().setVisible(false); 
  
  cp5.addBang("ZeroH",1360,52,25,25);
  
  cp5.getController("timeDiv").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  cp5.addBang("ZeroV",1360,250,25,25);
  
  cp5.addBang("Reset",1360,350,25,25);
  
  cp5.getController("ZeroV").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("Reset").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  cp5.getController("trigger").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("trigger").getValueLabel().setVisible(false);
  
//  rect(15,30,740,540);
//  line(30,270,800,270);
  
  
  f = createFont("Arial",16,true);
  
//  port = new Serial(this, "COM25", 115200);
  values = new int[1200];
  smooth();
}

int getY(int val) {
  return (int)(val / 1023.0f * 900) + 25 ;
}

public void controlEvent(ControlEvent theEvent) {
  //println(theEvent.getController().getName());  
}

public void ZeroV(int theValue) {
  println("event from ZeroV");
  cp5.controller("vertPos").setValue(512);
}

public void Reset(int theValue) {
  println("event from reset");
  cp5.controller("trigger").setValue(475);
}

public void ZeroH(int theValue) {
  println("event from ZeroH");
  cp5.controller("horPos").setValue(512);
}

public void vertPos(int theValue) {
  println("event from verPos");

}

public void Vcursor1(boolean flag) {
  if (flag == true) {
    cp5.controller("Vslider1").setVisible(true);
    Vcursor1 = true;
  } else {
    cp5.controller("Vslider1").setVisible(false);
    Vcursor1 = false;
  }
}

public void Vcursor2(boolean flag) {
  if (flag == true) {
    cp5.controller("Vslider2").setVisible(true);
    Vcursor2 = true;
  } else {
    cp5.controller("Vslider2").setVisible(false);
    Vcursor2 = false;
  }
}

public void Tcursor1(boolean flag) {
  if (flag == true) {
    cp5.controller("Hslider1").setVisible(true);
    Tcursor1 = true;
  } else {
    cp5.controller("Hslider1").setVisible(false);
    Tcursor1 = false;
  }
}

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
  
  background(120);
 
  strokeWeight(1);
  stroke(0);
  rect(1460,400,400,525);
  
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
  text("20us",1353,147);
  text("50us",1410,147);
  text("100us",1462,147);
  text("200us",1517,147);
  text("500us",1574,147);
  text("1ms",1634,147);
  text("2ms",1690,147);
  text("5ms",1747,147);
  text("10ms",1799,147);
  text("20ms",1854,147);

  trigger = cp5.getController("trigger").getValue();
  vertPos = cp5.getController("vertPos").getValue();
  horPos = cp5.getController("horPos").getValue();
  Hslider1 = cp5.getController("Hslider1").getValue();  
  
  hVal = ((horPos*.009765625) - 5);
  
  vVal = ((vertPos*.009765625) - 5);
  fill((vertPos/4),voltsDiv,timeDiv);
  rect(25,25,1200,900);
  
  stroke(0);
  strokeWeight(1.5);
  line(25,475,1225,475); // x-axis
  line(625,25,625,925); // y-axis
  
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
  
  stroke(0);
  strokeWeight(1.5);
  line(25,trigger,1225,trigger);
  
  stroke(245,245,40);
  fill(0);
  if (Tcursor1==true) {
    line(Hslider1,25,Hslider1,925);
    text("Tcursor1 = "+Hslider1,1480,420);
  }
  
  if (Tcursor2==true) {
    line(Hslider2,25,Hslider2,925);
  }  

  if (Vcursor1==true) {
    line(25,Vslider1,1225,Vslider1);
  }
  
  if (Vcursor2==true) {
    line(25,Vslider2,1225,Vslider2);
  }   
  
  textFont(f,14);
  vVal2 = String.format("%.3f", vVal);
  fill(255);
  text("Offset = "+vVal2+" V",1335,290);

  hVal2 = String.format("%.3f", hVal);
  text("Delay = "+hVal2,1400,70);
  
  
  
//  while (port.available() >= 3) {
//    if (port.read() == 0xff) {
//      val = (port.read() << 8) | (port.read());
//    }
//  }
//  for (int i=0; i<1200-1; i++)
//    values[i] = values[i+1];
//  values[1200-1] = val;
//  stroke(22, 245, 57);
//  strokeWeight(2);
//  for (int x=1; x<1200-1; x++) {
//    line(1200-x+25,900+50-getY(values[x-1]), 
//         1200-1-x+25,900+50-getY(values[x]));
//  }
}








/**
* ControlP5 Slider
*
*
* find a list of public methods available for the Slider Controller
* at the bottom of this sketch.
*
* by Andreas Schlegel, 2012
* www.sojamo.de/libraries/controlp5
*
*/

/*
a list of all methods available for the Slider Controller
use ControlP5.printPublicMethodsFor(Slider.class);
to print the following list into the console.

You can find further details about class Slider in the javadoc.

Format:
ClassName : returnType methodName(parameter type)

controlP5.Slider : ArrayList getTickMarks() 
controlP5.Slider : Slider setColorTickMark(int) 
controlP5.Slider : Slider setHandleSize(int) 
controlP5.Slider : Slider setHeight(int) 
controlP5.Slider : Slider setMax(float) 
controlP5.Slider : Slider setMin(float) 
controlP5.Slider : Slider setNumberOfTickMarks(int) 
controlP5.Slider : Slider setRange(float, float) 
controlP5.Slider : Slider setScrollSensitivity(float) 
controlP5.Slider : Slider setSize(int, int) 
controlP5.Slider : Slider setSliderMode(int) 
controlP5.Slider : Slider setTriggerEvent(int) 
controlP5.Slider : Slider setValue(float) 
controlP5.Slider : Slider setWidth(int) 
controlP5.Slider : Slider showTickMarks(boolean) 
controlP5.Slider : Slider shuffle() 
controlP5.Slider : Slider snapToTickMarks(boolean) 
controlP5.Slider : Slider update() 
controlP5.Slider : TickMark getTickMark(int) 
controlP5.Slider : float getValue() 
controlP5.Slider : float getValuePosition() 
controlP5.Slider : int getDirection() 
controlP5.Slider : int getHandleSize() 
controlP5.Slider : int getNumberOfTickMarks() 
controlP5.Slider : int getSliderMode() 
controlP5.Slider : int getTriggerEvent() 
controlP5.Controller : CColor getColor() 
controlP5.Controller : ControlBehavior getBehavior() 
controlP5.Controller : ControlWindow getControlWindow() 
controlP5.Controller : ControlWindow getWindow() 
controlP5.Controller : ControllerProperty getProperty(String) 
controlP5.Controller : ControllerProperty getProperty(String, String) 
controlP5.Controller : Label getCaptionLabel() 
controlP5.Controller : Label getValueLabel() 
controlP5.Controller : List getControllerPlugList() 
controlP5.Controller : PImage setImage(PImage) 
controlP5.Controller : PImage setImage(PImage, int) 
controlP5.Controller : PVector getAbsolutePosition() 
controlP5.Controller : PVector getPosition() 
controlP5.Controller : Slider addCallback(CallbackListener) 
controlP5.Controller : Slider addListener(ControlListener) 
controlP5.Controller : Slider bringToFront() 
controlP5.Controller : Slider bringToFront(ControllerInterface) 
controlP5.Controller : Slider hide() 
controlP5.Controller : Slider linebreak() 
controlP5.Controller : Slider listen(boolean) 
controlP5.Controller : Slider lock() 
controlP5.Controller : Slider plugTo(Object) 
controlP5.Controller : Slider plugTo(Object, String) 
controlP5.Controller : Slider plugTo(Object[]) 
controlP5.Controller : Slider plugTo(Object[], String) 
controlP5.Controller : Slider registerProperty(String) 
controlP5.Controller : Slider registerProperty(String, String) 
controlP5.Controller : Slider registerTooltip(String) 
controlP5.Controller : Slider removeBehavior() 
controlP5.Controller : Slider removeCallback() 
controlP5.Controller : Slider removeCallback(CallbackListener) 
controlP5.Controller : Slider removeListener(ControlListener) 
controlP5.Controller : Slider removeProperty(String) 
controlP5.Controller : Slider removeProperty(String, String) 
controlP5.Controller : Slider setArrayValue(float[]) 
controlP5.Controller : Slider setArrayValue(int, float) 
controlP5.Controller : Slider setBehavior(ControlBehavior) 
controlP5.Controller : Slider setBroadcast(boolean) 
controlP5.Controller : Slider setCaptionLabel(String) 
controlP5.Controller : Slider setColor(CColor) 
controlP5.Controller : Slider setColorActive(int) 
controlP5.Controller : Slider setColorBackground(int) 
controlP5.Controller : Slider setColorCaptionLabel(int) 
controlP5.Controller : Slider setColorForeground(int) 
controlP5.Controller : Slider setColorValueLabel(int) 
controlP5.Controller : Slider setDecimalPrecision(int) 
controlP5.Controller : Slider setDefaultValue(float) 
controlP5.Controller : Slider setHeight(int) 
controlP5.Controller : Slider setId(int) 
controlP5.Controller : Slider setImages(PImage, PImage, PImage) 
controlP5.Controller : Slider setImages(PImage, PImage, PImage, PImage) 
controlP5.Controller : Slider setLabelVisible(boolean) 
controlP5.Controller : Slider setLock(boolean) 
controlP5.Controller : Slider setMax(float) 
controlP5.Controller : Slider setMin(float) 
controlP5.Controller : Slider setMouseOver(boolean) 
controlP5.Controller : Slider setMoveable(boolean) 
controlP5.Controller : Slider setPosition(PVector) 
controlP5.Controller : Slider setPosition(float, float) 
controlP5.Controller : Slider setSize(PImage) 
controlP5.Controller : Slider setSize(int, int) 
controlP5.Controller : Slider setStringValue(String) 
controlP5.Controller : Slider setUpdate(boolean) 
controlP5.Controller : Slider setValueLabel(String) 
controlP5.Controller : Slider setView(ControllerView) 
controlP5.Controller : Slider setVisible(boolean) 
controlP5.Controller : Slider setWidth(int) 
controlP5.Controller : Slider show() 
controlP5.Controller : Slider unlock() 
controlP5.Controller : Slider unplugFrom(Object) 
controlP5.Controller : Slider unplugFrom(Object[]) 
controlP5.Controller : Slider unregisterTooltip() 
controlP5.Controller : Slider update() 
controlP5.Controller : Slider updateSize() 
controlP5.Controller : String getAddress() 
controlP5.Controller : String getInfo() 
controlP5.Controller : String getName() 
controlP5.Controller : String getStringValue() 
controlP5.Controller : String toString() 
controlP5.Controller : Tab getTab() 
controlP5.Controller : boolean isActive() 
controlP5.Controller : boolean isBroadcast() 
controlP5.Controller : boolean isInside() 
controlP5.Controller : boolean isLabelVisible() 
controlP5.Controller : boolean isListening() 
controlP5.Controller : boolean isLock() 
controlP5.Controller : boolean isMouseOver() 
controlP5.Controller : boolean isMousePressed() 
controlP5.Controller : boolean isMoveable() 
controlP5.Controller : boolean isUpdate() 
controlP5.Controller : boolean isVisible() 
controlP5.Controller : float getArrayValue(int) 
controlP5.Controller : float getDefaultValue() 
controlP5.Controller : float getMax() 
controlP5.Controller : float getMin() 
controlP5.Controller : float getValue() 
controlP5.Controller : float[] getArrayValue() 
controlP5.Controller : int getDecimalPrecision() 
controlP5.Controller : int getHeight() 
controlP5.Controller : int getId() 
controlP5.Controller : int getWidth() 
controlP5.Controller : int listenerSize() 
controlP5.Controller : void remove() 
controlP5.Controller : void setView(ControllerView, int) 
java.lang.Object : String toString() 
java.lang.Object : boolean equals(Object) 


*/



