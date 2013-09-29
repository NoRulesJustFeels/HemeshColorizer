/*
Hemesh Colorizer
 Copyright (C) 2013 Entertailion
 
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
 
 WB_Vector zAxis = new WB_Vector(0,0,1);
 WB_Vector xAxis = new WB_Vector(1,0,0);
 WB_Vector yAxis = new WB_Vector(0,-1,0);
 WB_Vector origin = new WB_Vector(0,0,0);
 
// color the mesh faces
void colorHemesh() {
  colorMap.clear();
  
  if (colorAlgorithm<1000) {
    Iterator <HE_Face> fItr = myShape.fItr();
    HE_Face f;
    color c;
    while (fItr.hasNext ()) { 
      f = fItr.next(); 
      c = faceColor(f);
      colorMap.put(f.key(), c);
    }
  } else {
    colorMode(RGB, 255, 255, 255, 255);
    color c = color(255, 255, 255); 
    
    switch(colorAlgorithm) {
  case 1000:  // Vertical stripes
    //c = color(int(map(faceZ-minZ, 0, shapeHeight, 0, P1)), int(map(faceZ-minZ, 0, shapeHeight, 0, P2)), int(map(faceZ-minZ, 0, shapeHeight, 0, P3)));
    break;
  case 1001: // Lighter/Darker
    //t = tan(map(faceZ, minZ, maxZ, 0, 1) * PI * 2 * P4);
    //c = color(t*P1, t*P2, t*P3);
    break;     
  default:
    c = color(255, 255, 255);
  }
  colorMode(RGB, 255, 255, 255, 255);
  }
}

color faceColor(HE_Face f) {
  // face data
  WB_Point faceCenter = f.getFaceCenter();
  float faceX = faceCenter.xf();
  float faceY = faceCenter.yf();
  float faceZ = faceCenter.zf();
  float faceArea = (float)f.getFaceArea();
  float relativeZ = faceZ-minZ;
  float originDistance = (float)WB_Distance.distance(origin, faceCenter.toVector());

  colorMode(RGB, 255, 255, 255, 255);
  color c = color(255, 255, 255); 

  switch(colorAlgorithm) {
  case 0:  // 1 color linear
    c = color(int(map(relativeZ, 0, diffZ, 0, P1)), int(map(relativeZ, 0, diffZ, 0, P2)), int(map(relativeZ, 0, diffZ, 0, P3)));
    break;
  case 1:  // 1 color linear inverse
    c = color(int(map(relativeZ, 0, diffZ, P1, 0)), int(map(relativeZ, 0, diffZ, P2, 0)), int(map(relativeZ, 0, diffZ, P3, 0)));
    break;
  case 2: // HSB
    colorMode(HSB, 255, 255, 255);
    float relative = (relativeZ)/maxZ;
    c = color(P1+(relative * P2), P3+(relative * P4), P5+(relative * P6));
    break;
  case 3: // Random
    c = color(random(255), random(255), random(255));
    break;
  case 4: // Random 2
    if (random(3)>1) {
      c = color(P1, P2, P3);
    } 
    else {
      c = color(P4, P5, P6);
    }
    break;
  case 5: // Random RGB
    c = color(P1 + random(P4-P1), P2 + random(P5-P2), P3 + random(P6-P3));
    break;
  case 6: // Face area
    c = color(int(map(faceArea-faceMin, 0, faceMax, 0, P1)), int(map(faceArea-faceMin, 0, faceMax, 0, P2)), int(map(faceArea-faceMin, 0, faceMax, 0, P3)));
    break;
  case 7: // 2 colors
    if (faceZ < middleZ) {
      c = color(int(map(faceZ, 0, diffZ, P1, 0)), int(map(faceZ, 0, diffZ, P2, 0)), int(map(faceZ, 0, diffZ, P3, 0)));
    } 
    else {
      c = color(int(map(faceZ, 0, diffZ, 0, P4)), int(map(faceZ, 0, diffZ, 0, P5)), int(map(faceZ, 0, diffZ, 0, P6)));
    }
    break;
  case 8: // 2 color linear
    float t = map(faceZ, minZ, maxZ, 0, 1);
    c = color((1-t)*P1+t*P4, (1-t)*P2+t*P5, (1-t)*P3+t*P6);
    break; 
  case 9: // Polar Color-Space Interpolation: http://www.stuartdenman.com/improved-color-blending/
    colorMode(HSB, 255, 255, 255);
    int h1 = P1;
    int h2 = P4;
    float h = h1;
    if (h1>h2) {  // swap
      int tmp = h1;
      h1 = h2;
      h2 = tmp;
    }
    t = map(faceZ, minZ, maxZ, 0, 1);
    int d = h2 - h1;
    //if (P1 > P2) then swap(h1, h2), d = -d, f = 1 - f
    if (d > 127) { 
      h1 = h1 + 255;
      h = ( h1 + t * (h2 - h1) ) % 255;
    } 
    else {
      h = h1 + t * d;
    }
    c = color(h, (1-t)*P2+t*P5, (1-t)*P3+t*P6);
    break; 
  case 10: // Odd
    if (f.getLabel()%2==0) {
      c = color(P1, P2, P3);
    } 
    else {
      c = color(P4, P5, P6);
    }
    break; 
  case 11: // Face height Hue 2
    colorMode(HSB, 255, 255, 255);
    t = map(faceZ, minZ, maxZ, 0, 1);
    c = color((1-t)*P1+t*P4, (1-t)*P2+t*P5, (1-t)*P3+t*P6);
    break; 
  case 12: // Rainbow
    colorMode(HSB, 255, 255, 255);
    t = map(faceZ, minZ, maxZ, 0, 255);
    c = color(t, 255, 255);
    break;  
  case 13: // Mapping
    c = color(int(map(relativeZ, 0, diffZ, P1, P4)), int(map(relativeZ, 0, diffZ, P2, P5)), int(map(relativeZ, 0, diffZ, P3, P6)));
    break;  
  case 14: // Ripples
    t = tan(map(faceZ, minZ, maxZ, 0, 1) * PI * 2 * P4);
    c = color(t*P1, t*P2, t*P3);
    break;  
  case 15: // Normals
    WB_Normal faceNormal = f.getFaceNormal();
    float normalDegrees = degrees((float)faceNormal.angleNorm(yAxis));
    //t = 1-sin(map(normalDegrees, 0, 180, 0, 1)*PI*2);
    if (normalDegrees<45) {  // make back black
      normalDegrees = 45;
    }
    t = cos(map(normalDegrees, 0, 180, 0, 1)*PI*2);
    c = color(t*P1, t*P2, t*P3);
    break;
   case 16: // Rainbow
    colorMode(HSB, 255, 255, 255);
    float max = shapeHeight;
    if (shapeWidth>shapeHeight) {
      max = shapeWidth;
    }
    t = map(originDistance, 0, maxD, 0, 255);
    c = color(t, 255, 255);
    break;  
  default:
    c = color(255, 255, 255);
  }
  colorMode(RGB, 255, 255, 255, 255);
  return c;
}

