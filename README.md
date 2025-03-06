# CAD::OpenSCAD

A simple SCAD Generator, allowing programmable 3D design from Perl.  This tool allows easy generation of
OpenSCAD scripts that can be used to generate 3D Objects, in a fairly Perlish way. It is currently working
its way through the tutorial and will hopefully have an incremental features that allow complex models to
be generated and produce files that can fed into a 3D printer.  

### Dependencies
* [OpenSCAD](https://openscad.org/documentation.html) 
* [Object::Pad](https://metacpan.org/pod/Object::Pad)

### Usage

```

#!/usr/env perl
use lib "lib";
use CAD::OpenSCAD;

my $car=new SCAD;
$car->cube("bodyBase",[60,20,10],1)
    ->cube("bodyTop",[30,20,10],1)
    ->translate("bodyTop",[0,0,5])
    ->group("carBody","bodyBase","bodyTop")
    ->color("carBody","blue");

```
### Installation

This is an early prototype and OpenSCAD.pm is a monolithic module.
The suggested path structure is CAD/OpenSCAD.pm somewehere in a path in @INC.
For experimenters (and this is a module not in CPAN yet so should be condidered experimental), i would recommend
1) Install Object::Pad   (This is a dependency only to make my coding easier and for me to learn Object Pad...it may be removed if this causes a problem for sufficient people, though I dont see why it should)
2) Install OpenSCAD
3) a folder in your script path containing OpenSCAD in a folder called CAD
 ```
├── car.pl
├── car.png
├── car.scad
├── car.stl
└── lib
    └── CAD
        └── OpenSCAD.pm
```
4) Use it in your scripts using 
```
#!/usr/env perl
use strict;use warnings;
use lib "lib";  
use CAD::OpenSCAD;
```


### Introduction

