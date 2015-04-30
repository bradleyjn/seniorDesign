#include <SPI.h>

#define CS_ADC 6

ISR(TIMER2_COMPB_vect){  // Interrupt service routine to pulse the modulated pin 3
  //if(adcOK == 1)
    readADC();
    //digitalWrite(LEDSq, HIGH);
}

void setIrModOutput(){  // sets pin 3 at 400kHz
  pinMode(3, OUTPUT);
  TCCR2A = _BV(COM2B1) | _BV(WGM21) | _BV(WGM20); // Just enable output on Pin 3 and disable it on Pin 11
  TCCR2B = _BV(WGM22) | _BV(CS22);
  OCR2A = 7; // defines the frequency 51 = 38.4 KHz, 54 = 36.2 KHz, 58 = 34 KHz, 62 = 32 KHz
  OCR2B = round(OCR2A/2);  // defines the duty cycle - Half the OCR2A value for 50%
  TCCR2B = TCCR2B & 0b00111000 | 0x2; // select a prescale value of 8:1 of the system clock
}

void setup()
{
  setIrModOutput();
  TIMSK2 = _BV(OCIE2B); // Output Compare Match B Interrupt Enable

  pinMode(CS_ADC, OUTPUT);

  Serial.begin(1000000); // start serial communication at 9600bps

  digitalWrite(CS_ADC, HIGH);

  SPI.setDataMode(SPI_MODE2); // requires SPI Mode for AD9837
  SPI.begin();

  delay(1000); //A little set up time, just to make sure everything's stable
}

void loop()
{
  //readADC();
}

void readADC(){
  digitalWrite(CS_ADC, LOW);
  int valA = SPI.transfer(0xff);
  int valB = SPI.transfer(0xff);
  digitalWrite(CS_ADC, HIGH);

  //Serial.println(valA, BIN);
  //Serial.println(valB, BIN);

  int val = ((valA << 8) & 0xff00 ) | (valB & 0xff);
  //Serial.println(val, BIN);
  val = (val >> 4) & 0xff;
  //Serial.println(val, BIN);
  Serial.write(0xff);
  Serial.write(val);

  //Serial.println();
  //delayMicroseconds(50);
}
