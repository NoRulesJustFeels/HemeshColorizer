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


ControlP5 controlP5; // http://www.sojamo.de/libraries/controlP5/reference/index.html
DropdownList shapeList;
DropdownList modifyList;
DropdownList colorList;
Textlabel keyboardShortcuts;

void gui() {
  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);

  // gui colors
  controlP5.setColorBackground(color(162, 153, 125));
  controlP5.setColorForeground(color(204, 204, 0));
  controlP5.setColorLabel(color(0, 0, 0));
  controlP5.setColorValue(color(0, 0, 0));
  controlP5.setColorActive(color(224, 224, 0));

  // view
  controlP5.addSlider("zoom", 0, 500, 20, 20, 200, 15).setDecimalPrecision(0);

  // color algorithm parameters
  controlP5.addSlider("P1", 0, 255, 20, 40, 200, 15).setLabel("P1");                      
  controlP5.addSlider("P2", 0, 255, 20, 60, 200, 15).setLabel("P2");        
  controlP5.addSlider("P3", 0, 255, 20, 80, 200, 15).setLabel("P3");         
  controlP5.addSlider("P4", 0, 255, 20, 100, 200, 15).setLabel("P4");         
  controlP5.addSlider("P5", 0, 255, 20, 120, 200, 15).setLabel("P5");        
  controlP5.addSlider("P6", 0, 255, 20, 140, 200, 15).setLabel("P6");    

  // jiggle button
  controlP5.addSlider("J", 0, 100, 20, 160, 200, 15).setLabel(""); 
  controlP5.addButton("jiggle", 0, 230, 160, 35, 20).setLabel("JIGGLE");

  // 250 146
  // ShapeList
  shapeList = controlP5.addDropdownList("myShapeList", width-355, 40, 96, 400);
  shapeList.setBarHeight(20);
  shapeList.setItemHeight(15);
  shapeList.captionLabel().set("Select Shape");
  shapeList.captionLabel().style().marginTop = 6;
  shapeList.captionLabel().style().marginLeft = 3;

  for (int i=0; i<stlFiles.length; i++) {
    shapeList.addItem(stlFiles[i], i);
  }

  // ModifyList
  modifyList = controlP5.addDropdownList("myModifyList", width-250, 40, 96, 400);
  modifyList.setBarHeight(20);
  modifyList.setItemHeight(15);
  modifyList.captionLabel().set("Select Modifier");
  modifyList.captionLabel().style().marginTop = 6;
  modifyList.captionLabel().style().marginLeft = 3;

  // modifiers
  for (int i=101; i<101 + numForLoop; i++) {
    if (numToName(i) != "None") { 
      modifyList.addItem(numToName(i), i);
    }
  }

  // ===
  modifyList.addItem(numToName(-1), -1);

  // subdividors
  for (int i=201; i<201 + numForLoop; i++) {
    if (numToName(i) != "None") { 
      modifyList.addItem(numToName(i), i);
    }
  }

  // ColorList
  colorList = controlP5.addDropdownList("myColorList", width-146, 40, 96, 400);
  colorList.setBarHeight(20);
  colorList.setItemHeight(15);
  colorList.captionLabel().set("Select Color");
  colorList.captionLabel().style().marginTop = 6;
  colorList.captionLabel().style().marginLeft = 3;

  colorList.addItem("1 Color Linear", 0);
  colorList.addItem("1 Color Linear Inv", 1);
  colorList.addItem("HSB", 2);
  colorList.addItem("Random", 3);
  colorList.addItem("Random 2", 4);
  colorList.addItem("Random RGB", 5);
  colorList.addItem("Face Area", 6);
  //colorList.addItem("2 Colors", 7);
  colorList.addItem("2 Color Linear", 8);
  colorList.addItem("2 Polar Interp", 9);
  colorList.addItem("Odd", 10);
  colorList.addItem("Face Height Hue 2", 11);
  colorList.addItem("Rainbow", 12);
  colorList.addItem("Mapping", 13);
  colorList.addItem("Ripples", 14);
  colorList.addItem("Normals", 15);
  colorList.addItem("Rainbow Origin", 16);
  //colorList.addItem("Vertical", 1000);

  // keyboard shortcuts
  keyboardShortcuts = controlP5.addTextlabel("keyboardShortcuts", "KEYBOARD SHORTCUTS: G = GUI, S = SCREENSHOT, E = EXPORT, A = AUTO-ROTATE, L = LINES, F = FACES, R = RENDER LIGHTS", 20, height-20);
  keyboardShortcuts.setColorValue(color(0, 0, 0));

  // reset button
  controlP5.addButton("reset", 0, width-50, height-30, 30, 20).setLabel("RESET");


  // ===========================================>
  // some non-gui stuff that needs to run @ setup

  // listen to mouseWheel (used for zooming)
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      if (!mousePressed) {
        mouseWheel(evt.getWheelRotation());
      }
    }
  }
  );
}

// zooming with the mouseWheel
void mouseWheel(int delta) {
  if (delta > 0) { 
    if (zoom > 20) { 
      controlP5.controller("zoom").setValue(zoom - 10);
    } 
    else { 
      controlP5.controller("zoom").setValue(zoom - 1);
    }
  }
  else if (delta < 0) { 
    if (zoom >= 20) { 
      controlP5.controller("zoom").setValue(zoom + 10);
    } 
    else { 
      controlP5.controller("zoom").setValue(zoom + 1);
    }
  }
}

