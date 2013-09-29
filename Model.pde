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

HE_Mesh myShape;
HEM_Extrude extrude1 = new HEM_Extrude();
HEM_Extrude extrude2 = new HEM_Extrude();
WB_Render render;
HashMap <Integer, Integer> colorMap = new HashMap <Integer, Integer> ();

float shapeDepth, shapeHeight, shapeWidth, faceMax, faceMin, minZ, maxZ, middleZ, diffZ, maxD;

// create shape and run modifiers
void createHemesh() {
  //hemeshCreate(creator, create0, create1, create2, create3);
  if (currentStlFile!=null) {
    myShape = new HE_Mesh(fromStl(currentStlFile));
  }

  for (int i=0; i<modifiers.size(); i++) {
    Modifier m = (Modifier) modifiers.get(i);
    m.index = i;
    m.newMenu();
    m.hemesh();
  }

  // extract shape data
  WB_AABB aabb = myShape.getAABB();
  shapeDepth = (float)aabb.getHeight();
  shapeHeight = (float)aabb.getDepth();
  shapeWidth = (float)aabb.getWidth();
  println(shapeDepth +  ", " + shapeHeight +  ", " + shapeWidth);

  faceMin = 10000;
  faceMax = -10000;
  minZ = 10000;
  maxZ = -10000;
  Iterator <HE_Face> fItr = myShape.fItr();
  HE_Face f;
  ArrayList<HE_Vertex> vlist;
  float faceArea, distance;
  HE_Vertex v1, v2, v3;
  WB_Point faceCenter;
  while (fItr.hasNext ()) { 
    f = fItr.next(); 
    faceArea = (float)f.getFaceArea();
    if (faceArea > faceMax && faceArea < shapeHeight) {  // check infinity
      faceMax = faceArea;
    } 
    if (faceArea < faceMin) {
      faceMin = faceArea;
    }

    vlist = new ArrayList(f.getFaceVertices());
    if (vlist.size()==3) {
      v1 = vlist.get(0);
      v2 = vlist.get(1);
      v3 = vlist.get(2);
      if (v1.zf() > maxZ) {
        maxZ = v1.zf();
      }
      if (v2.zf() > maxZ) {
        maxZ = v2.zf();
      }
      if (v3.zf() > maxZ) {
        maxZ = v3.zf();
      }

      if (v1.zf() < minZ) {
        minZ = v1.zf();
      }
      if (v2.zf() < minZ) {
        minZ = v2.zf();
      }
      if (v3.zf() < minZ) {
        minZ = v3.zf();
      }
    }
    faceCenter = f.getFaceCenter();
    distance = (float)WB_Distance.distance(origin, faceCenter.toVector());
    if (distance > maxD) {
      maxD = distance;
    }
  }
  middleZ = (maxZ-minZ)/2;
  diffZ = abs(maxZ-minZ);
  println("faceMin="+faceMin+", faceMax="+faceMax+", minZ="+minZ+", maxZ="+maxZ+", middleZ="+middleZ+", diffZ="+diffZ);
}

