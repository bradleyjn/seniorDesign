#include <SPI.h>

#define CS_DDS 7
#define CS_ADC 6
#define CS_POTS 8
#define freqPin 0
#define ampPin 1
#define offPin 2
#define buttonPin 5
#define LEDSinPin 10
#define LEDSqPin 9
#define LEDTriPin 4
#define MUXPin 2

volatile byte pulse = 0;

long freq;

ISR(TIMER2_COMPB_vect){  // Interrupt service routine to pulse 3
   pulse++;
   readADC();
}

void setMCLK(){  // sets pin 3 at 400kHz
 pinMode(3, OUTPUT);
 TCCR2A = _BV(COM2B1) | _BV(WGM21) | _BV(WGM20); // Just enable output on Pin 3 and disable it on Pin 11
 TCCR2B = _BV(WGM22) | _BV(CS22);
 OCR2A = 7; // defines the frequency 51 = 38.4 KHz, 54 = 36.2 KHz, 58 = 34 KHz, 62 = 32 KHz, 4 = 400kHz, 7 = 250 kHz
 OCR2B = round(OCR2A/2);  // deines the duty cycle - Half the OCR2A value for 50%
 TCCR2B = TCCR2B & 0b00111000 | 0x2; // select a prescale value of 8:1 of the system clock
}

void setup()
{
 //Set up the MCLK on pin D3 for the DDS
 setMCLK();
 TIMSK2 = _BV(OCIE2B); // Output Compare Match B Interrupt Enable
 
 //Set up chip select pins
 pinMode(CS_DDS, OUTPUT);
 pinMode(CS_ADC, OUTPUT);
 pinMode(CS_POTS, OUTPUT);
 
 pinMode(buttonPin, INPUT);
 pinMode(MUXPin, OUTPUT);

 //Turn off all chip selects
 digitalWrite(CS_DDS, HIGH);
 digitalWrite(CS_ADC, HIGH);
 digitalWrite(CS_POTS, HIGH);
 
 //Start the SPI bus
 SPI.setDataMode(SPI_MODE2);
 SPI.begin();
 delay(100); //A little set up time, just to make sure everything's stable
 
 //Initial frequency
 freq = 10000;
 WriteFrequencyAD9837(freq);
 
 //Set the digital pots all to 0
 for(int i=0; i<4;i++){
    digitalPotWrite(i, 0);
  }
  
  digitalWrite(MUXPin, HIGH);
 
 //Start the serial connection
 Serial.begin(9600);
}

void loop()
{
  
}

void WriteFrequencyAD9837(long frequency)
{
 //
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
 
 writeRegisterDDS(0x2100);
 
 //delay(500);
 
 //Set the frequency==========================
 writeRegisterDDS(LSB); //lower 14 bits
 
writeRegisterDDS(MSB); //upper 14 bits
 
writeRegisterDDS(phase); //mid-low
 
 //Power it back up
 //writeRegisterDDS(0x2020); //square with half frequency
 writeRegisterDDS(0x2028); //square
 //writeRegisterDDS(0x2000); //sin
 //writeRegisterDDS(0x2002); //triangle
 
}

void writeWaveform(int form){
  switch (form){
   case 0:  //sine
    writeRegisterDDS(0x2000); //sin
    digitalWrite(MUXPin, HIGH);
    break;
   case 1:  //square
    writeRegisterDDS(0x2028); //square
    digitalWrite(MUXPin, LOW);
    break;
   case 2:  //triangle
    writeRegisterDDS(0x2002); //triangle
    digitalWrite(MUXPin, HIGH);
    break; 
  }
  //writeRegisterDDS(0x2020); //square with half frequency
}
 
//This is the guy that does the actual talking to the AD9837
void writeRegisterDDS(int dat)
{
 //Writes data to the DDS registers
 digitalWrite(CS_DDS, LOW); //Set FSYNC low
 delay(10);
 
 SPI.transfer(highByte(dat)); Serial.println(highByte(dat));
 SPI.transfer(lowByte(dat)); Serial.println(lowByte(dat));
 
 delay(10);
 digitalWrite(CS_DDS, HIGH); //Set FSYNC high
}

void readADC(){
  //The ADC requires at least 14 SCLK cycles to calcuate a value
  //SPI.transfer transfers 1 byte, so by transferring 2 bytes (16 SCLK cycles)
  //and shifting them we can obtain the 10 bit value from the ADC.
  //Only 8 bits are used so we can ignore the 2 LSBs
  
  //Set up the variables needed to read the ADC
  byte byte1 = 0;  //The first byte transfered
  byte byte2 = 0;  //The second byte transfered
  unsigned int val = 0;
  
  //Read the value from the ADC
  digitalWrite(CS_ADC, LOW);
  byte1 = SPI.transfer(0xff);  //Read byte1
  byte2 = SPI.transfer(0xff);  //Read byte2
  digitalWrite(CS_ADC, HIGH);
  
  //Send the byte over serial
  val = ((byte1 << 8) & 0xff00 ) | (byte2 & 0xff);  //Concatenate byte 1 with byte 2
  val = (val >> 4) & 0xff;  //Get the 8 bit value from the concatenated bytes
  Serial.write(val);  //Write the byte over serial
}

void digitalPotWrite(int address, int value) {
  // take the SS pin low to select the chip:
  digitalWrite(CS_POTS,LOW);
  //  send in the address and value via SPI:
  SPI.transfer(address);
  SPI.transfer(value);
  // take the SS pin high to de-select the chip:
  digitalWrite(CS_POTS,HIGH); 
}

void setAmplitude(int amp){
  int level = map(amp, -10, 10, 0, 255);
  digitalPotWrite(2, level);
}

void setOffset(int off){
  int level = map(off, -5, 5, 0, 255);
  digitalPotWrite(3, level);
}

void setGain(int gain){
  int level = map(gain, 1, 100, 0, 255);
  digitalPotWrite(1, level);
}

int readFrequency(){
  int level = analogRead(freqPin);
  level = map(level, 0, 1023, 20, 20000);
  return level;
}

//void setFrequency(int freq){
//  writeFrequencyDDS(freq);
//}

