#include "pt.h"
#include <aJSON.h>

int E1 = 6;
int M1 = 7;

int E2 = 5;
int M2 = 4;

static struct pt pt_serial_read, pt_motor_right, pt_motor_left;

int LED = 13;

static long MOTOR_BLINK =  1000;

static int INIT_SPEED = 200;

int ML_STATUS;
int ML_SPEED;

int MR_STATUS;
int MR_SPEED;

// Serial read
// Test: Serial Input {"ml_status":0, "ml_speed":200, "mr_status":0, "mr_speed":200}

static int serial_read_thread( struct pt *pt ) {

  int availableBytes = Serial.available();

  PT_BEGIN( pt );

  while(1) {
    PT_WAIT_UNTIL( pt, availableBytes > 0 );

    Serial.print("execute here, availableBytes: ");
    Serial.println(Serial.available());

    // char inChar;
    // char inData[availableBytes + 1];

    // // Serial.readBytes(inData, availableBytes);

    // int index = 0;
    // while (Serial.available() > 0){

    //   inChar = char(Serial.read());

    //   Serial.println(inChar);

    //   inData[index] = inChar;
    //   index++;
    //   delay(2);
    // }

    // inData[index] = '\0';

    // // Serial.flush();

    // Serial.print("inData: ");
    // Serial.println(inData);

    availableBytes = 0;

    // aJsonObject* root = aJson.parse(inData);
    // aJsonObject* ml_status_obj = aJson.getObjectItem(root, "ml_status");
    // aJsonObject* ml_speed_obj = aJson.getObjectItem(root, "ml_speed");
    // aJsonObject* mr_status_obj = aJson.getObjectItem(root, "mr_status");
    // aJsonObject* mr_speed_obj = aJson.getObjectItem(root, "mr_speed");

    // ML_STATUS = ml_status_obj->valueint;
    // ML_SPEED = ml_speed_obj->valueint;
    // MR_STATUS = mr_status_obj->valueint;
    // MR_SPEED = mr_speed_obj->valueint;

    // Serial.println(ML_STATUS);
    // Serial.println(ML_SPEED);
    // Serial.println(MR_STATUS);
    // Serial.println(MR_SPEED);
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

  // PT_INIT( &pt_serial_read );
  // PT_INIT( &pt_motor_right );
  // PT_INIT( &pt_motor_left );
}

// Loop, put your main code here, to run repeatedly
void loop() {
  // serial_read_thread(&pt_serial_read);
  // motor_left_thread( &pt_motor_left, MOTOR_BLINK );
  // motor_right_thread( &pt_motor_right, MOTOR_BLINK );

  String comdata = "";

  while(Serial.available() > 0){ // Don't read unless there you know there is data
    comdata += char(Serial.read());
    delay(5);
  }

  if (comdata.length() > 0){
    Serial.println(comdata);

    char buf[comdata.length() + 1];
    comdata.toCharArray(buf, comdata.length() + 1);
    Serial.println(buf);
    comdata = "";
  }
  // Now do something with the string (but not using ==)
}


