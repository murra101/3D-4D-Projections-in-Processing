/*
  John Murray 
 CSE 270M
 Professor Krumpe
 Final Project
 */


// The matrix used for orthographic projection
float[][] orthographic = {
  {1, 0, 0}, 
  {0, 1, 0}
};

// Used to toggle current projection mode
int mode = 0;
// Togle rotation axis'
int[] rotations = {0, 1, 0};

// The vertices and edges of what will be rendered
PVector vertices[];
int[][] edges;


// Camera variables
// *This program does not actually rotate/translate the camera
// but I still added in the code for it in normal perspective 
float cameraRotX = 0.0f;
float cameraRotY = 0.0f;
float cameraRotZ = 0.0f;

float cameraPosX = 0.0f;
float cameraPosY = 0.0f;
float cameraPosZ = 0.0f;

// For camera rotation on the x, y, and z axis'
float[][] rm1 = {
  {1, 0, 0}, 
  {0, (float) Math.cos(cameraRotX), (float) Math.sin(cameraRotX)}, 
  {0, (float) -Math.sin(cameraRotX), (float) Math.cos(cameraRotX)}
};

float[][] rm2 = {
  {(float) Math.cos(cameraRotY), 0, (float) -Math.sin(cameraRotY)}, 
  {0, 1, 0}, 
  {(float) Math.sin(cameraRotY), 0, (float) Math.cos(cameraRotY)}
};

float[][] rm3 = {
  {(float) Math.cos(cameraRotZ), (float) Math.sin(cameraRotZ), 0}, 
  {-(float) Math.sin(cameraRotZ), (float) Math.cos(cameraRotZ), 0}, 
  {0, 0, 1}
};

// Can be used for to change scale or aspect ratio or skew
float pX = 1;
float pY = 1;
float skew = 0;
float f = 0.02;

float[][] adjust = {
  { (f * width) / (2 * pX), skew, 0, 0}, 
  { 0, (f * height) / (2 * pY), 0, 0 }, 
  { 0, 0, -1, 0}, 
  { 0, 0, 0, 1}
};

// Position of camera, (0, 0, 0) here
PVector cameraPosition = new PVector(cameraPosX, cameraPosY, cameraPosZ);

// 4D Tesseract Vertices
float[][] tesseract = {
  {1, 1, 1, 1}, 
  {-1, 1, 1, 1}, 
  {-1, -1, 1, 1}, 
  {-1, 1, -1, 1}, 
  {-1, -1, -1, 1}, 
  {1, -1, 1, 1}, 
  {1, -1, -1, 1}, 
  {1, 1, -1, 1}, 
  {1, 1, 1, -1}, 
  {-1, 1, 1, -1}, 
  {-1, -1, 1, -1}, 
  {-1, 1, -1, -1}, 
  {-1, -1, -1, -1}, 
  {1, -1, 1, -1}, 
  {1, -1, -1, -1}, 
  {1, 1, -1, -1}
};

// Tesseract's edge connections
int[][] tEdges;

void setup() {
  size(700, 700);
  // I know in advance my how many vertices/edges my obj file has
  vertices = new PVector[507];
  edges = new int[2904][2];

  // Load a .obj file's vertices and edges
  // (The number is the scale)
  // (Negative scale just turns it upside down)
  loadObj("ObjectLarge.obj", -10);

  connectTesseractEdges();

  println("The 3 buttons on top can be used to switch through perspective modes.");
  println("Normal and orthographic persepectives display a given .obj file.");
  println("For 4D projection, a tesseract (4 dimensional cube like object) is displayed.");
  println();
  println("The bottom 3 checkboxes can toggle which axis to rotate the object by.");
}

