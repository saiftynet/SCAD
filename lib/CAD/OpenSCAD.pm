use strict;
use warnings;
use Object::Pad;

our $VERSION=0.05;
=head1 CAD::OpenSCAD

Module to generate .scad file from Perl

=head1 SYNOPSIS

     use CAD::OpenSCAD;
     my $scad=new SCAD;
     $scad->cube("main",[10,10,10],1)
          ->cylinder("hole",{r=>4,h=>20},1)
          ->difference("newObject","main","hole")
          ->build("newObject")
          ->save("testScad");


=head1 DESCRIPTION

This module allows creation of SCAD scripts for running through OpenSCAD,
the "Programmers CAD Application". OpenSCAD can be scripted, having a
fairly comprehensive language to create complex 3D objects.
CAD::OpenSCAD allows generation and manipulation of 3D objects in a
Perlish way,while relying on OpenSCAD to all the hardwork, merely by
generating SCAD scripts.

=head1 MAIN METHODS

Creating a SCAD object is by the standard methods.
Optional parameters are hash C<< key=>value >> pairs.
valid keys are C<fa>, C<fs> and C<tab>

     use CAD::OpenSCAD;
     my $scad=new SCAD(<optional parameters>);

New elements can be added to this SCAD object; each object is named
for subsequent transformations
=cut


class SCAD{
   field $script :reader :param  //="";
   field $items  :reader :writer //={};
   field $fa     :writer :param //=1;
   field $fs     :writer :param //=0.4;
   field $tab    :writer :param //=2;
   field $vars   = {};
   field $externalFiles=[];
   field $modules={};

=head3 cube

C<cube> creates a cube element e.g. C<< $scad->cube("bodyBase",[60,20,10],1); >>.
The first parameter is the name of the element (if the named element
exists already, it will be over-written). The second parameter is an
arrayref of three dimensions. The third parameter defines whether the
element is centered in the origin (a true value here centers the element)

=cut
  
   method cube{
      my ($name,$dims,$center)=@_;
      $items->{$name}="\/\/ $name\ncube(".$self->dimsToStr($dims,"") .($center?",center=true);\n":");\n");
      return $self;
   }
   
=head3 cylinder

Creates a cylinder element e.g. C<< $scad->cylinder("wheel",{h=>2,r=>8},1) >>.
The first parameter is the name of the element (if the named element
exists already, it will be over-written). The second parameter is a
hashref of defining radius and height. The third parameter defines whether
the element is centered on the origin (a true value here centers the element)
=cut
   
  method cylinder{
      my ($name,$dims,$center)=@_;
      $items->{$name}="\/\/ $name\ncylinder(".$self->dimsToStr($dims,"HASH") .($center?",center=true);":");\n");
      return $self;
  }

=head3 sphere

Creates a sphere element e.g. C<< $scad->cylinder("ball",{r=>8})  >>. The
first parameter is the name of the element (if the named element exists
already, it will be over-written).The second parameter is a hashref
of defining radius of the sphere. 

=cut
  
  method sphere{
      my ($name,$dims)=@_;
      $items->{$name}="\/\/ $name\nsphere(".$self->dimsToStr($dims) .");\n";
      return $self;
  }
  
  method polyhedron{
      my ($name,$points,$faces,$convexity)=@_;
      $items->{$name}="\/\/ $name\npolyhedron($points, $faces, $convexity);\n";
      return $self;
  }


  
  method remove{  # remove unneeded shapes
      delete $items->{$_} foreach (@_);
      return $self;
  }
  
