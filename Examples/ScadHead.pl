#!/usr/bin/env perl
use strict; use warnings;
use lib "../lib/";
use Object::Pad;
use CAD::OpenSCAD;
use CAD::OpenSCAD::Math;
use CAD::OpenSCAD::Loft;

=pod

=head1 Scad Head

This used a scadItem object, that keeps the parameters of a shape
in a perl object rather than a string.  This means that the parameters
can be changed, modifying the object in Perl before transformation in
the build process into the appropriate script.

=over

=item* It uses the spheroid loft.

=item* It has a routine that identifies a point on the spheroid for
latitude and longitude

=item* Changing this point changes the shape

=item* The coodinate geometry that is used mean that the location on
the surface of the spheroid that is distorted remains the same (sort of).


=cut

my $scad=new OpenSCAD;
my $math=new CAD::OpenSCAD::Math;
my $loft=new CAD::OpenSCAD::Loft(scad=>$scad);

my $divisions=40;
my $radius=30;

# passing undef as a name to some loft methods returns parameters
# instead of inserting an item into the scad object; this scad item
# allows the points to be mannipulated before gnerating a polyhedron

my $args=$loft->spheroid(undef,$divisions,$radius);
$scad->item(new scadItem(name=>"head",function=>"polyhedron",args=>$args));

$scad->item("head")->scale(coordsToPoint($divisions,[0..10],[-5..11]),[1.1,1.1,1]) # flare
                   ->scale(coordsToPoint($divisions,[0..40],[0..5]),[1.1,1.1,1])     # bridge
                   ->scale(coordsToPoint($divisions,[15..30],[11..20,-15..-6]),[.6,0.6,1])     # eyes
                   ->scale(coordsToPoint($divisions,[-6..25],[40..50,-45..-40]),[1.08,1.08,1])     # ears
                   ->scale(coordsToPoint($divisions,[-25],[-15..20]),[.8,.9,1])# mouth
                   ->scale(coordsToPoint($divisions,[-80..-10],[30..90,-90..-25]),[.95,0.95,1])     # jaw
                   ->scale(coordsToPoint($divisions,[-45..-30],[-10..15]),[1.15,1.15,1]); # chin
$scad->build("head")
     ->save("test");;
     
     
sub coordsToPoint{
	my ($divs,$lat,$long)=@_;
	my $points=[];
	$lat=[$lat] unless ref $lat eq "ARRAY";
	$long=[$long] unless ref $long eq "ARRAY";
	foreach my $lt(@$lat){
	  foreach my $lg(@$long){
		my $ind=int( 0.5+$divs*(int (($divs)*(90-$lt)/360 +0.5)+((90-$lg+1)/180))-$divs);
		push @$points,$ind;
	  }	
	}
	$points = [keys %{{ map{$_=>1}@$points}}]; # get unique points better with List_Util
	return $points;
}