void draw() {
  background(170);
  drawButtons();
  // Draw check boxes if not 4D
  if (mode != 2) {
    drawChecks();
  }

  if (mode == 0) {
    //renderWeak();
    renderNormal();
    updateRotation();
  } else if (mode == 1) {
    renderOrthographic();
    updateRotation();
  } else {
    textSize(16);
    fill(0);
    text("*This is a different shape from the other perspectives", 20, 60);
    text("Rotating about the ZW and WX plane", 20, 650);
    rotateTesseractZW();
    rotateTesseractWX();
    render4D();
  }
}


// Rotate the object by toggled axis
void updateRotation() {
  // Rotate Object
  if (rotations[0] == 1) {
    rotateObjectX();
  }
  if (rotations[1] == 1) {
    rotateObjectY();
  }
  if (rotations[2] == 1) {
    rotateObjectZ();
  }
}

// Given two matrixes, multiply the first by the second
// and return the result
float[][] multiplyMatrix(float[][] m1, float[][] m2) {
  float[][] result = new float[m1.length][m2[0].length];
  // Multiply matrix
  for (int y = 0; y < m1.length; y++) {
    for (int x = 0; x < m2[0].length; x++) {
      for (int i = 0; i < m2.length; i++) {
        result[y][x] += (m1[y][i] * m2[i][x]);
      }
    }
  }

  return result;
}

//============================== Object rotations ==============

// Rotates the object on the Z axis
void rotateObjectZ() {
  // Loop through vertices
  for (int i = 0; i < vertices.length; i++) {
    // Rotate vertice
    vertices[i].rotate(0.01);
  }
}

// Rotates the object on the Y axis
void rotateObjectY() {
  // Loop through vertices
  for (int i = 0; i < vertices.length; i++) {
    PVector rotated = new PVector(vertices[i].z, vertices[i].x, vertices[i].y).rotate(0.01);
    vertices[i] = new PVector(rotated.y, rotated.z, rotated.x);
  }
}

// Rotates the object on the X axis
void rotateObjectX() {
  // Loop through vertices
  for (int i = 0; i < vertices.length; i++) {
    PVector rotated = new PVector(vertices[i].y, vertices[i].z, vertices[i].x).rotate(0.01);
    vertices[i] = new PVector(rotated.z, rotated.x, rotated.y);
  }
}


//========================== Tesseract Rotations
// Rotate the tesseract on the wx-axis plane
void rotateTesseractWX() {
  float theta = .02;
  // Rotate on the wx-axis rotation
  float[][] rotate = {
    {1, 0, 0, 0}, 
    {0, (float) Math.cos(theta), 0, (float) -Math.sin(theta)}, 
    {0, 0, 1, 0}, 
    {0, (float) Math.sin(theta), 0, (float) Math.cos(theta)}
  };
  // Loop through vertices
  for (int i = 0; i < tesseract.length; i++) {
    float[] v = tesseract[i];
    float[][] vertex = {
      {v[0]}, 
      {v[1]}, 
      {v[2]}, 
      {v[3]}
    };
    // Multiply rotation matrix by vertices
    float[][] result = multiplyMatrix(rotate, vertex);
    tesseract[i][0] = result[0][0];
    tesseract[i][1] = result[1][0];
    tesseract[i][2] = result[2][0];
    tesseract[i][3] = result[3][0];
  }
}

// Rotate the tesseract on the zw-axis plane
void rotateTesseractZW() {
  float theta = .02;

  float[][] rotate = {
    {1, 0, 0, 0}, 
    {0, 1, 0, 0}, 
    {0, 0, (float) Math.cos(theta), (float) -Math.sin(theta)}, 
    {0, 0, (float) Math.sin(theta), (float) Math.cos(theta)}
  };
  // Loop through vertices
  for (int i = 0; i < tesseract.length; i++) {
    float[] v = tesseract[i];
    float[][] vertex = {
      {v[0]}, 
      {v[1]}, 
      {v[2]}, 
      {v[3]}
    };
    // Multiply rotation matrix by vertices
    float[][] result = multiplyMatrix(rotate, vertex);
    tesseract[i][0] = result[0][0];
    tesseract[i][1] = result[1][0];
    tesseract[i][2] = result[2][0];
    tesseract[i][3] = result[3][0];
  }
}

