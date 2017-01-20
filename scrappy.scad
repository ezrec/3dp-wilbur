// Scrappy Core-XY based 3D printer
//
// Copyright (c) 2017 Jason S. McMullan
//
// Design constraints:
//  - Use junk I have laying around left over from other projects
//  - H-Bot style motion control, but:
//    - Sleds should have no rotational torque from belt tension
//    - Greased plastic linear bearings
//    - Clips onto frame, and mount-to-frame fasterners carry minimal load
//    - Majority of belt tension load is carried by the linear rods

// Show hardware?
hardware=true;
fn=30;

rod_x = [ 400, 8 ];
rod_y = [ 400, 8 ];
rod_slide = [400, 6.2];

// Depth of the pocket for rods
rod_pocket = 10;

// Length of the X axis between the MDF boards
x_length = 280;

belt_width = 6;
belt_thickness = 2;
tolerance_belt = 0.25;

m4_nut_flat=7;
m4_nut_height=3.5;

m8_nut_flat = 13;
m8_nut_height = 7;

nut_tolerance=0.2;
nut_wall = 1.5;

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

bearing_holder_diameter = bearing_diameter+wall;

// Distance between the X rods
x_rod_gap = max(bearing_diameter*2 + wall*2, hotend_fan_diameter + rod_y[1] + rod_wall*2);

// Calculated
bearing_cap_height = bearing_wall + nut_wall*2;

y_block_size = rod_y[1] * 2 + rod_wall*2 + x_rod_gap;
z_block_size = max(rod_y[1], rod_x[1]) + rod_wall*2;
z_block_offset = z_block_size/2 - rod_y[1]/2 - rod_wall*2 + rod_slide[1];
y_belt_gap = (bearing_holder_diameter + rod_y[1]/2 + grease_wall)*2;

pulley_gap = x_rod_gap + bearing_diameter;

mdf_x_offset = y_belt_gap/2 + bearing_diameter/2 + rod_pocket;

module drill(d=3, h=1, tolerance=0.2)
{
    translate([0, 0, -0.1]) cylinder(d=d + tolerance*2, h=h+0.2, $fn =fn);
}

switch_size = [10, 4.3, 3.75];

module switch()
{
    translate([0, switch_size[1]/2, switch_size[2]/2])
    difference()
    {
        union()
        {
            cube(switch_size, center=true);
            translate([0, switch_size[1]/2, 0]) rotate([0, 0, 45]) cube([5, 5, 0.5], center=true);
        }
        translate([-switch_size[0]/2+1.75, 0, -switch_size[2]/2-0.1])
            cylinder(d=2, h=switch_size[2]+0.2, $fn=fn);
    }
}

