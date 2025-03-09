# The Extensions

The OpenSCAD has an extension set of modules that allow a 
diverse set of structures to be created and extended.  This
will be eventually included (once I figure out how to). The current 
also experimental method is using Perl Modules.  Again, I have to
figure our how best to do this.  Like [CAD::OpenSCAD](https://github.com/saiftynet/SCAD/)
these examples us Object::Pad, but again, not using its full features.

### The template

The location of our Module that will come with OpenSCAD.pm is in a folder called 
OpenSCAD, the CAD Domain. e.g. An example is Gears.pm.

```
└── lib
    └── CAD
        ├── OpenSCAD
        │   ├── Gears.pm
        │   └── Math.pm
        └── OpenSCAD.pm
```

The typical internal structure may be (see [Gears.pm]())

```
use strict; use warnings;
use lib "../../../lib";
use Object::Pad;
use CAD::OpenSCAD::Math;
	
our $Math=new Math;
		
class GearMaker{
	 field $scad :param;	
	 ...
   method profile{
      ....
   }

}
```

1) The module doesn't use CAD::OenSCAD directly, instead...
2) It takes a `SCAD` object as a parameter
   * this brings with it the CAD::OpenSCAD methods
   * these methods use the `$items` field of that `SCAD` object as a workspace
   * to prevent overwriting of existing items, the modules items have a specific prefix
   * items with these prefixes are "cleanedUp" after methods finish if needed
   * when methods are used to create items, typically a name is passed, that becomes the name of the item created
3) The API is subject to change
