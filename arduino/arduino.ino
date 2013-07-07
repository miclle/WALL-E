#include "pt.h"
#include <aJSON.h>

int E1 = 6;
int M1 = 7;

int E2 = 5;
int M2 = 4;

static struct pt pt_serial_read, pt_motor_right, pt_motor_left;

int LED = 13;

static long MOTOR_BLINK =  1000;

static long SERIAL_IO_BLINK = 100;

static int INIT_SPEED = 200;

// Serial read
// Test: Serial Input {"name": "Miclle Zheng"}

static int serial_read_thread( struct pt *pt, long timeout ) {
  static long t2 = 0;
  PT_BEGIN( pt );
  while(1) {
    PT_WAIT_UNTIL( pt, (millis() - t2) > timeout );
    t2 = millis();

    int availableBytes = Serial.available();

    if( availableBytes > 0){

      char charBuf[availableBytes];

      Serial.println(availableBytes);

      Serial.readBytes(charBuf, availableBytes);

      // int i = 0;
      // while (Serial.available() > 0){
      //   // Serial.println(char(Serial.read()));
      //   // comdata += char(Serial.read());
      //   charBuf[i] = Serial.read();
      //   i++;
      // }

      Serial.print("charBuf: ");
      Serial.println(charBuf);

      aJsonObject* root = aJson.parse(charBuf);
      aJsonObject* name = aJson.getObjectItem(root, "name");

      Serial.print("name: ");
      Serial.println(name->valueint);
    }

  }
  PT_END( pt );
}

static int motor_right_thread( struct pt *pt, long timeout ) {
  static long t1 = 0;
  PT_BEGIN( pt );
  while(1) {
    PT_WAIT_UNTIL( pt, (millis() - t1) > timeout );

    digitalWrite( LED, !digitalRead( LED ) );
    digitalWrite(M1, LOW);
    analogWrite(E1, INIT_SPEED);   //PWM调速

    t1 = millis();
  }
  PT_END( pt );
}

static int motor_left_thread( struct pt *pt, long timeout ) {
  static long t1 = 0;
  PT_BEGIN( pt );
  while(1) {
    PT_WAIT_UNTIL( pt, (millis() - t1) > timeout );

    digitalWrite( LED, !digitalRead( LED ) );
    digitalWrite(M2, LOW);
    analogWrite(E2, INIT_SPEED);   //PWM调速

    t1 = millis();
  }
  PT_END( pt );
}

// Setup Initialization, setup code run once.
void setup() {
  Serial.begin(9600);

  pinMode( LED, OUTPUT );

  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);

  PT_INIT( &pt_motor_right );
  PT_INIT( &pt_serial_read );
  PT_INIT( &pt_motor_left );
}

// Loop, put your main code here, to run repeatedly
void loop() {
  motor_left_thread( &pt_motor_left, MOTOR_BLINK );
  motor_right_thread( &pt_motor_right, MOTOR_BLINK );
  serial_read_thread( &pt_serial_read, SERIAL_IO_BLINK );
}


