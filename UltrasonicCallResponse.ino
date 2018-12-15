// defines pins numbers
const int trigPin = 9;
const int echoPin = 10;
const int laserPin = 2;
const int startPin = 3;
// defines variables
long duration;
int distance;
int inByte = 0;
int distancemapped;
int laserReading;
int startReading;

void setup() {
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input
  establishContact();
}

void loop() {
  if (Serial.available() > 0) {
    // get incoming byte:
    inByte = Serial.read();

    // Clears the trigPin
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    // Sets the trigPin on HIGH state for 10 micro seconds
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    // Reads the echoPin, returns the sound wave travel time in microseconds
    duration = pulseIn(echoPin, HIGH);
    // Calculating the distance
    distance = duration * 0.034 / 2;
    distancemapped = map(distance, 0, 150, 0, 255);
    laserReading=digitalRead(laserPin);
    startReading=digitalRead(startPin);
    // Prints the distance on the Serial Monitor
    //Serial.print("Distance: ");
    //Serial.println(distancemapped);


    //if (distancemapped > 5 and distancemapped < 245) {
      Serial.write(distancemapped);
      Serial.write(laserReading);
      Serial.write(startReading);
    //}


  }

}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
}
