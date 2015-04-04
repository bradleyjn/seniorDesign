#include <SPI.h>

#define CS_ADC 6

byte valA = 0;
byte valB = 0;
unsigned int val = 0;

void setup() {
  pinMode(CS_ADC, OUTPUT);
  digitalWrite(CS_ADC, HIGH);
  
  Serial.begin(1000000); // start serial communication at 9600bps
  
  SPI.setDataMode(SPI_MODE2);
  SPI.begin();
  delay(100); //A little set up time, just to make sure everything's stable
  
}

void loop() {
  digitalWrite(CS_ADC, LOW);
  valA = SPI.transfer(0xff);
  valB = SPI.transfer(0xff);
  digitalWrite(CS_ADC, HIGH);
  
  //Serial.println(valA, BIN);
  //Serial.println(valB, BIN);
  
  val = ((valA << 8) & 0xff00 ) | (valB & 0xff);
  //Serial.println(val, BIN);
  val = (val >> 4) & 0xff;
  //Serial.println(val, BIN);
  Serial.write(0xff);
  Serial.write(val);
  
  //Serial.println();
    //delayMicroseconds(50);
  
}
