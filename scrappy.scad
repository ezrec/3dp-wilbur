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
press_tolerance = 0.1 * mm;

belt_width = 6 * mm;
belt_thickness = 2 * mm;
belt_tolerance = 0.25 * mm;

m4_nut_flat=7 * mm;
m4_nut_height=3.5 * mm;

m8_nut_flat = 13 * mm;
m8_nut_height = 7 * mm;

drill_tolerance=0.25 * mm;
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

mdf_x_offset = y_belt_gap/2 + bearing_diameter/2 + rod_pocket;

module drill(d=3, h=1, tolerance=drill_tolerance)
{
    translate([0, 0, -0.1]) cylinder(d=d + tolerance*2, h=h+0.2, $fn =fn);
}

switch_size = [10 * mm, 4.3 * mm, 3.75 * mm];

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
    translate([0, switch_size[1]/2, switch_size[2]/2-0.5])
    {
        cube([switch_size[0]+0.2, switch_size[1]+0.2, switch_size[2]+0.2], center=true);
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
			cylinder(d=15 * mm, h=1, $fn=fn);
		   cylinder(d=13 * mm, h=5 *mm, $fn=fn);
		}
	   drill(d=4 * mm, h = 5 * mm);
	}
}

module scrappy_bearing_cap(bottom=false, nut=true)
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

module scrappy_bearing_sleeve(bearing_sleeve_wall=1.6, tolerance=drill_tolerance)
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
        drill(h=h + (belt_width - bearing_width)/2, d=bearing_bore);
        translate([0, 0, -100.1])
            cylinder(h=m4_nut_height + 100, r=m4_nut_flat/sqrt(3) + drill_tolerance, $fn=6);
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

module rod_pocket_of(d=8, h=20, cut=false, adjustable=false)
{
    cd = d + rod_wall*2;
    
    rotate([0, 0, 180]) rotate([90, 0, 0]) translate([0, 0, -rod_pocket]) if (!cut) {
        cylinder(h=h, d=cd, $fn=fn);
        translate([-cd/2,-cd/2, 0]) 
            cube([cd, cd/2, h]);
    }
    else
    {
        drill(h=rod_pocket, d=d);
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
            drill(d=4, h=h);
        }
    }
}

