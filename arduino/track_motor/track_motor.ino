int E1 = 7;                        
int M1 = 6;

int E2 = 5;                        
int M2 = 4;

int val;//定义变量val

void setup() {
  // put your setup code here, to run once:
  pinMode(M1, OUTPUT);
  pinMode(M2, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly: 
  val = Serial.read();//读取PC机发送给Arduino的指令或字符，并将该指令或字符赋给val
  
//  int value;
//  for(value = 0 ; value <= 255; value+=5)
//  { 
    digitalWrite(M1, HIGH);
    digitalWrite(M2, HIGH);
    analogWrite(E1, val);   //PWM调速
    analogWrite(E2, -val);   //PWM调速
    Serial.print("#1 val: ");
    Serial.println(val);
    delay(1000);
//  }
}
