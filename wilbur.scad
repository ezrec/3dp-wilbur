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
fn=60;

// Units
in = 25.4;
mm = 1.0;

// colors
color_metal = [0.5, 0.5, 0.5, 0.5];

build_z = 200 * mm;

rod_x = [ 400 * mm, 8 * mm];
rod_y = [ 400 * mm, 8 * mm ];
rod_slide = [400 * mm, 1/4 * in];

nozzle_diameter = 0.8 * mm;

// Depth of the pocket for rods
rod_pocket = 20 * mm;

// Length of the X axis between the MDF boards
x_length = 280 * mm;

// Press-fit tolerance
press_tolerance = -0.05 * mm;

// Slide tolerance
slide_tolerance = 0.1 * mm;

// Tolerance for through-bolt drills
drill_tolerance=0.25 * mm;

belt_width = 6 * mm;
belt_thickness = 2 * mm;
belt_tolerance = 0.25 * mm;

m3_nut_flat = 5.5 * mm;
m3_nut_height = 2.25 * mm;

m4_nut_flat=7 * mm;
m4_nut_height=3.5 * mm;

m5_nut_flat=8 * mm;
m5_nut_height=4 * mm;

m8_nut_flat = 13 * mm;
m8_nut_height = 7 * mm;

nut_wall = 1.5 * mm;

mdf_width = 16.5 * mm;
mdf_length = 405 * mm;
mdf_tolerance = 0.2 * mm;

// Wall size (structural)
wall = 3 * mm;
// Wall size (rod mounting)
rod_wall = 3 * mm;
// Grease pocket size
grease_wall = 1 * mm;

// Hotend fan width
hotend_fan_diameter = 30 * mm;
hotend_fan_depth = 10.5 * mm;

hotend_latch_diameter = 16 * mm;
hotend_latch_height = 6.5 * mm;
hotend_bulk_diameter = 22 * mm;
hotend_height = 33 * mm;

// Distance from post to M3 hole
nema_mount_radius = 22 * mm;
nema_mount_width = 44 * mm;
nema_mount_height = 44 * mm;
nema_motor_shaft = 5 * mm;

// Exposed pulley height
pulley_height = 14 * mm;
pulley_diameter = 16 * mm;
pulley_belt_gap = 10 * mm;

// Bearing diameter and height
bearing_diameter = 13 * mm;
bearing_width = 5 * mm;
bearing_bore = 4 * mm;
bearing_wall = 1 * mm;

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

mdf_x_offset = y_belt_gap/2 + bearing_diameter/2 + rod_pocket - mdf_width;

module drill(d=3, h=1, tolerance=drill_tolerance)
{
    translate([0, 0, -0.1]) cylinder(d=d + tolerance*2, h=h+0.2, $fn =fn);
}

module m3_nut_cut(h=1, tolerance=drill_tolerance)
{
    cylinder(r=m3_nut_flat/sqrt(3)+tolerance, h = h, $fn=6);
}

module m4_nut_cut(h=1, tolerance=drill_tolerance)
{
    cylinder(r=m4_nut_flat/sqrt(3)+tolerance, h = h, $fn=6);
}

module m5_nut_cut(h=1, tolerance=drill_tolerance)
{
    cylinder(r=m5_nut_flat/sqrt(3)+tolerance, h = h, $fn=6);
}

switch_size = [20 * mm, 15 * mm, 6 * mm];

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
        translate([-(7+2.4)/2, 0, -switch_size[2]/2-0.1])
            cylinder(d=2.4, h=switch_size[2]+0.2, $fn=fn);
        translate([+(7+2.4)/2, 0, -switch_size[2]/2-0.1])
            cylinder(d=2.4, h=switch_size[2]+0.2, $fn=fn);
    }
}

module switch_cut()
{
    translate([0, switch_size[1]/2, switch_size[2]/2-0.5])
    {
        cube([switch_size[0]+0.2, switch_size[1]+0.2, switch_size[2]+0.2], center=true);
        translate([0, switch_size[1]/2, 0]) rotate([0, 0, 45]) cube([5, 5, 0.5], center=true);

        translate([-(7+2.4)/2, 0, -switch_size[2]/2-10.1])
            cylinder(d=2.4, h=switch_size[2]+10.2, $fn=fn);
        translate([+(7+2.4)/2, 0, -switch_size[2]/2-10.1])
            cylinder(d=2.4, h=switch_size[2]+10.2, $fn=fn);
    }
}

module flanged()
{
	difference()
	{
		union()
		{
			cylinder(d=15 * mm, h=1, $fn=fn);
		   cylinder(d=13 * mm, h=5 *mm, $fn=fn);
		}
	   drill(d=4 * mm, h = 5 * mm);
	}
}

module wilbur_bearing_cap(bottom=false, nut=true)
{
    difference()
    {
        union()
        {
            cylinder(d=bearing_bore+nozzle_diameter*4, h=bearing_cap_height, $fn=fn);
            translate([0, 0, bearing_wall])
                cylinder(d2=bearing_holder_diameter, d1=bearing_diameter, h = bearing_cap_height - bearing_wall + 0.01, $fn=fn);
        }
        drill(h=bearing_cap_height, d=bearing_bore);
        if (nut) {
            translate([0, 0, bearing_wall + nut_wall])
                cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=bearing_cap_height-(bearing_wall + nut_wall/2)+0.01, $fn = 6);

        }
    }
    if (nut && hardware) color([0.7, 0.5, 0.7])
    {
        translate([0, 0, bearing_wall + nut_wall])
            cylinder(r=m4_nut_flat/sqrt(3), h=m4_nut_height, $fn = 6);
    }
}

module wilbur_bearing_sleeve(bearing_sleeve_wall=1.6, tolerance=drill_tolerance)
{
    difference()
    {
        union()
        {
            cylinder(d=bearing_diameter+bearing_sleeve_wall*2, h=belt_width, $fn=fn*2);
            translate([0, 0, -bearing_sleeve_wall])
                cylinder(d=bearing_diameter+bearing_sleeve_wall*4, h=bearing_sleeve_wall+0.01, $fn=fn*2);
        }
        translate([0, 0, belt_width-bearing_width])
            cylinder(d1=bearing_diameter+tolerance, d2=bearing_diameter+tolerance*3, h=belt_width+0.1, $fn=fn*2);
        translate([0, 0, -bearing_sleeve_wall-0.01])
            cylinder(d=bearing_diameter-bearing_sleeve_wall*2, h=bearing_sleeve_wall+belt_width, $fn=fn*2);
    }
}

module bearing()
{
	color([0.7, 0.7, 0.7]) difference()
	{
        cylinder(d=bearing_diameter, h=bearing_width, $fn=fn);
		drill(d=bearing_bore, h=bearing_width);
	}

    translate([0, 0, bearing_width]) wilbur_bearing_cap();
}

module bearing_holder_of(h=4, cut=false)
{
    if (!cut)
    {
        cylinder(d=bearing_holder_diameter, h=h, $fn=fn);
        translate([0, 0, h + bearing_cap_height])
            rotate([180, 0, 0]) wilbur_bearing_cap(nut=false);
    }
    else
    {
        drill(h=h + belt_width, d=bearing_bore);
        translate([0, 0, -100.1])
            cylinder(h=m4_nut_height + 100, r=m4_nut_flat/sqrt(3) + drill_tolerance, $fn=6);
    }
    
    if (hardware)
    {
        translate([0, 0, h + bearing_cap_height ])
            bearing();
    }
}

