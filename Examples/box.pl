#!/usr/env perl
use lib "../lib";
use CAD::OpenSCAD;

# Create a box that can folded from a flat shape 
# usage: foldableBox($width,$depth,$height,$thickness,$creaseHeight)

foldableBox(50,30,20,2,.5);

sub foldableBox{
	my ($width,$depth,$height,$thickness,$creaseHeight)=@_;
	my $scad=new SCAD;
	
	# create a polygon that represent the ouline of the box folds
	# extrude it to the thickness of the walls
	my $points=[  
		[$height,0],
		[$height+$width,0],
		[$height+$width,$height],
		[2*$height+$width,$height],
		[2*$height+$width,$height+$depth],
		[$height+$width,$height+$depth],
		[$height+$width,2*($height+$depth)],
		[$height,2*($height+$depth)],
		[$height,$height+$depth],
		[0,$height+$depth],
		[0,$height],
		[$height,$height]];
		
	$scad->polygon("outline",$points)
		 ->linear_extrude("box","outline",$thickness);


    # This demonstrates how a shape can be cloned, and the clones used
    # We create a cutter shape, (cube dimensioned to exceed the cut
    # surface rotated by 45 degrees)
    # This is cloned and the clones translated to make the horizontal
    # creases. The same cutter can be rotated and recloned, the new
    # clones translated to make the vertical creases
    
	$scad->cube("cutter",[2*($height+$depth+$width),2*$thickness,2*$thickness],1)
		 ->rotate("cutter",[45,0,0])
		 ->translate("cutter",[($height+$depth+$width)/2,0,sqrt(2)*$thickness+$creaseHeight])
		 ->color("cutter","red")
		 ->clone("cutter",qw/h1 h2 h3 h4 h5/)
		 ->translate("h2",[0,$height,0])
		 ->translate("h3",[0,$height+$depth,0])
		 ->translate("h4",[0,2*$height+$depth,0])
		 ->translate("h5",[0,2*($height+$depth),0])
		 ->rotate("cutter",[0,0,90])
		 ->clone("cutter",qw/v1 v2 v3 v4/)
		 ->translate("v2",[$height,0,0])
		 ->translate("v3",[$height+$width,0,0])
		 ->translate("v4",[2*$height+$width,0,0])
		 ->difference("box","box",qw/h1 h2 h3 h4 h5 v1 v2 v3 v4/)
		 ->color("box","green");
		 $scad->build("box")->save("box");  
     
 }     
        
