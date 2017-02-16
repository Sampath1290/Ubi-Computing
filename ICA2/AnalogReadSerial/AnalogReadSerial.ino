// the setup routine runs once when you press reset:
void setup() {
  Serial.begin(57600);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin A3:
  int sensorValue = analogRead(A3);
  uint8_t new_val = map(sensorValue, 0, 4096, 0, 255);
  // print out the value you read:
  Serial.write(new_val);
  delay(1); // delay in between reads for stability
}
