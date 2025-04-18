# CAD::OpenSCAD::Gears

A Perl module to create gears.  Initial attempts were [long winded]().
A Gears.pm module was created to allow multiple different types of gears to be created

### Simple gears

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/animatedgears.gif?raw=true)

### Bevel Gears

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/gears.gif?raw=true)

```
my $scad=new SCAD;
my $gm=new GearMaker(scad=>$scad);
$gm->gear("Gear1",module=>3,teeth=>14, type=>"bevel", backlash=>50);
$gm->gear("Gear2",module=>3,teeth=>18, type=>"bevel", backlash=>50);
```

### Helical gears

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/bihelical.gif?raw=true)
```
my $scad=new SCAD;
my $gm=new GearMaker(scad=>$scad);
$gm->gear("Gear1",module=>3,teeth=>14, backlash=>50, type=>"doublehelix", helixAngle=>5, thickness=>10,key=>1);
$gm->gear("Gear2",module=>3,teeth=>18, helixAngle=>-5,type=>"doublehelix",backlash=>50, thickness=>10);
```
### Rack and gear

![image](https://github.com/saiftynet/dummyrepo/blob/main/SCAD/doublehelix%20rack%20and%20gear%20(1).gif?raw=true)
```

$gm->rack("rack",module=>3,teeth=>24, backlash=>50, type=>"doublehelix", width=>10);
$gm->gear("Gear2",module=>3,teeth=>18,type=>"doublehelix",backlash=>50, thickness=>10);
```