// jiggle the mesh vertices
void jiggleHemesh() {
  float adjustment = J/1000f*shapeHeight;
  /*
  Iterator <HE_Vertex> vItr = myShape.vItr();
   HE_Vertex v;
   while (vItr.hasNext ()) { 
   v = vItr.next(); 
   v.add(random(adjustment), random(adjustment), random(adjustment));
   }
   */

  HashMap <Integer, Integer> vertexKeys = new HashMap <Integer, Integer> ();
  Iterator <HE_Face> fItr = myShape.fItr();
  HE_Face f;
  ArrayList<HE_Vertex> vlist;
  WB_Normal hNormal;
  HE_Vertex v1, v2, v3;
  while (fItr.hasNext ()) { 
    f = fItr.next(); 
    hNormal = f.getFaceNormal().get();
    hNormal.invert(); // expand the jiggle
    vlist = new ArrayList(f.getFaceVertices());
    if (vlist.size()==3) {
      //println(vlist.get(0).key()+","+vlist.get(1).key()+","+vlist.get(2).key());
      v1 = vlist.get(0);
      if (vertexKeys.get(v1.key())==null) {
        v1.add(random(adjustment)*hNormal.xf(), random(adjustment)*hNormal.yf(), random(adjustment)*hNormal.zf());
        vertexKeys.put(v1.key(), 1);
      }
      v2 = vlist.get(1);
      if (vertexKeys.get(v2.key())==null) {
        v2.add(random(adjustment)*hNormal.xf(), random(adjustment)*hNormal.yf(), random(adjustment)*hNormal.zf());
        vertexKeys.put(v2.key(), 1);
      }
      v3 = vlist.get(2);
      if (vertexKeys.get(v3.key())==null) {
        v3.add(random(adjustment)*hNormal.xf(), random(adjustment)*hNormal.yf(), random(adjustment)*hNormal.zf());
        vertexKeys.put(v3.key(), 1);
      }
    }
    vlist.clear();
  }
}

// display shape
void drawHemesh() {
  if (facesOn) {
    noStroke();
    //render.drawFaces(myShape);
    Iterator <HE_Face> fItr = myShape.fItr();
    HE_Face f;
    color c;
    while (fItr.hasNext ()) { 
      f = fItr.next(); 
      if (colorMap.get(f.key())!=null) {
        c = colorMap.get(f.key());
        fill(c);
      }
      // draw the face
      render.drawFace(f);
    }
  }
  if (edgesOn) {
    fill(color(0));
    stroke(0);
    render.drawEdges(myShape);
  }
}

// names of shapes & modifiers
String numToName(int num) {
  String name = null;

  switch(num) {

    // shapes
  case 0: 
    name = "Box"; 
    break;
  case 1: 
    name = "Cone"; 
    break;
  case 2: 
    name = "Dodecahedron"; 
    break;
  case 3: 
    name = "Geodesic"; 
    break;
  case 4: 
    name = "Sphere"; 
    break;
  case 5: 
    name = "Cylinder"; 
    break;
  case 6: 
    name = "Icosahedron"; 
    break;
  case 7: 
    name = "Octahedron"; 
    break;
  case 8: 
    name = "Tetrahedron"; 
    break;

    // modifiers
  case 101: 
    name = "ChamferCorners"; 
    break;
  case 102: 
    name = "Extrude"; 
    break;
  case 103: 
    name = "Extrude-Extruded"; 
    break;
  case 104: 
    name = "Chamfer"; 
    break;
  case 105: 
    name = "Extrude-Chamfered"; 
    break;
  case 106: 
    name = "Lattice"; 
    break;
  case 107: 
    name = "Skew"; 
    break;
  case 108: 
    name = "Stretch"; 
    break;
  case 109: 
    name = "Twist (X)"; 
    break;
  case 110: 
    name = "Twist (Y)"; 
    break;
  case 111: 
    name = "Bend"; 
    break;
  case 112: 
    name = "VertexExpand"; 
    break;
  case 113: 
    name = "ChamferEdges"; 
    break;
  case 114: 
    name = "Slice (Capped)"; 
    break;
  case 115: 
    name = "Slice (Open)"; 
    break;

    // subdividors
  case 201: 
    name = "Planar"; 
    break;
  case 202: 
    name = "Planar-Random"; 
    break;
  case 203: 
    name = "PlanarMidEdge"; 
    break;
  case 204: 
    name = "CatmullClark"; 
    break;
  case 205: 
    name = "Smooth"; 
    break;

    // default
  default: 
    name = "None"; 
    break;

    // other
  case -1: 
    name = "================="; 
    break;
  }

  return name;
}

