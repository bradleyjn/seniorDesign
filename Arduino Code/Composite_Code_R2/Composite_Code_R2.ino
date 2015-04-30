/*
AD9837 Pro Generator sample code
 This was written in Arduino 1.0.1,
 for an Arduino Pro Mini, 5V, 16MHz
 Pete Dokter, 9/2/12
 Remixed by Anne Mahaffey, 10/8/12
 ReRemixed by sinneb, 15th of april 2013
 
 The connections to the AD9837 board are:
 
 FSYNC -> 2
 SCLK -> 13 (SCK)
 SDATA -> 11 (MOSI)
 MCLK -> 9 (Timer1)
 +Vin = VCC on Pro Micro
 GND -> GND
 
 This code bears the license of the beer. If you make money off of this,
 you gotta beer me.
 */

long freq; //32-bit global frequency variable
unsigned int dpot1 = 0;
unsigned int dpot2 = 0; 
unsigned int dpot3 = 0;
unsigned int potFreqVal = 0;
unsigned int potAmpVal = 0;
unsigned int potOffVal = 0;
int btnState;
int done = 0;
int genState = 0;
//volatile int adcOK = 0;

#include <SPI.h>
#include <math.h>
#include "TimerOne.h"

//Define pins
#define FSYNC 7
#define MUXPin 2
#define CS_POTS 8
#define LEDSin 10
#define LEDSq 9
#define LEDTri 4
#define buttonPin 5
#define CS_ADC 6

//Define variables

#define potFreq 0
#define potAmp 1
#define potOff 2
#define potFreqHyst 2
#define potAmpHyst 1
#define potOffHyst 1
#define freqMin 1000
#define freqMax 20000

