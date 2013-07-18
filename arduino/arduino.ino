int E1 = 6;
int M1 = 7;

int E2 = 5;
int M2 = 4;

int LED = 13;

int ML_STATUS;
int ML_SPEED;

int MR_STATUS;
int MR_SPEED;

String key = "";
int value = '\0';

static void serial_read() {
  String comdata = "";

  while(Serial.available() > 0){ // Don't read unless there you know there is data
    comdata += char(Serial.read());
    delay(5);
  }

  Serial.flush();

  if (comdata.length() > 0){
    int semicolonPosition = comdata.indexOf(':');

    if(semicolonPosition!= -1){
      controller(comdata.substring(0, semicolonPosition), comdata.substring(semicolonPosition+1, comdata.length()).toInt());
    }
    comdata = "";
  }
}

// {"ml_status":0, "ml_speed":200, "mr_status":0, "mr_speed":200}
static void controller(String key, int value){
  if( key == "ml_status"){
    Serial.println(key);
    Serial.println(value);
  }
}

// Setup Initialization, setup code run once.
void setup() {
  Serial.begin(9600);

  pinMode( LED, OUTPUT );

  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);
}

// Loop, put your main code here, to run repeatedly
void loop() {
  digitalWrite( LED, !digitalRead( LED ) );

  serial_read();

}