// default values per modifier
float[] numToFloats(int num) {
  float[] floatArray = new float[5];

  floatArray[3] = random(10);  // randomSeed for selection
  floatArray[4] = 50;          // default selection percentage

  switch(num) {

    // modifiers
  case 101: 
    floatArray[0] = 0.5; 
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    break;                      // ChamferCorners
  case 102: 
    floatArray[0] = 1;   
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    break;                      // Extrude
  case 103: 
    floatArray[0] = 1;   
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    break;                      // Extrude-Extruded
  case 104: 
    floatArray[0] = 0.5; 
    floatArray[1] = 0;   
    floatArray[2] = 0; 
    break;                      // Chamfer
  case 105: 
    floatArray[0] = 1;   
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    break;                      // Extrude-Chamfered
  case 106: 
    floatArray[0] = 0.3; 
    floatArray[1] = 0.3; 
    floatArray[2] = 0; 
    floatArray[4] = 100; 
    break; // Lattice
  case 107: 
    floatArray[0] = 1;   
    floatArray[1] = 0;   
    floatArray[2] = 0; 
    break;                      // Skew
  case 108: 
    floatArray[0] = 1;   
    floatArray[1] = 1;   
    floatArray[2] = 0; 
    break;                      // Stretch
  case 109: 
    floatArray[0] = 1;   
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    floatArray[4] = 100; 
    break; // Twist (X)
  case 110: 
    floatArray[0] = 1;   
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    floatArray[4] = 100; 
    break; // Twist (Y)
  case 111: 
    floatArray[0] = 1;   
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    floatArray[4] = 100; 
    break; // Bend
  case 112: 
    floatArray[0] = 1;   
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    break;                      // VertexExpand
  case 113: 
    floatArray[0] = 0.5; 
    floatArray[1] = 1;   
    floatArray[2] = 1; 
    break;                      // ChamferEdges
  case 114: 
    floatArray[0] = 0.5; 
    floatArray[1] = 0.5; 
    floatArray[2] = 0; 
    break;                      // Slice (Capped)
  case 115: 
    floatArray[0] = 0.5; 
    floatArray[1] = 0.5; 
    floatArray[2] = 0; 
    break;                      // Slice (Open)

    // subdividors
  case 201: 
    floatArray[0] = 1; 
    floatArray[1] = 0;   
    floatArray[2] = 0; 
    break;                        // Planar
  case 202: 
    floatArray[0] = 1; 
    floatArray[1] = 0;   
    floatArray[2] = 0; 
    break;                        // Planar-Random
  case 203: 
    floatArray[0] = 1; 
    floatArray[1] = 0;   
    floatArray[2] = 0; 
    break;                        // PlanarMidEdge
  case 204: 
    floatArray[0] = 1; 
    floatArray[1] = 0;   
    floatArray[2] = 0; 
    floatArray[4] = 100; 
    break;   // CatmullClark
  case 205: 
    floatArray[0] = 1; 
    floatArray[1] = 0.5; 
    floatArray[2] = 0.5; 
    break;                      // Smooth
  }

  return floatArray;
}

void hemeshCreate(int select, float value1, float value2, float value3, float value4) {
  switch(select) {

    // =====================================================================================//
    // cases 000-100 = hemesh.creators

  case 0: 
    myShape = new HE_Mesh(new HEC_Box().setDepth(value1).setHeight(value2).setWidth(value3)); 
    break;
  case 1: 
    myShape = new HE_Mesh(new HEC_Cone().setRadius(value1).setHeight(value2).setFacets(int(value3)).setSteps(int(value4))); 
    break;
  case 2: 
    myShape = new HE_Mesh(new HEC_Dodecahedron().setEdge(value1)); 
    break;
  case 3: 
    myShape = new HE_Mesh(new HEC_Geodesic().setRadius(value1).setLevel(int(value2))); 
    break;
  case 4: 
    myShape = new HE_Mesh(new HEC_Sphere().setRadius(value1).setUFacets(int(value2)).setVFacets(int(value3))); 
    break;
  case 5: 
    myShape = new HE_Mesh(new HEC_Cylinder().setRadius(value1).setHeight(value2).setFacets(int(value3)).setSteps(int(value4))); 
    break;
  case 6: 
    myShape = new HE_Mesh(new HEC_Icosahedron().setEdge(value1)); 
    break;
  case 7: 
    myShape = new HE_Mesh(new HEC_Octahedron().setEdge(value1)); 
    break;
  case 8: 
    myShape = new HE_Mesh(new HEC_Tetrahedron().setEdge(value1)); 
    break;
  }
}

