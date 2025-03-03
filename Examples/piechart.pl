#!/usr/env perl
use lib "../lib";
use CAD::OpenSCAD;

my $EnergyUtilisation={Electricity=>4000,Gas=>5100,Petrol=>1000,Coal=>2300};
pieChart($EnergyUtilisation);

sub pieChart{
	my $data=shift;
	my $total=0;
    my $pecentages={};
    my @colours=(qw/red orange yellow green blue indigo violet/);
    my $chart=new SCAD;
    $chart->square("profile", [20,5],1);

    $total+=$data->{$_} foreach(keys %$data);
    my @segments=();my $accum=0;my $colIndex=0;
    foreach my $segment (keys %$data){
		my $angle=360*$data->{$segment}/$total;
		$chart->rotate_extrude($segment,"profile",{angle=>$angle})
		      ->rotate($segment,[0,0,$accum])
              ->color($segment,$colours[$colIndex++]);
        push @segments,$segment;
        $accum+=$angle;      
	};
	
	$chart->build(@segments)->save("chart");
	
	
}


