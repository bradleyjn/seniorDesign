import processing.serial.*;

Serial port;  // Create object from Serial class
int[] values;
byte val;

void setup() 
{
  size(640, 480);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  port = new Serial(this, "COM16", 115200);
  values = new int[width];
 
  smooth();
}

void draw() {
  // Expand array size to the number of bytes you expect
  int inBuffer = 0;
  while (port.available() > 0) {
    inBuffer = port.read();
    val = byte(inBuffer);
      println(binary(val));
      //println("Space");
    }
  }