//============================== RENDERS ===================================//

// Renders the 4D tesseract on a 2D surface (the screen)
void render4D() {
  strokeWeight(5);
  stroke(0);

  float[][] points = new float[vertices.length][2];
  // Loop through every vertice 
  for (int i = 0; i < tesseract.length; i++) {
    float[] v = tesseract[i];

    float[][] vertex = {
      {v[0]}, 
      {v[1]}, 
      {v[2]}, 
      {v[3]}
    };

    // Get 3D projection of 4D shape
    float dist = 2;
    float w = 1 / (dist - v[3]);
    float[][] project = {
      {w, 0, 0, 0}, 
      {0, w, 0, 0}, 
      {0, 0, w, 0}
    };

    float[][] result = multiplyMatrix(project, vertex);

    float scale = 50.0f;
    points[i][0] = result[0][0]*scale + width/2;
    points[i][1] = result[1][0]*scale + height/2;
  }

  // Draw points
  for (int i = 0; i < points.length; i++) {
    point(points[i][0], points[i][1]);
  }
  // Connect points
  strokeWeight(1);
  for (int i = 0; i < tEdges.length; i++) {
    // println("bruh", i);
    float x1 = points[tEdges[i][0]][0];
    float y1 = points[tEdges[i][0]][1];
    float x2 = points[tEdges[i][1]][0];
    float y2 = points[tEdges[i][1]][1];
    line(x1, y1, x2, y2);
  }
}

// Apply normal perspective to the object's vertices
void renderNormal() {
  strokeWeight(5);
  stroke(0);
  float[][] points = new float[vertices.length][2];
  // Loop through every vertice 
  for (int i = 0; i < vertices.length; i++) {
    PVector v = vertices[i];
    v = PVector.sub(v, cameraPosition);
    // Translate by camera

    float[][] vertex = new float[3][1];
    vertex[0][0] = v.x;
    vertex[1][0] = v.y;
    vertex[2][0] = v.z;
    // Multiply by rotation matrix's 
    // (In this case no rotation is being done here)
    float[][] result = multiplyMatrix(multiplyMatrix(multiplyMatrix(rm1, rm2), rm3), vertex);

    // Can be used to change scale, skew, fov
    result = multiplyMatrix(adjust, result);
    // Apply perspective
    float dist = 500;
    float[][] n = {
      {1/(dist - result[2][0]), 0, 0, 0}, 
      {0, 1/(dist - result[2][0]), 0, 0}, 
      {0, 0, 1, 0}, 
      {0, 0, 0, 1}
    };
    result = multiplyMatrix(n, result);

    points[i][0] = result[0][0]*dist + width/2;
    points[i][1] = result[1][0]*dist + height/2;
  }
  // Draw points
  for (int i = 0; i < points.length; i++) {
    point(points[i][0], points[i][1]);
  }
  // Connect points
  strokeWeight(1);
  for (int i = 0; i < edges.length; i++) {
    float x1 = points[edges[i][0]-1][0];
    float y1 = points[edges[i][0]-1][1];
    float x2 = points[edges[i][1]-1][0];
    float y2 = points[edges[i][1]-1][1];
    line(x1, y1, x2, y2);
  }
}

// Apply orthographic perspective to the object's vertices
void renderOrthographic() {
  strokeWeight(5);
  stroke(0);

  float[][] points = new float[vertices.length][2];
  // Loop through every vertice 
  for (int i = 0; i < vertices.length; i++) {
    PVector v = vertices[i];
    float[][] vertex = new float[3][1];
    vertex[0][0] = v.x;
    vertex[1][0] = v.y;
    vertex[2][0] = v.z;
    float[][] result = multiplyMatrix(orthographic, vertex);

    points[i][0] = result[0][0] + width/2;
    points[i][1] = result[1][0] + height/2;
  }

  // Draw points
  for (int i = 0; i < points.length; i++) {
    point(points[i][0], points[i][1]);
  }
  // Connect points
  strokeWeight(1);
  for (int i = 0; i < edges.length; i++) {
    float x1 = points[edges[i][0]-1][0];
    float y1 = points[edges[i][0]-1][1];
    float x2 = points[edges[i][1]-1][0];
    float y2 = points[edges[i][1]-1][1];
    line(x1, y1, x2, y2);
  }
}