void hemeshModify(float select, float value1, float value2, float value3, float value4, float value5) {
  HE_Selection selection = new HE_Selection(myShape);
  Iterator <HE_Face> fItr = myShape.fItr();
  HE_Face f;
  randomSeed(int(value4));
  while (fItr.hasNext ()) { 
    f = fItr.next(); 
    if (random(100) < value5) { 
      selection.add(f);
    }
  }

  switch(int(select)) {

    // =====================================================================================//
    // cases 101-200 = hemesh.modifiers

  case 101:
    myShape.modifySelected(new HEM_ChamferCorners().setDistance(value1*value2*value3), selection);
    break;

  case 102:
    extrude1.setDistance(value1*value2*value3);
    myShape.modifySelected(extrude1, selection);
    break;

  case 103:
    extrude1.setDistance(value1*value2*value3);
    myShape.modifySelected(extrude1, extrude1.extruded);
    break;

  case 104:
    extrude2.setDistance(0).setChamfer(value1);
    myShape.modifySelected(extrude2, selection);
    break;

  case 105:
    extrude2.setDistance(value1*value2*value3).setChamfer(0);
    myShape.modifySelected(extrude2, extrude2.extruded);
    break;

  case 106:
    myShape.modifySelected(new HEM_Lattice().setDepth(value1).setWidth(value2).setThresholdAngle(radians(value3*45)).setFuse(true), selection);
    break;

  case 107:
    myShape.modifySelected(new HEM_Skew().setSkewFactor(value1).setGroundPlane(new WB_Plane(new WB_Point(0, 0, 0), new WB_Vector(0, 1, 0))).setSkewDirection(new WB_Point(0, 1, 0)), selection);
    break;

  case 108:
    myShape.modify(new HEM_Stretch().setStretchFactor(value1).setCompressionFactor(value2).setGroundPlane(new WB_Plane(new WB_Point(0, 0, 0), new WB_Vector(0, 1, 0))));
    break;

  case 109:
    myShape.modifySelected(new HEM_Twist().setAngleFactor(value1*value2*value3).setTwistAxis(new WB_Line(new WB_Point(0, 0, 0), new WB_Vector(1, 0, 0))), selection);
    break;

  case 110:
    myShape.modifySelected(new HEM_Twist().setAngleFactor(value1*value2*value3).setTwistAxis(new WB_Line(new WB_Point(0, 0, 0), new WB_Vector(0, 0, 1))), selection);
    break;

  case 111:
    myShape.modifySelected(new HEM_Bend().setAngleFactor(value1*value2*value3).setGroundPlane(new WB_Plane(new WB_Point(0, 0, 0), new WB_Vector(0, 1, 0))).setBendAxis(new WB_Line(new WB_Point(0, 0, 0), new WB_Vector(0, 1, 0))), selection);
    break;

  case 112:
    myShape.modifySelected(new HEM_VertexExpand().setDistance(value1*value2*value3), selection);
    break;

  case 113:
    myShape.modifySelected(new HEM_ChamferEdges().setDistance(value1*value2*value3), selection);
    break;

  case 114:
    myShape.modify(new HEM_Slice().setCap(true).setPlane(new WB_Plane(new WB_Point(0, 0, -value1), new WB_Vector(value3, 0, 1))));
    myShape.modify(new HEM_Slice().setCap(true).setPlane(new WB_Plane(new WB_Point(0, 0, value2), new WB_Vector(value3, 0, -1))));
    break;

  case 115:
    myShape.modify(new HEM_Slice().setCap(false).setPlane(new WB_Plane(new WB_Point(0, 0, -value1), new WB_Vector(value3, 0, 1))));
    myShape.modify(new HEM_Slice().setCap(false).setPlane(new WB_Plane(new WB_Point(0, 0, value2), new WB_Vector(value3, 0, -1))));
    break;

    // =====================================================================================//
    // cases 201-300 = hemesh.subdividors

  case 201:
    myShape.subdivide(new HES_Planar().setRandom(false), int(value1));
    break;

  case 202:
    myShape.subdivide(new HES_Planar().setRandom(true), int(value1));
    break;

  case 203:
    myShape.subdivideSelected(new HES_PlanarMidEdge(), selection, int(value1));
    break;

  case 204:
    myShape.subdivideSelected(new HES_CatmullClark(), selection, int(value1));
    break;

  case 205:
    myShape.subdivideSelected(new HES_Smooth().setWeight(value2, value3), selection, int(value1));
    break;

    // =====================================================================================//
    // default (all other cases)

  default:
    println("No Action Selected");
    break;
  }
}