module pulley()
{
    height = 12 * mm;
    diameter = 16 * mm;
    bore = 5 * mm;

    color([0.7, 0.7, 0.0]) difference()
    {
        union()
        {
            cylinder(h = height - 1 - belt_width - belt_tolerance*2, d = diameter, $fn = fn);
            cylinder(h = height, d = diameter - 4, $fn = fn);
            translate([0, 0, height - 1 - belt_tolerance])
                cylinder(h = 1, d = diameter, $fn = fn);
        }
        translate([0, 0, -0.1])
            cylinder(h = height + 0.2, d = bore, $fn = fn);
    }
}

module rod_pocket_of(d=8, h=20, cut=false, adjustable=false, zip=0)
{
    cd = d + rod_wall*2;

    rotate([0, 0, 180]) rotate([90, 0, 0]) translate([0, 0, -rod_pocket]) if (!cut) {
        cylinder(h=h, d=cd, $fn=fn);
        translate([-cd/2,-cd/2, 0])
            cube([cd, cd/2, h]);
    }
    else
    {
        translate([0, 0, -0.1]) rotate([0, 0, 30]) cylinder(h=rod_pocket, r=d/2+press_tolerance, $fn=fn);
        
        // Rod end
        if (!adjustable) {
            translate([0, 0, rod_pocket])
                sphere(r=d/2, $fn=fn);
        } else {
            translate([0, 0, rod_pocket+nut_wall-drill_tolerance]) {
                w=m4_nut_flat/sqrt(3)+drill_tolerance;
                cylinder(r=w, h = m4_nut_height+drill_tolerance*2, $fn=6);
                translate([-w, -cd/2-0.1, 0])
                    cube([w*2, cd/2+0.1, m4_nut_height+drill_tolerance*2]);
            }
            
            // What was this for?
            // drill(d=4, h=h);
        }
        
        * translate([0, 0, rod_wall]) linear_extrude(height = rod_wall) {
            difference() { circle(d=cd*2); circle(d=d + rod_wall*1.5, $fn=fn); }
        }
        
        if (zip < 0)
        {
            translate([0, -cd/2 - 1, -1]) cube([100, cd + 1, rod_pocket/2 + 1]);
        }
        if (zip > 0)
        {
            translate([-100, -cd/2 - 1, -1]) cube([100, cd + 1, rod_pocket/2 + 1]);
        }
    }
}

module rod_pocket(d=8, h=25, zip=0)
{
    difference()
    {
        rod_pocket_of(d=d,h=h,zip=zip,cut=false);
        rod_pocket_of(d=d,h=h,zip=zip,cut=true);
    }
}

module carriage_bearing_of(h=40 * mm, d=8 * mm, cut=false)
{
    cd = d + rod_wall*2;

    translate([0, h/2, 0]) if (!cut)
    {
        translate([0, -h+rod_pocket, 0]) rod_pocket_of(d=d, h=h, cut=false);
    }
    else
    {
        rotate([90, 0, 0]) {
            translate([0, 0, -0.1])
                cylinder(d=d, h=h+0.2, $fn=fn);
            translate([0, 0, rod_wall])
                cylinder(d=d+2*grease_wall, h = h-rod_wall*2, $fn=fn);
            translate([-d/2-grease_wall, -cd/2-0.1, rod_wall])
                cube([d+grease_wall*2, cd/2, h-rod_wall*2]);
        }
    }
}

module carriage_bearing(h=40 * mm, d=8 * mm)
{
    difference()
    {
        carriage_bearing_of(d=d, h=h, cut=false);
        carriage_bearing_of(d=d, h=h, cut=true);
    }
}

lm8uu_od = 15 * mm;
lm8uu_l = 24 * mm;

module lm8uu_bore_of(tolerance=press_tolerance, cut=false)
{
    // LM8UU bearing
    id = 8 * mm;
    od = lm8uu_od;
    l = lm8uu_l;

    cd = od + rod_wall*2;

    if (!cut)
    {
        intersection()
        {
            union()
            {
                cylinder(d = cd, h = l + rod_wall*2, $fn=fn);
                translate([-cd/2, -od/2, 0]) cube([cd, od/2, l + rod_wall*2]);
            }
            translate([-cd/2, -od/2, 0]) cube([cd, od/2 + cd/2, l + rod_wall*2]);
        }
    }
    else
    {
        // Slide path for the rod
        translate([0, 0, -0.1]) linear_extrude(height = l + rod_wall*2 + 0.2)
        {
            circle(d=id + drill_tolerance*2, $fn=fn);
            translate([-id/2 - drill_tolerance, -cd/2]) square([id + drill_tolerance*2, cd/2]);
        }
        
        translate([0, 0, rod_wall-tolerance])
            rotate([0, 0, 30]) cylinder(r=(od + drill_tolerance*2)/sqrt(3), h = l + tolerance*2, $fn=6);
        
        // LM8UU entrance path
        translate([-od/2-tolerance, -cd/2-0.1-100, rod_wall-tolerance])
            cube([od+tolerance*2, cd/2+100, l + tolerance*2]);
        
        // LM8UU exit push
        translate([-id/6, 0, rod_wall - tolerance])
            cube([id/3, cd/2 + 100, l + tolerance*2]);
        
        // Ziptie strips
        union() {
            translate([od/2 - 0.1, -od/2, rod_wall + 3.5 - 1.5]) cube([1.5, 20, 3]);
            mirror([1, 0, 0]) translate([od/2 - 0.1, -od/2, rod_wall + 3.5 - 1.5]) cube([1.5, 20, 3]);
            translate([od/2 - 0.1, -od/2, rod_wall + l - (3.5 + 1.5)]) cube([1.5, 20, 3]);
            mirror([1, 0, 0]) translate([od/2 - 0.1, -od/2, rod_wall + l - (3.5 + 1.5)]) cube([1.5, 20, 3]);
        }
    }
}


module y_motor_bracket(cut=false)
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

belt_span = 8 * mm;

y_mount_height = nema_mount_height + wall*2 - z_block_offset - z_block_size;
y_mount_depth = (nema_mount_width - mdf_width+ wall*2)/2;

module y_mount_of(cut=false)
{
    r = y_mount_depth;
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
                        cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=r, $fn=6);
                translate([mdf_width/2+nut_wall, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=r, $fn=6);
            }
        }
    }
}

module y_motor_of(cut=false)
{
    rod_offset = (mdf_length - rod_y[0])/2;
    mount_offset = y_belt_gap/2-pulley_belt_gap/2;
    guide_offset = -rod_pocket+bearing_holder_diameter/2-rod_offset;

