#!/usr/env perl
use strict;use warnings;
use lib "lib";
use CAD::OpenSCAD;

my $camel=new SCAD;

$camel->sphere("thorax", 40)->resize("thorax",[40,30,40])->translate("thorax",[0,0,10]);
$camel->cylinder("trunk",{h=>40,r1=>40,r2=>20})
      ->rotate("trunk",[0,90,0])
      ->resize("trunk",[40,30,40])
      ->translate("trunk",[0,0,10]);
$camel->sphere("pelvis", 30)
      ->resize("pelvis",[30,20,30])
      ->clone("pelvis","leftPelvis","rightPelvis")
      ->translate("leftPelvis",[30,5,10])
      ->translate("rightPelvis",[30,-5,10]);

limb($camel,"frontright", {seg1=>10,seg2=>20,seg3=>20,seg4=>10,abd1=>0,abd2=>0,abd3=>0,flex1=>60,flex2=>-120,flex3=>20,side=>"right"});
limb($camel,"frontleft", {seg1=>10,seg2=>20,seg3=>20,seg4=>10,abd1=>0,abd2=>0,abd3=>0,flex1=>10,flex2=>-20,flex3=>-20,side=>"left"});

limb($camel,"rearright", {seg1=>10,seg2=>20,seg3=>20,seg4=>10,abd1=>0,abd2=>0,abd3=>0,flex1=>5,flex2=>-10,flex3=>20,side=>"right"});
limb($camel,"rearleft", {seg1=>10,seg2=>20,seg3=>20,seg4=>10,abd1=>0,abd2=>0,abd3=>0,flex1=>10,flex2=>-20,flex3=>-20,side=>"left"});
$camel->translate("rearleft",[30,0,0])->translate("rearright",[30,0,0]);

neck($camel,"neck",{radius=>6,turn=>[0,20,00],count=>8});  
$camel->translate("neck",[-10,0,10]);  
 
$camel->sphere("cranium",8);
$camel->cylinder("bridge",{r1=>8,r2=>6,h=>12})->rotate("bridge",[0,270,0]);
$camel->sphere("mouth",6)->translate("mouth",[-12,0,0]);
$camel->union(qw/head cranium bridge mouth/);
$camel->translate("head",[-34,0,35]);


$camel->build(qw/thorax trunk leftPelvis rightPelvis 
             frontleft frontright rearleft rearright neck
             head/)->save("camel");


sub limb{
	my ($scad,$name,$params)=@_;
	my $m=$params->{side} eq "left"?-1:1;
	my $shape=[
	    [3,$params->{seg4},[  -$params->{abd3}, $params->{flex3}*$m,0]],
	    [4,$params->{seg3},[  -$params->{abd2},-$params->{flex2}*$m,0]],
	    [6,$params->{seg2},[90-$params->{abd1},2                   ,0]],
	    [3,$params->{seg1},[$m*90,      90-(90*$m)+$params->{flex1},0]]
	];

	my $x=0;
	my ($oldRadius,$radius,$length,$direction,$direction2)=(3);
	$scad->sphere($name,$oldRadius); 
	for(0..$#$shape){
			  ($radius,$length,$direction)=@{$shape->[$x++]};
	$scad->sphere("s", $oldRadius)
			->translate("s",[0,0,$length])
			->cylinder("c",{r2=>$oldRadius,r1=>$radius,h=>$length})
			->translate($name,[0,0,$length])
			->union($name,$name,"s","c")
			->rotate($name,$direction);
			$oldRadius=$radius;
		  };
}

sub neck{
	my ($scad,$name,$params)=@_;
	$scad->cylinder("c",{r=>$params->{radius},h=>$params->{radius}})
	     ->sphere("s",$params->{radius});
	$scad->union($name,"s","c");
	for (2..$params->{count}){
		$scad->rotate($name,$params->{turn})
		     ->translate($name,[0,0,$params->{radius}])
			 ->union($name,$name, "s","c");
	}
	$scad->rotate($name,[0,-120,0])
	     ->scale($name,[1,0.75,1])
}
