use strict; use warnings;
use lib "../../../lib";
use Object::Pad;
use CAD::OpenSCAD::Math;
	
our $Math=new Math;
		
class GearMaker{
	field $scad :param;	
	
	method profile{
		my %params=@_;
		my $pi=$Math->pi;
		my $module=$params{module}//2;  #  Module
		my $teeth=$params{teeth}//16;
		my $backlash=$params{backlash}//20;# profile shift degrees
		my $PressAngle=$params{pressure_angle}//20;
		
		my $PCD=$module*$teeth	;
		my $Addendum=$module;
		my $Dedendum=$Addendum*1.25;
		my $BaseD=$PCD*cos($PressAngle*$pi/180);
		my $Engagement=0;
		my $InitialAngle=$Engagement+((sin($PressAngle*$pi/180)*$PCD/2)*360/($pi*$BaseD) - $PressAngle);
		
		my $steps=3;
		my $points=[];
		for (my $ang=0;$ang<80;$ang+=$steps){
			my $colB=$InitialAngle-$ang;
			my $alpha=180*atan2($pi*$ang/180,1)/$pi;
			my $R=sqrt(($ang*$pi*$BaseD/360)**2+($BaseD/2)**2);
			my $x=cos(($InitialAngle-$ang+$alpha)*$pi/180)*$R;
			my $y=sin(($InitialAngle-$ang+$alpha)*$pi/180)*$R;
			unless ($ang){  # at the first pass insert the dip to dedendum
				my $dx=$PCD/2-$Dedendum;
				push @$points, [$dx,$y];
				unshift @$points, $Math->mirrorrotate([$dx,$y],($backlash/180+$pi)/$teeth);
			}
			last if sqrt($x**2+$y**2) > ($PCD/2+$Addendum);
			push @$points,[$x,$y]; 
			unshift @$points,$Math->mirrorrotate([$x,$y],($backlash/180+$pi)/$teeth);
			#if the involute arcs are going to collide...remove point and leave 
			if ($Math->angle($points->[-1],[1,0])>($pi/(2*$teeth))){
				pop @$points;shift @$points;
				last;
			};
		}
		my $allPoints=[];
		for my $tNo (0..$teeth-1){
			foreach my $pt (@$points){
				push @$allPoints,$Math->rotate($pt,-2*$pi*$tNo/$teeth)
			}
		}
		
		return {points=>$allPoints,PCD=>$PCD};
	}
	
	method gear{
		my ($name,%params)=@_;
		my $profile=$self->profile(%params);
		my $th=$params{thickness}//($params{module}//2)*2;
		$scad->polygon("GearMaker_outline",$profile->{points})
		       ->linear_extrude("GearMaker_gear","GearMaker_outline",$th);
		if ($params{bore}){
		   $scad->cylinder("GearMaker_bore",{r=>$params{bore}/2,h=>$th+2});
		   if ($params{key}){  
			   if (ref $params{key} eq "ARRAY"){
				   
			   }
			   else{
				   $scad->cube("GearMaker_key", [$params{bore},$params{bore},$th+3])
						  ->translate("GearMaker_key",[$params{bore}/4,-$params{bore}/2,-.5])
				          ->difference("GearMaker_bore","GearMaker_bore","GearMaker_key");
			   }
		   }
		    $scad->translate("GearMaker_bore",[0,0,-1])
		         ->union("GearMaker_gear","GearMaker_gear","GearMaker_bore");
		}
		$scad->clone("GearMaker_gear",$name)
		     ->cleanUp(qr{^GearMaker_});
	}
	
	method bevelGear{
		my ($name,%params)=@_;
		my $profile=$self->profile(%params);
		my $th=$params{thickness}//($params{module}//2)*2;
		my $bA=$params{bevelAngle}//45;
		my $scale=($profile->{PCD}-$th*$Math->tan($bA))/$profile->{PCD};
		$scad->polygon("GearMaker_outline",$profile->{points})
		       ->linear_extrude("GearMaker_gear","GearMaker_outline","$th, scale=$scale");
		$scad->clone("GearMaker_gear",$name)
		     ->cleanUp(qr{^GearMaker_});
	}
}
