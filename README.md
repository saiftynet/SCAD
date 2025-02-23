# SCAD

A simple SCAD Generator, allowing programmable 3D design from Perl.  This tool allows easy generation of
OpenSCAD scripts that can be used to generate 3D Objects, in a fairly Perlish way. It is curretly working
its way through the tutorial and will hopefully have an incremental features that allow complex models to
be generated and produce files that can fed into a 3D printer.  

### Dependencies
[OpenSCAD](https://openscad.org/documentation.html)
[Object::Pad](https://metacpan.org/pod/Object::Pad)

### Usage

```

#!/usr/env perl
use lib "lib";
use CAD::OpenSCAD;

my $box=new SCAD;
$box->cube("Box",[60,20,10],1)->translate("Box",[0,0,5])->color("Box","blue");
$car->build("Box")->save("Box");

```

### Introduction

CAD is not really something that has had significant recent Perl attention.  The OenSCAD framework allows
the use of scripted generation and manipulation of 3D objects, and this module attempts to make this
accessible in Perl. Object::Pad, a modern OOP paradigm, is used.  The OpenSCAD GUI can be used to display outputs,
although  STL, PNG,and SCAD files  (and others) may also be generated.  The example script [`car.pl`](https://github.com/saiftynet/SCAD/blob/main/car.pl) 
replicates one of the [tutorial](https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_1) objects.  As you can see,
the object is returned after every operation, allowing daisy-chaining of operations.  These operations produce 
items that can be collected, and built (to genereate the SCAD script), and potentially saved in various formats
using OpenSCAD, or injected directly into the GUI tool. (OpenSCAD is required to be installed for rendering)

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/OpenSCAD.png?raw=true)

### Methods implemented

* `cube`
* `cylinder`
* `sphere`
* `translate`
* `scale`
* `rotate`
* `union`
* `difference`
* `intersection`
* `clone`
* `variable`
* `build`
* `save`