CAD is not really something that has had significant recent Perl attention.  The OenSCAD framework allows
the use of scripted generation and manipulation of 3D objects, and this module attempts to make this
accessible in Perl. Object::Pad, a modern OOP paradigm, is used but deliberately not using its full features.  The OpenSCAD GUI can be used to display outputs,
although  STL, PNG,and SCAD files  (and others) may also be generated.  The example script [`car.pl`](https://github.com/saiftynet/SCAD/blob/main/car.pl) 
replicates one of the [tutorial](https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_1) objects.  As you can see,
the SCAD object is returned after every operation, allowing daisy-chaining of operations.  The items within 
are named for easy identification and often appear in the .scad file generated as comments. These items can be collected,
and built (to generate the SCAD script), and potentially saved in various formats using OpenSCAD,
or injected directly into the GUI tool for further fine-tuning. (OpenSCAD is required to be installed for rendering)

At this point the main goal is to have the ability to generate 3D objects within perl programs. With this
tool one can use data acquired in perl programs to create 3D objects without having to know the OpenSCAD
scripting language, although knowing this would allow fuller exploitation of the native SCAD powers. One could
use the output for [3D printing](https://github.com/saiftynet/SCAD/blob/main/Examples/box.pl),
[charting](https://github.com/saiftynet/SCAD/tree/main/Examples#pichartpl),
[graphical design](https://github.com/saiftynet/SCAD/tree/main/Examples#circletextpl),
[mechanical design](https://github.com/saiftynet/SCAD/tree/main/Examples#gearpl),
and even [animations](https://github.com/saiftynet/SCAD/tree/main/Examples#animation-using-scad)


![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/animatedgears.gif?raw=true)

### Methods implemented
```
use lib "lib";
use CAD::OpenSCAD;
my $scad=new SCAD;
# optionally can add fs, fa and tab on intialisation
# e.g my $scad=new SCAD(fs=>1, fa=>0.4, tab=>0);
```
After creating a SCAD Object, elements can be added to the object, transformed etc.  **Note**: minimal error checking
is done currently.  This will happen in the future, but for now the module relies on error checking at the OpenSCAD tool.

* `set_fs` `set_fa` `set_tab`
  
Using these, one can set parameters for the surface generation and script outputs. e.g. `$scad->set_fa(10)` 

* `cube` *new element created*
  
Creates a cube element e.g. `$scad->cube("bodyBase",[60,20,10],1)`.  The first parameter is the
name of the element (if the named element exists already, it will be over-written). The second parameter
is an arrayref of three dimensions. The third parameter defines whether the element is centered in the origin
(a true value here centers the element)

* `cylinder` *new element created*
  
Creates a cylinder element e.g. `$scad->cylinder("wheel",{h=>2,r=>8},1)`.  The first parameter is the
name of the element (if the named element exists already, it will be over-written).The second parameter
is a hashref of defining radius and height. The third parameter defines whether the element is centered
on the origin (a true value here centers the element)

* `sphere` *new element created*
  
Creates a sphere element e.g. `$scad->cylinder("ball",{r=>8})`.  The first parameter is the
name of the element (if the named element exists already, it will be over-written).The second parameter
is a hashref of defining radius of the sphere.

* `translate`  *element modified*
  
Moves an element by name a specified displacement in X,Y,Z directions.e.g.
`$scad->cube("bodyTop",[30,20,10],1)->translate("bodyTop",[0,0,5])`  The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayref of three elements
defining displacement.

* `scale`  *element modified*
  
Scales an element by name by specified ratios in X,Y,Z directions.e.g.
`$scad->cube("bodyTop",[30,20,10],1)->scale("bodyTop",[1,2,0.5])`.  The first parameter is the
name of the element (the element must exist already). The second parameter is an arrayref of three scale factors.

* `resize`  *element modified*
  
Resizes an element by name to specified dimensions in X,Y,Z directions.e.g.
`$scad->cube("bodyTop",[30,20,10],1)->resize("bodyTop",[30,40,5]);`.  The first parameter is the
name of the element (the element must exist already). The second parameter is an arrayref of three new dimensions.

* `rotate`  *element modified*
  
  Rotates an element by name around in  X,Y,Z axes.e.g.
`$scad->cylinder("wheel",{h=>2,r=>8},1)->rotate("wheel",[90,0,0]);`.  The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayref of three rotations
in degrees.

* `union` *new element created*
  
Implicitly joins multiple elements into one element.e.g. $scad->union("wheel",qw/wheel nut nut1 nut2 nut3/);
the first item is the name of the new element created, the following elements are elements to be joined together.
If an element with the name of the first parameter does not exist, it is created, otherwise it is over-written.
  
* `difference` *new element created*
  
Subtracts one or more elements from one element and creates a new element.e.g. `$scad->difference("wheel",qw/wheel nut nut1 nut2 nut3/)`;
The first parameter`"wheel"` in this example is the name of the new element created, the second parameter refers to the item that all other elements are subtracted from. If an element with the name of the first parameter does not exist, it is created, otherwise it is over-written.So this statement takes the item "wheel" (the scendond parameter), subtracts all the nuts, and overwrites the code in "wheel"(first parameter). 

* `intersection` *new element created*
  
creates an element representing the overlapping parts of 2 or more elements and creates a new element.e.g. `$scad->intersection("overlap",qw/item1  item2 item3/); The first parameter is the name of the new element created, the other names refer to elements which overlap neach other.

* `circle`  *new element created*
  
a 2D drawing primitive that creates a circle that may be extruded to create other 3D structures.
e.g `$scad->circle("circle",{r=>5})`;

* `square` *new element created*
  
a 2D drawing primitive that creates a rectangle that may be extruded to create other 3D structures.
e.g `$scad->square("square",[10,10]);`.,  Rectingles may be created using the same method, but squares
may also be created using  `$scad->square("square",5);`

* `polygon` *new element created*
  
a 2D drawing primitive that creates a polygon that may be extruded to create other 3D structures.
The easiest way to do it in Perl is to create an arrayref of points. and pass that as a parameter.
an example of this is the gear.pl in Examples.  the linear_extrude option below also provides an example
using SCAD variables.  A simple solution making a filled line chart is shown below :- 
```
# create a Filled Line Chart from values
my @values=(10,30,15,40,35,45,40,35,10);
my $separation =10; my $start=[0,0];my $count=0;

# starting corner of chart
my $points=[$start];
# add points to be plotted as a line graph                                   
push @$points, [$separation*$count++,$_] foreach @values;
# add end corner
push @$points, [$separation*(--$count),$start->[1]];

my $chart=new SCAD;	
$chart->polygon("chart",$points)
      ->build("chart")->save("filledline");
```

* `linear_extrude` *new element created*
  
A method to extrude a 2D shape.  creates a new 3D objects from a 2d shape *: API CHANGED: method creates new item now*
```
my $extrusion=new SCAD;
$extrusion->variable({p0=>[0, 0],p1 => [0, -30],p2 => [15, 30],p3=> [35, 20],p4 => [35, 0]});
$extrusion->variable("points",[qw/p0 p1 p2 p3 p4 /] );
$extrusion->polygon("poly","points");
$extrusion->linear_extrude("extrudedPoly","poly",{height=>100,twist=>180});
```

* `rotate_extrude` **new element created**
A method to extrude a 2D shape while rotating invokes similar to liner_extrude *: API CHANGED: method creates new item now*
```
my $extrusion=new SCAD;
$extrusion->circle("circle",{r=>5})
          ->translate("circle",[10,0,0])
          ->rotate_extrude("extrudedCircle","circle",{angle=>180})
          ->build("extrudedCircle")->save("extrusion");
```

* `clone` *one or more new elements created*
  
  Creates copies of elements with same features. e.g.`$car->clone("axle",qw/frontaxle rearaxle/);`   This just copies the code for the element into new elements, for subsequent transformation (otherwise all the elements are positioned in the same place overlying one another) 

* `makeModule` (v0.02) *experimental*
  
converts an object into a module to create other objects (see [`car.pl`](https://github.com/saiftynet/SCAD/blob/main/car.pl) for an example ).  Using modules reduces code repetition in the generated .scad file.

* `runModule` (v0.02) *experimental*
  
Create an object using a predefined module (see [`car.pl`](https://github.com/saiftynet/SCAD/blob/main/car.pl) for an example ).

* `variable`
creates variables that SCAD can use for customising objects easily

* `build`
Collects the elements specified (i.e. not all the elements, just the items required for the build)
and all the variables to generate a scad file.  The scad file generated include all the variables defined,
the modules built and the libraries used
   
* `save`
saves the `.scad` file, and also uses openscad to generate images or 3D objects
from the script, or open it in openSCAD directly after building the shape;
`$scad->build("ext")->save("extrusion");` builds a scad file containing the item "ext",
then saves the scad file as "extrusion.scad", and automatically opens OpenSCAD with that file.
If another parameter passed, the generates a corresponding file, from one of
(stl|png|t|off|wrl|amf|3mf|csg|dxf|svg|pdf|png|echo|ast|term|nef3|nefdbg)
e.g. $scad->save("extrusion","png")


* `import` *experimental*
  
  imports files. Valid files are STL|OFF|OBJ|AMF3MF|STL|DXF|SVG files

* `use` *experimental*
  
   uses library files.  These are external files in OpenSCAD paths and allow access to OpenSCADs extensive libraries.  The modules in these libraries are executed using `$scad runModule($modulename,$name_for_item,$params_as_scalar_or_ref)`


### Planned Features

The OpenSCAD language itself is very powerful, and some of these may be implemented in the module using a "raw" method.
Indeed, as a mature framework, many modules exist that enhance to its capabilities.  To be able to use or extend these
capabilities through Perl is one  goal of this module.  Complex things take some time to render, and having a tool that
can allow the generation multiple scenes/structures separately quickly to be later rendered by OpenSCAD is one goal.

* Analysis of Generated STL files. e.g. dimensions/bounding box of composite objects
* Secondary Manipulation
* Part interference detection
* Simulations
* Chart generation

### Author SAIFTYNET

### Contributors [jmlynesjr](https://github.com/jmlynesjr)



