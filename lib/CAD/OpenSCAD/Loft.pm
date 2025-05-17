package CAD::OpenSCAD::Loft;  # for MetaCPAN

use strict;use warnings;
use lib "../../../lib";

use Object::Pad;
use CAD::OpenSCAD::Math;

our $Math=new CAD::OpenSCAD::Math;

=pod

=head1 NAME

CAD::OpenSCAD::Loft - A module to generate lofted shapes for CAD::OpenSCAD

=cut


class CAD::OpenSCAD::Loft{
	field $scad :param;	

our $VERSION='0.17';	
=head3 C<loftSolid>

A solid created from lofts between 2 faces.

  $loft->loftSolid($name,$face1,$face2)


if $name is undefined returns a hashref {points=>$points,faces=>$faces}
Otherwise inserts a polyhedron named $name in the openSCAD objects items list

=cut	
	
	method loftSolid{
		my ($name,$face1,$face2)=@_;
		my $pts=[@$face1,@$face2];
		my $faces=[[reverse(0..$#$face1)],@{$self->loftShell($face1,$face2)},[$#$face1+1..$#$face1+$#$face2+1]];
		if ($name){
			$scad->polyhedron($name,{points=>$pts,faces=>$faces});
			return $scad;
		}
		return {points=>$pts,faces=>$faces}
	}

=head3 C<helix>


=cut	

	method helix{
		my $name=shift;
		my ($profile,$radius,$steps,$turns,$verticalShift,$radialShift);
		unless (ref $_[0] eq "HASH"){
			($profile,$radius,$steps,$turns,$verticalShift,$radialShift)=@_;
		}
		else{
			my $params=$_[0];
			($profile,$radius,$steps,$turns,$verticalShift,$radialShift)=
			   map {$params->{$_}}(qw/profile radius steps turns verticalShift radialShift/);
		}
		my $face1=[];
		push @$face1,[0,$_->[0],$_->[1]] foreach(@$profile);  # map profile in Y and Z plane
		$face1=$Math->add($face1,[0,$radius,0]);              # shift profile $radius distance along X
		my $faces=[[reverse(0..$#$face1)]];
		my $points=[@$face1];my $index=0;                     # first face   
		for (0..$turns*$steps){
			my $face2=$Math->rotz($face1,$Math->deg2rad(-360/$steps));  # rotate and shift to get next face
			$face2=$Math->add($face2,[$radialShift*sin($_*2*$Math->pi/$steps),$radialShift*cos($_*2*$Math->pi/$steps),$verticalShift]);
			push @$points,@$face2;                           # add to points list
			push @$faces, @{$self->loftShell($face1,$face2,$index)};# the lofted faces added
			$face1=[@$face2];                                # last face becomes first for the next loft;
			$index+=scalar @$face1;
		}
		#? old ? error push @$faces,[$#$faces..$#$faces+scalar @$face1];
		# new one below...
		push @$faces,[$#$points-$#$face1..$#$points];
		
		if ($name){
			$scad->polyhedron($name,{points=>$points,faces=>$faces});
			return $scad;
		}
		return {points=>$points,faces=>$faces}
	}	


=head3 C<spheroid>

Returns a shere shaped polyhedron based on lofted regular polygons

  $loft->spheroid($name,$sides,$radius);
  $loft->spheroid($name,{sides=>$sides,radius->$radius});

if $name is undefined returns a hashref {points=>$points,faces=>$faces}
Otherwise inserts a polyhedron named $name in the openSCAD objects items list


=cut	

	method spheroid{# this generates a spheroid using a series of lofts between polygons
	  my $name=shift;
      my ($sides,$radius);
	  unless (ref $_[0]){
		($sides,$radius)=@_;
	  }
	  else{
		my $params=$_[0];
		($sides,$radius)=
		   map {$params->{$_}}(qw/sides radius/);
	  }
	  my $angle=2*$Math->pi/$sides;
	  my $pts=[];my $layers=[];my $faces;my $index=0;
	  my $start=$sides/4+1;
	  my $end=3*$sides/4 -($sides%4?0:1);
	  for my $lat ($start..$end){
		my $layer=[];
		for my $long(0..$sides-1){
		  unshift @$layer,[$radius*cos($lat*$angle)*sin($long*$angle),$radius*cos($lat*$angle)*cos($long*$angle),$radius*sin($lat*$angle)]
		}
		push @$pts,@$layer;
		push @$layers,[@$layer];
		if ( 1 == @$layers ){
			push @$faces,[reverse(0..$#$layer)]; #top polygon
		}
		else{
			push @$faces,@{$self->loftShell($layers->[-2],$layers->[-1],$index)};# the lofted faces added
			$index+=scalar @{$layers->[-2]};
		}
	   }
	   push @$faces,[$#$pts-$sides+1..$#$pts];# bottom polygon;
	   if ($name){
		   $scad->polyhedron($name,{points=>$pts,faces=>$faces});
		   return $scad
	   }
	   return {points=>$pts,faces=>$faces};
    }

=head3 C<regularPolygon>

Returns a regular polygon given sides and bounding circle radius

  $loft->regularPolygon($sides,$radius);
  $loft->regularPolygon({sides=>$sides,radius->$radius});

=cut	

	method regularPolygon{
	  my $name=shift;
      my ($sides,$radius);
	  unless (ref $_[0]){
		($sides,$radius)=@_;
	  }
	  else{
		my $params=$_[0];
		($sides,$radius)=
		   map {$params->{$_}}(qw/sides radius/);
	  }
	  my $angle=2*$Math->pi/$sides;
	  my $pts=[];
	  for (0..$sides-1){
		  push @$pts,[$radius*sin($_*$angle),$radius*cos($_*$angle)]
	  }
	  if ($name) {
		  $scad->polygon($name,$pts);
		  return $scad;
	  }
	  return $pts;
	}

=head3 C<star>

Returns a polygon given points, internal and external radii

  $loft->star($points,$extRadius,$intRadius);
  $loft->star({points=>$points,extRadius=>$extRadius,intRadius=>$intRadius});

=cut	

	method star{
	  my $name=shift;
      my ($points,$extRadius,$intRadius);
	  unless (ref $_[0]){
		($points,$extRadius,$intRadius)=@_;
	  }
	  else{
		my $params=$_[0];
		($points,$extRadius,$intRadius)=
		   map {$params->{$_}}(qw/ points extRadius intRadius/);
	  }
	  my $angle=$Math->pi/$points;
	  my $pts=[];
	  for (0..$points-1){
		  push @$pts,[$extRadius*sin(2*$_*$angle),$extRadius*cos(2*$_*$angle)];
		  push @$pts,[$intRadius*sin((2*$_+1)*$angle),$intRadius*cos((2*$_+1)*$angle)];
	  }
	  if ($name) {
		  $scad->polygon($name,$pts);
		  return $scad;
	  }
	  return $pts;
	}

=head3 C<loftShell>

This basic funstion cteates a shell of the loft bewteen two profiles
The end profile faces are not included, so a hollow shell is produced, allowing
joining of multiple shells. an index is passed to indicate the position
of the points of the vertices of the faces to be lofted between.

=cut	

    method loftShell{
		my ($face1,$face2,$index)=@_;
		$index//=0;
		my $loftFaces=[];
		my @indices=($index..$#$face1+$index,@$face1+$index..@$face1+$#$face2+$index);
		my $diff=abs(@$face2-@$face1); # difference in vertex count of faces
		if ($diff){
			my $steps=@$face2>@$face1?$#$face1/$diff:$#$face2/$diff; # smaller array needs to be padded;
			my $start=(@$face2>@$face1?$#$face1:$#indices)-$steps/2;
			for (1..$diff){
				splice (@indices,$start,0,$indices[$start]);
				$start-=$steps;
			}
		}
		
		foreach (0..@indices/2-2){
		   my $face=[$indices[$_],$indices[$_+1],$indices[(@indices/2)+1+$_],$indices[(@indices/2)+$_]];
		   push @$loftFaces,$face;
		}
		push @$loftFaces,[$indices[@indices/2-1],$indices[0],$indices[@indices/2],$indices[-1]];
		return $loftFaces;
   }

=head3 C<profilePlane>

maps a profile (a 2D shape) onto a x,y,or z plane,

=cut	
   
   method profilePlane{
	   my $profile=shift;
	   my $plane=shift;
	   my $disp=shift//0;
	   for ($plane){
		   /0|x/i && do{
			   $profile=[map{[$disp,$_->[0],$_->[1]]}@$profile];
			   last;
		   };
		   /1|y/i && do{
			   $profile=[map{[$_->[0],$disp,$_->[1]]}@$profile];
			   last;
		   };
		   /2|z/i && do{
			   $profile=[map{[$_->[0],$_->[1],$disp]}@$profile];
			   last;
		   };
		   die "Unrecognised plane"
	   }
	   return $profile;
	   
   }
   
=head3 C<conoid>


=cut	
    
   method conoid{
	  my $name=shift;
      my ($apex,$sides,$radius);
	  unless (ref $_[0] eq "HASH"){
		($apex,$sides,$radius)=@_;
	  }
	  else{
		my $params=$_[0];
		($sides,$radius)=
		   map {$params->{$_}}(qw/apex sides radius/);
	  }
	  my $profile=$self->regularPolygon(undef,$sides,$radius);
	  my $pts=[$apex,$profile->[-1]];my $faces=[];
	  foreach(0..$#$profile){
		  push @$faces,[0,$_+1,$_+2];
		  push @$pts,$profile->[$_];
	  }
	  push @$faces,([0,$#$profile+2,1],[reverse(1..$sides+1)]);
	  $faces=$self->reverseFaces($faces) if $apex->[2]<0;
	  if ($name){
			$scad->polyhedron($name,{points=>$pts,faces=>$faces});
			return $scad;
		}
		return {points=>$pts,faces=>$faces}
   }
   
=head3 C<reverseFaces>


=cut	
       
   method reverseFaces{
	   my $faces=shift;
	   return [map {[reverse @$_]}@$faces]
   }
   
=head3 C<arc>

Makes an arc


=cut	
       
   method arc{
		my $name=shift;
		my ($profile,$radius,$steps,$angle);
		unless (ref $_[0] eq "HASH"){
			($profile,$radius,$steps,$angle)=@_;
		}
		else{
			my $params=$_[0];
			($profile,$radius,$steps,$angle)=
			   map {$params->{$_}}(qw/profile radius steps angle/);
		}
		my $face1=[];
		push @$face1,[$_->[0],$_->[1],0] foreach(@$profile);  # map profile in X and Y plane
		my $faces=[[reverse(0..$#$face1)]];
		$face1=$Math->add($face1,[$radius,0,0]);              # shift profile $radius distance along X
		my $stepAngle=$Math->deg2rad($angle/$steps);
		my $points=[@$face1];my $index=0;                     # first face   
		for (0..$steps-1){
			my $face2=$Math->roty($face1,-$stepAngle);  # rotate and shift to get next face
			#$face2=$Math->add($face2,[$radius*sin($stepAngle),$radius*cos($stepAngle),0]);
			push @$points,@$face2;                           # add to points list
			push @$faces, @{$self->loftShell($face2,$face1,$index)};# the lofted faces added
			$face1=[@$face2];                                # last face becomes first for the next loft;
			$index+=scalar @$face1;
		}
		push @$faces,[$#$points-$#$face1..$#$points];
		
		if ($name){
			$scad->polyhedron($name,{points=>$points,faces=>$faces});
			return $scad;
		}
		return {points=>$points,faces=>$faces}
	}	
	
   
=head3 C<loftPath>

Given a path and a profile, sweeps the profile along that path e.g.

	my $scad=new OpenSCAD;
	my $loft= new  CAD::OpenSCAD::Loft(scad=>$scad);

	# create profile to loft as a set of points;
	my $profile=$loft->regularPolygon(undef,10,3);

	# Create a path
	my $path=[];
    foreach (0..360){
	  next if $_ % 5;
	  my $t=$math->deg2rad($_);
	  push @$path,[(sin($t)+2*sin(2*$t))*10,
	             (cos($t)-2*cos(2*$t))*10,
	             -sin(3*$t)*10] ;          
    }
    
    # loft profile along path 
	$loft->loftPath("pathFollow",$profile,$path);		

	$scad->build("pathFollow")
		 ->save("test");


=cut	
  	
	method loftPath{
		my $name=shift;
		my ($profile,$path);
		unless (ref $_[0] eq "HASH"){
			($profile,$path)=@_;
		}
		else{
			my $params=$_[0];
			($profile,$path)=
			   map {$params->{$_}}(qw/profile path/);
		}
		
		my $faces=[]; my $points=[];my $index=0;
		my $profile3D=$self->profilePlane($profile,"x",0);
		my $face1=$Math->add($Math->pointTo($profile3D,$Math->subtract($path->[-1],$path->[+1])),$path->[0]);
		push @$points,@$face1;
		foreach (1..$#$path){
			my $face2=$Math->add($Math->pointTo($profile3D,$Math->subtract($path->[$_-1],$path->[($_+1)%$#$path])),$path->[$_]);
			#$profile3D=$self->profilePlane($Math->rotate($profile,$_*$Math->pi*20/@$path),"x",0);
			push @$points,@$face2;
			push @$faces, @{$self->loftShell($face1,$face2,$index)};# the lofted faces added
			$face1=[@$face2];                                # last face becomes first for the next loft;
			$index+=scalar @$face1;
		}
		unshift @$faces,[reverse(0..$#$face1)];        # first face
		push @$faces,[$#$points-$#$face1..$#$points];  # last face
		
		if ($name){
			$scad->polyhedron($name,{points=>$points,faces=>$faces});
			return $scad;
		}
		return {points=>$points,faces=>$faces}	
	}
	
	
	method prism{
		my ($name,$face1,$face2)=@_;
		return $self->loftSolid($name,$face1,$face2);
	}
  	
	method globoid{
		my ($name,$edge,$radius)=@_;
		my $face1=$self->regularPolygon(undef,3);
		my $face2=$self->regularPolygon(undef,4);
		
		
		
	} 

}