//=============================== Load initial data ========================

// Load the given .obj file into arrays of vertices and edges to be used to render
// Also uses a scale which the file can be scaled by
void loadObj(String fileName, float scale) {
  // Read every line in the obj file,
  // lines that start with v are vertices
  // lines that start with f are faces
  BufferedReader reader = createReader(fileName);
  String line = null;
  try {
    // Skip first 4 lines
    for (int i = 0; i < 4; i++) {
      reader.readLine();
    }
    int count = 0;
    int edgeCount = 0;
    while ((line = reader.readLine()) != null) {
      String[] pieces = split(line, ' ');
      if (pieces[0].equals("v")) {  // Then its a vertex so add it
        // println(line);
        vertices[count] = new PVector(float(pieces[1]) * scale, float(pieces[2]) * scale, float(pieces[3]) * scale);

        count += 1d;
      } else if (pieces[0].equals("f")) {  // Then it tells us faces (which can be used as edges)
        for (int i = 1; i <= 3; i++) {
          String[] numbers1 = split(pieces[i], '/');
          String[] numbers2 = split(pieces[(i%3)+1], '/');
          edges[edgeCount][0] = Integer.parseInt(numbers1[0]);
          edges[edgeCount][1] = Integer.parseInt(numbers2[0]);
          edgeCount++;
        }
      }
    }
    reader.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
}

// This is used to connec the edges on a tesseract
void connectTesseractEdges() {
  tEdges = new int[64][2];
  int edgeCount = 0;
  // Basically, any point that is a distance of 1 from another, 
  // connect those as edges
  for (int i = 0; i < tesseract.length; i++) {
    // For every vertice, loop through every other vertice and check distance
    for (int e = 0; e < tesseract.length; e++) {
      if (e == i) continue;
      // The way I calculate it, if the dist == 2 here then it is 1 unit away
      float dist = Math.abs(tesseract[i][0] - tesseract[e][0]) + Math.abs(tesseract[i][1] - tesseract[e][1])
        + Math.abs(tesseract[i][2] - tesseract[e][2]) + Math.abs(tesseract[i][3] - tesseract[e][3]);
      if (dist < 2.01) {
        // Add edge for these points
        tEdges[edgeCount][0] = i;
        tEdges[edgeCount][1] = e;

        // println(edgeCount);  Hey there's 64 edges so it must be working right
        edgeCount++;
      }
    }
  }
}



















// ========================== BUTTONS TO TOGGLE BETWEEN MODES =================================//
// I was not planning on adding so many buttons 
// so I should have made the process easier than
// just copying and pasting earlier code, so this
// section of code is longer than it should be

// Draw perspective buttons
void drawButtons() {
  strokeWeight(2);
  stroke(0);
  color c = #F0F0F0;

  // Button 1 
  int offSet = 0;
  int buttonMode = 0;
  // Set color button
  c = overButton(offSet) ? (buttonMode == mode ? (mousePressed ? #FF7777 : #E07070) : (mousePressed ? #FFFFFF : #E0E0E0))
    : (buttonMode == mode ? #F07070 : #C0C0C0);
  fill(c);
  rect(10 + offSet, 10, 150, 30);

  // Draw text
  textSize(15);
  fill(0);
  text("Normal Perspective", 14 + offSet, 30);

  // Button 2
  offSet = 165;
  buttonMode = 1;
  // Set color button
  c = overButton(offSet) ? (buttonMode == mode ? (mousePressed ? #FF7777 : #E07070) : (mousePressed ? #FFFFFF : #E0E0E0))
    : (buttonMode == mode ? #F07070 : #C0C0C0);
  fill(c);
  rect(10 + offSet, 10, 150, 30);

  // Draw text
  textSize(12);
  fill(0);
  text("Orthographic Projection", 14 + offSet, 30);

  // Button 3
  offSet = 330;
  buttonMode = 2;
  // Set color button
  c = overButton(offSet) ? (buttonMode == mode ? (mousePressed ? #FF7777 : #E07070) : (mousePressed ? #FFFFFF : #E0E0E0))
    : (buttonMode == mode ? #F07070 : #C0C0C0);
  fill(c);
  rect(10 + offSet, 10, 150, 30);

  // Draw text
  textSize(12);
  fill(0);
  text("4 Dimensional Projection", 12 + offSet, 30);
}

// Check if mouse clicks one of the buttons
void mousePressed() {
  if (overButton(0)) {  // Check mouse for mode buttons
    mode = 0;
  } else if (overButton(165)) {
    mode = 1;
  } else if (overButton(330)) {
    mode = 2;
  } else if (overCheck(0)) {  // Check for check marks
    rotations[0] = (rotations[0]+1) % 2;
  } else if (overCheck(40)) {
    rotations[1] = (rotations[1]+1) % 2;
  } else if (overCheck(80)) {
    rotations[2] = (rotations[2]+1) % 2;
  }
}

// Check if mouse is over a button
boolean overButton(int xOffset) {
  // If mouse is within button
  if (mouseX <= 10 + xOffset + 150 && mouseX >= 10 + xOffset
    && mouseY >= 10 &&  mouseY <= 40) {
    return true;
  }
  return false;
}

// ========================== BUTTONS TO TOGGLE ROTATION AXIS =================================//

// Draw axis check boxes on bottom
void drawChecks() {
  strokeWeight(2);
  stroke(0);
  color c = #F0F0F0;

  textSize(20);
  fill(0);
  text("Rotate on:", 10, 561);

  // Button 1 
  int offSet = 0;
  // Set color button
  c = overCheck(offSet) ? (rotations[0] == 1 ? (mousePressed ? #FF7777 : #E07070) : (mousePressed ? #FFFFFF : #E0E0E0))
    : (rotations[0] == 1 ? #F07070 : #C0C0C0);
  fill(c);
  rect(10, 570 + offSet, 30, 30);

  // Draw text
  textSize(15);
  fill(0);
  text("X Axis", 50, 591 + offSet);

  // Button 2 
  offSet = 40;
  // Set color button
  c = overCheck(offSet) ? (rotations[1] == 1 ? (mousePressed ? #FF7777 : #E07070) : (mousePressed ? #FFFFFF : #E0E0E0))
    : (rotations[1] == 1 ? #F07070 : #C0C0C0);
  fill(c);
  rect(10, 570 + offSet, 30, 30);

  // Draw text
  textSize(15);
  fill(0);
  text("Y Axis", 50, 591 + offSet);

  // Button 3 
  offSet = 80;
  // Set color button
  c = overCheck(offSet) ? (rotations[2] == 1 ? (mousePressed ? #FF7777 : #E07070) : (mousePressed ? #FFFFFF : #E0E0E0))
    : (rotations[2] == 1 ? #F07070 : #C0C0C0);
  fill(c);
  rect(10, 570 + offSet, 30, 30);

  // Draw text
  textSize(15);
  fill(0);
  text("Z Axis", 50, 591 + offSet);
}


// Check if mouse is over checkbox
boolean overCheck(int yOffset) {
  // If mouse is within button
  if (mouseX <= 40 && mouseX >= 10
    && mouseY >= 570 + yOffset &&  mouseY <= 600 + yOffset) {
    return true;
  }
  return false;
}

// ============================================================================================ //
