#!/usr/env perl
use lib "../lib";
use CAD::OpenSCAD;

my $scad=new SCAD;	
my $gear=gear(teeth=>18,module=>3,pressure_angle=>28);
my $gear2=gear(teeth=>10,module=>3,pressure_angle=>28);
$scad->polygon("outline",$gear->{points})
	  ->linear_extrude("gear","outline","10")
	  ->color("gear","red")
	  ->polygon("outline",$gear2->{points})
	  ->linear_extrude("gear2","outline","10")
	  ->color("gear2","blue")
	  ->translate("gear2",[($gear->{PCD}+$gear2->{PCD})/2,0,0])
	  ->build("gear","gear2")->save("gear");



sub gear{
	my %params=@_;
	my $pi=4*atan2(1,1);
    my $module=$params{module}//2;  #  Module
    my $teeth=$params{teeth}//16;
    my $backlash=$params{backlash}//2;
    my $PressAngle=$params{pressure_angle}//20;
    
    my $PCD=$module*$teeth	;
    my $Addendum=$module;
    my $Dedendum=$Addendum*1.25;
    my $BaseD=$PCD*cos($PressAngle*$pi/180);
    my $Engagement=0;
    my $InitialAngle=$Engagement+((sin($PressAngle*$pi/180)*$PCD/2)*360/($pi*$BaseD) - $PressAngle);
    
    my $steps=10;
    my $points=[];
    for (my $ang=0;$ang<80;$ang+=$steps){
		my $colB=$InitialAngle-$ang;
		my $alpha=sprintf("%.3f", 180*atan2($pi*$ang/180,1)/$pi);
		my $R=sprintf("%.3f", sqrt(($ang*$pi*$BaseD/360)**2+($BaseD/2)**2));
		my $x=sprintf("%.3f", cos(($InitialAngle-$ang+$alpha)*$pi/180)*$R);
		my $y=sprintf("%.3f", sin(($InitialAngle-$ang+$alpha)*$pi/180)*$R);
		unless ($ang){
			my $dx=$x-30/$teeth;
			push @$points, [$dx,$y];
			unshift @$points, mirrorrotate([$dx,$y],($backlash/18+$pi)/$teeth);
		}
		push @$points,[$x,$y];
		unshift @$points,mirrorrotate([$x,$y],($backlash/18+$pi)/$teeth);
		if (angle($points->[-1],$points->[0])>($pi/(2*$teeth))){
			pop @$points;shift @$points;
			last;
		};
	}
	my $allPoints=[];
	for my $tNo (0..$teeth-1){
		foreach my $pt (@$points){
			push @$allPoints,rotate($pt,-2*$pi*$tNo/$teeth)
		}
	}
	
	return {points=>$allPoints,PCD=>$PCD};
}

sub mirrorrotate{
	my ($point,$angle)=@_;
	return [$point->[0]*cos($angle)+$point->[1]*sin($angle),
	       -$point->[1]*cos($angle)+$point->[0]*sin($angle)];
}
sub rotate{
	my ($point,$angle)=@_;
	return [$point->[0]*cos($angle)-$point->[1]*sin($angle),
	        $point->[1]*cos($angle)+$point->[0]*sin($angle)];
	
}

sub angle{
	my ($p1,$p2)=@_;
	return atan2($p1->[0],$p1->[1])-atan2($p2->[0],$p2->[2]);
}

# old method used one set of points to create a gear cutters
__END__	     
	my $scad=new SCAD;	
	my @cuts=();
	$scad->polygon("outline",$allPoints)
	      ->linear_extrude("gear","outline","10")
	      ->clone ("gear","gear2")
	      ->translate("gear2",[$PCD,0,0])
	     ->build("gear","gear2")->save("gear");

		
	my $scad=new SCAD;	
	my @cuts=();
	$scad->polygon("outline",$points)
	      ->linear_extrude("cut","outline","4")
	      ->translate("cut",[0,0,-1]);
	for my $tNo(0..$Teeth-1){
		$scad->clone("cut","cut$tNo")
		     ->rotate("cut$tNo",[0,0,360*$tNo/$Teeth]);
		push @cuts,"cut$tNo";
	};
	$scad->cylinder("gear",{r=>$PCD/2+$Addendum,h=>2})
	     ->difference("Gear","gear",@cuts)
	     ->clone("Gear","Gear1","Gear2")
	     ->translate("Gear2",[$PCD,0,0])
	     ->build("Gear1","Gear2")->save("gear");
