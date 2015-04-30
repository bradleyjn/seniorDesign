// include the SPI library:
#include <SPI.h>
#include <math.h>

// set pin 10 as the slave select for the digital pot:
const int slaveSelectPin = 8;
unsigned int pot1 = 0;
unsigned int pot2 = 0; 
unsigned int pot3 = 0;

void setup() {
  // set the slaveSelectPin as an output:
  pinMode (slaveSelectPin, OUTPUT);
  // initialize SPI:
  SPI.begin(); 
  Serial.begin(9600);
  setResGain(1);
  setAmp(1);
  setOff(0);
  printValues3();
  printPots();
}

void loop() {
  
  delay(1000);
  //For one resolution test
  /*
  for (int i = 1; i < 100; i=i+5) { 
   // change the gain on this channel from min to max:
   setResGain(i);
   delay(10);
   Serial.print("i = ");
   Serial.println(i);
   Serial.print("\t\t\tA0 = ");
   Serial.println(analogRead(0));
   delay(1000);
   }
    */
}


void printPots(){
  Serial.println("POTS------");
  Serial.print(pot1);
  Serial.print("   ");
  Serial.print(pot2);
  Serial.print("   ");
  Serial.println(pot3);  
}
void digitalPotWrite(int address, int value) {
  value = constrain(value, 0, 256);
  switch(address){
    case(1):
      //Serial.println("CASE 1");
      pot1 = value;
    break;
    case(2):
      pot2 = value;
    break;
    case(3):
      pot3 = value;
    break;
    default:
    break;
  }
  // take the SS pin low to select the chip:
  digitalWrite(slaveSelectPin,LOW);
  delay(10);
  SPI.transfer(pot3);
  SPI.transfer(pot2);
  SPI.transfer(pot1);
  delay(10);
  // take the SS pin high to de-select the chip:
  digitalWrite(slaveSelectPin,HIGH); 
}


void printValues3(){
  int a0 = analogRead(0);
  int a1 = analogRead(1);
  int a2 = analogRead(2);
  int res0 = map(a0, 0, 1023, 0, 100000);
  int res1 = map(a1, 0, 1023, 0, 100000);
  Serial.println("ADC------");
  Serial.print(a0);
  Serial.print("   ");
  Serial.print(a1);
  Serial.print("   ");
  Serial.println(a2);
  Serial.print(res0);
  Serial.print("   ");
  Serial.println(res1);
}

void setResGain(int gain){
  gain = constrain(gain, 1, 100);
  unsigned int r = map(gain, 1, 100, 0, 256);
  digitalPotWrite(1, r);
}

void setAmp(double amp){
  amp = constrain(amp, .1, 10);
  unsigned int r = map(amp, 0, 10, 0, 256);
  digitalPotWrite(2, r);
}

void setOff(double off){
  off = constrain(off, -5, 5);
  unsigned int r = map(off, -5,5, 0, 256);
  digitalPotWrite(3, r);
}



