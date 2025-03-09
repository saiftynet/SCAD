use strict;
use warnings;
use Object::Pad;
use lib "../../lib";

class Math{
	field $pi  :reader;
	
	BUILD{
		$pi=4*atan2(1,1);
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
	
	method angle{
		my ($p1,$p2)=@_;
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
	
	method distance{
		my ($p1,$p2)=@_;		
		return sqrt(($p1->[0]-$p2->[0])**2+($p1->[1]-$p2->[1])**2);
	}
	
	method tan{
		my ($ang)=@_;
		return sin($ang)/cos($ang);
		
	}
}

