import processing.serial.*;
import processing.video.*;

Serial arduino;
Capture cam;
int lf = 10;
PFont font;

int blurOn = 0;
int convolutionOn = 0;

void setup() {
  size(800, 600);
  background(255);
  
  font = loadFont("BankGothic-Light-48.vlw");
  textFont(font);
  stroke(153);
  
  println("Capture devices:");
  println(Capture.list());
  
  cam = new Capture(this, width, height - 20, 30);
}

void draw() {
  background(255);
  String resp;
  String[] resparr;
  if (arduino == null) {
    try {
      arduino = new Serial(this, Serial.list()[4], 9600);
      arduino.bufferUntil(lf);
      arduino.clear();
    }
    catch (Exception ex) {
      println("Unable to connect to Arduino");
    }
  }
  else {
    while (arduino.available() > 0) {
      resp = arduino.readStringUntil(lf);
      if (resp != null) {
        if (resp.indexOf(":") > 0) {
          resparr = resp.split(":");
          int mode = -1;
          try {
            mode = Integer.parseInt(trim(resparr[1]));
          } catch (Exception e) {
          }
          finally {
            toggleEffect(resparr[0], mode);
          }
        }
        else {
          println("Got bad data: " + resp);
        }
      }
    }
    
  }

  //image(cam, 0, 0);
  
  fill(0, 0, 255);
  textSize(15);
  text("Blur is " + str(blurOn), 5, height - 5);
  text("Convolution is " + str(convolutionOn), 200, height - 5);
  
  if (blurOn == 1) {
    float v = 1.0/9.0;
    float[][] kernel = { { v, v, v },
                     { v, v, v },
                     { v, v, v } };
    cam.loadPixels();
    // Create an opaque image of the same size as the original
    PImage edgeImg = createImage(cam.width, cam.height, RGB);
    // Loop through every pixel in the image.
    for (int y = 1; y < cam.height-1; y++) { // Skip top and bottom edges
      for (int x = 1; x < cam.width-1; x++) { // Skip left and right edges
        float sum = 0; // Kernel sum for this pixel
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            // Calculate the adjacent pixel for this kernel point
            int pos = (y + ky)*width + (x + kx);
            // Image is grayscale, red/green/blue are identical
            float val = red(cam.pixels[pos]);
            // Multiply adjacent pixels based on the kernel values
            sum += kernel[ky+1][kx+1] * val;
          }
        }
        // For this pixel in the new image, set the gray value
        // based on the sum from the kernel
        edgeImg.pixels[y*cam.width + x] = color(sum);
      }
    }
    // State that there are changes to edgeImg.pixels[]
    edgeImg.updatePixels();
    image(edgeImg, 0, 0); // Draw the new image
  }
  else {
    image(cam, 0, 0);
  }
}

void toggleEffect(String effect, int state) {
  //print("effect: " + effect);
  //println(state);
  if (effect.equals("blur")) {
    blurOn = state;
  }
  else if (effect.equals("convolution")) {
    convolutionOn = state;
  }
}

void captureEvent(Capture cam) {
  cam.read();
}
