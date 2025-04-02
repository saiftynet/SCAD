#!/usr/env perl
use strict;use warnings;
use lib "../lib";
use CAD::OpenSCAD;
use CAD::OpenSCAD::Math;
use CAD::OpenSCAD::Loft;

my $Math=new Math;
my $scad=new SCAD(preview=>1);
my $profile=[[-1,1],[1,0.5],[1.75,0.25],[1.75,-0.25],[1,-0.5],[-1,-1]];
my $lt = new Loft(scad=>$scad);
$lt->helix("loft1",$profile,4,30,3,.1,.1);
$scad->build("loft1")->save("test");
