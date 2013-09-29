/*
Hemesh Colorizer
 Copyright (C) 2013 Amnon Owed, Entertailion
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

/*
 Based on HemeshGui (https://code.google.com/p/amnonp5/)
 by Amnon Owed (http://amnonp5.wordpress.com)
 */

import wblut.processing.*;
import wblut.hemesh.tools.*;
import wblut.hemesh.creators.*;
import wblut.hemesh.modifiers.*;
import wblut.hemesh.subdividors.*;
import wblut.hemesh.core.*;
import wblut.geom.*;

// Toxiclibs for the import stl and save color stl
import toxi.util.datatypes.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.util.*;
import toxi.processing.*;
import controlP5.*;

import processing.opengl.*;

// general settings
int sceneWidth = 1280;                 // sketch width
int sceneHeight = 720;                 // sketch height

// view
float zoom = 20;                       // zoom factor
boolean autoRotate = false;             // toggle autorotation
float translateX;
float translateY;
float autoRotationX;
float autoRotationZ;
float autoRotationSpeed = 1.5;  

// presentation
color bgColor = color(255, 255, 255);    // background color
color shapecolor;                      // shape color
boolean facesOn = true;                // toggle display of faces
boolean edgesOn = true;                // toggle display of edges
boolean ligthsOn = true;

// basic shape variables
int creator = 2;                       // default shape: Dodecahedron
float create0 = 4;                     // default shape value
float create1 = 4;                     // default shape value
float create2 = 4;                     // default shape value
float create3 = 4;                     // default shape value

// assorted
ArrayList modifiers = new ArrayList(); // arraylist to hold all the modifiers
int numForLoop = 20;                   // max number of shapes, modifiers and/or subdividors in the gui (for convenience, just increase when there are more)
boolean drawControlP5 = true;          // toggle drawing of controlP5 gui

String[] stlFiles;
String currentStlFile;

String shapesDirectory = "shapes";
String outputDirectory = "output";
String screenshotsDirectory = "screenshots";

int colorAlgorithm;

// mouse rotation
float mouseStartX, mouseStartY;
float mouseRotateX, mouseRotateY, mouseRotateZ;
float rotationX, rotationY, rotationZ;
boolean mouseDragged;

// color algorithm parameters
int P1 = 207;
int P2 = 181;
int P3 = 59;
int P4 = 57;
int P5 = 96;
int P6 = 100;

// Jiggle
int J = 10;


void setup() {
  size(sceneWidth, sceneHeight, OPENGL);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  frameRate(30);
  stlFiles = listStlFiles();
  if (stlFiles.length>0) {
    currentStlFile = stlFiles[0];
  }

  render = new WB_Render(this);

  initViewport();
  createHemesh();
  colorHemesh();
  autoZoom();

  gui();
}

void autoZoom() {
  zoom = (100/shapeHeight*4);
  println(zoom);
}

void draw() {
  background(bgColor);

  hint(ENABLE_DEPTH_TEST);

  pushMatrix();
  if (ligthsOn) {
    lights();
  } else {
    noLights();
  }
  noStroke();
  viewport();
  drawHemesh();
  popMatrix();

  hint(DISABLE_DEPTH_TEST);

  if (drawControlP5) {
    perspective();
    hint(DISABLE_DEPTH_TEST);
    controlP5.draw(); 
    hint(ENABLE_DEPTH_TEST);
  }
}

void viewport() {
  translate(translateX, translateY);
  //rotateX(PI/2);

  if (autoRotate && !mousePressed) {
    autoRotationX += autoRotationSpeed;
    autoRotationZ -= autoRotationSpeed;
  }
  rotateX(radians(autoRotationX));
  rotateZ(radians(autoRotationZ));

  rotateX(rotationX);
  rotateZ(rotationZ);

  scale(zoom);
}

void initViewport() {
  // move origin to center of the screen
  translateX = width/2;
  translateY = height/2;
  
  rotationX = PI/2;
  rotationZ = PI;
  
  autoRotationX = 0;
  autoRotationZ = 0;
  
  zoom = 1;
}

// mouse events
public void mouseDragged() { 
  if (controlP5.window(this).isMouseOver()) return;

  rotationX = (((mouseY-mouseStartY+height/2)*-1.0f/height)*TWO_PI-PI)+mouseRotateX;
  rotationZ =  (((mouseX-mouseStartX+width/2)*-1.0f/width)*TWO_PI-PI)+mouseRotateZ;
}

public void mouseReleased() {
  mousePressed = false;
}

public void mousePressed() {
  mouseStartX = mouseX;
  mouseStartY = mouseY;
  mouseRotateX = rotationX;
  mouseRotateZ = rotationZ;
  mousePressed = true;
}

String[] listStlFiles() {
  println("listStlFiles");
  // we'll have a look in the shapes folder
  java.io.File folder = new java.io.File(sketchPath+"/"+shapesDirectory);

  // let's set a filter (which returns true if file's extension is .stl)
  java.io.FilenameFilter stlFilter = new java.io.FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".stl");
    }
  };

  // list the files in the shapes folder, passing the filter as parameter
  String[] filenames = folder.list(stlFilter);

  // get and display the number of jpg files
  println(filenames.length + " STL files");

  // display the filenames
  for (int i = 0; i < filenames.length; i++) {
    println(filenames[i]);
  }
  return filenames;
}

