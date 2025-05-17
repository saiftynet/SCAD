# Examples

### Tutorial car

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/OpenSCAD.png?raw=true)


### [pichart.pl](https://github.com/saiftynet/SCAD/blob/main/Examples/piechart.pl)
Subroutine to draw a pieChart.  Although not labelled, note that the actual
.scadfile generated contains the labels as comments

```
my $EnergyUtilisation={Electricity=>4000,Gas=>5100,Petrol=>1000,Coal=>2300};
pieChart($EnergyUtilisation)
```

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/pichart.png?raw=true)


### [surfaceplot.pl](https://github.com/saiftynet/SCAD/blob/main/Examples/surfacePlot.pl)

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/surfaceplot.png?raw=true)



### [circletext.pl](https://github.com/saiftynet/SCAD/blob/main/Examples/circletext.pl)

Subroutine to create text in a circle

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/cicletext.png?raw=true)


### [box.pl](https://github.com/saiftynet/SCAD/blob/main/Examples/box.pl) 

Subroutine to create a box that can folded from a flat shape 

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/box.png?raw=true)

### [gear.pl](https://github.com/saiftynet/SCAD/blob/main/Examples/gear.pl) 

Subroutine to create involute gears

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/involutegears.png?raw=true)

### [Animation](https://github.com/saiftynet/SCAD/blob/main/Examples/animatedGears.pl) using SCAD and Perl

OpenSCAD Uses $t to handle animations.  The best way to pass these is using single quotes, for example: -

```
$scad->polygon("outline",$gear->{points})
	  ->linear_extrude("gear","outline","10")
	  ->color("gear","red")
	  ->rotate("gear",[0,0,'$t*360'])
```

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/animatedgears.gif?raw=true)



### [Loft](https://github.com/saiftynet/SCAD/blob/main/Examples/loft.pl) 

An extra module Loft.pm allows the creation of lofts betweeen two faces.  This can be used to create complex polyhedrons, resulting in an object that renders much quicker than hull.


![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/helix.png?raw=true)


### [ScadHead](https://github.com/saiftynet/SCAD/blob/main/Examples/ScadHead.pl) 

This used a scadItem object, that keeps the parameters of a shape
in a perl object rather than a string.  This means that the parameters
can be changed, modifying the object in Perl before transformation in
the build process into the appropriate script.


![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/ScadHead.png?raw=true)


### [Torus Knot](https://github.com/saiftynet/SCAD/blob/main/Examples/knots.pl) 

This demonstrates loft along path (version 0.17)


![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/Torusknot.png?raw=true)



