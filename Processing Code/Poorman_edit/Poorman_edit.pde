/*
 * Oscilloscope
 * Gives a visual rendering of analog pin 0 in realtime.
 * 
 * This project is part of Accrochages
 * See http://accrochages.drone.ws
 * 
 * (c) 2008 Sofian Audry (info@sofianaudry.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */ 
import processing.serial.*;

Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[] values;

void setup() 
{
  size(800, 600);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  port = new Serial(this, "COM25", 115200);
  values = new int[600];
  smooth();
  

}

int getY(int val) {
  return (int)(val / 1023.0f * 400) - 1;
}

void draw()
{
  while (port.available() >= 3) {
    if (port.read() == 0xff) {
      val = (port.read() << 8) | (port.read());
    }
  }
  for (int i=0; i<600-1; i++)
    values[i] = values[i+1];
  values[600-1] = val;
  background(0);
  fill(100);
  rect(100,100,600,400);
  stroke(255);
  for (int x=1; x<600; x++) {
    line(600-x+100,   400-1+100-getY(values[x-1]), 
         600-1-x+100, 400-1+100-getY(values[x]));
  }
}

/*
// The Arduino code.

#define ANALOG_IN 0

void setup() {
  Serial.begin(9600); 
}

void loop() {
  int val = analogRead(ANALOG_IN);
  Serial.print( 0xff, BYTE);
  Serial.print( (val >> 8) & 0xff, BYTE);
  Serial.print( val & 0xff, BYTE);
}

*/

