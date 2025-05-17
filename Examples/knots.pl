#!/usr/bin/env perl
use strict; use warnings;
use lib "../lib/";
use Object::Pad;
use CAD::OpenSCAD;
use CAD::OpenSCAD::Math;
use CAD::OpenSCAD::Loft;

my $scad=new OpenSCAD;
my $math= new CAD::OpenSCAD::Math;
my $loft= new  CAD::OpenSCAD::Loft(scad=>$scad);

my $profile=$loft->star(undef,5,10,4);


$loft->loftPath("pathFollow",$profile,torusKnot(2,5,30),0.1);	


sub trefoil{
	my $path=[];
	foreach (0..360){
		next if $_ % 10;
		my $t=$math->deg2rad($_);
		push @$path,[(sin($t)+2*sin(2*$t))*10,
					 (cos($t)-2*cos(2*$t))*10,
					 -sin(3*$t)*10] ;          
	}
	return $path;
}
	


sub torusKnot{
	my ($p,$q,$d)=@_;
	my $path=[];
    foreach (0..360){
	   next if $_ % 2;
	   my $t=$math->deg2rad($_);
	   my $r=cos($q*$t)+2;
	   push @$path,[$r*cos($p*$t)*$d,
	                $r*sin($p*$t)*$d,
	                -sin($q*$t)*$d] ;          
    }	
    return $path;
    
}




$scad->build("pathFollow")
     ->save("test");;
