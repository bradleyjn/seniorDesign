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

ControlP5 cp5;
int myColor = color(0,0,0);

float vertPos = 100;
int voltsDiv = 100;
int timeDiv = 30;
float horPos = 128;
float vVal = 128;
float hVal = 128;
float trigger;
PFont f;
String vVal2, hVal2;
Slider abc;

void setup() {
  size(1200,600);
  noStroke();
  cp5 = new ControlP5(this);
  
  // add a horizontal sliders, the value of this slider will be linked
  // to variable 'sliderValue' 
  cp5.addSlider("vertPos")
     .setPosition(770,30)
     .setRange(0,1024)
     .setSize(15,540)
     .setValue(512)
     ;
     
  cp5.getController("vertPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);   
  cp5.getController("vertPos").getValueLabel().setVisible(false);
  
  // create another slider with tick marks, now without
  // default value, the initial value will be set according to
  // the value of variable sliderTicks2 then.
  cp5.addSlider("voltsDiv")
     .setPosition(850,170)
     .setWidth(320)
     .setRange(0,255)
     .setValue(128)
     .setHeight(15)
     .setNumberOfTickMarks(6)
     .setSliderMode(Slider.FLEXIBLE)
     ;
     
     
  // reposition the Label for controller 'slider'
  cp5.getController("voltsDiv").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  

  cp5.addSlider("timeDiv")
     .setPosition(850,100)
     .setWidth(320)
     .setHeight(15)
     .setRange(0,255) // values can range from big to small as well
     .setValue(128)
     .setNumberOfTickMarks(10)
     .setSliderMode(Slider.FLEXIBLE)
     ;
  // use Slider.FIX or Slider.FLEXIBLE to change the slider handle
  // by default it is Slider.FIX
  
  cp5.addSlider("horPos")
     .setPosition(850,30)
     .setWidth(320)
     .setHeight(15)
     .setRange(0,1024)
     .setValue(512)
     ;
    
  cp5.addSlider("trigger")
     .setPosition(810,30)
     .setWidth(15)
     .setHeight(540)
     .setRange(570,30)
     .setValue(300)
     ;

  cp5.addToggle("Vcursor1")
     .setPosition(920,235)
     .setSize(50,20)
     .setMode(ControlP5.SWITCH)
     ;
    
  cp5.addToggle("Vcursor2")
     .setPosition(980,235)
     .setSize(50,20)
     .setMode(ControlP5.SWITCH)
     ;

  cp5.addToggle("Tcursor1")
     .setPosition(1060,235)
     .setSize(50,20)
     .setMode(ControlP5.SWITCH)
     ;    

  cp5.addToggle("Tcursor2")
     .setPosition(1120,235)
     .setSize(50,20)
     .setMode(ControlP5.SWITCH)
     ;
    
  cp5.addSlider("Vslider1")
     .setPosition(920,350)
     .setWidth(15)
     .setHeight(225)
     .setRange(0,255)
     .setValue(128)
     .setVisible(false)
     ; 

  cp5.addSlider("Vslider2")
     .setPosition(960,350)
     .setWidth(15)
     .setHeight(225)
     .setRange(0,255)
     .setValue(128)
     .setVisible(false)
     ; 
    
  cp5.addSlider("Hslider1")
     .setPosition(920,280)
     .setWidth(250)
     .setHeight(15)
     .setRange(0,255)
     .setValue(128)
     .setVisible(false)
     ; 

  cp5.addSlider("Hslider2")
     .setPosition(920,310)
     .setWidth(250)
     .setHeight(15)
     .setRange(0,255)
     .setValue(128)
     .setVisible(false)
     ;     
    
  cp5.getController("horPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("horPos").getValueLabel().setVisible(false); 
  
  cp5.addBang("ZeroH",850,55,20,20);
  
  cp5.getController("timeDiv").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  cp5.addBang("ZeroV",855,250,20,20);
  
  cp5.addBang("Reset",855,350,20,20);
  
  cp5.getController("ZeroV").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("Reset").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  cp5.getController("trigger").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("trigger").getValueLabel().setVisible(false);
  
  rect(15,30,740,540);
  line(30,270,800,270);
  
  
  f = createFont("Arial",16,true);


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
  cp5.controller("trigger").setValue(300);
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
  } else {
    cp5.controller("Vslider1").setVisible(false);
  }
}

public void Vcursor2(boolean flag) {
  if (flag == true) {
    cp5.controller("Vslider2").setVisible(true);
  } else {
    cp5.controller("Vslider2").setVisible(false);
  }
}

public void Tcursor1(boolean flag) {
  if (flag == true) {
    cp5.controller("Hslider1").setVisible(true);
  } else {
    cp5.controller("Hslider1").setVisible(false);
  }
}

public void Tcursor2(boolean flag) {
  if (flag == true) {
    cp5.controller("Hslider2").setVisible(true);
  } else {
    cp5.controller("Hslider2").setVisible(false);
  }
}

void draw() {
  background(120);
  
  rect(1010,350,160,225);
  
  textFont(f,12);
  fill(255);
  text("100mV",835,205);
  text("200mV",900,205);
  text("500mV",964,205);
  text("1V",1034,205);
  text("2V",1096,205);
  text("5V",1158,205);
  
  textFont(f,10);
  fill(255);
  text("20us",845,135);
  text("50us",880,135);
  text("100us",912,135);
  text("200us",948,135);
  text("500us",982,135);
  text("1ms",1017,135);
  text("2ms",1050,135);
  text("5ms",1082,135);
  text("10ms",1112,135);
  text("20ms",1150,135);

  trigger = cp5.getController("trigger").getValue();
  vertPos = cp5.getController("vertPos").getValue();
  horPos = cp5.getController("horPos").getValue();
  
  
  hVal = ((horPos*.009765625) - 5);
  
  vVal = ((vertPos*.009765625) - 5);
  fill((vertPos/4),voltsDiv,timeDiv);
  rect(15,30,740,540);
  
  stroke(0);
  line(15,300,755,300); // x-axis
  line(385,30,385,570); // y-axis
  
  stroke(100);
  line(15,165,755,165);
  line(15,435,755,435);
  line(15,232.5,755,233.5);
  line(15,97.5,755,97.5);
  line(15,367.5,755,367.6);
  line(15,502.5,755,502.5);
  
  line(89,30,89,570);
  line(163,30,163,570);
  line(237,30,237,570);
  line(311,30,311,570);
  line(459,30,459,570);
  line(533,30,533,570);
  line(607,30,607,570);
  line(681,30,681,570);
  
  stroke(0);
  line(15,trigger,755,trigger);
  
  
  textFont(f,10);
  vVal2 = String.format("%.3f", vVal);
  fill(255);
  text("Offset = "+vVal2+" V",830,285);

  hVal2 = String.format("%.3f", hVal);
  fill(255);
  text("Delay = "+hVal2,890,70);

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



