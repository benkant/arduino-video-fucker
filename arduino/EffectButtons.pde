int blurPin = 13;
int brightnessPin;
int convolutionPin = 12;
int edgePin;
int val = 0;

void setup() {
  Serial.begin(9600);
  pinMode(blurPin, INPUT);
}

void loop() {
  // blur
  Serial.print("blur:");
  Serial.println(digitalRead(blurPin));
  
  // convolution
  Serial.print("convolution:");
  Serial.println(digitalRead(convolutionPin));
}
  
