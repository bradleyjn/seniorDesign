#include <SPI.h>
#include <math.h>

const int slaveSelectPin = 8;
int btnPin = 7;
int done = 0;
int val = 0;

void setup() {
  pinMode (slaveSelectPin, OUTPUT);
  pinMode(btnPin, INPUT);
  // initialize SPI:
  SPI.begin(); 
  Serial.begin(9600);
  digitalPotWrite(0);
  Serial.println("Begin");
}

void loop() {
if((digitalRead(btnPin) == HIGH) && (done == 0)){
  if(val < 256){
    Serial.println(val);
    digitalPotWrite(val);
    val = val++;
  }
  else if (val == 256){
   val = 0;
  }
  done = 1;
}
if((digitalRead(btnPin) == LOW) && (done == 1)){
 done = 0; 
}
  delay(50);
}

void digitalPotWrite(int value) {
  value = constrain(value, 0, 255);
  digitalWrite(slaveSelectPin,LOW);
  delay(10);
  SPI.transfer(value);
  delay(10);
  // take the SS pin high to de-select the chip:
  digitalWrite(slaveSelectPin,HIGH); 
}