void reset() {
  // color algorithm parameters
  controlP5.controller("P1").setValue(207);
  controlP5.controller("P2").setValue(181);
  controlP5.controller("P3").setValue(59);
  controlP5.controller("P4").setValue(57);
  controlP5.controller("P5").setValue(100);
  controlP5.controller("P6").setValue(96);

  // ShapeList + ModifyList
  shapeList.captionLabel().set("Select Shape");
  modifyList.captionLabel().set("Select Modifier");

  // remove the gui elements for all modifiers
  for (int i=0; i<modifiers.size(); i++) {
    controlP5.remove("remove" + i);
    for (int j=0; j<5; j++) {
      controlP5.remove(i+"v"+j);
    }
  }

  // remove all modifiers
  modifiers.clear();

  initViewport();

  // start up again
  createHemesh();
  colorHemesh();
  autoZoom();

  controlP5.controller("zoom").setValue(zoom);
}

void jiggle() {
  println("jiggle");
  jiggleHemesh();
}

// reset the view & color, but leave shape & modifiers intact
void resetView() {

  // view
  controlP5.controller("zoom").setValue(20);

  // color algorithm parameters
  controlP5.controller("P1").setValue(207);
  controlP5.controller("P2").setValue(181);
  controlP5.controller("P3").setValue(59);
  controlP5.controller("P4").setValue(57);
  controlP5.controller("P5").setValue(100);
  controlP5.controller("P6").setValue(96);
}

// command & control center ;-)
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    int selected = int(theEvent.group().value());
    if (selected >= 0) {
      // when a shape is selected
      if (theEvent.group().name() == "myShapeList") {
        initViewport();
        creator = selected;
        currentStlFile = stlFiles[int(theEvent.group().value())];
        createHemesh();
        colorHemesh();
        autoZoom();
        controlP5.controller("zoom").setValue(zoom);
      } 
      else if (theEvent.group().name() == "myModifyList") {
        // when a modifier is selected
        modifiers.add( new Modifier(modifiers.size(), selected, numToFloats(selected)) );
        createHemesh();
        colorHemesh();
        autoZoom();
        controlP5.controller("zoom").setValue(zoom);
      }
      else if (theEvent.group().name() == "myColorList") {
        // when a color algorithm is selected
        colorAlgorithm = selected;
        colorHemesh();
      }
    }
  } 
  else if (theEvent.isController()) {
    // when a remove button is pressed
    if (theEvent.controller().name().startsWith("remove")) {
      modifiers.remove(theEvent.controller().id());
      controlP5.remove("remove" + theEvent.controller().id());
      for (int i=0; i<5; i++) {
        controlP5.remove(theEvent.controller().id()+"v"+i);
      }
      createHemesh();
      colorHemesh();
    }
    else if (theEvent.controller().name().equals("P1") || theEvent.controller().name().equals("P2") || theEvent.controller().name().equals("P3") || theEvent.controller().name().equals("P4") || theEvent.controller().name().equals("P5") || theEvent.controller().name().equals("P6")) {
      // when a color algorithm parameter slider is modified
      colorHemesh();
    }

    for (int i=0; i<5; i++) {
      // forward modify values from controlP5 into seperate classes
      if (theEvent.controller().name().endsWith("v" + i)) {
        Modifier m = (Modifier) modifiers.get(theEvent.controller().id());
        for (int j=0; j<5; j++) {
          if (i==j) { 
            m.values[j] = theEvent.value();
          }
        }
        createHemesh();
        colorHemesh();
      }
    }
  }
}

// some useful keyboard actions
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      translateY = translateY+1;
    } 
    else if (keyCode == DOWN) {
      translateY = translateY-1;
    } 
    else if (keyCode == LEFT) {
      translateX = translateX-1;
    } 
    else if (keyCode == RIGHT) {
      translateX = translateX+1;
    }
  }

  // toggle the controlP5 gui
  if (key == 'g') { 
    println("GUI");
    drawControlP5 = !drawControlP5;
  }

  // save a single screenshot
  if (key == 's') {
    println("Screenshot");
    save(screenshotsDirectory+"/" + DateUtils.timeStamp() + ".png");
  }

  // export shape to a STL file
  if (key == 'e') {
    println("Export");
    String name = DateUtils.timeStamp();
    save(outputDirectory+"/" + name + ".png");

    stlWrite(name);
    println("STL exported");

    exportVRML(name);
    println("VRML exported");

    exportSettings(name);
    println("Settings exported");
  }

  // auto-rotate
  if (key == 'a') {
    println("Auto-Rotate");
    autoRotate = !autoRotate;
  }
  
  // edge lines
  if (key == 'l') {
    println("Lines");
    edgesOn = !edgesOn;
  }
  
  // faces
  if (key == 'f') {
    println("Faces");
    facesOn = !facesOn;
  }
  
   // render lights
  if (key == 'r') {
    println("Render lights");
    ligthsOn = !ligthsOn;
  }
}

void exportSettings(String name) {
  println("exportSettings");
  StringBuffer buffer = new StringBuffer();
  buffer.append("zoom=").append(zoom).append("\n");
  buffer.append("P1=").append(P1).append("\n");
  buffer.append("P2=").append(P2).append("\n");
  buffer.append("P3=").append(P3).append("\n");
  buffer.append("P4=").append(P4).append("\n");
  buffer.append("P5=").append(P5).append("\n");
  buffer.append("P6=").append(P6).append("\n");
  buffer.append("colorAlgorithm=").append(colorAlgorithm).append("\n");

  String[] output=new String[1];
  output[0] = buffer.toString();
  saveStrings(outputDirectory+"/" + name + ".txt", output);
}

