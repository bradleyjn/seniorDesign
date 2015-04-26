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
}

void loop() {

  //For one resolution test

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

}

void digitalPotWrite(int address, int value) {
  switch(address){
    case(1):
      //Serial.println("CASE 1");
      pot1 = constrain(value, 0, 256);
      Serial.print("pot1 = ");
      Serial.println(pot1);
    break;
    case(2):
      value = constrain(value, 0, 100000);
      pot2 = round((value-1)*1000);
    break;
    case(3):
      value = constrain(value, -5, 5);
      pot3 = round((value+5)*(10/256));
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
  Serial.print(analogRead(0));
  Serial.print("   ");
  Serial.print(analogRead(1));
  Serial.print("   ");
  Serial.println(analogRead(2)); 
}

void setResGain(int gain){
  gain = constrain(gain, 1, 100);
  unsigned int r = map(gain, 1, 100, 0, 256);
  Serial.print("r = ");
  Serial.println(r);
  digitalPotWrite(1, r);
}



