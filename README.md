Hemesh Colorizer
================

<p>Hemesh Colorizer is an interactive tool to assign colors to 3D models. These models can then be exported and 3D printed.</p>

<p>The tool is written in <a title="Processing" href="http://leonnicholls.com/processing/">Processing</a> and based on 
<a href="https://code.google.com/p/amnonp5/">HemeshGUI</a> for the <a href="http://hemesh.wblut.com/">HE_Mesh library</a>.</p>

<p><img src="https://dl.dropboxusercontent.com/u/17958951/hemeshcolorizer.png"/></p>

<p>At the top left of the GUI, there is a zoom control but you can also the same by holding both mouse buttons down. 
Next are 6 color parameters. Depending on the coloring algorithm, these parameters would have different meanings. 
The “jiggle” feature randomly shifts the vertices of the mesh.</p>

<p>On the right are various dropdown controls with options. The first is to select the model shape to load (model files are loaded from the "shapes" directory). 
The second dropdown control is to select a HE_Mesh modifier and the third is to select the coloring algorithm.</p>

<p>Color algorithms:
<ul>
<li>1 Color Linear: (P1,P2,P3) is RGB color mapped over model height</li>
  <li>1 Color Linear Inv: (P1,P2,P3) is (R,G,B) mapped over model height inverted</li>
  <li>HSB: (P1,P2,P3) is start and (P3,P4,P5) end HSB colors</li>
  <li>Random: Random colors (P1-P6 not used)</li>
  <li>Random 2: Randomly picks from (P1,P2,P3) or (P4,P5,P6) RGB colors</li>
  <li>Random RGB: Randomly picks colors from (P1,P2,P3) to (P4,P5,P6) RGB range</li>
  <li>Face Area: (P1,P2,P3) RGB color mapped to face area</li>
  <li>2 Color Linear: Linear color range between (P1,P2,P3) and (P4,P5,P6) RGB colors</li>
  <li>2 Polar Interp: Polar color range between (P1,P2,P3) and (P4,P5,P6) HSB colors</li>
  <li>Odd: Odd numbered faces from (P1,P2,P3) and (P4,P5,P6) RGB colors</li>
  <li>Face Height Hue 2: Face height mapped to color range between (P1,P2,P3) and (P4,P5,P6) HSB colors</li>
  <li>Rainbow: Face height mapped to full HSB color range</li>
  <li>Mapping: RGB color mapping between P1 and P4, P2 and P5, P3 and P6</li>
  <li>Ripples: Rippled effect using P4 angle and (P1,P2,P3) RGB color</li>
  <li>Normals: Highlight forward facing normals using (P1,P2,P3) RGB color</li>
  <li>Rainbow Origin: Colored from the origin using full HSB color range</li>
</ul>
</p>

<p>The model can be rotated by holding down the left mouse button. The tool also supports various keyboard shortcuts:
<ul>
<li>G: hide/show the GUI</li>
<li>S: generate screenshot and store image file in "screenshots" directory</li>
<li>E: export the model to VRML and store the .wrl file in "output" directory</li>
<li>A: animate the rotation of the model</li>
<li>L: hide/show the model lines</li>
<li>F: hide/show the model faces</li>
<li>R: hide/show the lights</li>
</ul>
</p>

<p>If you need to manually edit the model after it is colorized, you can import it into <a href="http://blender.org">Blender</a>. Unfortunately, 
Blender does not support colors in WRL files. So the file has to be converted to 3DS format to keep 
the colors in the model. You can use a free tool called <a href="http://meshlab.sourceforge.net/">MeshLab</a> to convert the WRL file to a 3DS file.</p>

<p>
The tool is developed for Processing 1.5.1 and HE_Mesh version 1.5 since there are compatibility issues with the newer versions of both Processing and HE_Mesh.
The tool also uses <a href="http://www.sojamo.de/libraries/controlP5/">ControlP5</a>
<a href="http://toxiclibs.org/">Toxiclibs</a>.
Here are the Processing libraries that are required by Hemesh Colorizer (extract these into the Processing libraries directory):
<ul>
<li><a href="https://dl.dropboxusercontent.com/u/17958951/hemesh.zip">Hemesh</a></li>
<li><a href="https://dl.dropboxusercontent.com/u/17958951/controlP5.zip">ControlP5</a></li>
<li><a href="https://dl.dropboxusercontent.com/u/17958951/toxiclibscore.zip">Toxiclibs core</a></li>
<li><a href="https://dl.dropboxusercontent.com/u/17958951/toxiclibs_p5.zip">Toxiclibs P5</a></li>
</ul>
</p>

<p>See my <a href="http://leonnicholls.com/">Gallery and Blog of my 3D Designs</a>.</p>