  method group{  # group shapes together
	   my ($name,@itemNames)=@_;
	   my $merged="";
	   $merged.=$items->{$_} foreach @itemNames;
	   $items->{$name}="{\n".$self->tab($merged)."}\n";
	   return $self;
  }

=head3 translate

Moves an element by name a specified displacement in X,Y,Z directions
.e.g. C<< $scad->cube("bodyTop",[30,20,10],1)->translate("bodyTop",[0,0,5]) >> 
The first parameter is the name of the element (the element must exist already).
The second parameter is an arrayef of three elements defining disp[lacement.
=cut

  method translate{
      my ($name,$dims)=@_;
      die "No item called $name" unless ($items->{$name});
      $items->{$name}="translate(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tab($items->{$name});
      return $self;
	  
  }

=head3 rotate

Rotates an element by name around in  X,Y,Z axes.e.g.
 C<< $scad->cylinder("wheel",{h=>2,r=>8},1)->rotate("wheel",[90,0,0]); >>.  The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayref of three rotations
in degrees.
=cut

  method rotate{
      my ($name,$dims)=@_;
      $items->{$name}="rotate(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tab($items->{$name});
      return $self;
	  
  }
   
  method resize{
      my ($name,$dims)=@_;
      $items->{$name}="resize(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tab($items->{$name});
      return $self;
	  
  }
  
=head3 scale

Scales an element by name by specified ratios in X,Y,Z directions.e.g.
C<< $scad->cube("bodyTop",[30,20,10],1)->scale("bodyTop",[1,2,0.5]) >>.  The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayref of three scale factors. 
=cut
  
  method scale{
      my ($name,$dims)=@_;
      $items->{$name}="scale(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tab($items->{$name});
      return $self;
	  
  } 

=head3  union

Implicitly joins multiple elements into one element.e.g.C<< $scad->union("wheel",qw/wheel nut nut1 nut2 nut3/); >>
the first item is the name of the new element created, the following elements are elements to be joined together.
If an element with the name of the first parameter does not exist, it is created, otherwise it is over-written.

=cut
  
  method union{
      my ($name,@names)=@_;
      die "Union requires more than one shape" unless scalar @names>1;
      $self->group($name,@names);
      $items->{$name}="union()\n".$items->{$name};
      return $self;
  }


=head3 difference

Subtracts one or more elements from one element and creates a new element.
e.g. C<< $scad->difference("wheel",qw/wheel nut nut1 nut2 nut3/); >>
The first parameter`"wheel"` in this example is the name of the new element created,
the second parameter refers to the item that all other elements are subtracted from.
If an element with the name of the first parameter does not exist, it is created,
otherwise it is over-written.So this statement takes the item "wheel"
(the scendond parameter), subtracts all the nuts, and overwrites the code
in "wheel"(first parameter). 

=cut    
  method difference{
      my ($name,@names)=@_;
      die "Difference requires more than one shape" unless scalar @names>1;
      $self->group($name,@names);
      $items->{$name}="\/\/ $name\ndifference()\n".$items->{$name};
      return $self;
  }  
  
=head3 intersection

Creates an element representing the overlapping parts of 2 or more elements
.e.g. C<< $scad->intersection("overlap",qw/item1  item2 item3/); >> The first
parameter is the name of the new element created, the other names refer to
elements which overlap neach other.  
=cut

  method intersection{
      my ($name,@names)=@_;
      die "Intersection requires more than one shape" unless scalar @names>1;
      $self->group($name,@names);
      $items->{$name}="\/\/ $name\nintersection()".$items->{$name}  ;
      return $self;
  }  

=head3 circle

A 2D drawing primitive that creates a circle that may be extruded to create other 3D structures.
e.g C<< $scad->circle("circle",{r=>5}); >>
=cut
  method circle{
      my ($name,$dims)=@_;
      $items->{$name}="\/\/ $name\ncircle(".$self->dimsToStr($dims,"HASH") .");\n";
      return $self;
  }
  
=head3 square

a 2D drawing primitive that creates a rectangle that may be extruded to create other 3D structures.
e.g C<< $scad->square("square",[10,10]); >>
=cut  

  method square{
      my ($name,$dims)=@_;
      $items->{$name}="square(".$self->dimsToStr($dims) .");\n";
      return $self;
  }

=head3 polygon

A 2D drawing primitive that creates a polygon that may be extruded to create other 3D structures .
Example:- 

  my $extrusion=new SCAD;
  $extrusion->variable({p0=>[0, 0],p1 => [0, -30],p2 => [15, 30],p3=> [35, 20],p4 => [35, 0]})
            ->variable("points",[qw/p0 p1 p2 p3 p4 /] )
            ->polygon("poly","points")
            ->linear_extrude("poly",{height=>100,twist=>180}); 

=cut  

  method polygon{
      my ($name,$dims)=@_;
      $items->{$name}="polygon(".$self->dimsToStr($dims) .");\n";
      return $self;
  }

=head3 rotate_extrude

A method to extrude a 2D shape while rotating invokes similar to liner_extrude

  my $extrusion=new SCAD;
  $extrusion->circle("circle",{r=>5})
            ->translate("circle",[10,0,0])
            ->rotate_extrude("circle",{angle=>180});

=cut 
	 	  
  method rotate_extrude{
      my ($name,$item,$dims)=@_;
      $items->{$name}="rotate_extrude(".$self->dimsToStr($dims,"HASH")."){\n  ".$items->{$item}."}\n"  ;
      return $self;
  }  

=head3 liner_extrude

A method to extrude a 2D shape see above for example
=cut

  method linear_extrude{
      my ($name,$item,$dims)=@_;
      $items->{$name}="linear_extrude(".$self->dimsToStr($dims,"HASH")."){\n  ".$items->{$item}."}\n"  ;
      return $self;
  }  

=head3 color

colors an item e.g. . C<< $scad->cylinder("ball",{r=>8})->color("ball","green")  >>. 
=cut
  	  
  method color{
	  my ($name,$color)=@_;
      $items->{$name}="color(\"$color\")\n".$self->tab($items->{$name});
      return $self;
  }

# internal methods

  method tab{ # internal tabbing for scripts;
	  my $scr=shift;
	  return unless $scr;
	  my $tabs=" "x$tab;
	  chomp $scr;
	  $scr=$tabs.(join "\n$tabs", (split "\n",$scr))."\n";
	  return $scr;
  }
=head3 clone

Creates copies of elements with same features. e.g.C<< $car->clone("axle",qw/frontaxle rearaxle/); >>
This just copies the code for the element into new elements, for subsequent transformation 
(otherwise all the elements are positioned in the same place overlying one another)
=cut  

  method clone{
	   my ($name,@cloneNames)=@_;
	   $items->{$_}=$items->{$name} foreach @cloneNames;
	   return $self;
  }
  
=head3 variable

Creates variables that SCAD can use for customising objects easily 
(see polygon example above)

=cut
   method variable{
	   my ($varName,$value)=@_;
	   if (ref $varName){
		   for (keys %$varName){
			   $vars->{$_}=$varName->{$_}
		   }
	   }
	   else{
		   $vars->{$varName}=$value;
	   }
	   return $self;
   }

   method dimsToStr{
	  my ($dims,$expected)=@_;
	  return "" unless $dims;
      if (ref $dims){
        if (ref $dims eq "ARRAY"){
          return "[".(join ",",map{ref $_ eq "ARRAY"?"[".join(",",@$_)."]":$_ }@$dims)."]";
        }
        elsif ($expected && $expected eq "ARRAY"){
			die "Incorrect parameter...should be arrayref";
		}
        elsif (ref $dims eq "HASH" ){
			my $ret="";
			$ret.= $_."=".$dims->{$_}."," for (keys %$dims);
			chop $ret;
			return $ret;			
        }
        elsif ($expected && $expected eq "HASH"){
			die "Incorrect parameter...should be hashref";
		}
        else{
           die "Incorrect dimensions...should be arrayref of 3 numbers or hashref or string";
        }
      }
      return $dims;
  }
  
=head3 build

Collects the elements specified (i.e. not all the elements, just the items required for the build)
and all the variables to generate a scad file.  The scad file generated include all the variables defined,
the modules built and the libraries used  
=cut

  method build{
	  $script="\$fa=$fa;\n\$fs=$fs;\n";
	  if (scalar @$externalFiles){
		  $script.="use <$_>;\n" foreach  @$externalFiles;
	  }
	  if (%$vars){
		  for my $k(sort keys %$vars){
			  my $value=(ref $vars->{$k})?"[".join(",",@{$vars->{$k}})."]":$vars->{$k};
			 $script.="$k = $value;\n"; 
		  }
	  }
	  $script.=$modules->{$_}  foreach (keys %$modules);
	  $script.=$items->{$_}  foreach @_;
	  return $self;
  }
=head3 save

saves the .scad file, and also uses openscad to generate images or 3D objects
from the script, or open it in openSCAD directly after building the shape;
C<< $scad->build("ext")->save("extrusion"); >> builds a scad file with the item "ext",
then saves the scad file, and automatically opens OpenSCAD file.
if another parameter passed, the generates a corresponding file, from one of
(stl|png|t|off|wrl|amf|3mf|csg|dxf|svg|pdf|png|echo|ast|term|nef3|nefdbg)
e.g. C<< $scad->save("extrusion","png") >>
=cut

  method save{  #
	  my ($fileName,$format)=@_;
	  $fileName=$fileName.".scad" unless ($fileName=~/\.scad$/);
	  die "No script to save" unless $script;
	 # (my $newFile=$fileName)=~s/scad$/stl/;
	  open my $fh,">",$fileName or die "Cannot save $fileName";
	  print $fh $script;
	  if ($format  && ($format=~/^(stl|png|t|off|wrl|amf|3mf|csg|dxf|svg|pdf|png|echo|ast|term|nef3|nefdbg)$/)){
        (my $newFile=$fileName)=~s/scad$/$format/;
        system ("openscad", $fileName, "-o$newFile");
	  }
	  else{
		  system ("openscad", $fileName)
	  }
	  return $self;
  }
  
## External files

  method import{
      my ($name,$dims)=@_;
      my $file=ref $dims?$dims->{file}:$dims;
      my ($ext) = $file =~ /(\.[^.]+)$/;# get extension
      if ($ext=~/^(STL|OFF|OBJ|AMF3MF|STL|DXF|SVG)$/i){
		   $items->{$name}="import(".dimsToStr($dims).");\n"  ;
	  }
	  return $self;
  }

  method importModule{# use this only to generate standalone files
	  my ($file,$moduleName)=@_;
	  my $regexp=qr/module\s+([A-z0-9_]+)[\s\(]([^\)]*)\)\s*(\{([^\{\}]+|\{[^\{\}]*\})*\})/;
	  my $data="";
	  open my $fh,"<",$file or die "Cannot open $file";
	  while(my $line = <$fh>){
		  $data.=$line;
       }
       close $fh;
       
       my @groups = $data =~ m/$regexp/g;
       if ($1 eq $moduleName){
          $modules->{$1}={params=>$2,code=>$3};
	   }
	  return $self;
  }  


# modules

  method use{
	  $externalFiles=[@$externalFiles,@_];
	  return $self;
  }
  
  method makeModule{
	  my ($moduleName,$params,@names)=@_;
      $self->group("_tmp_$moduleName",@names);
	  $modules->{$moduleName}="module $moduleName($params)".$items->{"_tmp_$moduleName"};
	  $self->remove("_tmp_$moduleName");
	  return $self;
  }

  method runModule{
	  my ($moduleName,$name,$dims)=@_;
	  die "No module $moduleName" unless $modules->{$moduleName};
      $items->{$name}="$moduleName(".$self->dimsToStr($dims).");\n"  ;
      return $self;
  }

}

=head1 SUPPORT
=cut

=head1 COPYRIGHT AND DISCLAIMERS
Copyright (c) 2025 Saif Ahmed.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
=cut

=head1 AUTHOR
SAIFTYNET
=cut
