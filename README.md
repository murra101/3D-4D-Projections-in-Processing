# Projecting 3D and 4D Points on a 2D Plane

In this project, linear algebra is used to essentially calculate how 3 or 4 dimensional objects would cast a shadow on a 2 dimensional plane. Reading in a series of vertices and edges from a .obj file, matrix multiplication is then used to project the vertices/edges onto the screen. This is all written using Processing.

## Normal Perspective
For normal perspective, the distance between the camera affect the vertices being mapped, unlike orthographic project. Matrix multiplication is used to do this efficiently.

<img src="images/NormalPerspective.png">

## Orthographic Projection
In orthographic projection, the distance of vertices from the camera does not change how they are projected onto the screen. In this case the x and y coordinates are mapped onto the screen while the z coordinate is overlooked, which generates the result shown below.

<img src="images/OrthographicProjection.png">

## 4 Dimensional Projection
For this projection, a 4 Dimensional equivilent of a cube, or a tesseract, is projected onto a 2D surface, the screen. In order to connect the lines between the tesseract vertices, the distance between each point is calculated and if it returns a 1 then these lines are to be connected. Matrix multiplication is used to rotate the tesseract on the ZW and WX planes. 

<img src="images/4DimensionalProjection.png">
