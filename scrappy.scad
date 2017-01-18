// Scrappy Core-XY based 3D printer
//
// Copyright (c) 2017 Jason S. McMullan
//
// Design constraints:
//  - Use junk I have laying around left over from other projects
//  - CoreXY style motion control, but:
//    - without belt crossing
//    - both motors are in the same location
//    - Sleds should have no rotational torque from belt tension
//    - Alpha and Beta belts are planar separated ("top" and "bottom")
//    - Greased plastic linear bearings
//    - Clips onto frame, and mount-to-frame fasterners carry minimal load
//    - Majority of belt tension load is carried by the linear rods

// Show hardware?
hardware=true;
fn=30;

rod_x = [ 400, 8 ];
rod_y = [ 400, 8 ];

// Depth of the pocket for rods
rod_pocket = 11;


belt_width = 6;
belt_thickness = 2;
tolerance_belt = 0.25;

m4_nut_flat=7;
m4_nut_height=3.5;

m8_nut_flat = 13;
m8_nut_height = 7;

nut_tolerance=0.2;
nut_wall = 1;

mdf_width = 16;
mdf_length = 405;
mdf_tolerance = 0.2;

// Wall size (structural)
wall = 3;
// Wall size (rod mounting)
rod_wall = 2;
// Grease pocket size
grease_wall = 0.25;

// Hotend fan width
hotend_fan_diameter = 30;
hotend_fan_depth = 10.5;

hotend_latch_diameter = 16;
hotend_latch_height = 6.5;
hotend_bulk_diameter = 22;
hotend_height = 33;

// Distance from post to M3 hole
nema_mount_radius = 22;
nema_mount_width = 44;
nema_mount_height = 44;
nema_motor_shaft = 5;

// Exposed pulley height
pulley_height = 14;
pulley_diameter = 16;
pulley_belt_gap = 10;

// Bearing diameter and height
bearing_diameter = 13;
bearing_width = 5;
bearing_bore = 4;
bearing_wall = 0.5;

// Distance between the X rods
x_rod_gap = max(bearing_diameter*2 + wall*2, hotend_fan_diameter + rod_y[1] + rod_wall*2);

// Gap from MDF to the bottom of the block
z_block_gap = 1.5;

// Calculated
bearing_cap_height = bearing_wall + nut_wall*2;

y_block_size = rod_y[1] * 2 + rod_wall*2 + x_rod_gap;
z_block_size = max(rod_y[1], rod_x[1]) + rod_wall*2;
z_block_offset = z_block_gap;
y_belt_gap = pulley_belt_gap;

pulley_gap = x_rod_gap + bearing_diameter;
block_size = [y_belt_gap+bearing_diameter+rod_wall*2, max(y_block_size, pulley_gap + bearing_diameter + wall*2), z_block_size];

module drill(d=3, h=1, tolerance=0.2)
{
    translate([0, 0, -0.1]) cylinder(d=d + tolerance*2, h=h+0.2, $fn =fn);
}

module flanged()
{
	difference()
	{
		union()
		{
			cylinder(d=15, h=1, $fn=fn);
		   cylinder(d=13, h=5, $fn=fn);
		}
	   drill(d=4, h = 5);
	}
}

bearing_holder_diameter = bearing_diameter+wall;

module scrappy_bearing_cap(bottom=false, nut=true)
{
    difference()
    {
        union()
        {
            cylinder(d=6, h=bearing_cap_height, $fn=fn);
            translate([0, 0, bearing_wall])
                cylinder(d2=bearing_holder_diameter, d1=bearing_diameter, h = bearing_cap_height - bearing_wall, $fn=fn);
        }
        drill(h=bearing_cap_height, d=bearing_bore);
        if (nut) {
            translate([0, 0, bearing_wall + nut_wall])
                cylinder(r=m4_nut_flat/sqrt(3)+nut_tolerance, h=bearing_cap_height-(bearing_wall + nut_wall)+0.01, $fn = 6);

        }
    }
    if (nut && hardware) color([0.7, 0.5, 0.7])
    {
        translate([0, 0, bearing_wall + nut_wall])
            cylinder(r=m4_nut_flat/sqrt(3), h=m4_nut_height, $fn = 6);
    }
}

module bearing()
{
	color([0.7, 0.7, 0.7]) difference()
	{
        cylinder(d=bearing_diameter, h=bearing_width, $fn=fn);
		drill(d=bearing_bore, h=bearing_width);
	}
    
