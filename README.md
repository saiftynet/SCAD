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
accessible in Perl. Object::Pad, a modern OOP paradigm, is used.  The OpenSCAD GUI can be used to display outputs,
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
* `scale`
* `rotate`
* `union`
* `difference`
* `intersection`
* `circle`
* `polygon`
* `linear_extrude`
* `rotate_extrude`
* `clone`
* `variable`
* `build`
* `save`


