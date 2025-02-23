#!/usr/env perl
use lib "lib";
use CAD::OpenSCAD;

my $car=new SCAD;
$car->cube("bodyBase",[60,20,10],1)->cube("bodyTop",[30,20,10],1)->translate("bodyTop",[0,0,5]);
$car->group("carBody","bodyBase","bodyTop")->color("carBody","blue");
$car->cylinder("wheel",{h=>2,r=>8},1)->rotate("wheel",[90,0,0])->color("wheel","black");
$car->cylinder("nut",{h=>4,r=>1},1)->rotate("nut",[90,0,0])->translate("nut",[0,-0.5,4]);
$car->clone("nut",qw/nut1 nut2 nut3/)->rotate("nut1",[0,90,0])->rotate("nut2",[0,180,0])->rotate("nut3",[0,270,0]);
$car->difference("wheel",qw/wheel nut nut1 nut2 nut3/);
#$car->sphere("wheel",{r=>8})->resize("wheel",[20,8,20]);
$car->cylinder("axle",{h=>30,r=>2},1)->rotate("axle",[90,0,0]);
$car->clone("wheel",qw/frontleft frontright rearleft rearright/);
$car->rotate("frontleft",[0,0,"wheelsturn"]);
$car->rotate("frontright",[0,0,"wheelsturn"]);
$car->clone("axle",qw/frontaxle  rearaxle/);
$car->translate("frontleft",[-20,"-track/2",0]);
$car->translate("frontright",[-20,"track/2",0]);
$car->translate("rearleft",[20,"-track/2",0]);
$car->translate("rearright",[20,"track/2",0]);
$car->translate("rearaxle",[-20,0,0]);
$car->translate("frontaxle",[20,0,0]);
$car->variable("track",30);
$car->variable("wheelsturn",20);

$car->build(qw/carBody frontleft frontright rearleft rearright frontaxle  rearaxle/ )->save("car");
