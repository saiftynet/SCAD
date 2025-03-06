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


### [circletext.pl](https://github.com/saiftynet/SCAD/blob/main/Examples/circletext.pl)

Subroutine to create text in a circle

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/cicletext.png?raw=true)


### [box.pl](https://github.com/saiftynet/SCAD/blob/main/Examples/box.pl) 

Subroutine to create a box that can folded from a flat shape 

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/box.png?raw=true)

### [gear.pl](https://github.com/saiftynet/SCAD/blob/main/Examples/gear.pl) 

Subroutine to create involute gears

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/involutegears.png?raw=true)

### Animation using SCAD

OpenSCAD Uses $t to handle animations.  The best way to pass these is using single quotes, for example: -

```
$scad->polygon("outline",$gear->{points})
	  ->linear_extrude("gear","outline","10")
	  ->color("gear","red")
	  ->rotate("gear",[0,0,'$t*360'])
```

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/animatedgears.gif?raw=true)

