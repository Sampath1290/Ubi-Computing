int ledPin = 6;    // LED connected to digital pin 9

void setup()  { 
  // nothing happens in setup 
  Serial.begin(9600);

  pinMode(6,OUTPUT);
} 

void loop()  { 
  int value[50]; 
  int max_ = 0;
  int min_ = 4096;
  for(int i = 0; i < 50; i++){
    value[i] = analogRead(A3);
    if(value[i] < min_){
      min_ = value[i];
    }
    if(value[i] > max_){
      max_ = value[i];
    }
  }

  if(max_ > 4000) {
    analogWrite(6, 255);
    Serial.println("Bright!");
  }
  else{
    analogWrite(6,25);
  }
  delay(100);
  
  Serial.print("asparagus ");
  Serial.print(min_);
  Serial.print(", ");
  Serial.println(max_);
}