module switch_cut()
{
    translate([0, switch_size[1]/2, switch_size[2]/2])
    {
        cube(switch_size, center=true);
        translate([0, switch_size[1]/2, 0]) rotate([0, 0, 45]) cube([5, 5, 0.5], center=true);
        
        translate([-switch_size[0]/2+1.75, 0, -switch_size[2]/2-100-0.1])
            cylinder(d=2, h=switch_size[2]+200+0.2, $fn=fn);
    }
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

module scrappy_bearing_cap(bottom=false, nut=true)
{
    difference()
    {
        union()
        {
            cylinder(d=6, h=bearing_cap_height, $fn=fn);
            translate([0, 0, bearing_wall])
                cylinder(d2=bearing_holder_diameter, d1=bearing_diameter, h = bearing_cap_height - bearing_wall + 0.01, $fn=fn);
        }
        drill(h=bearing_cap_height, d=bearing_bore);
        if (nut) {
            translate([0, 0, bearing_wall + nut_wall])
                cylinder(r=m4_nut_flat/sqrt(3)+nut_tolerance, h=bearing_cap_height-(bearing_wall + nut_wall/2)+0.01, $fn = 6);

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

module bearing_holder_of(h=4, cut=false)
{
    if (!cut)
    {
        cylinder(d=bearing_holder_diameter, h=h, $fn=fn);
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
        translate([0, 0, -100.1])
            cylinder(h=m4_nut_height + 100, r=m4_nut_flat/sqrt(3) + nut_tolerance, $fn=6);
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

module rod_pocket_of(d=8, h=20, cut=false)
{
    cd = d + rod_wall*2;
    
    if (!cut) {
        cylinder(h=h, d=cd, $fn=fn);
        translate([-cd/2,-cd/2, 0]) 
            cube([cd, cd/2, h]);
    }
    else
    {
        // Slit for expansion
        translate([-cd/16,-cd/2, -0.1]) 
            cube([cd/8, cd/2, rod_pocket+0.1]);
        drill(h=rod_pocket, d=d);
        // Rod end
        translate([0, 0, rod_pocket])
            sphere(r=d/2, $fn=fn);
    }
}

module carriage_bearing_of(h=40, d=8, cut=false)
{
    cd = d + rod_wall*2;
    
    if (!cut)
    {
        rod_pocket_of(d=d, h=h, cut=false);
    }
    else
    {
        translate([0, 0, -0.1])
            cylinder(d=d, h=h+0.2, $fn=fn);
        translate([0, 0, rod_wall])
            cylinder(d=d+2*grease_wall, h = h-rod_wall*2, $fn=fn);
        translate([-d/2-grease_wall, -cd/2-0.1, rod_wall])
            cube([d+grease_wall*2, cd/2, h-rod_wall*2]);
    }
}

module carriage_bearing(h=40, d=8)
{
    difference()
    {
        carriage_bearing_of(d=d, h=h, cut=false);
        carriage_bearing_of(d=d, h=h, cut=true);
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

y_mount_height = nema_mount_height + wall*2 - z_block_offset - z_block_size;

module y_mount_of(cut=false)
{
    r = (nema_mount_width - mdf_width+ wall*2)/2;
    h = y_mount_height;
    
    translate([0, 0, -h])
    {
        if (!cut)
        {
            translate([-mdf_width/2-wall, -r, 0])
                cube([mdf_width+wall*2, r+wall, h + wall]);
        }
        else
        {
            translate([-mdf_width/2-mdf_tolerance, -100, -0.1])
                cube([mdf_width+mdf_tolerance*2, 100, h+0.2]);
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
    
module y_motor_of(cut=false)
{
    rod_offset = (mdf_length - rod_y[0])/2;
    mount_offset = -y_belt_gap/2+pulley_belt_gap/2;
    
    if (!cut)
    {
        linear_extrude(height = z_block_size/2) hull() {
            translate([mount_offset+nema_mount_width/2+wall-0.1, 0])
                square([0.1, nema_mount_width + wall*2]);
            translate([y_belt_gap/2-bearing_diameter/2, nema_mount_width/2 + wall - (bearing_diameter - pulley_belt_gap)/2])
                circle(d=bearing_holder_diameter);
        }
    }
    else
    {
        // Cuts for the motor bracket
        translate([mount_offset, 0, 0])
        {
            tilt=45;
            translate([0, -wall*2, -wall*5]) translate([-nema_mount_width/2-wall-0.1, sin(tilt)*(200), -(nema_mount_width+wall*2-z_block_size/2-z_block_offset)-cos(tilt)*(200)]) rotate([tilt, 0, 0]) cube([nema_mount_width*3+wall*2+0.2, 200, 200]);
        }
    }

    // Rod holder for primary rod
    translate([0, -rod_pocket+rod_offset, 0]) rotate([-90, 0, 0]) rotate([0, 0, 180])
        rod_pocket_of(d=rod_y[1], h=rod_pocket+rod_offset, cut=cut);
    
   
    // Bracket for the motor
    translate([mount_offset, 0, z_block_size/2])
        motor_bracket(cut=cut);
    
    if (!cut)
    {
       // Attach bracket to mount
       translate([mount_offset - nema_mount_width/2 - wall , 0, -z_block_size/2 - z_block_offset - y_mount_height])
        {
            cube([nema_mount_width/2 + wall - mount_offset + mdf_width/2 + wall + mdf_x_offset, wall, y_mount_height + wall]);
        
            for (i=[0:2:6]) translate([0, wall, y_mount_height/7*i]) {
                cube([nema_mount_width/2 + wall - mount_offset + mdf_width/2 + wall + mdf_x_offset, nema_mount_width, wall]);
            }
        }
    }

    // Bracket to attach to the MDF
    translate([mdf_x_offset, 0, -z_block_size/2 - z_block_offset])
        y_mount_of(cut=cut);
        
    // Secondary pulley
    translate([y_belt_gap/2-bearing_diameter/2, nema_mount_width/2 + wall - (bearing_diameter - pulley_belt_gap)/2, 0])
        bearing_holder_of(h=z_block_size/2, cut=cut, teeth=true);
    
}

module y_motor()
{
    mount_offset = -y_belt_gap/2+pulley_belt_gap/2;
    
    difference()
    {
        y_motor_of(cut=false);
        y_motor_of(cut=true);
    }

    if (hardware) {

        color([0.0, 0.5, 0.7]) {
            translate([mount_offset, nema_mount_width/2 + wall, z_block_size/2 - wall])
                pulley();
        }

        # translate([-y_belt_gap/2-belt_thickness, -50, z_block_size/2 + bearing_cap_height])
            cube([belt_thickness, 100, belt_width]);
        # translate([y_belt_gap/2, -50, z_block_size/2 + bearing_cap_height])
            cube([belt_thickness, 100, belt_width]);
    }
}

module scrappy_y_motor_max()
{
    y_motor();
}

module scrappy_y_motor_min()
{
    difference()
    {
        mirror([0, 1, 0]) y_motor();
        translate([mdf_x_offset + mdf_width/2 - switch_size[0]/2, rod_pocket - switch_size[1] + 0.5, -z_block_size/2 - z_block_offset + wall - 0.1])
            switch_cut();
    }
    
    if (hardware)
    {
        translate([mdf_x_offset + mdf_width/2 - switch_size[0]/2, rod_pocket - switch_size[1] + 0.5, -z_block_size/2 - z_block_offset + wall - 0.1])
            color([0, 0.8, 0.8]) switch();
     }
 }

module y_rail_cap_of(cut=false)
{
    rod_offset = (mdf_length - rod_y[0])/2;
    
    // Rod holder for secondary rod
    translate([0, -(mdf_length - rod_slide[0])/2-rod_pocket, -z_block_size/2-z_block_offset+rod_slide[1]/2]) rotate([-90, 0, 0]) rotate([0, 0, 180])
        rod_pocket_of(d=rod_slide[1], h=(mdf_length - rod_slide[0])/2+rod_pocket+wall, cut=cut);
    
    // Bracket to attach to the MDF
    translate([0, 0, -z_block_size/2 - z_block_offset])
        y_mount_of(cut=cut);    
}

module scrappy_y_rail_cap()
{
    difference()
    {
        y_rail_cap_of(cut=false);
        y_rail_cap_of(cut=true);
    }
}

module x_cap_of(cut=false)
{
    x_size = rod_pocket+bearing_diameter+wall*2;
    
    if (!cut) {
        translate([0, 0, -z_block_size/2]) linear_extrude(height=z_block_size) hull()
        {
            translate([0, -x_rod_gap/2])
                circle(d=bearing_holder_diameter);
            translate([0, x_rod_gap/2])
                circle(d=bearing_holder_diameter);
        }
    }
        
    translate([-x_size/2, -x_rod_gap/2, 0]) rotate([0, 90, 0]) rotate([0, 0, 90])
        rod_pocket_of(d=rod_y[1], h=rod_pocket+rod_wall, cut=cut);
    
    translate([-x_size/2, x_rod_gap/2, 0]) rotate([0, 90, 0]) rotate([0, 0, 90])
        rod_pocket_of(d=rod_y[1], h=rod_pocket+rod_wall, cut=cut);
    
    translate([0, -x_rod_gap/2+bearing_diameter/2, -z_block_size/2])
        bearing_holder_of(h=z_block_size, cut=cut);
    
    translate([0, x_rod_gap/2-bearing_diameter/2, -z_block_size/2])
        bearing_holder_of(h=z_block_size, cut=cut);
}

module scrappy_x_cap()
{
    difference()
    {
        x_cap_of(cut=false);
        x_cap_of(cut=true);
    }
}


sled_size = [y_block_size, x_rod_gap, hotend_latch_height];

module gt2_belt_arc(h=1, r=10)
{
    belt_thickness = 1;
    belt_pitch = 2.0;
    tooth_radius = 0.8;
    
    translate([r, r-belt_thickness, 0])
    {
        difference()
        {
            cylinder(r = r + belt_thickness, h = h);
            translate([0, 0, -0.1])
                cylinder(r = r, h = h+0.2);
        }
        for (theta = [0:belt_pitch/r:2*PI])
        {
            translate([r*cos(theta*180/PI),r*sin(theta*180/PI),0])
                cylinder(r = tooth_radius, h=h, $fn=fn);
        }
    }
}

module gt2_belt_holder_of(h=10, d=10, cut=false)
{
    if (!cut)
    {
        cylinder(h=h, r=d/2, $fn=fn);
    }
    else
    {
        translate([0, 0, h-belt_width])
            gt2_belt_arc(h=belt_width+0.1, r=d/2);
    }
}

module gt2_belt_holder(h=10, d=10)
{
    difference()
    {
        gt2_belt_holder_of(h=h, d=d, cut=false);
        gt2_belt_holder_of(h=h, d=d, cut=true);
    }
}

module scrappy_sled_of(cut=false)
{
    s_size = sled_size;
    
    if (!cut)
    {
        translate([0, 0, -z_block_size/2+s_size[2]/2])
            cube([s_size[0], s_size[1]-rod_x[1]-grease_wall*2, s_size[2]], center=true);
    }
    else
    {
        // Hotend mounting drills
        translate([0, 0, -z_block_size/2])
            drill(h=s_size[2], d=hotend_latch_diameter);
    }
    
    // Bearing holder
    translate([-s_size[0]/2+bearing_holder_diameter/2, 0, -z_block_size/2])
            bearing_holder_of(h=z_block_size, cut=cut);
               
    // Belt holders
    translate([s_size[0]/2-bearing_holder_diameter/2, x_rod_gap/2-bearing_diameter, -z_block_size/2])
        gt2_belt_holder_of(d=bearing_diameter, h=z_block_size + bearing_cap_height + belt_width, cut=cut);
    
    translate([s_size[0]/2-bearing_holder_diameter/2, -(x_rod_gap/2-bearing_diameter), -z_block_size/2])
        mirror([0,1,0])
            gt2_belt_holder_of(d=bearing_diameter, h=z_block_size + bearing_cap_height + belt_width, cut=cut);
    
    translate([-s_size[0]/2, -x_rod_gap/2, 0]) rotate([0, 90, 0]) rotate([0, 0, 90])
        carriage_bearing_of(h=s_size[0], d=rod_x[1], cut=cut);
    
    translate([-s_size[0]/2, x_rod_gap/2, 0]) rotate([0, 90, 0]) rotate([0, 0, 90])
        carriage_bearing_of(h=s_size[0], d=rod_x[1], cut=cut);
}

module scrappy_sled()
{
    difference()
    {
        scrappy_sled_of(cut=false);
        scrappy_sled_of(cut=true);
    }
}

// X and Y axis interface block
module scrappy_block_of(cut=false)
{       
    // Y rod pockets
    if (!cut)
    {
        translate([0, 0, -z_block_size/2]) linear_extrude(height=z_block_size) hull() {
            translate([y_belt_gap/2+bearing_diameter/2, -pulley_gap/2, 0]) circle(d=bearing_holder_diameter);
            translate([y_belt_gap/2+bearing_diameter/2, pulley_gap/2, 0]) circle(d=bearing_holder_diameter);
            translate([-y_belt_gap/2+bearing_diameter/2, -bearing_diameter, 0]) circle(d=bearing_holder_diameter);
            translate([-y_belt_gap/2+bearing_diameter/2, bearing_diameter, 0]) circle(d=bearing_holder_diameter);
        }
    }
    
    translate([y_belt_gap/2+bearing_diameter, 0, 0])
    {
        translate([0, -x_rod_gap/2, 0]) rotate([0, 90, 0]) rotate([0, 0, 90])
            rod_pocket_of(d=rod_x[1], h=rod_pocket, cut=cut);
        translate([0, x_rod_gap/2, 0]) rotate([0, 90, 0]) rotate([0, 0, 90])
            rod_pocket_of(d=rod_x[1], h=rod_pocket, cut=cut);
    }
    
    translate([0, -x_rod_gap/2 - bearing_holder_diameter/2, 0]) rotate([-90, 0, 0]) rotate([ 0, 0, -180])
        carriage_bearing_of(h=x_rod_gap + bearing_holder_diameter, d=rod_y[1], cut=cut);
    
    // Bearings
    translate([y_belt_gap/2+bearing_diameter/2, 0, -z_block_size/2])
    {
        translate([0, -pulley_gap/2, 0])  bearing_holder_of(h=z_block_size, cut=cut);
        translate([0, pulley_gap/2, 0])  bearing_holder_of(h=z_block_size, cut=cut);
    }
    
    translate([-y_belt_gap/2+bearing_diameter/2, 0, -z_block_size/2])
    {
        translate([0, -bearing_diameter, 0])  bearing_holder_of(h=z_block_size, cut=cut);
        translate([0, bearing_diameter, 0])  bearing_holder_of(h=z_block_size, cut=cut);
    }
}

module scrappy_block()
{
    difference()
    {
        scrappy_block_of(cut=false);
        scrappy_block_of(cut=true);
    }

    if (hardware)
    {
        # translate([-y_belt_gap/2-belt_thickness, -50, z_block_size/2 + bearing_cap_height])
            cube([belt_thickness, 100, belt_width]);
        # translate([y_belt_gap/2, -50, z_block_size/2 + bearing_cap_height])
            cube([belt_thickness, 100, belt_width]);
    }
}

// Total Y travel
y_travel = rod_y[0] - rod_pocket*2 - x_rod_gap - bearing_diameter/2;
x_travel = x_length - sled_size[0];

module scrappy(x_percent=0.0025, y_percent=0.0025)
{    
    translate([0, mdf_length/2, 0]) scrappy_y_motor_max();
    translate([0, -mdf_length/2, 0]) scrappy_y_motor_min();
    translate([0, y_travel * (y_percent - 0.5), 0]) {
        scrappy_block();
        translate([y_belt_gap/2+bearing_diameter, 0, 0])
        {
            translate([rod_pocket + sled_size[0]/2 + x_travel * x_percent, 0, 0]) scrappy_sled();
            translate([rod_x[0], 0, 0]) scrappy_x_cap();
            if (hardware)
            {
                color([0, 0.8, 0]) {
                    translate([0, x_rod_gap/2, 0]) rotate([0, 90, 0]) cylinder(h = rod_x[0], d = rod_x[1], $fn=fn);
                    translate([0, -x_rod_gap/2, 0]) rotate([0, 90, 0]) cylinder(h = rod_x[0], d = rod_x[1], $fn=fn);
                }
            }
        }
    }
    translate([mdf_x_offset + x_length+mdf_width, mdf_length/2, 0]) scrappy_y_rail_cap();
    translate([mdf_x_offset + x_length+mdf_width, -mdf_length/2, 0]) rotate([0, 0, 180]) scrappy_y_rail_cap();

    // Additional Mechanicals
    if (hardware)
    {
        color([0, 0.8, 0]) {
            translate([0, rod_y[0]/2, 0]) rotate([90, 0, 0]) cylinder(h = rod_y[0], d = rod_y[1], $fn=fn);
            translate([mdf_x_offset + x_length+mdf_width, rod_slide[0]/2, -z_block_offset-z_block_size/2+rod_slide[1]/2]) rotate([90, 0, 0]) cylinder(h = rod_slide[0], d = rod_slide[1], $fn=fn);
        }

        translate([mdf_x_offset, 0, 0]) {
        # translate([-mdf_width/2, -mdf_length/2, -100-z_block_offset-z_block_size/2])
            cube([mdf_width, mdf_length, 100]);        
        # translate([mdf_width/2 + x_length, -mdf_length/2, -100-z_block_offset-z_block_size/2])
            cube([mdf_width, mdf_length, 100]);
        }
    }
 }
 
scrappy();

echo("Belt length:", y_belt_gap*2 + (mdf_length+nema_mount_width/2+wall)*2 - (2*bearing_diameter) - x_rod_gap + 2*(rod_y[0]+2*(rod_pocket+rod_wall)) + 2*y_belt_gap + bearing_diameter);
echo("Maximum printable X,Y:",x_travel-sled_size[1],y_travel - (x_rod_gap + bearing_diameter/2));

