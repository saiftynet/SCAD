use strict; use warnings;
use lib "../";

use Object::Pad;
use CAD::OpenSCAD::Math;

our $Math=new CAD::OpenSCAD::Math;

our $VERSION='0.16';

=pod

=head1 NAME

CAD::OpenSCAD - A module to generate OpenSCAD files for 3D Object creation in Perl

=head2 SYNOPSIS

     use CAD::OpenSCAD;
     my $scad=new OpenSCAD;
     $scad->cube("main",[10,10,10],1)
          ->cylinder("hole",{r=>4,h=>20},1)
          ->difference("newObject","main","hole")
          ->build("newObject")
          ->save("testScad");


=head2 DESCRIPTION

*** B<From Version 0.14 the API change to make class the same name as module file
means that the className is now OpenSCAD (was SCAD before> ***
CAD is not really something that has had significant recent Perl
attention.  The OenSCAD framework allows the use of scripted generation
and manipulation of 3D objects, and this module attempts to make this
accessible in Perl. Object::Pad, a modern OOP paradigm, is used but
deliberately not using its full features.  The OpenSCAD GUI can be
used to display outputs, although  .STL, .PNG,and .SCAD files  (and
others) may also be generated.  The example script L<car.pl|https://github.com/saiftynet/SCAD/blob/main/Examples/car.pl> 
replicates one of the L<tutorial|https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_1>
objects.  As you can see, the OpenSCAD object is returned after every
operation, allowing daisy-chaining of operations.  The items within are
named for easy identification and often appear in the .scad file
generated as comments. These items can be collected, and built (to
generate the OpenSCAD script), and potentially saved in various formats
using OpenSCAD, or injected directly into the GUI tool for further 
fine-tuning. (OpenSCAD is required to be installed for rendering)

At this point the main goal is to have the ability to generate 3D
objects within perl programs. With this tool one can use data acquired
in perl programs to create 3D objects without having to know the OpenSCAD
scripting language, although knowing this would allow fuller exploitation
of the native OpenSCAD powers. One could use the output for

=over

=item * L<3D printing|https://github.com/saiftynet/SCAD/blob/main/Examples/box.pl>

=item * L<charting|https://github.com/saiftynet/SCAD/tree/main/Examples#pichartpl>

=item * L<graphical design|https://github.com/saiftynet/SCAD/tree/main/Examples#circletextpl>

=item * L<mechanical design|https://github.com/saiftynet/SCAD/tree/main/Examples#gearpl>,

=item * L<animations|https://github.com/saiftynet/SCAD/tree/main/Examples#animation-using-scad>

=back

=begin html

<hr> <img src="https://github.com/saiftynet/dummyrepo/raw/main/SCAD/doublehelix%20rack%20and%20gear%20(1).gif?raw=true">

=end html


=head2 MAIN METHODS

Creating an  OpenSCAD object is by the standard methods.
Optional parameters are hash C<< key=>value >> pairs.
valid keys are C<fa>, C<fs> and C<tab>

     use CAD::OpenSCAD;
     my $scad=new OpenSCAD();
     # optionally can add fs, fa and tab on intialisation
     # e.g my $scad=new OpenSCAD(fs=>1, fa=>0.4, tab=>0);

New elements can be added to this OpenSCAD object; each object is named
for subsequent transformations
=cut


class OpenSCAD{
   field $script :reader :param  //="";
   field $items  :reader :writer //={};
   field $fa     :writer :reader :param //=1;
   field $fs     :writer :reader:param //=0.4;
   field $vp     :writer :reader;
   field $vpt    :writer :reader;  # viewport translation;
   field $vpd    :writer :reader;  # viewport camera distance
   field $vpf    :writer :reader;  # viewport camera field of view
   field $preview:writer :reader :param //=1;  # preview
   field $tab    :writer :param //=2;
   field $vars   = {};
   field $externalFiles=[];
   field $modules={};
   field $status :writer;
   field $extensions  ={};
   
   our $VERSION='0.16';

=head4 set_fs set_fa set_tab set_vpt set_vpd set_vpf set_vp set_preview

Using these, one can set parameters for the surface generation and script
outputs. e.g.

  $scad->set_fa(10) 

=head3 3D Primitive Shapes

=head4 cube

C<cube> creates a cube element e.g.

  $scad->cube("bodyBase",[60,20,10],1);

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
   
=head4 cylinder

Creates a cylinder element e.g.

   $scad->cylinder("wheel",{h=>2,r=>8},1);
   
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

=head4 sphere

Creates a sphere element e.g.

  $scad->sphere("ball",{r=>8});
  
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
      my ($name,$dims)=@_;
      $items->{$name}="\/\/ $name\npolyhedron(points= ".$self->dimsToStr($dims->{points})." , faces= ".$self->dimsToStr($dims->{faces}).($dims->{convexity}?" , convexity=".$self->dimsToStr($dims->{convexity}):"").");\n";
      return $self;
  }



=head3 Transformations

=head4 translate

Moves an element by name a specified displacement in X,Y,Z directions
e.g. 

  $scad->cube("bodyTop",[30,20,10],1)->translate("bodyTop",[0,0,5]);
  
The first parameter is the name of the element (the element must exist already).
The second parameter is an arrayref of three elements defining displacement.
=cut

  method translate{
      my ($name,$dims)=@_;
      die "No item called $name" unless ($items->{$name});
      $items->{$name}="translate(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tabThis($items->{$name});
      return $self;
	  
  }

=head4 rotate

Rotates an element by name around X,Y,Z axes about the origin [0,0,0].e.g.

    $scad->cylinder("wheel",{h=>2,r=>8},1)->rotate("wheel",[90,0,0]);

The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayref of three rotations
in degrees.
=cut


  method rotate{
      my ($name,$dims)=@_;
      $items->{$name}="rotate(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tabThis($items->{$name});
      return $self;
	  
  }
  
=head4 mirror

Mirrors an element by name about a plane. That plane is defined by the normal to that vector, 
and the plane goes through the origin.

    $scad->cube([2,2,2])->mirror("cube",[1,0,0]);
    
The first parameter is the name of the element (the element must exist already). The second parameter
is an arrayref containg the planes normal e.g.[1,0,0] implies a mirroring about the X-axis.

=cut
 

  method mirror{
      my ($name,$dims)=@_;
      $items->{$name}="mirror(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tabThis($items->{$name});
      return $self;
	  
  }
    
=head4 resize

Resizes an element by name to specified dimensions in X,Y,Z directions.e.g.

   $scad->cube("bodyTop",[30,20,10],1)->resize("bodyTop",[3,2,6]);

The first parameter is the
name of the element (the element must exist already).The second parameter is an arrayref of three
scale factors. 
=cut
   
  method resize{
      my ($name,$dims)=@_;
      $items->{$name}="resize(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tabThis($items->{$name});
      return $self;
	  
  }
  
=head4 scale

Scales an element by name by specified ratios in X,Y,Z directions.e.g.

   $scad->cube("bodyTop",[30,20,10],1)->scale("bodyTop",[1,2,0.5]);
   
The first parameter is the name of the element (the element must exist already).
The second parameter is an arrayref of three scale factors. 
=cut
  
  method scale{
      my ($name,$dims)=@_;
      $items->{$name}="scale(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tabThis($items->{$name});
      return $self;
	  
  } 

=head4 multimatrix

Multiplies the geometry of all child elements with the given
L<affine|https://en.wikipedia.org/wiki/Transformation_matrix#Affine_transformations>
 transformation matrix, where the matrix is 4X3, or a 4X4 matrix
with the 4th row always forced to [0,0,0,1].  
=cut
  
  method  multimatrix{
      my ($name,$dims)=@_;
      $items->{$name}="multimatrix(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tabThis($items->{$name});
      return $self;
	  
  } 

=head4 skew

Uses MultiMatrix to transform a item by skewing in xy, yx, zy, yz, xz, zx  planes.
this uses a matrix described in L<this gist|https://gist.github.com/boredzo/fde487c724a40a26fa9c>
(see corrections). e.g.

   $scad ->cube("box",[10,10,20])->skew("box",{xz=>-25});


  
=cut
  

   method skew{
      my ($name,$dims)=@_;
	  my $matrix=[
		[ 1, $Math->tan($Math->deg2rad($dims->{xy}//0)), $Math->tan($Math->deg2rad($dims->{xz}//0)), 0 ],
		[$Math->tan($Math->deg2rad($dims->{yx}//0)), 1, $Math->tan($Math->deg2rad($dims->{yz}//0)), 0 ],
		[ $Math->tan($Math->deg2rad($dims->{zx}//0)), $Math->tan($Math->deg2rad($dims->{zy}//0)), 1, 0 ],
		[ 0, 0, 0, 1 ]
	];
	   
	$items->{$name}= "//skew\nmultmatrix(".$self->dimsToStr($matrix).")\n".$self->tabThis($items->{$name});
    return $self;
	   
   }



=head4 offset

Offset generates a new 2d interior or exterior outline from an existing outline.
There are two modes of operation: radial and delta.
=cut

  method  offset{
      my ($name,$dims)=@_;
      $items->{$name}="offset(".$self->dimsToStr($dims,"HASH").")\n".$self->tabThis($items->{$name});
      return $self;
	  
  } 

=head4 hull

Displays the convex hull of child nodes.

	my $chart=new OpenSCAD;
	my $pos=[0,0,0]; my @cubes=(); my @hulls=();
	for (0..100){   # a hundred randomly displaced cubes
		$chart->cube("dot$_",3)->translate("dot$_",$pos);
		$pos=[$pos->[0]+((-20..20)[rand()*40]),$pos->[1]+((-20..20)[rand()*40]),$pos->[2]+((-20..20)[rand()*40])];
		push @cubes,"dot$_";
	}   
	for (0..100){  # hulls between sequential pairs 
		$chart->hull("hull$_",$cubes[$_],$cubes[$_-1]);
		push @hulls,"hull$_";
	}   
		 $chart->build(@hulls)->save("hull");


=cut
  
  method  hull{
      my ($name,@names)=@_;
      $self->group($name,@names);
      $items->{$name}="hull()\n".$self->tabThis($items->{$name});
      return $self;
	  
  }   

=head4 minkowski

=cut
  
  method  minkowski{
      my ($name,$dims)=@_;
      $items->{$name}="minkowski(".$self->dimsToStr($dims).")\n".$self->tabThis($items->{$name});
      return $self;
	  
  }   
  
  
=head3 Boolean Operations

=head4  union

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


=head4 difference

Subtracts one or more elements from one element and creates a new element.
e.g.

    $scad->difference("wheel",qw/wheel nut nut1 nut2 nut3/); 

The first parameter`"wheel"` in this example is the name of the new element created,
the second parameter refers to the item that all other elements are subtracted from.
If an element with the name of the first parameter does not exist, it is created,
otherwise it is over-written. So this statement takes the item "wheel"
(the second parameter), subtracts all the nuts, and overwrites the code
in "wheel" (first parameter). 

=cut    
  method difference{
      my ($name,@names)=@_;
      die "Difference requires more than one shape" unless scalar @names>1;
      $self->group($name,@names);
      $items->{$name}="\/\/ $name\ndifference()\n".$items->{$name};
      return $self;
  }  
  
=head4 intersection

Creates an element representing the overlapping parts of 2 or more elements
.e.g.

  $scad->intersection("overlap",qw/item1  item2 item3/);

The first
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

=head3 2D Primitive Shapes

=head4 circle

A 2D drawing primitive that creates a circle that may be extruded to create other 3D structures.
e.g

    $scad->circle("circle",{r=>5});

=cut
  method circle{
      my ($name,$dims)=@_;
      $items->{$name}="\/\/ $name\ncircle(".$self->dimsToStr($dims,"HASH") .");\n";
      return $self;
  }
  
=head4 square

a 2D drawing primitive that creates a rectangle that may be extruded to create other 3D structures.
e.g 

$scad->square("square",[10,10]);

=cut  

  method square{
      my ($name,$dims)=@_;
      $items->{$name}="square(".$self->dimsToStr($dims) .");\n";
      return $self;
  }

=head4 polygon

A 2D drawing primitive that creates a polygon that may be extruded to create other 3D structures .
Example:- 

  my $extrusion=new OpenSCAD;
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

=head4 text

Allows 2D text shapes to be created, that may be extruded and manipulated like other items
e.g. 

    $output->text($label,{text=>$textString,size=>$size,font=>$fontName})

or  

    $output->text($label,"Hello World")
 
to just use defaults.

=cut  

  method text{
      my ($name,$dims)=@_;
      if (ref $dims){
		   $dims->{text}="\"$dims->{text}\"";
		   $dims->{font}="\"$dims->{font}\"";
	   }
	   else{
		   $dims="\"$dims\"";
	   };
      $items->{$name}="text(".$self->dimsToStr($dims) .");\n";
      return $self;
  }


=head3 Extrusion

=head4 rotate_extrude

A method to extrude a 2D shape while rotating invokes similar to liner_extrude

  my $extrusion=new OpenSCAD;
  $extrusion->circle("circle",{r=>5})
            ->translate("circle",[10,0,0])
            ->rotate_extrude("circle",{angle=>180});

=cut 
	 	  
  method rotate_extrude{
      my ($name,$item,$dims)=@_;
      $items->{$name}="\/\/$name\nrotate_extrude(".$self->dimsToStr($dims,"HASH")."){\n  ".$items->{$item}."}\n"  ;
      return $self;
  }  

=head4 liner_extrude

A method to extrude a 2D shape see above for example
=cut

  method linear_extrude{
      my ($name,$item,$dims)=@_;
      $items->{$name}="\/\/$name\nlinear_extrude(".$self->dimsToStr($dims,"HASH")."){\n  ".$items->{$item}."}\n"  ;
      return $self;
  }  


=head4 color

colors an item e.g. . 

    $scad->cylinder("ball",{r=>8})->color("ball","green");

=cut
  	  
  method color{
	  my ($name,$color)=@_;
      $items->{$name}="color(\"$color\")\n".$self->tabThis($items->{$name});
      return $self;
  }

# internal methods

  method tabThis{ # internal tabbing for scripts; name changed from tab to tabThis in v0.06)
	  my $scr=shift;
	  return unless $scr;
	  my $tabs=" "x$tab;
	  chomp $scr;
	  $scr=$tabs.(join "\n$tabs", (split "\n",$scr))."\n";
	  return $scr;
  }
=head4 clone

Creates copies of elements with same features. e.g.

  $car->clone("axle",qw/frontaxle rearaxle/);
  
This just copies the code for the element into new elements, for subsequent transformation 
(otherwise all the elements are positioned in the same place overlying one another)
=cut  

  method clone{
	   my ($name,@cloneNames)=@_;
	   $items->{$_}=$items->{$name} foreach @cloneNames;
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
	   $items->{$name}="{\n".$self->tabThis($merged)."}\n";
	   return $self;
  }
  
  method cleanUp{ # remove items with certain patterns
	   my ($regExp)=@_;
	   foreach my $i (keys %$items){
	     delete $items->{$i} if $i=~$regExp;
	   }
	   return $self;
  }

  
  method list{ # list items with certain patterns
	   print $_,"\n" foreach (keys %$items);
	   return $self;
  }
  
  method item{
	  my $sI=shift;
	  return $items->{$sI} unless(ref $sI);
	  $items->{$sI->name}=$sI;
	  return $self;
  }
    

    
=head4 variable

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
      }
      return $dims;
  }
  
=head3 Build and Save
  
=head4 build

Collects the elements specified (i.e. not all the elements, just the items required for the build)
and all the variables to generate a scad file.  The scad file generated include all the variables defined,
the modules built and the libraries used  
=cut

  method build{
	  foreach(qw/fa fs vp vpt vpd vpf preview/){
		  $script.="\$$_=".$self->$_.";\n" if $self->$_;
	  }
	  #$script="\$fa=$fa;\n\$fs=$fs;\n";
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
	  foreach (@_){
		  if ($items->{$_}){# add items if they exist
			  if (ref $items->{$_}){
				 $script.=$items->{$_}->script();			  
			  }
			  else{
				  $script.=$items->{$_}  ;
			  }
		  } 
		  else {
			  warn "$_ does not exist to build"
		  }
	  }
	  return $self;
  }
=head4 save

saves the .scad file, and also uses openscad to generate images or 3D objects
from the script, or open it in openSCAD directly after building the shape;

    $scad->build("ext")->save("extrusion");

builds a scad file with the item "ext",
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
	  close $fh;
	  if ($format  && ($format=~/^(stl|png|t|off|wrl|amf|3mf|csg|dxf|svg|pdf|png|echo|ast|term|nef3|nefdbg)$/)){
        (my $newFile=$fileName)=~s/scad$/$format/;
        system ("openscad", $fileName, "-o$newFile");
	  }
	  else{
		  $status=system ("openscad", $fileName) unless $status;
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

=head3 scadItem

This is class for future use to allow an item in OpenSCAD to know its
dimensions vertexes, faces and orientations.  For now it works with
polyhedrons to allow distortions.  It is possible that many OpenSCAD
primitivs will be convertable to scadItem polyhedra to allow such
manipulations.  It is inserted as C<< $scad->items->{"item_name"} >>, and
during the  C<< $scad->build("item_name") >> the script is gnerated by 
the C<script> method below.

=cut



class scadItem{
   field $name            :reader :param;               # the name to allow indexing of the item
   field $description     :reader :writer :param  //="";# optional description
   field $function        :reader :param ;              # function to generate the scad item
   field $args            :reader :param ;
   
   field $nDim            :reader         //="3";            # number of dimensions
   field $insPoint        :reader :writer :param //=[0,0];   # translation from original
   field $axis            :reader :writer :param //=[0,0,0]; # rotation from original
   
   our $VERSION='0.16';

      
   method script{
	   my $buildParams="";
	   foreach (keys %$args){
		   $buildParams.="$_=".$Math->serialise($args->{$_}).",\n"
	   }
	   substr($buildParams,-2)="";
	   return "\/\/$name\n$function($buildParams);\n"
   }
   
=head4 C<scadItem::point()>

gets or sets the point at a certain index position in  C<< <scadItem>->args->{points} >>
e.g.  C<< <scadItem>->point($index) >> or  C<< <scadItem>->point($index,$newPoint) >>

=cut   
   
   
   method point{
	   die "No points in Item:$name\n"  && return  unless $args->{points};
	   my ($index,$newPoint) =@_;
	   if ($newPoint){
		   $args->{points}->[$index]=$newPoint;
		   return;
	   }
	   return $args->{points}->[$index]
   }
   
=head4 C<scadItem::scale>

scales the coordinates of a point or set of points (passed as index poitions)

=cut   
      
   method scale{
	   die "No points in Item:$name\n"  && return  unless $args->{points};
	   my ($index,$dent) =@_;
	   $index=[$index] unless (ref $index eq "ARRAY");
	   foreach my $ind (@$index){
		   next unless  $args->{points}->[$ind];
	     for (0..2){
		   $args->{points}->[$ind]->[$_]*=$dent->[$_]
	     }
	   }
	   return $self;
   }
   
=head4 C<scadItem::shear>

translates the coordinates of a point or set of points (passed as index poitions)

=cut   
       
   method shear{
	   die "No points in Item:$name\n"  && return  unless $args->{points};
	   my ($index,$dent) =@_;
	   $index=[$index] unless (ref $index eq "ARRAY");
	   foreach my $ind (@$index){
	     for (0..2){
		   $args->{points}->[$ind]->[$_]+=$dent->[$_]
	     }
	   }
	   return $self;
   } 
   
=head4 C<scadItem::adjacent()>

retrieves a list of indices of a points with edges connecting a point 

=cut
   
   method adjacent{
	   my $index=shift;
	   my $facets=[];my $inds=[];my $count=0;
	   foreach my $face (@{$args->{faces}}){
		   foreach my $ptI(@$face){
			   if ($index==$ptI){
				   push @$facets,$face;
				   push @$inds,$count;
				   next;
			   }
		   }
		   $count++;
	   }
	   
	   return {facets=>$facets,indices=>$inds};
   }
   
=head4 C<scadItem::remove>

removes a point or a set of points from the faces (but not from the
points list), and regenerates a new face to restore the object 

=cut
      
   method remove{
	   my ($pt,$ret)=@_;
	   $ret//={newFace=>[],index=>0};
	   if (ref $pt eq "ARRAY"){
		   $self->remove($_,$ret) foreach @$pt;
	   }
	   my $adj=$self->adjacent($pt);
	   my ($facets,$indices)=($adj->{facets},$adj->{indices});
	   return $ret unless (@$facets);
	   foreach (@$facets){
		   push @$_, shift @$_ while ($_->[0] !=$pt);
		   shift  @$_;
	   }
	   my @newFace=();
	   while (1){
			push @newFace,@{$facets->[0]};
			shift @$facets;
			last unless @$facets;
			while ($facets->[0]->[0] !=$newFace[-1]){
				push @$facets, shift @$facets;
			}
			pop @newFace;
		}
		pop @newFace;
		foreach (reverse sort { $a <=> $b } @$indices){
			splice (@{$self->args->{faces}},$_,1);
		}
		splice (@{$self->args->{faces}},$indices->[0], 0, [@newFace]);
		$ret->{newFace}=[@newFace];
		$ret->{index}=$indices->[0];
		return $ret;
   }    
   
}

=head2 SUPPORT

=head2 COPYRIGHT AND DISCLAIMERS

Copyright (c) 2025 Saif Ahmed.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.


=head2 AUTHOR

SAIFTYNET

=head2 CONTRIBUTORS

jmlynesjr
=cut
