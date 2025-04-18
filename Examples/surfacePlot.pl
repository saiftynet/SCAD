#!/usr/env perl
use lib "../lib";
use CAD::OpenSCAD;

surfacePlot(-30,-30,30,30,3,1,"saddle");

sub function{
	my ($x,$y,$fn)=@_;
	for ($fn){
		$_ eq "saddle"    && do { return ($y**2)/40-($x**2)/40;};
		$_ eq "waves"     && do { return 5*sin(sqrt($y**2+$x**2)/5);}; 
		$_ eq "conic"     && do { return (sqrt($y**2+$x**2));}; 
		$_ eq "parabolic" && do { return ($y**2+$x**2)/40; }; 
		$_ eq "cubic" && do { return ($y**3+$x**3 )/1000; }; 
	}
}

sub surfacePlot{
	my ($minX,$minY,$maxX,$maxY,$spacing,$pixel,$funct)=@_;
	my $chart=new OpenSCAD;
	my ($col,$row)=(0,0);
	for(my $x=$minX;$x<$maxX;$x+=$spacing){
		for(my $y=$minY;$y<$maxY;$y+=$spacing){
			$chart->cube("C_".$col."_".$row,$pixel)->translate("C_".$col."_".$row,[$x,$y,function($x,$y,$funct)]);
			if ($row){ $chart->hull("H_".$col."_".$row."_X","C_".$col."_".$row,"C_".$col."_".($row-1))};
			if ($col){ $chart->hull("H_".$col."_".$row."_Y","C_".$col."_".$row,"C_".($col-1)."_".$row)};
			$row++;
		}
		$col++;
		$row=0;
	}
	$chart->cleanUp(qr{^C_})->build(keys %{$chart->items})->save("hull");
}

