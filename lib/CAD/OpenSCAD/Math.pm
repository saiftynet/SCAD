use strict;
use warnings;
use Object::Pad;
use lib "../../lib";

class Math{
	field $pi  :reader;
	field $e   :reader;
	
	BUILD{
		$pi=4*atan2(1,1);
		$e= exp(1);
	}
	method mirrorrotate{
		my ($point,$angle)=@_;
		return [$point->[0]*cos($angle)+$point->[1]*sin($angle),
			   -$point->[1]*cos($angle)+$point->[0]*sin($angle)];
	}
	method rotate{
		my ($point,$angle)=@_;
		return [$point->[0]*cos($angle)-$point->[1]*sin($angle),
				$point->[1]*cos($angle)+$point->[0]*sin($angle)];
	}	
	
	# measure angle between 2 points from origin
	# if one point passed, angle from point to X-axis
	method angle{
		my ($p1,$p2)=@_;
		$p2=[1,0] unless $p2;
		return atan2($p1->[0],$p1->[1])-atan2($p2->[0],$p2->[1]);
	}
	
	method deg2rad{
		my ($deg)=@_;
		return $deg*$pi/180;
	}
	
	method rad2deg{
		my ($rad)=@_;
		return $rad*180/$pi;
	}
	
	# measure distance between 2 points
	# if only one point passed, distance between point and origin
	method distance{
		my ($p1,$p2)=@_;	
		$p2=[0,0] unless $p2;	
		return sqrt(($p1->[0]-$p2->[0])**2+($p1->[1]-$p2->[1])**2);
	}
	
	method tan{
		my ($ang)=@_;
		return sin($ang)/cos($ang);
		
	}
}

