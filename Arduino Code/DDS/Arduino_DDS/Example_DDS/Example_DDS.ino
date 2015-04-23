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
 
#include <SPI.h>
 
// Define the FSYNC (used for SD funtion)
#define FSYNC 7

//volatile byte pulse = 0;

ISR(TIMER2_COMPB_vect){  // Interrupt service routine to pulse the modulated pin 3
   //pulse++;
 //if(pulse >= 8) { // change number for number of modulation cycles in a pulse
 //  pulse =0;
//   TCCR2A ^= _BV(COM2B1); // toggle pin 3 enable, turning the pin on and off
 //}
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
 
 Serial.begin(9600); // start serial communication at 9600bps
 
 digitalWrite(FSYNC, HIGH);
 
 SPI.setDataMode(SPI_MODE2); // requires SPI Mode for AD9837
 SPI.begin();
 
 delay(100); //A little set up time, just to make sure everything's stable
 
 //Initial frequency
 freq = 10000;
 WriteFrequencyAD9837(freq);
 
 Serial.print("Frequency is ");
 Serial.print(freq);
 Serial.println("");
 
}
 
void loop()
{
  //WriteFrequencyAD9837(20000);
  delay(100);
  
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
 
 WriteRegisterAD9837(0x2100);
 
 //delay(500);
 
 //Set the frequency==========================
 WriteRegisterAD9837(LSB); //lower 14 bits
 
WriteRegisterAD9837(MSB); //upper 14 bits
 
WriteRegisterAD9837(phase); //mid-low
 
 //Power it back up
 //WriteRegisterAD9837(0x2020); //square with half frequency
 WriteRegisterAD9837(0x2028); //square
 //WriteRegisterAD9837(0x2000); //sin
 //WriteRegisterAD9837(0x2002); //triangle
 
}
 
//This is the guy that does the actual talking to the AD9837
void WriteRegisterAD9837(int dat)
{
 digitalWrite(FSYNC, LOW); //Set FSYNC low
 delay(10);
 
 SPI.transfer(highByte(dat)); Serial.println(highByte(dat));
 SPI.transfer(lowByte(dat)); Serial.println(lowByte(dat));
 
delay(10);
 digitalWrite(FSYNC, HIGH); //Set FSYNC high
}