HEC_FromFacelist fromStl(String stlName) { 
  println("fromStl");
  WETriangleMesh wemesh = (WETriangleMesh) new STLReader().loadBinary(sketchPath(shapesDirectory+"/" + stlName), STLReader.WEMESH);
  //convert toxi mesh to a hemesh. Thanks to wblut for personally coding this part during #GX30
  int n=wemesh.getVertices().size();
  ArrayList<WB_Point> points=new ArrayList<WB_Point>(n);
  for (Vec3D v : wemesh.getVertices()) { 
    points.add(new WB_Point(v.x, v.y, v.z));
  }
  int[] toxiFaces=wemesh.getFacesAsArray();
  int nf=toxiFaces.length/3;
  int[][] faces=new int[nf][3];
  for (int i=0;i<nf;i++) {
    faces[i][0]=toxiFaces[i*3];
    faces[i][1]=toxiFaces[i*3+1];
    faces[i][2]=toxiFaces[i*3+2];
  }
  HEC_FromFacelist ff=new HEC_FromFacelist().setVertices(points).setFaces(faces);
  return ff;
}

// http://www.processing.org/discourse/beta/num_1268405776.html
void stlWrite(String name) {
  println("stlWrite");
  // create stl color model with mesh base color
  // the true flag means facets can have their own RGB value
  MaterialiseSTLColorModel colModel=new MaterialiseSTLColorModel(0x112233, true);
  colModel.enableFacetColors(true);
  // create STLWriter instance
  STLWriter stl = new STLWriter(colModel, 100000);
  // write the file header
  stl.beginSave(sketchPath + "/"+outputDirectory+"/" + name + ".stl", myShape.numberOfFaces());
  // iterate over all mesh faces
  Iterator <HE_Face> fItr = myShape.fItr();
  HE_Face f;
  ArrayList<HE_Vertex> vlist;
  while (fItr.hasNext ()) { 
    f = fItr.next(); 
    vlist = new ArrayList(f.getFaceVertices());
    if (vlist.size()==3) {
      // map hemesh face data to toxi face data
      WB_Normal hNormal = f.getFaceNormal();
      Vec3D tNormal = new Vec3D(hNormal.xf(), hNormal.yf(), hNormal.zf());
      Vec3D tVector1 = new Vec3D(vlist.get(0).xf(), vlist.get(0).yf(), vlist.get(0).zf()); 
      Vec3D tVector2 = new Vec3D(vlist.get(1).xf(), vlist.get(1).yf(), vlist.get(1).zf()); 
      Vec3D tVector3 = new Vec3D(vlist.get(2).xf(), vlist.get(2).yf(), vlist.get(2).zf()); 

      stl.face(tVector2, tVector1, tVector3, tNormal, colorMap.get(f.key())); // order of vectors is important
    }
    vlist.clear();
  }
  stl.endSave();
}

