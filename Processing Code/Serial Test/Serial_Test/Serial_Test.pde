import processing.serial.*;

Serial port;  // Create object from Serial class
byte[] buff;
byte val;
int dat = 0;

void setup() 
{
  size(640, 480);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  port = new Serial(this, "COM16", 115200);
  buff = new byte[width];
 
  smooth();
}

byte getY(byte val) {
  return byte((val / 1023 * height) - 1);
}

void draw() {
  // Expand array size to the number of bytes you expect
  int inBuffer = 0;
  while (port.available() > 0) {
    val = byte(port.read());
    println(binary(val));
    if (dat == 1){
      dat = 0;
      buff[width-1] = val;
       background(0);
       stroke(255);
     for (int x=1; x<width; x++) {
       line(width-x,   height-1-getY(buff[x-1]), 
         width-1-x, height-1-getY(buff[x]));
      }
    }
    else{
      dat = 1;
    }
    
      
      //println("Space");
    }
  }
