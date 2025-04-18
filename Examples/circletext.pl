#!/usr/env perl
use lib "../lib";
use CAD::OpenSCAD;

circleText(text=>"Perl & OpenSCAD ",size=>10,height=>4,font=>"Times New Roman");

sub circleText{
	my %params=@_;
	die "no text to circleText()" unless exists $params{text};
	$params{size}//=10;
	$params{height}//=3;
	$params{radius}//=(length $params{text})*$params{size}/6;
	my $index=0;
	my $output=new OpenSCAD;
	my @labels=();
	for (reverse split //,$params{text}){
		my $label="char$index";
		$output->text($_,{text=>$_,size=>$params{size},font=>$params{font}})
		       ->linear_extrude($label,$_,$params{height})
		       ->translate($label,[-$params{size}/2,-$params{size}/2,0,])
		       ->rotate($label,[0,0,270])
		       ->translate($label,[$params{radius},0,0,])
		       ->rotate($label,180+(360*$index++/(length $params{text})));
		push @labels, $label;
	}
	$output->build (@labels)->save("circletext")
	
	
}