    translate([0, 0, bearing_width]) scrappy_bearing_cap();
}

module bearing_holder(h=4, cut=false)
{
    if (!cut)
    {
        cylinder(d=6, h=h, $fn=fn);
        translate([0, 0, h + bearing_cap_height])
            rotate([180, 0, 0]) scrappy_bearing_cap(nut=false);
        if (hardware)
        {
            translate([0, 0, h + bearing_cap_height ])
                bearing();
        }
    }
    else
    {
        drill(h=h + (belt_width - bearing_width)/2, d=4);
        translate([0, 0, -0.1])
            cylinder(h=m4_nut_height, r=m4_nut_flat/sqrt(3) + nut_tolerance, $fn=6);
    }
}

module pulley()
{
    height = 12;
    diameter = 16;
    bore = 5;
    
    color([0.7, 0.7, 0.0]) difference()
    {
        union()
        {
            cylinder(h = height - 1 - belt_width - tolerance_belt*2, d = diameter, $fn = fn);
            cylinder(h = height, d = diameter - 4, $fn = fn);
            translate([0, 0, height - 1 - tolerance_belt])
                cylinder(h = 1, d = diameter, $fn = fn);
        }
        translate([0, 0, -0.1])
            cylinder(h = height + 0.2, d = bore, $fn = fn);
    }
}

module motor_bracket(cut=false)
{
    translate([0, nema_mount_width/2 + wall, -nema_mount_width/2-wall])
    if (!cut) {
        cube([nema_mount_width + wall*2, nema_mount_width + wall*2, nema_mount_height + wall*2], center=true);
    }
    else
    {
        translate([0, wall, -wall-0.1])
            cube([nema_mount_width, nema_mount_width+wall*2+0.1, nema_mount_height+wall*2+0.1], center=true);
        for (i=[0:3])
            rotate([0, 0, 45 + 90*i])
                translate([nema_mount_radius, 0, 0])
                    drill(d=3, h=nema_mount_height/2+wall);
        drill(d = pulley_diameter + 2, h =nema_mount_height/2+pulley_height+2);
    }
}

belt_span = 8;

module y_mount()
{
    r = (nema_mount_width - mdf_width+ wall*2)/2;
    h = nema_mount_height + wall*2 - z_block_offset - z_block_size;
    
