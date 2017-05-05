/*

Copyright (c) 2012-2014 RedBearLab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

/*
 *    Chat
 *
 *    Simple chat sketch, work with the Chat iOS/Android App.
 *    Type something from the Arduino serial monitor to send
 *    to the Chat App or vice verse.
 *
 */

//"RBL_nRF8001.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <Servo.h>
#include <RBL_nRF8001.h>

Servo myservo;

//const int BTN_PIN = 2;
//const int LED_PIN = 3;
const int SERVO_PIN = 6; 
//const int POT_PIN = A0;

void setup()
{  
  // Set your BLE Shield name here, max. length 10
  ble_set_name("Gizmo v1.0");

//  pinMode(BTN_PIN,INPUT);
//  pinMode(LED_PIN,OUTPUT);
//  pinMode(POT_PIN, INPUT);
//  digitalWrite( LED_PIN, LOW );

  
//  attachInterrupt(digitalPinToInterrupt(BTN_PIN), strobeTheLight, CHANGE);
//  attachInterrupt(digitalPinToInterrupt(BTN_PIN), buttonRelease, FALLING);


  myservo.attach(SERVO_PIN);
  myservo.write(0);
  
  // Init. and start BLE library.
  ble_begin();
    
  // Enable serial debug
  Serial.begin(57600);
}

void writeMulti(int servoPos1, int servoPos2, int servoPos3) {
  myservo.write(servoPos1);
  delay(100);
  myservo.write(servoPos2);
  delay(200);
  myservo.write(servoPos3);
}

unsigned char buf[16] = {0};
unsigned char len = 0;
String command;


bool waiting = false;
unsigned long TimerA;
unsigned long scheduledMillis = 0;
int scheduledVal1 = 0;
int scheduledVal2 = 0;
int scheduledVal3 = 0;

void loop()
{

  //read from bluetooth low energy
  if ( ble_available() )
  {
    command = "";
    while ( ble_available() ) {
      char c = ble_read();
      command += c; //add each character to the command
    }
    Serial.println(command);
    

//    if( command.substring(0,9) == "Light ON;" ) {
//      lightOn = HIGH;
//      digitalWrite( LED_PIN, HIGH );
//    }
//    else if ( command.substring(0,10) == "Light OFF;" ) {
//      lightOn = LOW;
//      digitalWrite( LED_PIN, LOW );
//    }
    
    if ( command.substring(0,5) == "Servo" ) {
        String servoPos = command.substring(6,command.indexOf(';'));
        myservo.write(servoPos.toInt());
    } else if ( command.substring(0,10) == "MultiServo" ) {
        int spaceIndex = command.indexOf(' ',11);
        int spaceIndex2 = command.indexOf(' ',spaceIndex+1);
        String servoPos1 = command.substring(11,spaceIndex);
        String servoPos2 = command.substring(spaceIndex+1,spaceIndex2);
        String servoPos3 = command.substring(spaceIndex2+1,command.indexOf(';'));
        
        Serial.println("Writing: ("+servoPos1+","+servoPos2+","+servoPos3+")");
        
        writeMulti(servoPos1.toInt(),servoPos2.toInt(),servoPos3.toInt());
    } else if ( command.substring(0,8) == "Schedule" ) {
       String seconds = command.substring(9,command.indexOf(';'));
       
       Serial.println("Waiting seconds: "+seconds);
       scheduledMillis = millis();
       Serial.println("Millis now: "+String(scheduledMillis));
       Serial.println("Add: "+String(1000*seconds.toInt()));
       scheduledMillis += 1000*seconds.toInt();
       Serial.println("Scheduled millis: "+String(scheduledMillis));
       Serial.println("millis now: "+String(millis()));
       
       scheduledVal1 = 20;
       scheduledVal2 = 50;
       scheduledVal3 = 20;
    } else if ( command.substring(0,13) == "MultiSchedule" ) {

       int spaceIndex = command.indexOf(' ',14);
       int spaceIndex2 = command.indexOf(' ',spaceIndex+1);
       int spaceIndex3 = command.indexOf(' ',spaceIndex2+1);
       String seconds = command.substring(14,spaceIndex);
       String servoPos1 = command.substring(spaceIndex+1,spaceIndex2);
       String servoPos2 = command.substring(spaceIndex2+1,spaceIndex3);
       String servoPos3 = command.substring(spaceIndex3+1,command.indexOf(';'));
        
       Serial.println("Writing: ("+servoPos1+","+servoPos2+","+servoPos3+")");
        
       Serial.println("Waiting seconds: "+seconds);
       scheduledMillis = millis() + 1000*seconds.toInt();
       
       scheduledVal1 = servoPos1.toInt();
       scheduledVal2 = servoPos2.toInt();
       scheduledVal3 = servoPos3.toInt();
    }
    Serial.println("Command: "+ command);
    
    Serial.println();
  } 
  
  


  //check if there's something scheduled
  if( scheduledMillis > 0 ) {
    unsigned long millisNow = millis();
    Serial.println(millisNow);
    if( millisNow > scheduledMillis) {
      //activate servo
      Serial.println("ACTIVATE SCHEDULED ACTIVITY");
      writeMulti(scheduledVal1,scheduledVal2,scheduledVal3);
      scheduledMillis = 0;
    }
  }

//  interrupts();
  //read from serial port
  if ( Serial.available() )
  {
    delay(5);
    
    while ( Serial.available() )
      ble_write(Serial.read());
  }

  //read from pot
//  int newPotVal = analogRead(POT_PIN);
//  if( newPotVal != potVal ) {
//
//    //update potentiometer value
//    potVal = newPotVal;
//
//    //send the potentiometer value along BLE
//    String sendCommand = "POT " + String(potVal);
//    for( int i = 0; i < sendCommand.length(); i++ ) {
//      ble_write( sendCommand[i] );
//    }
//  }


  // determine strobe mode
//  if(lightOn) {
//    if( !waiting ) {
//      //turn LED off
//      digitalWrite(LED_PIN,LOW);
//      analogWrite(LED_PIN, 0);
//      waiting = true;
//      TimerA = millis();
//    }
//    else if(millis()-TimerA > delayVals[strobeMode]){
//      //wait a certain amount of time
//      waiting = false;
//      
//      //turn LED back on
//      digitalWrite(LED_PIN,HIGH);
//      int newBrightness = potVal/4;
//      analogWrite(LED_PIN, newBrightness);
//    }
//  }

  delay(10);
  
  
  ble_do_events();

//  interrupts();
  
}

