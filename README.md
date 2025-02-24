# SCAD

A simple SCAD Generator, allowing programmable 3D design from Perl.  This tool allows easy generation of
OpenSCAD scripts that can be used to generate 3D Objects, in a fairly Perlish way. It is curretly working
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

### Introduction

CAD is not really something that has had significant recent Perl attention.  The OenSCAD framework allows
the use of scripted generation and manipulation of 3D objects, and this module attempts to make this
accessible in Perl. Object::Pad, a modern OOP paradigm, is used but deliberately not using its full features.  The OpenSCAD GUI can be used to display outputs,
although  STL, PNG,and SCAD files  (and others) may also be generated.  The example script [`car.pl`](https://github.com/saiftynet/SCAD/blob/main/car.pl) 
replicates one of the [tutorial](https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_1) objects.  As you can see,
the object is returned after every operation, allowing daisy-chaining of operations.  The objects are named for easy 
identification. These operations produce items that can be collected, and built (to generate the SCAD script),
and potentially saved in various formats using OpenSCAD, or injected directly into the GUI tool for further fine-tuning.
(OpenSCAD is required to be installed for rendering)

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/OpenSCAD.png?raw=true)

### Methods implemented
```
use lib "lib";
use CAD::OpenSCAD;
my $scad=new SCAD;
```
After creating a SCAD Object, elements can be added to the object, transformed etc.  **Note**: minimal error checking
is done currently.  This will happen in the future, but for now the module relies on error checking at the OpenSCAD tool.

* `cube`
Creates a cube element e.g. `$scad->cube("bodyBase",[60,20,10],1)`.  The first parameter is the
name of the element (if the named element exists already, it will be over-written). The second parameter
is an arrayref of three dimensions. The third parameter defines whether the element is centered in the origin
(a true value here centers the element)

* `cylinder`
Creates a cylinder element e.g. `$scad->cylinder("wheel",{h=>2,r=>8},1)`.  The first parameter is the
name of the element (if the named element exists already, it will be over-written).The second parameter
is a hashref of defining radius and height. The third parameter defines whether the element is centered
on the origin (a true value here centers the element)

* `sphere`
Creates a sphere element e.g. `$scad->cylinder("ball",{r=>8})`.  The first parameter is the
name of the element (if the named element exists already, it will be over-written).The second parameter
is a hashref of defining radius of the sphere.

* `translate`
Moves an element by name a specified displacement in X,y,z directions.e.g.
`$scad->cube("bodyTop",[30,20,10],1)->translate("bodyTop",[0,0,5])`  The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayef of three elements.

* `scale`
Scales an element by name by specified ratios in X,y,z directions.e.g.
`$scad->cube("bodyTop",[30,20,10],1)->scale("bodyTop",[1,2,0.5])`.  The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayef of three scale factors.

* `rotate`
  Rotates an element by name around in X,y,z axes.e.g.
`$scad->cylinder("wheel",{h=>2,r=>8},1)->rotate("wheel",[90,0,0]);`.  The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayef of three rotations in degrees.

* `union`
Implicitly joins multiple elements into one element.e.g. $scad->union("wheel",qw/wheel nut nut1 nut2 nut3/);
the first item is the name of the new element created, the following elements are elements to be joined together.
If an element with the name of the first parameter does not exist, it is created, otherwise it is over-written.
  
* `difference`
Subtracts one or more elements from one element and creates a new element.e.g. `$scad->difference("wheel",qw/wheel nut nut1 nut2 nut3/); The first parameter is the name of the new element created, the second parameter refers to the item that all other elements are subtracted from.
If an element with the name of the first parameter does not exist, it is created, otherwise it is over-written.

* `intersection`
creates an element representing the overlapping parts of 2 or more elements and creates a new element.e.g. `$scad->intersection("overlap",qw/item1  item2 item3/); The first parameter is the name of the new element created, the other names refer to elements which overlap neach other.

* `circle`
a 2D drawing primitive that creates a circle that may be extruded to create other 3D structures

* `polygon`
a 2D drawing primitive that creates a polygon that may be extruded to create other 3D structures

* `linear_extrude`
A method to extrude a 2D shape

* `rotate_extrude`
A method to extrude a 2D shape while rotating

* `clone`
  Creates copies of elements with same features. e.g.`$car->clone("axle",qw/frontaxle rearaxle/);`   This just copies the code for the element into new elements, for subsequent transformation (otherwise all the elements are positioned in the same place overlying one another) 

* `makeModule` (v0.02)
converts an object into a module to create other objects (see [`car.pl`](https://github.com/saiftynet/SCAD/blob/main/car.pl) for an example ).  Using modules reduces code repetition in the generated .scad file.

* `runModule` (v0.02)
Create an object using a predefined module (see [`car.pl`](https://github.com/saiftynet/SCAD/blob/main/car.pl) for an example ).

* `variable`
creates variables that SCAD can use for customising objects easily

* `build`
  collects all the elements, and all the variables to generate a scad file
   
* `save`
  saves the .scad file, and also uses openscad to generate images or 3D objects
  from the script, or open it in openSCAD directly.


### Planned Features

The OpenSCAD language itself is very powerful, and some of these may be implemented in the module using a "raw" method.
Indeed, as a mature framework, many modules exist that enhance to its capabilities.  To be able to use or extend these
capabilities through Perl is one  goal of this module.  Complex things take some time to render, and having a tool that
can allow the generation multiple scenes/structures separately quickly to be later rendered by OpenSCAD is one goal.