    translate([0, 0, z_block_gap -h])
    {
        difference()
        {
            
            union() {
                translate([mdf_width/2, 0, 0])
                    cylinder(r = r, h = h);
                translate([-mdf_width/2, 0, 0])
                    cylinder(r = r, h = h);
            }
            translate([-mdf_width/2-mdf_tolerance, -100, -0.1])
                cube([mdf_width+mdf_tolerance*2, 100, h-z_block_gap+mdf_tolerance+0.2]);
            translate([mdf_width/2 + r, -r, -0.1])
                cylinder(r = r, h=h+0.2);
            translate([-mdf_width/2 - r, -r, -0.1])
                cylinder(r = r, h=h+0.2);
            translate([-r-mdf_width/2, 0, -0.1])
                cube([r*2+mdf_width+0.1, r+0.1, h+0.2]);
            for (i=[1:3]) translate([0, -r/2, h/4*i]) {
                translate([-r-mdf_width/2, 0, 0])
                    rotate([0, 90, 0])
                        drill(h=r*2+mdf_width, d=4);
                translate([-mdf_width/2-nut_wall, 0, 0])
                    rotate([0, -90, 0])
                        cylinder(r=m4_nut_flat/sqrt(3)+nut_tolerance, h=r, $fn=6);
                translate([mdf_width/2+nut_wall, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(r=m4_nut_flat/sqrt(3)+nut_tolerance, h=r, $fn=6);
            }
                        
        }
    }
}
    
module scrappy_y_motor()
{
    rod_offset = (mdf_length - rod_y[0])/2;
    
    difference()
    {
        union() {
            // Rod holder
            translate([-rod_y[1]/2-rod_wall, -rod_pocket - rod_offset, -z_block_offset - z_block_size/2 - 0.01])
                cube([rod_y[1] + rod_wall*2, rod_pocket + rod_offset + 0.1, z_block_offset + z_block_size]);
            translate([0, 0, z_block_size/2 + z_block_offset])
                motor_bracket(cut=false);
            translate([0, 0, -z_block_size/2 - z_block_offset])
                y_mount();
        }
        translate([0, 0, z_block_size/2 + z_block_offset])
            motor_bracket(cut=true);
        translate([0, -rod_pocket-rod_offset, 0]) rotate([-90, 0, 0]) drill(h=rod_pocket, d=rod_y[1]);
        tilt=45;
        translate([-nema_mount_width/2-wall-0.1, sin(tilt)*200, -(nema_mount_width+wall*2-z_block_size/2-z_block_offset)-cos(tilt)*200]) rotate([tilt, 0, 0]) cube([nema_mount_width+wall*2+0.2, 200, 200]);
    }

    if (hardware) color([0.0, 0.5, 0.7]) {
        translate([0, nema_mount_width/2 + wall, z_block_size/2])
        {
            pulley();
        }
    }    
}

module x_cap_of(cut=false)
{
    x_size = [rod_pocket+bearing_diameter+wall*2, y_block_size, z_block_size];
    
    if (!cut)
    {
        cube(x_size, center=true);
    }
    else
    {
        translate([-x_size[0]/2, -x_rod_gap/2, 0])
            rotate([0, 90, 0]) drill(h=rod_pocket, d=rod_y[1]);
        translate([-x_size[0]/2, x_rod_gap/2, 0])
            rotate([0, 90, 0]) drill(h=rod_pocket, d=rod_y[1]);
    }
    
    translate([0, -x_rod_gap/2+bearing_diameter/2, -x_size[2]/2])
        bearing_holder(h=x_size[2], cut=cut);
    
    translate([0, x_rod_gap/2-bearing_diameter/2, -x_size[2]/2])
        bearing_holder(h=x_size[2], cut=cut);
}

module scrappy_x_cap()
{
    difference()
    {
        x_cap_of(cut=false);
        x_cap_of(cut=true);
    }
}

module sled_rod_cut(size=[1,2,3])
{
    translate([-size[0]/2, -x_rod_gap/2, 0]) rotate([0, 90, 0]) drill(d=rod_y[1], h=size[0]);
    translate([-size[0]/2+wall, -x_rod_gap/2, 0]) rotate([0, 90, 0]) drill(d=rod_y[1]+grease_wall*2, h=size[0]-wall*2);
    translate([-size[0]/2+wall, -x_rod_gap/2-rod_y[1]/sqrt(3)/2, -rod_y[1]/2-wall-0.1])
            cube([size[0]-wall*2, rod_y[1]/sqrt(3), rod_y[1]/2 + wall + 0.1]);
}

sled_size = [y_block_size, x_rod_gap, hotend_latch_height];

module gt2_belt_arc(h=1, r=10)
{
    belt_thickness = 1;
    translate([r, -r+belt_thickness, 0])
    difference()
    {
        cylinder(r = r, h = h);
        translate([0, 0, -0.1])
            cylinder(r = (r - belt_thickness), h = h+0.2);
    }
}

module scrappy_sled()
{
    s_size = sled_size;
    
    difference()
    {
        union()
        {
            cube(s_size, center=true);
            translate([-s_size[0]/2, -x_rod_gap/2, 0]) rotate([0, 90, 0]) rotate([0, 0, 30])
                cylinder(r=(rod_y[1] + wall)/sqrt(3), h = s_size[0], $fn = 6);
            translate([-s_size[0]/2, x_rod_gap/2, 0]) rotate([0, 90, 0]) rotate([0, 0, 30])
                cylinder(r=(rod_y[1] + wall)/sqrt(3), h = s_size[0], $fn = 6);
            
            // Belt loop bearing
            translate([-s_size[0]/2+bearing_holder_diameter/2, 0, 0]) {
                cylinder(d=bearing_holder_diameter, h=z_block_size/2, $fn=fn);
                bearing_holder(h=z_block_size/2);
            }
            
            // Belt holders
            translate([s_size[0]/2-bearing_holder_diameter/2, x_rod_gap/2-bearing_diameter])
                cylinder(d=bearing_diameter, h=z_block_size/2 + bearing_cap_height + belt_width, $fn=fn);
            
            translate([s_size[0]/2-bearing_holder_diameter/2, -(x_rod_gap/2-bearing_diameter)])
                cylinder(d=bearing_diameter, h=z_block_size/2 + bearing_cap_height + belt_width, $fn=fn);
        }
        sled_rod_cut(size=s_size); rotate([0, 0, 180]) sled_rod_cut(size=s_size);
        translate([0, 0, -s_size[2]/2]) {
            drill(h=s_size[2], d=hotend_latch_diameter);
        }
        translate([s_size[0]/2-bearing_holder_diameter/2, x_rod_gap/2-bearing_diameter, z_block_size/2 + bearing_cap_height])
            gt2_belt_arc(h=belt_width+0.1, r=belt_width);
        translate([s_size[0]/2-bearing_holder_diameter/2, -(x_rod_gap/2-bearing_diameter), z_block_size/2 + bearing_cap_height])
            mirror([0, 1, 0]) gt2_belt_arc(h=belt_width+0.1, r=belt_width);
    }
}

// X and Y axis interface block
module scrappy_block()
{
    b_size = block_size;
    
    difference()
    {
        union()
        {
            cube(b_size, center=true);
            translate([-y_belt_gap/2, -b_size[1]/2, -b_size[2]/2]) 
                cube([y_belt_gap + bearing_diameter + rod_pocket, b_size[1], b_size[2]]);
            // Pulleys
            translate([y_belt_gap/2+bearing_diameter/2, 0, 0])
            {
                translate([0, -pulley_gap/2, -b_size[2]/2])  bearing_holder(h=b_size[2], cut=false);
                translate([0, pulley_gap/2, -b_size[2]/2])  bearing_holder(h=b_size[2], cut=false);
            }
            
            translate([-y_belt_gap/2, 0, 0])
            {
                translate([0, -bearing_diameter, -b_size[2]/2])  bearing_holder(h=b_size[2], cut=false);
                translate([0, bearing_diameter, -b_size[2]/2])  bearing_holder(h=b_size[2], cut=false);
            }
        }
        // Bearing surfaces
        translate([0, b_size[1]/2]) rotate([90, 0, 0]) drill(d=rod_y[1], h=b_size[1]);
        translate([0, b_size[1]/2-wall]) rotate([90, 0, 0]) drill(d=rod_y[1]+grease_wall*2, h=b_size[1]-wall*2);
        translate([-rod_y[1]/2, 0, 0])
            cube([rod_y[1]+rod_wall+0.1, b_size[1]-wall*2, rod_y[1]+grease_wall*2], center=true);
        // Y rod pockets
        translate([y_belt_gap/2+bearing_diameter, 0, 0])
        {
            translate([0, -x_rod_gap/2, 0]) rotate([0, 90, 0]) drill(d=rod_x[1], h=rod_pocket);
            translate([0, x_rod_gap/2, 0]) rotate([0, 90, 0]) drill(d=rod_x[1], h=rod_pocket);
        }
        // Pulleys
        translate([y_belt_gap/2+bearing_diameter/2, 0, 0])
        {
            translate([0, -pulley_gap/2, -b_size[2]/2])  bearing_holder(h=b_size[2], cut=true);
            translate([0, pulley_gap/2, -b_size[2]/2])  bearing_holder(h=b_size[2], cut=true);
        }
    }
}


module scrappy()
{
    translate([0, mdf_length/2, 0]) scrappy_y_motor();
    translate([0, 0, 0]) scrappy_block();
    translate([0, -mdf_length/2, 0]) rotate([0, 0, 180]) scrappy_y_motor();
    translate([rod_x[0]/2, 0, 0]) scrappy_sled();
    translate([rod_x[0], 0, 0]) scrappy_x_cap();
    
    // Additional Mechanicals
    if (hardware) color([0, 0.8, 0]) {
        translate([0, x_rod_gap/2, 0]) rotate([0, 90, 0]) cylinder(h = rod_x[0], d = rod_x[1], $fn=fn);
        translate([0, -x_rod_gap/2, 0]) rotate([0, 90, 0]) cylinder(h = rod_x[0], d = rod_x[1], $fn=fn);
        
        translate([0, rod_y[0]/2, 0]) rotate([90, 0, 0]) cylinder(h = rod_y[0], d = rod_y[1], $fn=fn);
    }

    # translate([-mdf_width/2, -mdf_length/2, -100-z_block_offset-z_block_size/2])
        cube([mdf_width, mdf_length, 100]);
 }

scrappy();

echo("Maximum printable X,Y:",rod_x[0]-rod_pocket*2-sled_size[1],rod_y[0]-rod_pocket*2-block_size[1]);