module rod_pocket(d=8, h=20)
{
    difference()
    {
        rod_pocket_of(d=d,h=h,cut=false);
        rod_pocket_of(d=d,h=h,cut=true);
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

module lm8uu_bearing_of(h=40 * mm, cut=false)
{
    // LM8UU bearing
    id = 8 * mm;
    od = lm8uu_od;
    l = lm8uu_l;
    
    cd = od + rod_wall*2;
    
    translate([0, h/2, 0]) if (!cut)
    {
        translate([0, -h+rod_pocket, 0]) rod_pocket_of(d=od, h=h, cut=false);
    }
    else
    {
        rotate([90, 0, 0]) {
            translate([0, 0, -0.1])
                cylinder(d=id, h=h+0.2, $fn=fn);
            translate([0, 0, rod_wall])
                cylinder(d=od+2*grease_wall, h = l, $fn=fn);
            translate([0, 0, h-l-rod_wall])
                cylinder(d=od+2*grease_wall, h = l, $fn=fn);
            translate([-od/2-grease_wall, -cd/2-0.1, rod_wall])
                cube([od+grease_wall*2, cd/2, l]);
            translate([-od/2-grease_wall, -cd/2-0.1, h-l-rod_wall])
                cube([od+grease_wall*2, cd/2, l]);
        }
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
    if (y_belt_gap > bearing_holder_diameter)
    {
        translate([-mount_offset, guide_offset, -z_block_size/2])
            bearing_holder_of(h=z_block_size, cut=cut, teeth=true);
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

module scrappy_y_motor_max()
{
    y_motor();
}

module scrappy_y_motor_min()
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

module y_rail_cap_of(cut=false)
{
    // Rod holder for secondary rod
    translate([0, wall, -z_block_size/2-z_block_offset+rod_slide[1]/2]) {
        rotate([90, 0, 0]) {
            if (!cut) {
                cylinder(d=rod_slide[1]+rod_wall*2, h=y_mount_depth+wall);
            } else {
                translate([0, 0, rod_wall]) drill(d=rod_slide[1], h=y_mount_depth+wall);
            }
        }
    }
            
    // Zip clip
    translate([-mdf_width/2-wall, -wall, -z_block_size/2-z_block_offset-y_mount_height]) rotate([0, 0, 90])
    {
        if (!cut) {
             cube([wall*2, y_mount_depth, y_mount_height + wall]);
        } else union() {
            r = y_mount_depth;
            h = y_mount_height;
            w = wall*2;
            for (i=[1:3]) translate([w/2, r/2, h/4*i]) {
                translate([-r-w/2, 0, 0])
                    rotate([0, 90, 0])
                        drill(h=r*2+w, d=4);
                translate([-w/2+nut_wall, 0, 0])
                    rotate([0, -90, 0])
                        cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=r, $fn=6);
                translate([w/2-nut_wall, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=r, $fn=6);
            }                   }
    }
    
    // Bracket to attach to the MDF
    translate([0, 0, -z_block_size/2 - z_block_offset])
        y_mount_of(cut=cut);    
}

module scrappy_y_rail_min()
{
    difference()
    {
        y_rail_cap_of(cut=false);
        y_rail_cap_of(cut=true);
    }
}

module scrappy_y_rail_max()
{
    mirror([0, 1, 0]) scrappy_y_rail_min();
}

module x_cap_of(cut=false)
{
    x_size = rod_pocket+nut_wall+m4_nut_height+rod_wall*2;
    
    if (!cut) hull() {
        translate([0, -x_rod_gap/2, 0]) rotate([0, 0, -90])
            rod_pocket_of(d=rod_y[1], h=rod_pocket+nut_wall+m4_nut_height+rod_wall*2, adjustable=true, cut=cut);
        
        translate([0, x_rod_gap/2, 0]) rotate([0, 0, -90])
            rod_pocket_of(d=rod_y[1], h=rod_pocket+nut_wall+m4_nut_height+rod_wall*2, adjustable=true, cut=cut);
    } else {
        translate([0, -x_rod_gap/2, 0]) rotate([0, 0, -90])
            rod_pocket_of(d=rod_y[1], h=rod_pocket+nut_wall+m4_nut_height+rod_wall*2, adjustable=true, cut=cut);
        
        translate([0, x_rod_gap/2, 0]) rotate([0, 0, -90])
            rod_pocket_of(d=rod_y[1], h=rod_pocket+nut_wall+m4_nut_height+rod_wall*2, adjustable=true, cut=cut);
    }
    
    translate([-rod_pocket/2, -x_rod_gap/2+bearing_diameter/2, -z_block_size/2])
        bearing_holder_of(h=z_block_size, cut=cut);
    
    translate([-rod_pocket/2, x_rod_gap/2-bearing_diameter/2, -z_block_size/2])
        bearing_holder_of(h=z_block_size, cut=cut);
    
    // Remove some bulk
    if (cut) {
        translate([z_block_size/2+rod_wall+nut_wall-x_size/2, 0, -z_block_size/2])
            sphere(r=z_block_size-wall);
    }
}

module scrappy_x_cap()
{
    difference()
    {
        x_cap_of(cut=false);
        x_cap_of(cut=true);
    }
}

gt2_belt_thickness = 1 * mm;
gt2_belt_pitch = 2.0 * mm;
gt2_belt_tooth_radius = 0.8 * mm;
gt2_belt_compression = 0.1 * mm;

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
    delta_y=outside ? gt2_belt_tooth_radius - gt2_belt_compression : gt2_belt_commpression;
    translate([0, gt2_belt_compression+delta_y, 0]) square([l, gt2_belt_thickness - gt2_belt_compression]);
    for (i = [gt2_belt_pitch/2:gt2_belt_pitch:l])
    {
        translate([i, gt2_belt_tooth_radius])
            circle(r = gt2_belt_tooth_radius, $fn=fn);
    }
}

module gt2_belt_holder_of(h=10 * mm, teeth=10, cut=false, outside=true)
{
    r = gt2_belt_radius(teeth=teeth, angle=180)+gt2_belt_thickness;
    d = r*2+wall*2;
    
    if (!cut)
    {
        translate([-d/2, -d+wall, 0])
            cube([d/2, d, h]);
        translate([-d/2, -d/2+wall, 0]) cylinder(r=d/2, h=h);
    }
    else
    {
        translate([-d/2, 2*wall-d, h-belt_width])
            linear_extrude(height=belt_width + 0.1) {
                gt2_belt_line(l=d/2+gt2_belt_pitch, outside=outside);
                translate([0, r*2]) rotate([0, 0, 180]) {
                    rotate([180, 0, 0]) rotate([0, 0, 180]) gt2_belt_line(l=d/2+gt2_belt_pitch, outside=outside);
                    gt2_belt_arc(teeth=teeth, angle=180, outside=outside);
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

module scrappy_sled_of(cut=false)
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
        
        // Zip-tie points or bolt - 10mm apart, M4
        ziptie_spacing = 10 * mm;
        ziptie_drill = 4 * mm;
        translate([s_size[0]/2+0.1, -ziptie_spacing/2, ziptie_drill])
            rotate([0, -90, 0]) {
                drill(d=ziptie_drill, h = s_size[1]/2);
                translate([0, 0, 11])
                    cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h = s_size[1]/2-10, $fn=6);
            }
            
        translate([s_size[0]/2+0.1, ziptie_spacing/2, ziptie_drill])
            rotate([0, -90, 0]) {
                drill(d=ziptie_drill, h = s_size[1]/2);
                translate([0, 0, 11])
                    cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h = s_size[1]/2-10, $fn=6);
            }
    }
    
    // Bearing holder
    translate([-s_size[0]/2+bearing_holder_diameter/2, 0, -z_block_size/2])
            bearing_holder_of(h=z_block_size, cut=cut);
               
    // Teeth for the inside arc of the belt clip
    belt_teeth = 5;
    
    // Belt holders
    translate([s_size[0]/2, x_rod_gap/2-bearing_diameter, -z_block_size/2])
        gt2_belt_holder_of(teeth=belt_teeth, h=z_block_size + bearing_cap_height + belt_width, cut=cut);
    
    translate([s_size[0]/2, -(x_rod_gap/2-bearing_diameter), -z_block_size/2])
        mirror([0,1,0])
            gt2_belt_holder_of(teeth=belt_teeth, h=z_block_size + bearing_cap_height + belt_width, cut=cut);
    
    translate([0, -x_rod_gap/2, 0]) rotate([0, 0, 90])
        carriage_bearing_of(h=s_size[0], d=rod_x[1], cut=cut);
    
    translate([0, x_rod_gap/2, 0]) rotate([0, 0, 90])
        carriage_bearing_of(h=s_size[0], d=rod_x[1], cut=cut);

    // X-min detection switch mount
    translate([-s_size[0]/2-(bearing_holder_diameter/2-rod_wall)+switch_size[1], 0, -z_block_size/2])  {
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

module scrappy_sled()
{
    difference()
    {
        scrappy_sled_of(cut=false);
        scrappy_sled_of(cut=true);
    }

    if (hardware) {
        translate([-sled_size[0]/2-(bearing_holder_diameter/2-rod_wall)+switch_size[1], 0, -z_block_size/2+wall])
            rotate([0, 0, 90]) color([0, 0.8, 0.8]) switch();
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
    else
    {
        // Remove some bulk
        translate([0, 0, -z_block_size/2-0.1]) linear_extrude(height=z_block_size+0.2) hull() {
            x=(x_rod_gap/2-rod_y[1]/2-rod_wall)/2;
            r=min(y_belt_gap/4, x);
            translate([y_belt_gap/2, -x, 0]) circle(r=r);
            translate([y_belt_gap/2,  x, 0]) circle(r=r);
        }
    }
    
    translate([y_belt_gap/2, 0, 0])
    {
        translate([0, -x_rod_gap/2, 0]) rotate([0, 0, 90])
            rod_pocket_of(d=rod_x[1], h=rod_pocket, cut=cut);
        translate([0, x_rod_gap/2, 0]) rotate([0, 0, 90])
            rod_pocket_of(d=rod_x[1], h=rod_pocket, cut=cut);
    }
    
    lm8uu_bearing_of(h=x_rod_gap + bearing_holder_diameter, cut=cut);
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
y_travel = rod_y[0] - rod_pocket*2 - x_rod_gap - bearing_holder_diameter;
x_travel = x_length - sled_size[0] + mdf_width;

module scrappy(x_percent=0.0025, y_percent=0.0025)
{    
    translate([0, mdf_length/2, 0]) scrappy_y_motor_max();
    translate([0, -mdf_length/2, 0]) scrappy_y_motor_min();
    translate([0, y_travel * (y_percent - 0.5), 0]) {
        scrappy_block();
        translate([y_belt_gap/2, 0, 0])
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
echo("M4 bolt x9:", ceil((z_block_size+bearing_cap_height*2-m4_nut_height+bearing_width)/5)*5);
echo("M4 bolt x12:", ceil((mdf_width+nut_wall)/5)*5);
echo("M3 bolt x8:", ceil((wall + 4)/5)*5);
echo("M2 screw x2:", ceil((wall + switch_size[2])/5)*5);

