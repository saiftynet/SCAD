package CAD::OpenSCAD::Math;  # for MetaCPAN

use strict; use warnings;

use Object::Pad;

our $VERSION="0.17";

=pod

=head1 NAME

CAD::OpenSCAD::Math - A module to provide maths routines for
CAD::OpenSCAD.

=cut

class CAD::OpenSCAD::Math{
	field $pi  :reader;
	field $e   :reader;
		
	BUILD{
		$pi=4*atan2(1,1);
		$e= exp(1);
	}
	
	method mirrorrotate{ # 2d rotate and mirror (made for GearMaker class)
		my ($point,$angle)=@_;
		return [$point->[0]*cos($angle)+$point->[1]*sin($angle),
			   -$point->[1]*cos($angle)+$point->[0]*sin($angle)];
	}
	 
	method rotate{# rotate point or set of points 2d rotate with angle or 3d rotate with 3 rotations
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
	

	method rotx{
		my ($point,$angle)=@_;
		my $matrix=[
		             [1,0,0],
		             [0,cos($angle),-sin($angle)],
		             [0,sin($angle),cos($angle)],
		           ];
		return $self->matrixTransform($point,$matrix);
		
	}
	
	method roty{
		my ($point,$angle)=@_;
		my $matrix=[
		             [ cos($angle),0,  sin($angle)],
		             [     0,      1,       0     ],
		             [-sin($angle),0,cos($angle)  ],
		           ];
		return $self->matrixTransform($point,$matrix);
		
	}
	
	method rotz{
		my ($point,$angle)=@_;
		my $matrix=[
		             [cos($angle),-sin($angle),    0],
		             [sin($angle),cos($angle) ,    0],
		             [      0    ,    0       ,    1],
		           ];
		return $self->matrixTransform($point,$matrix);
	}
	
	
	#rotate about a given point; if center of rotation not given
	#rotate about the mean of the points 
	method rotAbout{
		my ($point,$angle,$cor)=@_;
		$cor//=$self->meanPoint($point);
		$point=$self->subtract($point,$cor);
		$point=$self->rotate($point,$angle);
		$point=$self->add($point,$cor);
		return $point;
	}
				
	method matrixTransform{
		my ($point,$matrix)=@_;
		if (ref $point->[0] ne "ARRAY"){
			return unless defined $point->[0];
			
			
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
		if((scalar @$point1 == scalar @$point2) && (! ref $point1->[0])){
		      return [map{$point1->[$_]+$point2->[$_]} (0..$#$point1)]
		 }
		 elsif (ref $point1->[0] eq "ARRAY"){
			 my $tmp=[@$point1];
			 foreach (0..$#$tmp){
				 $tmp->[$_]=$self->add($tmp->[$_],$point2);
			 }
			 return $tmp;
				
		}#
		else {die "Math->add failed\n'\$point1' was ".
			      $self->serialise($point1)."\n'\$point2' was ".
			      $self->serialise($point2)."\n";
			 };
	}
		
	method subtract{ # add vectors
		my ($point1,$point2)=@_;
		$point2=[map{-$_}@$point2];
		return $self->add($point1,$point2);
	}
	
	method multiply{ # multiply a vector or set of vectors by a scalar
		my ($point1,$scalar)=@_;
		if (ref $point1 eq "ARRAY"){
		  if (!ref $point1->[0]){
			return [map {$scalar*$point1->[$_]} (0..$#$point1)];
		  }
		  elsif(ref $point1->[0] eq "ARRAY"){
			 my $tmp=[@$point1];
			 foreach (0..$#$tmp){
				 $tmp->[$_]=$self->multiply($tmp->[$_],$scalar);
			 }
			 return $tmp;
		  }
		  else{
			  die "Math::multiply() failed";
		  }
		}
		else {return $point1*$scalar};
	}
				
	# measure angle between 2 points from origin
	# if one point passed, angle from point to X-axis
	method angle{
		my ($p1,$p2)=@_;
		$p2//=scalar (@$p1 ==2)?[1,0]:[1,0,0];
		
		die "Cannot measure Math::angle() ; mismatched vector dimensions \n" if (scalar @$p1 != scalar @$p2);
		if (scalar @$p1 ==2){
			return atan2($p1->[0],$p1->[1])-atan2($p2->[0],$p2->[1]);
		}
		else{
			#die $self->serialise([$self->magnitude($p1)*$self->magnitude($p2)]);
			my $div=$self->magnitude($p1)*$self->magnitude($p2);
			return 0 unless $div; # if one of the vector is 0, 0 ISRETURNED;
			die  " One of these vectors ".
			      $self->serialise([$p1,$self->magnitude($p1),$p2,$self->magnitude($p2)]).
			      " is zero length...cannot get angle" if $div==0;
			my $cos=($p1->[0]*$p2->[0]+$p1->[1]*$p2->[1]+$p1->[2]*$p2->[2])/($self->magnitude($p1)*$self->magnitude($p2));
			#die $cos;
			return $self->acos($cos);
		}
	}
	
	method deg2rad{
		my ($deg)=@_;
		return $deg*$pi/180;
	}
	
	method rad2deg{
		my ($rad)=@_;
		return $rad*180/$pi;
	}
	
	method acos{
		my $number=shift;
		die "Out of range in Math::acos(): $number;" if (($number < -1)||($number >1));
		return atan2(sqrt(1-$number*$number),1+$number)*2;
	}
	
	method asin{
		my $number=shift;
		die "Out of range in Math::asin(): $number;" if (($number <= -1)||($number >1));
		return atan2($number,1+sqrt(1-$number*$number))*2;
	}	
	# measure distance between 2 points
	# if only one point passed, distance between point and origin
	# also Euclidian norm, or SRSS (square root of sum of squares)
	method magnitude{
		my ($v1,$v2)=@_;	
		$v2=[(0)x@$v1] unless $v2;	
		my $sum=0;
		for(0..$#$v1){$sum+=($v1->[$_]-$v2->[$_])**2};
		return sqrt($sum);
	}
	
	method dot{ # dot product of two points
		my ($p1,$p2)=@_;	
		die "Points not same dimensions in Math::dot() product\n" if @$p1 !=  @$p2 ;
		my $sum=0;
		for(0..$#$p1){$sum+=$p1->[$_]*$p2->[$_]};
		return $sum;
		
	}
	
	method cross{# cross product of two 3d points
		my ($p1,$p2)=@_;	
		die "Point(s) not 3d in Math::cross() product\n" if((@$p1 !=  @$p2) &&( @$p1 !=3));
		return [$p1->[1]*$p2->[2]-$p1->[2]* $p2->[1],
		        $p1->[2]*$p2->[0]-$p1->[0]* $p2->[2],
		        $p1->[0]*$p2->[1]-$p1->[1]* $p2->[0]]
	}
	
	method unit{# unit vector
		my ($p1)=@_;
		my $mag=$self->magnitude($p1);
		return [map{$p1->[$_]/$mag} 0..$#$p1] ;
	}
		
	method tan{  # tangent of an angle 
		my ($ang)=@_;
		return sin($ang)/cos($ang);
	}
	
	method serialise{ # simple serialiser
		my $st=shift;
		if (ref $st eq "ARRAY"){
			return "[".join(",",map{$self->serialise($_)}@$st)."]"
		}
		elsif (ref $st eq "HASH"){
			return "{".join(",",map{$_."=>".$self->serialise($st->{$_})}keys %$st)."}"
		}
		else{
			$st//="undefined";
			return $st=~/^[\d+-\.]/?$st:"\"$st\"";
		};
	}
	
	method equal{  # test equality between 2 vectors
		my ($p1,$p2)=@_;	
		if (! ref $p1){
			return (($p1==$p2)||($p1 eq $p2))?1:0};
		die "Points not same dimensions in Math::equal()\n" if @$p1 !=  @$p2 ;
		for(0..$#$p1){return 0 unless $self->equal($$p1[$_],$$p2[$_])};
		return 1;
	}
	
	method closest{
		my ($pt,$ptArray)=@_;	
		my $closest={};my $index=0;
		foreach my $tst (@$ptArray){
			if (!$closest->{mag}||($self->magnitude($pt,$tst)<$closest->{mag})){
				$closest={mag=>$self->magnitude($pt,$tst),index=>$index,point=>$tst}   
			}
		}
		return $closest;
	}
	
	method meanPoint{
		my ($ptArray)=@_;	
		my $sums=[(0)x@{$ptArray->[0]}];
		$sums=$self->add($sums,$_) foreach @$ptArray;
		$sums->[$_]=$sums->[$_]/@$ptArray foreach (0..$#$sums);
		return $sums;
	}
	
	method type{
		my $v=shift;
		if (ref $v eq "ARRAY"){
			if (ref $v->[0]  eq "ARRAY"){
				return "LIST of VECTORS";
			}
			elsif (ref $v->[0]  eq "HASH"){
				return "LIST of HASHES";
			}
			else {
				return "VECTOR";
			}
		}
	}
	
	method normal{
		my ($ptArray)=@_;
		die "Insufficient points in Math::normal()" unless @$ptArray>2;
		my $normal=[0,0,0];	
		for (2..$#$ptArray){
			$normal=$self->add($normal,
			              $self->cross(
			                   $self->subtract($ptArray->[$_-1],$ptArray->[$_]),
			                   $self->subtract($ptArray->[$_-2],$ptArray->[$_-1]))
			                   );
		}
		return $self->unit($normal);
		
	}
	
	# doesnot work---to fix
	method normTo{
		my ($profile,$newNorm)=@_;
		my $oldNorm=$self->normal($profile);
		my $xr=$self->angle([0,$oldNorm->[1],$oldNorm->[2]],[0,$newNorm->[1],$newNorm->[2]]);
		my $yr=$self->angle([$oldNorm->[0],0,$oldNorm->[2]],[$newNorm->[0],0,$newNorm->[2]]);
		my $zr=$self->angle([$oldNorm->[0],$oldNorm->[1],0],[$newNorm->[0],$newNorm->[1],0]);
		return $self->rotAbout($profile,[$xr,$yr,$zr]);
		
	}
	
	# points a profile/point Array with normal in z-direction (unit normal is [0,0,1]), into a new direction 
	method pointTo{#credit Charthulius Wheezer
		my ($pointArray, $direction)=@_;
		$pointArray=$self->roty($pointArray,atan2($self->magnitude([$direction->[0],$direction->[1]]),$direction->[2] )+$self->pi()/2);
		$pointArray=$self->rotz($pointArray,atan2($direction->[1],$direction->[0] ));
		return $pointArray;
		
	}
}
