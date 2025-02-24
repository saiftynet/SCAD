use strict;
use warnings;
use Object::Pad;

our $VERSION=0.02;

class SCAD{
   field $script :reader :param  //="";
   field $items  :reader :writer //={};
   field $fa     :writer :param //=1;
   field $fs     :writer :param //=0.4;
   field $tab    :writer :param //=2;
   field $vars   = {};
   field $externalFiles=[];
   field $modules={};
   
   method cube{
      my ($name,$dims,$center)=@_;
      $items->{$name}="\/\/ $name\ncube(".$self->dimsToStr($dims,"") .($center?",center=true);\n":");\n");
      return $self;
   }
   
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
        if (ref $dims eq "ARRAY" and scalar @$dims==3){
          return "[".(join ",",map{ref $_ eq "ARRAY"?"[".join(",",@$_)."]":$_ }@$dims)."]";
        }
        elsif ($expected && $expected eq "ARRAY"){
			die "Incorrect parameter...should be arrayref of 3 numbers";
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
  
  method cylinder{
      my ($name,$dims,$center)=@_;
      $items->{$name}="cylinder(".$self->dimsToStr($dims,"HASH") .($center?",center=true);":");\n");
      return $self;
  }
  method sphere{
      my ($name,$dims)=@_;
      $items->{$name}="sphere(".$self->dimsToStr($dims) .");\n";
      return $self;
  }
  method polyhedron{
      my ($name,$points,$faces,$convexity)=@_;
      $items->{$name}="polyhedron($points, $faces, $convexity);\n";
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
  
  method translate{
      my ($name,$dims)=@_;
      $items->{$name}="translate(".$self->dimsToStr($dims,"ARRAY").")\n".$self->tab($items->{$name});
      return $self;
	  
  }
  
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
  
  method union{
      my ($name,@names)=@_;
      die "Union requires more than one shape" unless scalar @names>1;
      $self->group($name,@names);
      $items->{$name}="union()\n".$items->{$name};
      return $self;
  }
    
  method difference{
      my ($name,@names)=@_;
      die "Difference requires more than one shape" unless scalar @names>1;
      $self->group($name,@names);
      $items->{$name}="difference()\n".$items->{$name};
      return $self;
  }  
  
  method intersection{
      my ($name,@names)=@_;
      die "Intersection requires more than one shape" unless scalar @names>1;
      $self->group($name,@names);
      $items->{$name}="intersection()".$items->{$name}  ;
      return $self;
  }  
  
  method circle{
      my ($name,$dims)=@_;
      $items->{$name}="circle(".$self->dimsToStr($dims,"HASH") .");\n";
      return $self;
  }
  method polygon{
      my ($name,$dims)=@_;
      $items->{$name}="polygon(".$self->dimsToStr($dims) .");\n";
      return $self;
  }
	 	  
  method rotate_extrude{
      my ($name,$dims)=@_;
      $items->{$name}="rotate_extrude(".$self->dimsToStr($dims,"HASH")."){\n  ".$items->{$name}."}\n"  ;
      return $self;
  }  
  
  method linear_extrude{
      my ($name,$dims)=@_;
      $items->{$name}="linear_extrude(".$self->dimsToStr($dims,"HASH")."){\n  ".$items->{$name}."}\n"  ;
      return $self;
  }  
  	  
  method color{
	  my ($name,$color)=@_;
      $items->{$name}="color(\"$color\")\n".$self->tab($items->{$name});
      return $self;
  }

  method useFile{
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

  method tab{ # internal tabbing for scripts;
	  my $scr=shift;
	  return unless $scr;
	  my $tabs=" "x$tab;
	  chomp $scr;
	  $scr=$tabs.(join "\n$tabs", (split "\n",$scr))."\n";
	  return $scr;
  }
  
  method clone{
	   my ($name,@cloneNames)=@_;
	   $items->{$_}=$items->{$name} foreach @cloneNames;
	   return $self;
  }
  
  method build{
	#  $script="\$fa=$fa;\n\$fs=$fs;\n";
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
  
  method save{  #
	  my ($fileName,$format)=@_;
	  $fileName=$fileName.".scad" unless ($fileName=~/\.scad$/);
	  die "No script to save" unless $script;
	  (my $newFile=$fileName)=~s/scad$/stl/;
	  open my $fh,">",$fileName or die "Cannot save $fileName";
	  print $fh $script;
	  if ($format  && ($format=~/^(stl|png|t|off|wrl|amf|3mf|csg|dxf|svg|pdf|png|echo|ast|term|nef3|nefdbg)$/)){
        (my $newFile=$fileName)=~s/scad$/$format/;
        system ("openscad", $fileName, "-o $newFile");
	  }
	  else{
		  system ("openscad", $fileName)
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
}

__END__
sphere(radius | d=diameter)
cube(size, center)
cube([width,depth,height], center)
cylinder(h,r|d,center)
cylinder(h,r1|d1,r2|d2,center)
polyhedron(points, faces, convexity)
import("….ext", convexity)
linear_extrude(height,center,convexity,twist,slices)
rotate_extrude(angle,convexity)
surface(file = "….ext",center,convexity)
