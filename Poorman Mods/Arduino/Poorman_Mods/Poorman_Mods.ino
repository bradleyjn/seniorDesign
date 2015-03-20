#define ANALOG_IN 0

void setup() {
  Serial.begin(115200); 
}

void loop() {
  byte val = analogRead(ANALOG_IN);
  Serial.write(val);
}
