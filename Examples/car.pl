#!/usr/env perl
use lib "lib";
use CAD::OpenSCAD;

my $car=new SCAD;

# creates a car body shape using two cubes, groups them and colours the group
$car->cube("bodyBase",[60,20,10],1)
    ->cube("bodyTop",[30,20,10],1)
    ->translate("bodyTop",[0,0,5])
    ->group("carBody","bodyBase","bodyTop")->color("carBody","blue");

# creates a generic axle, makes two clones and moves each to 
$car->cylinder("axle",{h=>30,r=>2},1)->rotate("axle",[90,0,0]);
$car->clone("axle",qw/frontaxle rearaxle/);
$car->translate("rearaxle",[-20,0,0]);
$car->translate("frontaxle",[20,0,0]);

# creates a module to draw a wheel of definable size;
# with holes for the wheel which are clones of a nut
# converted into a module using a makeModule method
$car->cylinder("wheel",{h=>2,r=>"size"},1)->rotate("wheel",[90,0,0])->color("wheel","brown");
$car->cylinder("nut",{h=>4,r=>1},1)->rotate("nut",[90,0,0])->translate("nut",[0,-0.5,4]);
$car->clone("nut",qw/nut1 nut2 nut3/)->rotate("nut1",[0,90,0])->rotate("nut2",[0,180,0])->rotate("nut3",[0,270,0]);
$car->difference("wheel",qw/wheel nut nut1 nut2 nut3/);
$car->makeModule("wheel","size=8","wheel");

$car->runModule("wheel","frontleft") # runs module "wheel" creating an item "frontleft"
    ->rotate("frontleft",[0,0,"wheelsturn"])
    ->translate("frontleft",[-20,"-track/2",0]);
$car->runModule("wheel","frontright") 
    ->rotate("frontright",[0,0,"wheelsturn"])
    ->translate("frontright",[-20,"track/2",0]);
$car->runModule("wheel","rearleft",10) 
    ->translate("rearleft",[20,"-track/2",0]);
$car->runModule("wheel","rearright",10) 
    ->translate("rearright",[20,"track/2",0]);
    
#$car->translate("rearright",[20,"track/2",0]);
$car->variable("track",30);
$car->variable("wheelsturn",20);

# builds the car and saves it to a scad file, which can be rendered in OpenSCAD.
$car->build(qw/carBody frontleft frontright rearleft rearright frontaxle  rearaxle/ )->save("car");
