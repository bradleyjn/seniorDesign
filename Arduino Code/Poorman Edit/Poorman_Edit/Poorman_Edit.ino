#define ANALOG_IN 0

void setup() {
  Serial.begin(115200); 
}

void loop() {
  int val = analogRead(ANALOG_IN);
  Serial.write( 0xff);
  Serial.write( (val >> 2) & 0xff);
  //Serial.write( val & 0xff);
}