    if (!cut)
    {
        translate([0, 0, -z_block_size/2]) linear_extrude(height = z_block_size) hull() {
            translate([-0.1, -rod_pocket-rod_offset])
                square([0.1, nema_mount_width + wall + rod_offset + rod_pocket]);
            translate([0, 0])
                square([nema_mount_width-wall, 0.1]);
            translate([-mount_offset, guide_offset])
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
    translate([0, -rod_offset, 0])
        rod_pocket_of(d=rod_y[1], h=rod_pocket+rod_offset, cut=cut);


    // Bracket for the motor
    translate([mount_offset, 0, z_block_size/2])
        y_motor_bracket(cut=cut);

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
    if (y_belt_gap > bearing_holder_diameter)
    {
        translate([-mount_offset, guide_offset, -z_block_size/2])
            bearing_holder_of(h=z_block_size, cut=cut);
    }

}

module y_motor()
{
    mount_offset = y_belt_gap/2-pulley_belt_gap/2;

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

module wilbur_y_motor_max()
{
    y_motor();
}

module wilbur_y_motor_min()
{
    rod_offset = (mdf_length - rod_y[0])/2;
    switch_y = rod_pocket + rod_offset - bearing_diameter/2;
    switch_x = y_belt_gap/2 + bearing_diameter/2;

    difference()
    {
        union()
        {
            mirror([0, 1, 0]) y_motor();
            translate([switch_x - switch_size[0]/2, 0, -z_block_size/2 - z_block_offset])
                cube([switch_size[0]+(mdf_x_offset-switch_x), switch_y, wall]);
        }
        translate([switch_x, switch_y - switch_size[1], -z_block_size/2 - z_block_offset + wall - 0.2])
            switch_cut();
    }

    if (hardware)
    {
        translate([switch_x, switch_y - switch_size[1], -z_block_size/2 - z_block_offset + wall - 0.2])
            color([0, 0.8, 0.8]) switch();
     }
}

y_support = [ 2.5 * mm, 15 * mm];

// Clamp
cable_clamp_id = 20 * mm;
cable_clamp_od = 20 * mm+ wall*2;
cable_clamp_gap = 10 * mm;

module cable_clamp_of(h = 10 * mm, cut=false)
{

    if (!cut)
    {
        cylinder(d=cable_clamp_od, h=h, $fn=fn);
    }
    else
    {
        drill(d=cable_clamp_id, h=h);
        translate([-cable_clamp_gap/2, -cable_clamp_od/2-0.1, -0.1])
            cube([cable_clamp_gap, cable_clamp_od/2, h + 0.2]);
    }
}

module y_cable_clip_of(cut=false)
{

    // Drill diameter
    bolt_d = 3 * mm;
    nut_flat = m3_nut_flat;

    tolerance = slide_tolerance;

    bracket_w = wall*3 + nut_flat*2;
    bracket_h = y_support[0] + wall*2;

    clamp_h = 10 * mm;

    // Rod holder for secondary rod
    if (!cut) {
        hull()  {
            translate([0, -wall - cable_clamp_od/2, -bracket_h/2-clamp_h/2])
                cable_clamp_of(h = clamp_h, cut=false);
            translate([-bracket_w/2, -wall, -y_support[0] - wall*2])
                cube([bracket_w, wall, wall*2+y_support[0]]);
        }
        translate([-bracket_w/2, -wall, -rod_slide[1]/2 - y_support[0] - wall])
            cube([bracket_w, y_support[1] + wall*2 + nut_flat + wall, y_support[0] + wall*2]);
    } else {
        translate([0, -wall - cable_clamp_od/2, -bracket_h/2-clamp_h/2])
            cable_clamp_of(h = clamp_h, cut=true);

        translate([-bracket_w/2-0.1, -tolerance, -rod_slide[1]/2 - y_support[0] - tolerance])
            cube([bracket_w+0.2, tolerance + y_support[1] + wall + nut_flat + wall + 0.1, y_support[0] + tolerance*2]);

        for (d=[-1:2:1])
        {
            translate([-d * (wall + nut_flat/2), (y_support[1] + bolt_d/2 + tolerance), -rod_slide[1]/2-y_support[0]/2])
            {
                translate([0, 0, y_support[0]/2 + wall/2]) m3_nut_cut(h=10);
                translate([0, 0, -y_support[0]/2-wall-0.1]) m3_nut_cut(h=wall/2);
                translate([0, 0, -y_support[0]/2-wall*2]) drill(h=wall*4+20, d=bolt_d);
            }
        }
    }
}

module wilbur_y_cable_clip()
{
    difference()
    {
        y_cable_clip_of(cut = false);
        y_cable_clip_of(cut = true);
    }
}

module y_rail_cap_of(cut=false)
{
    // Drill diameter
    bolt_d = 3 * mm;
    nut_flat = m3_nut_flat;

    tolerance = slide_tolerance;

    // Rod holder for secondary rod
    translate([-(wall + nut_flat + wall + rod_slide[1]/2), wall, -z_block_size/2-z_block_offset+rod_slide[1]/2]) {
        if (!cut) {
            hull()  {
                translate([wall + nut_flat + wall + rod_slide[1]/2, -wall, 0]) rotate([-90, 0, 0]) cylinder(d=rod_slide[1]+rod_wall*2, h=y_mount_depth+wall*2, $fn=fn);
                translate([-rod_slide[1]/2-wall-nut_flat-wall, -wall, -rod_slide[1]/2])
                    cube([wall*4 + nut_flat*2, y_support[1] + wall*2 + nut_flat + wall, wall]);
            }
            translate([-rod_slide[1]/2-wall-nut_flat-wall, -wall, -rod_slide[1]/2 - y_support[0] - wall])
                cube([wall*4 + nut_flat*2, y_support[1] + wall*2 + nut_flat + wall, y_support[0] + wall*2]);
        } else {
            translate([wall + nut_flat + wall + rod_slide[1]/2, 0, 0])
            {
                rotate([-90, 0, 0]) translate([0, 0, rod_wall]) drill(d=rod_slide[1], h=y_mount_depth+wall+100);
                * translate([-rod_slide[1]/2-drill_tolerance, rod_wall, -rod_slide[1]-0.1]) cube([rod_slide[1] + drill_tolerance*2, y_mount_depth+wall+100, rod_slide[1]+0.1]);
                translate([-rod_slide[1]/2-drill_tolerance*5, 0, -rod_slide[1]-0.1]) cube([rod_slide[1] + drill_tolerance*2, y_mount_depth+wall+100, rod_slide[1]/2+0.1]);
                translate([-rod_slide[1]/2-wall- wall*4-nut_flat-wall*2-0.1, -tolerance, -rod_slide[1]/2 - y_support[0] - tolerance])
                    cube([wall + rod_slide[1] + wall+ wall*4 + nut_flat*2+0.2, tolerance + y_support[1] + wall + nut_flat + wall + 0.1, y_support[0] + tolerance*2]);
            }

            for (d=[0:1])
            {
                translate([-d * (wall + nut_flat), (y_support[1] + bolt_d/2 + tolerance), -rod_slide[1]/2-y_support[0]/2])
                {
                    translate([0, 0, y_support[0]/2 + wall/2]) m3_nut_cut(h=10);
                    translate([0, 0, -y_support[0]/2-wall-0.1]) m3_nut_cut(h=wall/2);
                    translate([0, 0, -y_support[0]/2-wall*2]) drill(h=wall*4+20, d=bolt_d);
                }
            }
        }

    }
}

module wilbur_y_rail_max()
{
    difference()
    {
        y_rail_cap_of(cut=false);
        y_rail_cap_of(cut=true);
    }
    if (hardware) { color(color_metal) translate([-50, wall, -z_block_size/2-z_block_offset-y_support[0]]) cube([100, y_support[1], y_support[0]]); }
}

module wilbur_y_rail_min()
{
    mirror([0, 1, 0]) wilbur_y_rail_max();
}

module x_cap_of(cut=false)
{
    x_extra = rod_pocket/2;
    x_size = x_extra + rod_pocket+nut_wall+m4_nut_height+rod_wall*2;

    if (!cut) hull() {
        translate([-x_extra, -x_rod_gap/2, 0]) rotate([0, 0, -90])
            rod_pocket_of(d=rod_y[1], h=x_size, adjustable=true, cut=cut);

        translate([-x_extra, x_rod_gap/2, 0]) rotate([0, 0, -90])
            rod_pocket_of(d=rod_y[1], h=x_size, adjustable=true, cut=cut);
    } else {
        translate([-x_extra, -x_rod_gap/2, 0]) rotate([0, 0, -90]) {
            rod_pocket_of(d=rod_y[1], h=x_size, adjustable=true, cut=cut);
            translate([0, x_size - x_extra, 0]) rotate([90, 0, 0]) drill(h = x_size, d = 3);
        }

        translate([-x_extra, x_rod_gap/2, 0]) rotate([0, 0, -90])
        {
            rod_pocket_of(d=rod_y[1], h=x_size, adjustable=true, cut=cut);
            translate([0, x_size - x_extra, 0]) rotate([90, 0, 0]) drill(h = x_size, d = 3);
        }
    }

    bearing_tilt = 2;
    translate([0, -x_rod_gap/2+bearing_diameter/2, -z_block_size/2])
        rotate([0, bearing_tilt, 0]) bearing_holder_of(h=z_block_size, cut=cut);

    translate([0, x_rod_gap/2-bearing_diameter/2, -z_block_size/2])
        rotate([0, bearing_tilt, 0]) bearing_holder_of(h=z_block_size, cut=cut);

    // Remove some bulk
    if (cut) {
        translate([z_block_size/2+rod_wall+nut_wall-x_size/2, 0, -z_block_size/2])
            sphere(r=z_block_size-wall);
    }
}

module wilbur_x_cap()
{
    difference()
    {
        x_cap_of(cut=false);
        x_cap_of(cut=true);
    }
}

flanged_bearing_d = 13 * mm;
flanged_bearing_fd = 15 * mm;
flanged_bearing_h = 5 * mm;
flanged_bearing_id = 4 * mm;

module x_grip_of(cut=false)
{
    x_size = rod_pocket;


    if (!cut) {
        hull() {
            translate([0, -x_rod_gap/2, 0]) rotate([0, 0, -90])
                rod_pocket_of(d=rod_y[1], h=rod_pocket, adjustable=true, cut=cut);

            translate([0, x_rod_gap/2, 0]) rotate([0, 0, -90])
                rod_pocket_of(d=rod_y[1], h=rod_pocket, adjustable=true, cut=cut);
        }
    } else {
        translate([0, -x_rod_gap/2, 0]) rotate([0, 0, -90])
            rod_pocket_of(d=rod_y[1], h=rod_pocket, adjustable=true, cut=cut);

        translate([0, x_rod_gap/2, 0]) rotate([0, 0, -90])
            rod_pocket_of(d=rod_y[1], h=rod_pocket, adjustable=true, cut=cut);
        
    }
    
    if (!cut) hull()
    {
        mirror([0, 0, 1]) translate([0, 0, -rod_y[1]/2 - rod_slide[1]/2 + 0.2])
        {
                    {
                translate([0, -x_rod_gap/2+bearing_holder_diameter/2+rod_y[1]/2, 0])             cylinder(h=rod_y[1]/2+wall, d=bearing_holder_diameter);

                
                translate([0, x_rod_gap/2-bearing_holder_diameter/2-rod_y[1]/2, 0])             cylinder(h=rod_y[1]/2+wall, d=bearing_holder_diameter);

            }
            
            // Side bearing mounts
            translate([flanged_bearing_d + rod_slide[1], 0, ])
            {
                translate([0, -x_rod_gap/2+bearing_holder_diameter/2+rod_y[1]/2, 0])             cylinder(h=rod_y[1]/2+wall, d=bearing_holder_diameter);

                
                translate([0, x_rod_gap/2-bearing_holder_diameter/2-rod_y[1]/2, 0])             cylinder(h=rod_y[1]/2+wall, d=bearing_holder_diameter);

            }
        }
    }
        
    mirror([0, 0, 1]) translate([0, 0, -rod_y[1]/2 - rod_slide[1]/2 + 0.2])
    {
        // Middle bearing mount
        bearing_holder_of(h=rod_y[1]/2+wall, cut=cut);
    
        // Side bearing mounts
        translate([flanged_bearing_d + rod_slide[1], 0, ])
        {
            translate([0, -x_rod_gap/2+bearing_holder_diameter/2+rod_y[1]/2, 0]) bearing_holder_of(h=rod_y[1]/2+wall, cut=cut);
            
            translate([0, x_rod_gap/2-bearing_holder_diameter/2-rod_y[1]/2, 0]) bearing_holder_of(h=rod_y[1]/2+wall, cut=cut);
        }
    }
}

module wilbur_x_grip()
{
    difference()
    {
        x_grip_of(cut=false);
        x_grip_of(cut=true);
    }
    
    if (hardware)
    {
        color(color_metal) translate([flanged_bearing_d/2 + rod_slide[1]/2, 0, -rod_y[1]/2 - rod_slide[1]/2])
            rotate([90, 0, 0]) translate([0, 0, -50]) cylinder(d = rod_slide[1], h =100, $fn=fn);
    }
}

gt2_belt_thickness = 1 * mm;
gt2_belt_pitch = 2.0 * mm;
gt2_belt_tooth_radius = 0.8 * mm;
gt2_belt_compression = 0.1 * mm;
gt2_belt_width = 6 * mm;

module gt2_belt_loop(r=10 * mm, outside=true)
{
    delta_r = outside ? gt2_belt_tooth_radius : 0;
    difference()
    {
        circle(r = r + gt2_belt_thickness - gt2_belt_compression - delta_r, $fn=360);
        circle(r = r - delta_r, $fn=360);
    }
    for (theta = [gt2_belt_pitch/r/2:gt2_belt_pitch/r:2*PI])
    {
        translate([r*cos(theta*180/PI),r*sin(theta*180/PI)])
            circle(r = gt2_belt_tooth_radius, $fn=fn);
    }
}

function gt2_belt_radius(teeth=15, angle=180) = (teeth*360/angle)*gt2_belt_pitch/2/PI;

module gt2_belt_arc(teeth=15, angle=180, outisde=true)
{
    r = gt2_belt_radius(teeth=teeth, angle=angle);

    translate([0, r + gt2_belt_thickness]) rotate([0, 0, -180+angle]) intersection()
    {
        rotate([0, 0, 90-angle]) gt2_belt_loop(r=r, outside=outside);
        if (angle > 270) {
            difference() {
                circle(r=2*r + 0.1, $fn=fn);
                polygon([[0,0], [0, 2*r + 0.2], [2*r*sin(angle), 2*r*cos(angle)]]);
            }
        } else if (angle > 180) {
            translate([0, -2*r, 0]) square([r*4, r*4]);
            polygon([[0,0], [0, -2*r + 0.2], [2*r*sin(angle), 2*r*cos(angle)]]);
        } else if (angle > 90) {
            square([r*2, r*2]);
            polygon([[0,0], [2*r + 0.2, 0], [2*r*sin(angle), 2*r*cos(angle)]]);
        } else {
            polygon([[0, 0], [0, 2*r + 0.2], [2*r*sin(angle), 2*r*cos(angle)]]);
        }
    }
}

module gt2_belt_line(l=20 * mm, outside=true)
{
    delta_y=outside ? gt2_belt_tooth_radius - gt2_belt_compression : gt2_belt_compression;
    translate([0, gt2_belt_compression+delta_y, 0]) square([l, gt2_belt_thickness - gt2_belt_compression]);
    for (i = [gt2_belt_pitch/2:gt2_belt_pitch:l])
    {
        translate([i, gt2_belt_tooth_radius])
            circle(r = gt2_belt_tooth_radius, $fn=fn);
    }
}

module gt2_belt_holder_of(h=10 * mm, teeth=10, cut=false, outside=true)
{
    gt2_both = 2.0 * mm;
    gt2_single = 1.6 * mm;
    bolt = 5 * mm;
    id = bolt + 2 * gt2_single;
    od = id+wall*2;

    translate([-od/2+od/3, 0, 0]) if (!cut)
    {
        hull() {
            translate([-od/3, -od+wall, 0])
                cube([od/2, od, h]);
            translate([-od/2, -od/2+wall, 0]) cylinder(r=od/2, h=h);
        }
    }
    else
    {
        translate([-od/2, -od/2+wall*3/2, 0]) {
            drill(d=bolt, h = h);
            translate([0, 0, -0.1]) m5_nut_cut(h = m5_nut_height + 0.1);
            translate([0, 0, h - gt2_belt_width]) {
                drill(d=id, h = gt2_belt_width + 0.1);
                translate([0, -gt2_both/2, 0]) cube([od + wall, gt2_both, h - gt2_belt_width]);
            }
        }
    }
}

module gt2_belt_holder(h=10 * mm, teeth=5)
{
    difference()
    {
        gt2_belt_holder_of(h=h, teeth=teeth, cut=false);
        gt2_belt_holder_of(h=h, teeth=teeth, cut=true);
    }
}

sled_size = [y_block_size, x_rod_gap, hotend_latch_height];

module wilbur_sled_of(cut=false)
{
    s_size = sled_size;

    if (!cut)
    {
        // Bulk
        translate([0, 0, -z_block_size/2+s_size[2]/2])
            cube([s_size[0], s_size[1]-rod_x[1]-grease_wall*2, s_size[2]], center=true);
    }
    else
    {
        // Hotend mounting drills
        translate([0, 0, -z_block_size/2]) {
            drill(h=s_size[2], d=hotend_latch_diameter);

            // M4 mounting holes, 20mm apart
            for (r = [0:90:270]) rotate([0, 0, 45+r]) translate([20*sin(45), 0, 0]) {
                drill(h=s_size[2], d=4);
                translate([0, 0, s_size[2] - m4_nut_height/2])
                    rotate([0, 0, 30]) cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=m4_nut_height+0.1, $fn=6);
            }

        }

    }

    // Bearing holder
    translate([-s_size[0]/2+bearing_holder_diameter/2, 0, -z_block_size/2]) {
        if (!cut) translate([-bearing_holder_diameter/2, -(s_size[1]-rod_x[1]/2)/2, 0])
            cube([bearing_holder_diameter, s_size[1]-rod_x[1]/2, z_block_size]);
        if (!cut) translate([s_size[0]-bearing_holder_diameter*1.5, -(s_size[1]-rod_x[1]/2)/2, 0])
            cube([bearing_holder_diameter, s_size[1]-rod_x[1]/2, z_block_size]);
        bearing_holder_of(h=z_block_size, cut=cut);
    }

    // Teeth for the inside arc of the belt clip
    belt_teeth = 5;

    // Belt holders
    translate([s_size[0]/2, x_rod_gap/2-bearing_diameter, -z_block_size/2])
        gt2_belt_holder_of(teeth=belt_teeth, h=z_block_size + bearing_cap_height + belt_width, cut=cut);

    translate([s_size[0]/2, -(x_rod_gap/2-bearing_diameter), -z_block_size/2])
        mirror([0,1,0])
            gt2_belt_holder_of(teeth=belt_teeth, h=z_block_size + bearing_cap_height + belt_width, cut=cut);

    // Carriage bearings
    {
        translate([0, -x_rod_gap/2, 0]) rotate([0, 0, 90])
            carriage_bearing_of(h=s_size[0], d=rod_x[1], cut=cut);

        translate([0, x_rod_gap/2, 0]) rotate([0, 0, 90])
            carriage_bearing_of(h=s_size[0], d=rod_x[1], cut=cut);
    }

    // X-min detection switch mount
    translate([-s_size[0]/2-(bearing_holder_diameter/2-rod_wall)+switch_size[1]/2, 0, -z_block_size/2])  {
        if (!cut) {
            translate([-switch_size[1], -switch_size[0]/2, 0])
                cube([s_size[0], switch_size[0], wall]);

        }
        else
        {
            rotate([0, 0, 90]) {
                translate([0, 0, wall]) switch_cut();
            }
        }
    }
}

module wilbur_sled()
{
    difference()
    {
        wilbur_sled_of(cut=false);
        wilbur_sled_of(cut=true);
    }

    if (hardware) {
        translate([-sled_size[0]/2-(bearing_holder_diameter/2-rod_wall)+switch_size[1]/2, 0, -z_block_size/2+wall])
            rotate([0, 0, 90]) color([0, 0.8, 0.8]) switch();
    }
}


// X and Y axis interface block
module wilbur_block_of(cut=false)
{
    // Y rod pockets
    if (!cut)
    {
        // Bulk of the block (location of the 4 bearing holders)
        translate([0, 0, -z_block_size/2]) linear_extrude(height=z_block_size) hull() {
            translate([y_belt_gap/2+bearing_diameter/2, -pulley_gap/2, 0]) circle(d=bearing_holder_diameter);
            translate([y_belt_gap/2+bearing_diameter/2, pulley_gap/2, 0]) circle(d=bearing_holder_diameter);
            translate([-y_belt_gap/2+bearing_diameter/2, -bearing_diameter, 0]) circle(d=bearing_holder_diameter);
            translate([-y_belt_gap/2+bearing_diameter/2, bearing_diameter, 0]) circle(d=bearing_holder_diameter);
        }
    }
    else
    {
        // Remove some bulk
        translate([0, 0, -z_block_size/2-0.1]) linear_extrude(height=z_block_size+0.2) hull() {
            x=(x_rod_gap/2-rod_y[1]/2-rod_wall)/2;
            r=min(y_belt_gap/4, x);
            translate([y_belt_gap/2, -x, 0]) circle(r=r);
            translate([y_belt_gap/2,  x, 0]) circle(r=r);
        }
        
        // Endstop blocker (M5 bolt)
        // Press tolerance, so it can be threaded lightly
        translate([y_belt_gap/2, 0, 0]) rotate([0, 90, 0]) cylinder(r=5/sqrt(3), h=y_belt_gap, $fn=6);
    }

    translate([y_belt_gap/2 + rod_wall*1.5, 0, 0])
    {
        translate([0, -x_rod_gap/2, 0]) rotate([0, 0, 90])
            rod_pocket_of(d=rod_x[1], h=rod_pocket, cut=cut, zip = -1);
        translate([0, x_rod_gap/2, 0]) rotate([0, 0, 90])
            rod_pocket_of(d=rod_x[1], h=rod_pocket, cut=cut, zip = 1);
    }

    rotate([90, 0, 0]) lm8uu_bore_of(cut=cut);
    rotate([-90, 0, 0]) rotate([0, 0, 180]) lm8uu_bore_of(cut=cut);
    if (cut) {
        translate([-100, -100, -z_block_size/2-100])
            cube([200, 200, 100.01]);
    }

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

module wilbur_block()
{
    difference()
    {
        wilbur_block_of(cut=false);
        wilbur_block_of(cut=true);
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
y_travel = rod_y[0] - rod_pocket*2 - x_rod_gap - bearing_holder_diameter;
x_travel = x_length - sled_size[0] + mdf_width;

z_bracket_bend_diameter = 260 * mm;
z_bracket_length = 600 * mm;
z_bracket_section = [ 1/8 * in,  2 * in];

module z_sled_bracket()
{
    // Bent aluminum bracket
    union() {
        z_bracket_leg = (z_bracket_length - z_bracket_bend_diameter * PI / 2) / 2;
        translate([z_bracket_leg, 0, 0]) difference()
        {
            cylinder(d = z_bracket_bend_diameter + z_bracket_section[0]*2, h = z_bracket_section[1], $fn=fn*2);
            translate([0, 0, -0.1]) {
                cylinder(d = z_bracket_bend_diameter, h = z_bracket_section[1] + 0.2, $fn=fn*2);
                translate([-z_bracket_bend_diameter/2 - z_bracket_section[0] - 0.1, -z_bracket_bend_diameter/2 - z_bracket_section[0] - 0.1, -0.1]) cube([z_bracket_bend_diameter/2 + z_bracket_section[0], z_bracket_bend_diameter + z_bracket_section[0]*2, z_bracket_section[1] + 0.3]);
            }
        }

        translate([0, -z_bracket_bend_diameter/2 - z_bracket_section[0], 0])
            cube([z_bracket_leg + 0.1, z_bracket_section[0], z_bracket_section[1]]);

        translate([0, z_bracket_bend_diameter/2, 0])
            cube([z_bracket_leg + 0.1, z_bracket_section[0], z_bracket_section[1]]);
    }
}

module z_sled_heatbed()
{
    heatbed = [220 * mm, 275 * mm, 3 * mm];

    translate([heatbed[0]/2, 0, 0])
        cube(heatbed, center=true);
}

z_screw_diameter = 10 * mm;

module alum_u_extrusion(h = 10, cut = false)
{
    translate([-10.125*mm/2, 0, 0]) linear_extrude(height=h) {
        if (!cut)
        {
            difference()
            {
                square([10.125*mm, 12.9*mm]);
                translate([1.55*mm, 1.55*mm])
                    square([10.125*mm - 1.55*mm*2, 12.9*mm]);
            }
        }
        else
        {
            translate([-slide_tolerance, -slide_tolerance]) square([10.125*mm + 2*slide_tolerance, 12.9*mm + 2*slide_tolerance]);
        }
    }
}

z_sled_bridge = 250 *mm;
z_sled_slider_d = 8 * mm;
z_visible_h = 20;


module z_sled_hardware()
{
    screw_d = z_screw_diameter;

    // Heatbed bracket and heatbed
    translate([screw_d/2 + wall, 0, 0])
    {
        color(color_metal) z_sled_bracket();
        color(color_metal) translate([0, 0, z_bracket_section[1] + wall + 10]) z_sled_heatbed();
    }

    // Sled bridge
    color(color_metal) translate([z_screw_diameter/2 + wall, -z_sled_bridge/2, z_bracket_section[1]/2]) rotate([-90, -90, 0]) alum_u_extrusion(h = z_sled_bridge);

    color(color_metal) translate([0, 0, -z_visible_h]) linear_extrude(height = z_visible_h * 2 + z_bracket_section[1])
    {
        // Z screws
        translate([0, -z_bracket_bend_diameter/2-z_bracket_section[0]/2])
            circle(d = 10 * mm);
        translate([0, z_bracket_bend_diameter/2+z_bracket_section[0]/2])
            circle(d = 10 * mm);

    }
}

module z_sled_of(cut=false)
{
    z_screw_clip_od = 22 * mm;
    z_screw_clip_id = 10 * mm;
    z_screw_clip_m3_radius = 8 * mm;

    if (!cut)
    {
        // Z screw bracket
        union()
        {
            cylinder(d = z_screw_clip_od, h = z_bracket_section[1]/5, $fn=fn);
            translate([0, 0, z_bracket_section[1]/5*4]) cylinder(d = z_screw_clip_od, h = z_bracket_section[1]/5, $fn=fn);
        }

        // Heatbed bracket holder (inner)
        translate([0, wall + z_bracket_section[0]/2+drill_tolerance, 0]) hull()
        {
            translate([z_screw_clip_od/2 - wall, 0, 0]) cylinder(d = wall*2, h = z_bracket_section[1], $fn=fn);
            translate([z_screw_clip_id/2 + z_bracket_section[1]/2, 0, 0])
                cylinder(d = wall*2, h = z_bracket_section[1], $fn=fn);
        }
        // Heatbed bracket holder (outer)
        translate([0, -(wall + z_bracket_section[0]/2)-drill_tolerance, 0]) hull()
        {
            translate([z_screw_clip_od/2 - wall, 0, 0]) cylinder(d = wall*2, h = z_bracket_section[1], $fn=fn);
            translate([z_screw_clip_id/2 + z_bracket_section[1]/2, 0, 0])
                cylinder(d = wall*2, h = z_bracket_section[1], $fn=fn);
        }
        hull()
        {
            translate([z_screw_clip_od/2, 0, 0]) cylinder(d = z_screw_clip_id, h = z_bracket_section[1], $fn=fn);
            translate([wall, z_screw_clip_od/2, 0]) cylinder(d = z_screw_clip_id, h = z_bracket_section[1], $fn=fn);
        }
        hull()
        {
            translate([wall, z_screw_clip_od/2, 0]) cylinder(d = z_screw_clip_id, h = z_bracket_section[1], $fn=fn);
            translate([z_screw_diameter/2 + wall, (z_bracket_bend_diameter - z_sled_bridge)/2 + 20, z_bracket_section[1]/2 - 20*mm/2]) cylinder(d = 15 * mm, h = 20 * mm);
        }
    }
    else
    {
        // Screw clearnance
        drill(d = z_screw_clip_id, h = z_bracket_section[1]);

        // Screw clip attachments
        for (d = [0:3]) rotate([0, 0, 45 + 90 * d]) translate([z_screw_clip_m3_radius, 0, 0]) {
            drill(d = 3 - drill_tolerance*2, h = z_bracket_section[1]/5);
            translate([0, 0, z_bracket_section[1]/5*4]) drill(d = 3 - drill_tolerance*4, h = z_bracket_section[1]/5);
        }

        // Heatbed bracket
        translate([z_screw_clip_id/2 + wall, -z_bracket_section[0]/2, -0.1]) {
            translate([0, -drill_tolerance, 0]) cube([z_bracket_section[1]/2 + z_bracket_section[0]/2 + wall*5 + 0.1, z_bracket_section[0] + drill_tolerance*2, z_bracket_section[1]+0.2]);
            for (d = [0:2]) translate([z_bracket_section[1]/2-m4_nut_flat, -z_screw_clip_od/2, (d + 1) * z_bracket_section[1]/4])
            {
                rotate([-90, 0, 0]) drill(d = 4 *mm, h = z_screw_clip_od);
                rotate([-90, 0, 0]) rotate([0, 0, 30]) cylinder(r = m4_nut_flat / sqrt(3) + drill_tolerance, $fn = 6, h = z_screw_clip_od/2 - wall);
                translate([0, z_screw_clip_od/2 + z_bracket_section[0]+wall,0]) rotate([-90, 0, 0]) rotate([0, 0, 30]) cylinder(r = m4_nut_flat / sqrt(3) + drill_tolerance, $fn = 6, h = z_screw_clip_od/2 - wall);
            }
        }

        // Bridge cutout
        translate([z_screw_diameter/2 + wall, 0, z_bracket_section[1]/2]) rotate([-90, -90, 0]) alum_u_extrusion(h = z_sled_bridge, cut=true);

        bridge_inset = 20*mm;

        // Bridge drills
        for (d = [0:1]) translate([z_screw_diameter/2 + wall, (z_bracket_bend_diameter - z_sled_bridge)/2 + bridge_inset - (d + 1) * d * bridge_inset/3, z_bracket_section[1]/2 ])
        {
            rotate([0, -90, 0]) drill(d = 4*mm, h = 20);
            translate([-wall*2, 0, 0]) rotate([0, -90, 0]) cylinder(r1 = m4_nut_flat / sqrt(3) + drill_tolerance, r2 = m4_nut_flat*2, $fn = 6, h = z_screw_clip_od);
        }

    }
}

module wilbur_z_edge()
{
    difference()
    {
        z_sled_of(cut=false);
        z_sled_of(cut=true);
    }
}

module wilbur_z_edge_mirror()
{
    mirror([0, 1, 0]) wilbur_z_edge();
}

slide_x_offset = wall + wall + lm8uu_od/2;
bridge_x_offset = wall + nema_mount_width/2 + z_screw_diameter/2 + wall;

module z_slide_center_of(cut = false, mirrored = false)
{
    if (!cut) {
        hull()
        {
            translate([slide_x_offset, 0, 0]) cylinder(d = z_sled_slider_d + wall*2, h = z_bracket_section[1]);
            translate([bridge_x_offset, (z_bracket_bend_diameter - z_sled_bridge)/2 + 20, z_bracket_section[1]/2 - 20*mm/2]) cylinder(d = 15 * mm, h = 20 * mm);
            translate([bridge_x_offset, -((z_bracket_bend_diameter - z_sled_bridge)/2 + 20), z_bracket_section[1]/2 - 20*mm/2]) cylinder(d = 15 * mm, h = 20 * mm);
        }
    } else {
        bridge_inset = 20 *mm;

        for (d = [0:1]) translate([bridge_x_offset, (z_bracket_bend_diameter - z_sled_bridge)/2 + bridge_inset - (d + 0) * bridge_inset/3, z_bracket_section[1]/2 ])
        {
            rotate([0, -90, 0]) drill(d = 4*mm, h = 20);
            translate([-wall*2, 0, 0]) rotate([0, -90, 0]) cylinder(r1 = m4_nut_flat / sqrt(3) + drill_tolerance, r2 = m4_nut_flat*2, $fn = 6, h = z_sled_slider_d + wall*2);
        }

        if (!mirrored)
        {
            * translate([slide_x_offset, 0, 0]) {
                drill(d = z_sled_slider_d, h = z_bracket_section[1]);
            }

            translate([bridge_x_offset, -z_sled_bridge/2, z_bracket_section[1]/2]) rotate([-90, -90, 0]) alum_u_extrusion(h = z_sled_bridge, cut=true);
            mirror([0, 1, 0]) z_slide_center_of(cut = cut, mirrored = true);
        }
    }

    translate([slide_x_offset, 0, z_bracket_section[1]/2]) rotate([0, 0, 90]) lm8uu_bore_of(cut = cut);
}

module wilbur_z_center()
{
    difference()
    {
        z_slide_center_of(cut = false);
        z_slide_center_of(cut = true);
    }
}

module z_bed_clip_of(cut=false)
{
    h = z_bracket_section[1]/3;
    tolerance = 0.1;
    slot = [1.6*mm, 6*mm];
    w = wall*2 + max(slot[0], z_bracket_section[0]);

    if (!cut)
    {
        // Bracket friction clip
        translate([-w/2, -w/2, -h])
            cube([w, w, h+wall]);
        hull() {
            translate([slot[0]/2, -w/2, 0])
                cube([w, w, wall+slot[1]]);
            translate([-w/2, -w/2, 0])
                cube([w, w, wall]);
        }
    }
    else
    {
        translate([-w/2-0.1, 0, 0]) rotate([0, 90, 0]) cylinder(d = z_bracket_section[0] + tolerance*2, h = w, $fn=fn);
        translate([-w/2-0.1, -z_bracket_section[0]/2-tolerance, -h-0.1])
            cube([w+0.2, z_bracket_section[0]+tolerance*2, h+0.1]);

        translate([w/2, -w/2-0.1, wall])
            cube([w + 0.1, w +0.2, slot[1] + tolerance]);

        // Nut cut for bed
        translate([0, 0, wall + slot[1]/2]) rotate([0, -90, 0]) {
            m3_nut_cut(h=10);
            translate([0, 0, -w*2]) drill(h=w*2, d=3);
        }

        // Nut cuts for bracket
        translate([0, 0, -h/2]) rotate([90, 0, 0]) {
            translate([0, 0, wall]) m3_nut_cut(h=10);
            translate([0, 0, -wall]) drill(h=w*2, d=3);
        }
        translate([0, 0, -h/2]) rotate([-90, 0, 0]) {
            translate([0, 0, wall]) m3_nut_cut(h=10);
            translate([0, 0, -wall]) drill(h=w*2, d=3);
        }
    }
}

module wilbur_z_bed_clip()
{
    difference()
    {
        z_bed_clip_of(cut=false);
        z_bed_clip_of(cut=true);
    }
}

module wilbur_z_foot_of(cut = false, x_offset=slide_x_offset, d = 8*mm)
{
    // Depth of well = diameter of rod
    foot_h = 8 * mm;
    // Width of foot
    foot_w = d + m4_nut_flat*2 + wall*5;
    if (!cut)
    {
        translate([0, 0, -wall*2])
        {
            translate([x_offset, 0, 0])
                cylinder(d = wall*2 + d, h = wall*2 + foot_h, $fn=fn);
            hull()
            {
                translate([x_offset, 0, 0])
                    cylinder(d = 0.01, h = wall*2 + foot_h, $fn=fn);
                translate([0, -foot_w/2, 0])
                    cube([wall, foot_w, foot_h + wall*2]);
            }
        }
    }
    else
    {
        translate([x_offset, 0, 0]) {
            cylinder(d=8*mm, h = foot_h + 0.1, $fn=fn);
            translate([0, -wall/2, 0]) cube([wall+d/2 + 0.1, wall, foot_h+0.1]);
        }
        for (k = [-1:2:1])
        {
            translate([0, k*(foot_w/2 - m4_nut_flat/2 - wall), -wall*2 + wall + foot_h/2])
            {
                rotate([0, 90, 0]) {
                    drill(d = 4 * mm, h = wall*4);
                    translate([0, 0, wall]) m4_nut_cut(h=wall*4);
                }
            }
        }
    }
}

module wilbur_z_foot()
{
    difference()
    {
        wilbur_z_foot_of(cut = false, x_offset=slide_x_offset);
        wilbur_z_foot_of(cut = true, x_offset=slide_x_offset);
    }
}

screw_x_offset =wall + nema_mount_width/2;

module wilbur_z_cap()
{
    rotate([180, 0, 0]) difference()
    {
        wilbur_z_foot_of(cut = false, x_offset=screw_x_offset);
        wilbur_z_foot_of(cut = true, x_offset=screw_x_offset);
    }
}

module z_slide_assembly()
{
    translate([0, 0, z_visible_h + z_bracket_section[1]]) rotate([180, 0, 0]) wilbur_z_foot();
    translate([0, 0, -z_visible_h]) wilbur_z_foot();

    wilbur_z_center();

    if (hardware)
    {
        color(color_metal) translate([slide_x_offset, 0, -z_visible_h]) linear_extrude(height = z_visible_h * 2 + z_bracket_section[1])
        {
            // Z slider
            circle(d = 8 * mm);
        }
    }
}

module z_motor_bracket(cut=false)
{
    rotate([0, 0, 180]) translate([-nema_mount_width/2-wall, 0, 0]) translate([nema_mount_width/2 + wall, 0, -nema_mount_width/2-wall])
    if (!cut) {
        translate([nema_mount_width/2 - m4_nut_height, -mdf_width-nema_mount_width/2-wall, -nema_mount_height/2 - wall])
            cube([wall + m4_nut_height, mdf_width*2+nema_mount_width+wall*2,nema_mount_height + wall*2]);
        cube([nema_mount_width + wall*2, nema_mount_width + wall*2, nema_mount_height + wall*2], center=true);
        // Front switch lip
        translate([-nema_mount_width/2, 0, nema_mount_height/2 + wall - 0.1]) hull() {
            rotate([0, 0, -90]) translate([nema_mount_radius, 0, 0]) cylinder(d=wall, h = 6, $fn=fn);
            rotate([0, 0, 90]) translate([nema_mount_radius, 0, 0]) cylinder(d=wall, h = 6, $fn=fn);
        }
    }
    else
    {
        // Front switch lip cutout
        translate([-nema_mount_width/2-wall, 0, nema_mount_height/2 + wall + 6/2 - 0.1]) {
            for (d = [-1:1]) {
                translate([0, d * 9.5, 0])
                    rotate([0, 90, 0]) drill(d=2.2, h=20);
            }
        }

        translate([wall, 0, -wall-0.1])
            cube([nema_mount_width+wall*2+0.1, nema_mount_width, nema_mount_height+wall*2+0.1], center=true);
        //Rear cutout
        translate([wall - 0.1, -5 * mm, nema_mount_height/2 - wall])
            cube([nema_mount_width/2 + wall, 10 * mm, wall*2 + 0.1]);
        for (i=[0:3]) {
            if (i < 3) {
                translate([nema_mount_width/2-m4_nut_height-0.1, -mdf_width/2-nema_mount_width/2-wall, (nema_mount_width/2+wall)-(nema_mount_height + wall*2)/4*(i+1)])
                {
                    rotate([0, 0, 90]) rotate([90, 0, 0]) {
                        m4_nut_cut(h=m4_nut_height);
                        drill(d=4 + drill_tolerance*2, h=10);
                    }
                    translate([0, nema_mount_width+mdf_width+wall*2, 0]) rotate([0, 0, 90]) rotate([90, 0, 0]) {
                        m4_nut_cut(h=m4_nut_height);
                        drill(d=4 + drill_tolerance*2, h=10);
                    }
                }
            }
            rotate([0, 0, 45 + 90*i])
                translate([0, nema_mount_radius, 0])
                    drill(d=3, h=nema_mount_height/2+wall);
        }
        drill(d = 22, h =nema_mount_height/2+pulley_height+2);
    }
}

module wilbur_z_motor()
{
    difference()
    {
        intersection()
        {
            z_motor_bracket(cut=false);
            translate([-nema_mount_width/2-wall, -100, -nema_mount_height-wall-wall*sin(45)]) rotate([0, -45, 0]) cube([200, 200, 200]);
        }
        z_motor_bracket(cut=true);
    }
}

module z_sled_assembly()
{
    z_offset = -build_z/2 - z_bracket_section[1]/2;

    translate([mdf_width/2, 0, z_offset])
    {
        translate([screw_x_offset, 0, 0])
        {
            translate([0, z_bracket_bend_diameter/2 + z_bracket_section[0]/2, 0]) {
                wilbur_z_edge_mirror();
                translate([50, 0, z_bracket_section[1]]) wilbur_z_bed_clip();
                translate([150, 0, z_bracket_section[1]]) rotate([0, 0, 180]) wilbur_z_bed_clip();
                translate([0, 0, -build_z - z_offset + nema_mount_height]) wilbur_z_motor();
                translate([-screw_x_offset, 0, z_bracket_section[1] + 20]) wilbur_z_cap();
            }
            translate([0, -z_bracket_bend_diameter/2 - z_bracket_section[0]/2, 0]) {
                wilbur_z_edge();
                translate([50, 0, z_bracket_section[1]]) wilbur_z_bed_clip();
                translate([150, 0, z_bracket_section[1]]) rotate([0, 0, 180]) wilbur_z_bed_clip();
                translate([0, 0, -build_z - z_offset + nema_mount_height]) wilbur_z_motor();
                translate([-screw_x_offset, 0, z_bracket_section[1] + 20]) wilbur_z_cap();
            }
            if (hardware)
            {
                z_sled_hardware();
            }
        }
        z_slide_assembly();
    }
}

module wilbur(x_percent=0.0025, y_percent=0.0025)
{
    translate([mdf_x_offset, 0, 0]) z_sled_assembly();

    translate([0, mdf_length/2, 0]) wilbur_y_motor_max();
    translate([0, -mdf_length/2, 0]) wilbur_y_motor_min();
    translate([0, y_travel * (y_percent - 0.5), 0]) {
        wilbur_block();
        translate([y_belt_gap/2, 0, 0])
        {
            translate([rod_pocket + sled_size[0]/2 + x_travel * x_percent, 0, 0]) wilbur_sled();
            translate([rod_x[0], 0, 0]) wilbur_x_cap();
            if (hardware)
            {
                color([0, 0.8, 0]) {
                    translate([0, x_rod_gap/2, 0]) rotate([0, 90, 0]) cylinder(h = rod_x[0], d = rod_x[1], $fn=fn);
                    translate([0, -x_rod_gap/2, 0]) rotate([0, 90, 0]) cylinder(h = rod_x[0], d = rod_x[1], $fn=fn);
                }
            }
        }
    }
    translate([mdf_x_offset + x_length+mdf_width, mdf_length/2, 0]) wilbur_y_rail_min();
    translate([mdf_x_offset + x_length+mdf_width, -mdf_length/2, 0])  wilbur_y_rail_max();

    // Additional Mechanicals
    if (hardware)
    {
        color([0, 0.8, 0]) {
            translate([0, rod_y[0]/2, 0]) rotate([90, 0, 0]) cylinder(h = rod_y[0], d = rod_y[1], $fn=fn);
            translate([mdf_x_offset + x_length+mdf_width, rod_slide[0]/2, -z_block_offset-z_block_size/2+rod_slide[1]/2]) rotate([90, 0, 0]) cylinder(h = rod_slide[0], d = rod_slide[1], $fn=fn);
        }

        translate([mdf_x_offset, 0, 0]) {
        # translate([-mdf_width/2, -mdf_length/2, -build_z-z_block_offset-z_block_size/2])
            cube([mdf_width, mdf_length, build_z]);
        }
    }
 }

wilbur();

echo("Belt length:", y_belt_gap*2 + (mdf_length+nema_mount_width/2+wall)*2 - (2*bearing_diameter) - x_rod_gap + 2*(rod_y[0]+2*(rod_pocket+rod_wall)) + 2*y_belt_gap + bearing_diameter);
echo("Maximum printable X,Y:",x_travel-sled_size[1],y_travel - (x_rod_gap + bearing_diameter/2));
echo("M4 bolt x9:", ceil((z_block_size+bearing_cap_height*2-m4_nut_height+bearing_width)/5)*5);
echo("M4 bolt x12:", ceil((mdf_width+nut_wall)/5)*5);
echo("M3 bolt x8:", ceil((wall + 4)/5)*5);
echo("M2 screw x2:", ceil((wall + switch_size[2])/5)*5);

