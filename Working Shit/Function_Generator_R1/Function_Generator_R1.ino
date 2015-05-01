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

#include <SPI.h>
#include <math.h>

//Define pins
#define FSYNC 7
#define MUXPin 2
#define CS_POTS 8
#define LEDSin 10
#define LEDSq 9
#define LEDTri 4
#define buttonPin 5

//Define variables

#define potFreq 0
#define potAmp 1
#define potOff 2
#define potFreqHyst 2
#define potAmpHyst 1
#define potOffHyst 1
#define freqMin 100
#define freqMax 10000
//volatile byte pulse = 0;

ISR(TIMER2_COMPB_vect){  // Interrupt service routine to pulse the modulated pin 3
}

void setIrModOutput(){  // sets pin 3 at 400kHz
  pinMode(3, OUTPUT);
  TCCR2A = _BV(COM2B1) | _BV(WGM21) | _BV(WGM20); // Just enable output on Pin 3 and disable it on Pin 11
  TCCR2B = _BV(WGM22) | _BV(CS22);
  OCR2A = 7; // defines the frequency 51 = 38.4 KHz, 54 = 36.2 KHz, 58 = 34 KHz, 62 = 32 KHz
  OCR2B = round(OCR2A/2);  // deines the duty cycle - Half the OCR2A value for 50%
  TCCR2B = TCCR2B & 0b00111000 | 0x2; // select a prescale value of 8:1 of the system clock
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

  Serial.begin(9600); // start serial communication at 9600bps

  digitalWrite(FSYNC, HIGH);
  digitalWrite(CS_POTS, HIGH);

  SPI.setDataMode(SPI_MODE2); // requires SPI Mode for AD9837
  SPI.begin();

  delay(1000); //A little set up time, just to make sure everything's stable

  digitalPotWrite(1, 255);

  //Initial frequency
  freq = 500;
  WriteFrequencyAD9837(freq);
  writeWaveformDDS(0);

  delay(100);


  Serial.print("Frequency is ");
  Serial.print(freq);
  Serial.println("");

  setResGain(1);
  setAmp(1);
  setOff(0);
}

void loop()
{
  checkButton();
  checkAPots();
  //Serial.println("-------------");
  delay(50);
}

void WriteFrequencyAD9837(long frequency)
{
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
}

void writeFrequencyDDS(long frequency)
{
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
}

void writeWaveformDDS(int form){
  switch (form){
  case 0:  //sine
    Serial.println("Now generating Sine");
    WriteRegisterAD9837(0x2000); //sin
    digitalWrite(MUXPin, HIGH);
    digitalWrite(LEDSin, HIGH);
    digitalWrite(LEDSq, LOW);
    digitalWrite(LEDTri, LOW);
    break;
  case 1:  //square
    Serial.println("Now generating Square");
    digitalWrite(MUXPin, LOW);
    digitalWrite(LEDSin, LOW);
    digitalWrite(LEDSq, HIGH);
    digitalWrite(LEDTri, LOW);
    WriteRegisterAD9837(0x2028); //square
    break;
  case 2:  //triangle
    Serial.println("Now generating Triangle");
    WriteRegisterAD9837(0x2002); //triangle
    digitalWrite(MUXPin, HIGH);
    digitalWrite(LEDSin, LOW);
    digitalWrite(LEDSq, LOW);
    digitalWrite(LEDTri, HIGH);
    break; 
  }
  //writeRegisterDDS(0x2020); //square with half frequency
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

void printPots(){
  Serial.println("POTS------");
  Serial.print(dpot1);
  Serial.print("   ");
  Serial.print(dpot2);
  Serial.print("   ");
  Serial.println(dpot3);  
}
void digitalPotWrite(int address, int value) {
  value = constrain(value, 0, 256);
  switch(address){
    case(1):
    //Serial.println("CASE 1");
    dpot1 = value;
    break;
    case(2):
    dpot2 = value;
    break;
    case(3):
    dpot3 = value;
    break;
  default:
    break;
  }
  // take the SS pin low to select the chip:
  digitalWrite(CS_POTS,LOW);
  delay(10);
  SPI.transfer(dpot3);
  SPI.transfer(dpot2);
  SPI.transfer(dpot1);
  delay(10);
  // take the SS pin high to de-select the chip:
  digitalWrite(CS_POTS,HIGH); 
  delay(100);
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
  Serial.print("ResGain: ");
  Serial.println(r);
  digitalPotWrite(1, r);
}

void setAmp(double amp){
  amp = constrain(amp, 0, 10);
  unsigned int r = map(amp, 0, 10, 0, 256);
  Serial.print("Amplitude: ");
  Serial.println(r);
  digitalPotWrite(2, r);
}

void setOff(double off){
  off = constrain(off, -5, 5);
  unsigned int r = map(off, -5,5, 0, 256);
  Serial.print("Offset: ");
  Serial.println(r);
  digitalPotWrite(3, r);
}


void checkAPots(){
  int potFreqNow = analogRead(potFreq);
  int potAmpNow = analogRead(potAmp);
  int potOffNow = analogRead(potOff);

  if (abs(potFreqNow-potFreqVal) > potFreqHyst){
    potFreqVal = potFreqNow;
    writeFrequencyDDS(map(potFreqVal, 0, 1023, freqMin, freqMax));
  }
  if (abs(potAmpNow-potAmpVal) > potAmpHyst){
    potAmpVal = potAmpNow;
    int r = potAmpVal/4;
    digitalPotWrite(2, r);
    Serial.print("Amplitude: ");
    Serial.println(r);
    //setAmp(map(potAmpVal, 0, 1023, 0, 10));
  }
  if (abs(potOffNow-potOffVal) > potOffHyst){
    potOffVal = potOffNow;
    setOff(map(potOffVal, 0, 1023, -5, 5));
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




