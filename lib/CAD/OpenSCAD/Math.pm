use strict; use warnings;
use lib "../../lib";

package CAD::OpenSCAD::Math; #  this is just so that it is picked up by the CPAN indexer

use Object::Pad;

our $VERSION='0.10';

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
	
	method rotate{ # rotate point or set of points 
		my ($point,$angle)=@_;
		if (ref $point->[0] ne "ARRAY"){
			if (scalar @$point ==2){  # 2d rotations
				return [$point->[0]*cos($angle)-$point->[1]*sin($angle),
					$point->[1]*cos($angle)+$point->[0]*sin($angle)];
			}
			else{                     # 3d rotations
				my $result=$self->rotx($point,$angle->[0]);
				$result=$self->roty($result,$angle->[1]);
				$result=$self->rotz($result,$angle->[2]);
				return $result;
			}
		}
		else{
			 my $tmp=[@$point];
			 foreach (0..$#$tmp){
				 $tmp->[$_]=$self->rotate($tmp->[$_],$angle);
			 }
			 return $tmp;
		}
	}		
	
	
	method roty{
		my ($point,$angle)=@_;
		my $matrix=[
		             [cos($angle),0,sin($angle)],
		             [0,1,0],
		             [-sin($angle),0,cos($angle)],
		           ];
		return $self->matrixTransform($point,$matrix);
		
	}
	
	method rotz{
		my ($point,$angle)=@_;
		my $matrix=[
		             [cos($angle),-sin($angle),0],
		             [sin($angle),cos($angle),0],
		             [0,0,1],
		           ];
		return $self->matrixTransform($point,$matrix);
	}
	
	
				
	method matrixTransform{
		my ($point,$matrix)=@_;
		if (ref $point->[0] ne "ARRAY"){
			my $output=[];
			foreach my $c (0..$#{$matrix->[0]}){
				my $sum=0;
				foreach my $r (0..$#$matrix){
					$sum+=$point->[$r]*$matrix->[$c]->[$r];
				}
				$output->[$c]=$sum;
			}
			return $output;
		}
		else{
			 my $tmp=[@$point];
			 foreach (0..$#$tmp){
				 $tmp->[$_]=$self->matrixTransform($tmp->[$_],$matrix);
			 }
			 return $tmp;
		}
	}
	
		
	method add{ # add vectors
		my ($point1,$point2)=@_;
		if((scalar @$point1 == scalar @$point2) && (! ref $point1->[0])){;
		      return [map{$point1->[$_]+$point2->[$_]} (0..$#$point1)]
		 }
		 elsif (ref $point1->[0] eq "ARRAY"){
			 my $tmp=[@$point1];
			 foreach (0..$#$tmp){
				 $tmp->[$_]=$self->add($tmp->[$_],$point2);
			 }
			 return $tmp;
				
		};
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
	
		
	method serialise{
		my $st=shift;
		if (ref $st eq "ARRAY"){
			return "[".join(",",map{serialise($_)}@$st)."]"
		}
		elsif (ref $st eq "HASH"){
			return "{".join(",",map{$_."=>".serialise($st->{$_})}keys %$st)."}"
		}
		else{
			return $st=~/^[\d+-\.]/?$st:"\"$st\"";
		};
	}
	
	
}