ISR(TIMER2_COMPB_vect){  // Interrupt service routine to pulse the modulated pin 3
  //if(adcOK == 1)
    //readADC();
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

void pollADC(){
  //readADC();
}

void setup()
{
  setIrModOutput();
  TIMSK2 = _BV(OCIE2B); // Output Compare Match B Interrupt Enable
  
  pinMode(FSYNC, OUTPUT); //FSYNC
  pinMode(MUXPin, OUTPUT);
  pinMode(CS_POTS, OUTPUT);
  pinMode(LEDSin, OUTPUT);
  pinMode(LEDSq, OUTPUT);
  pinMode(LEDTri, OUTPUT);
  pinMode(buttonPin, INPUT);
  pinMode(CS_ADC, OUTPUT);
  
  //Timer1.initialize(4);
  //Timer1.pwm(9, 512);
  //Timer1.attachInterrupt(pollADC);

  Serial.begin(9600); // start serial communication at 9600bps

  digitalWrite(FSYNC, HIGH);
  digitalWrite(CS_ADC, HIGH);

  SPI.setDataMode(SPI_MODE2); // requires SPI Mode for AD9837
  SPI.begin();

  delay(1000); //A little set up time, just to make sure everything's stable

  //Initial frequency
  freq = 10000;
  WriteFrequencyAD9837(freq);
  writeWaveformDDS(0);

  delay(100);


  Serial.print("Frequency is ");
  Serial.print(freq);
  Serial.println("");
  interrupts();
}

void loop()
{
  noInterrupts();
  checkButton();
  checkAPots();
  Serial.println(micros());
  //readADC();
  interrupts();
  //Serial.println("-------------");
  delay(50);
}

void WriteFrequencyAD9837(long frequency)
{
  noInterrupts();
  //
  frequency = constrain(frequency, freqMin, freqMax);
  int MSB;
  int LSB;
  int phase = 0;

  //We can't just send the actual frequency, we have to calculate the "frequency word".
  //This amounts to ((desired frequency)/(reference frequency)) x 0x10000000.
  //calculated_freq_word will hold the calculated result.
  long calculated_freq_word;
  float AD9837Val = 0.00000000;

  AD9837Val = (((float)(frequency))/250000);
  calculated_freq_word = AD9837Val*0x10000000;

  /*
 Serial.println("");
   Serial.print("Frequency word is ");
   Serial.print(calculated_freq_word);
   Serial.println("");
   */

  //Once we've got that, we split it up into separate bytes.
  MSB = (int)((calculated_freq_word & 0xFFFC000)>>14); //14 bits
  LSB = (int)(calculated_freq_word & 0x3FFF);

  //Set control bits DB15 ande DB14 to 0 and one, respectively, for frequency register 0
  LSB |= 0x4000;
  MSB |= 0x4000;

  phase &= 0xC000;

  WriteRegisterAD9837(0x2100);

  //delay(500);

  //Set the frequency==========================
  WriteRegisterAD9837(LSB); //lower 14 bits

  WriteRegisterAD9837(MSB); //upper 14 bits

  WriteRegisterAD9837(phase); //mid-low

  //Power it back up
  //WriteRegisterAD9837(0x2020); //square with half frequency
  //WriteRegisterAD9837(0x2028); //square
  //WriteRegisterAD9837(0x2000); //sin
  //WriteRegisterAD9837(0x2002); //triangle
  writeWaveformDDS(genState);
  interrupts();
}

void writeFrequencyDDS(long frequency)
{
  noInterrupts();
  //
  frequency = constrain(frequency, freqMin, freqMax);
  int MSB;
  int LSB;
  int phase = 0;

  //We can't just send the actual frequency, we have to calculate the "frequency word".
  //This amounts to ((desired frequency)/(reference frequency)) x 0x10000000.
  //calculated_freq_word will hold the calculated result.
  long calculated_freq_word;
  float AD9837Val = 0.00000000;

  AD9837Val = (((float)(frequency))/250000);
  calculated_freq_word = AD9837Val*0x10000000;

  /*
 Serial.println("");
   Serial.print("Frequency word is ");
   Serial.print(calculated_freq_word);
   Serial.println("");
   */

  //Once we've got that, we split it up into separate bytes.
  MSB = (int)((calculated_freq_word & 0xFFFC000)>>14); //14 bits
  LSB = (int)(calculated_freq_word & 0x3FFF);

  //Set control bits DB15 ande DB14 to 0 and one, respectively, for frequency register 0
  LSB |= 0x4000;
  MSB |= 0x4000;

  //phase &= 0xC000;

  WriteRegisterAD9837(0x2100);

  //delay(500);

  //Set the frequency==========================
  WriteRegisterAD9837(LSB); //lower 14 bits

  WriteRegisterAD9837(MSB); //upper 14 bits

  //WriteRegisterAD9837(phase); //mid-low

  //Power it back up
  //WriteRegisterAD9837(0x2020); //square with half frequency
  //WriteRegisterAD9837(0x2028); //square
  //WriteRegisterAD9837(0x2000); //sin
  //WriteRegisterAD9837(0x2002); //triangle
  writeWaveformDDS(genState);
  interrupts();
}

void writeWaveformDDS(int form){
  noInterrupts();
  switch (form){
  case 0:  //sine
    Serial.println("Now generating Sine");
    WriteRegisterAD9837(0x2000); //sin
    digitalWrite(MUXPin, HIGH);
    digitalWrite(LEDSin, HIGH);
    //digitalWrite(LEDSq, LOW);
    digitalWrite(LEDTri, LOW);
    break;
  case 1:  //square
    Serial.println("Now generating Square");
    digitalWrite(MUXPin, LOW);
    digitalWrite(LEDSin, LOW);
    //digitalWrite(LEDSq, HIGH);
    digitalWrite(LEDTri, LOW);
    WriteRegisterAD9837(0x2028); //square
    break;
  case 2:  //triangle
    Serial.println("Now generating Triangle");
    WriteRegisterAD9837(0x2002); //triangle
    digitalWrite(MUXPin, HIGH);
    digitalWrite(LEDSin, LOW);
    //digitalWrite(LEDSq, LOW);
    digitalWrite(LEDTri, HIGH);
    break; 
  }
  //writeRegisterDDS(0x2020); //square with half frequency
  interrupts();
}
//This is the guy that does the actual talking to the AD9837
void WriteRegisterAD9837(int dat)
{
  digitalWrite(FSYNC, LOW); //Set FSYNC low
  delay(10);

  SPI.transfer(highByte(dat)); 
  //Serial.println(highByte(dat));
  SPI.transfer(lowByte(dat)); 
  //Serial.println(lowByte(dat));

  delay(10);
  digitalWrite(FSYNC, HIGH); //Set FSYNC high
}

void checkAPots(){
  int potFreqNow = analogRead(potFreq);

  if (abs(potFreqNow-potFreqVal) > potFreqHyst){
    potFreqVal = potFreqNow;
    writeFrequencyDDS(map(potFreqVal, 0, 1023, freqMin, freqMax));
  }
}

void checkButton(){
  btnState = digitalRead(buttonPin); 
  if((btnState == 1) && (done == 0)){
    switch(genState){
    case 0:
      writeWaveformDDS(1);
      genState = 1;
      break;
    case 1: 
      writeWaveformDDS(2);
      genState = 2;
      break;
    case 2:
      writeWaveformDDS(0);
      genState = 0;
      break;
    } 
    done = 1;
  }
  if((done == 1) && (btnState == 0)){
    done = 0; 
  }
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



