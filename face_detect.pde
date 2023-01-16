import saito.objloader.*;  // model loader
OBJModel model;

import hypermedia.video.*; // OpenCV
OpenCV opencv;

import processing.opengl.*; // needed for OpenCV

import java.awt.Rectangle; // needed for OpenCV in more recent versions of Processing

float rotX;
float rotY;
PFont font;
float heightval = 0;
float counter = 0;
float deg = 0;
float scaleval = 0;

boolean direction = true;
boolean rot = true;

PImage face;

void setup()
{ 
  font = loadFont("Futura-CondensedExtraBold-35.vlw");

  size(400, 400, OPENGL);

  opencv = new OpenCV( this );
  opencv.allocate( width, height );  
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );  

  model = new OBJModel(this, "femalehead.obj"); 
  scaleval = 1.0; 
  heightval = 0;  
}

void draw()
{
  if (rot){
    if (direction){
      counter = counter - .1;
    }
    else{
      counter = counter + .1;
    }
  }

  background(0);  // black background
  noStroke();
  lights();       // light the scene

  textFont(font);
  text(deg, 15, 30); // display the angle in degrees

  pushMatrix();
  translate(width/2, height/2 + heightval, 0);
  rotateX(rotX); 
  rotateY(counter);

  scale(scaleval);
  model.drawMode(POLYGON);
  model.draw();
  popMatrix();

  PImage img = createImage(width, height, RGB); // set up the image for OpenCV
  img.loadPixels();
  loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = pixels[i];
  }
  img.updatePixels();

  opencv.copy(img);

  // proceed detection
  Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );
  // draw face area(s)
  noFill();
  stroke(255,0,0);
  for( int i=0; i<faces.length; i++ ) { // draw box around face
    beginShape();
    vertex(faces[i].x, faces[i].y, 60);
    vertex(faces[i].x, faces[i].y+faces[i].height, 60);
    vertex(faces[i].x+faces[i].width, faces[i].y+faces[i].height, 60);    
    vertex(faces[i].x+faces[i].width, faces[i].y, 60);
    endShape(CLOSE);
  }

  if (faces.length < 1){
    direction = !direction;
    deg = degrees(counter);

  }
}

void keyPressed()
{
  if(key == 'q')
    model.enableTexture(); // enable textures
  if(key == 'w')
    model.disableTexture(); // disable textures
  if(key == 'a')
    rot = !rot;             // toggle rotation
}

void mouseDragged()
{
  rotX += (mouseX - pmouseX) * 0.05;
}

public void stop() {
  opencv.stop();
  super.stop();
}


