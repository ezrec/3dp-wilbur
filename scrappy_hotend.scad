//
// Copyright (C) 2017, Jason S. McMullan <jason.mcmullan@gmail.com>
// All rights reserved.
//
// Licensed under the MIT License:
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
// All units are in mm

use <Geeetech/jhead_peek.scad>

geeetech_peek_clamp_diameter = 12;
geeetech_peek_clamp_height = 4.5;
geeetech_peek_bulk_diameter = 16;
geeetech_peek_bulk_length = 29;

geeetech_peek_nozzle_height = 16;

m4_nut_flat=7;
m4_nut_height=3.5;

drill_tolerance = 0.25;

blower_fan_mounting_radius = 49.5/2;
blower_fan_width = 19.5;
blower_fan_mounting_post_height = 7;
blower_fan_mounting_post_diameter = 6.5;
blower_fan_radius = 41/2;
blower_fan_airflow_radius = 29/2;
blower_out_height = 30.5;

wall = 3;

fn=30;

module drill(d=3, h=1, tolerance=drill_tolerance)
{
    translate([0, 0, -0.1]) cylinder(d=d + tolerance*2, h=h+0.2, $fn =fn);
}

module blower_fan_of(cut=false)
{
    if (!cut)
    {
        // Mounting posts
        translate([0, blower_fan_width/2 - blower_fan_mounting_post_height, blower_fan_radius])
        for (x=[0:2]) rotate([0, 45+x*90, 0]) translate([blower_fan_mounting_radius, 0, 0])
                rotate([-90, 0, 0]) cylinder(d=blower_fan_mounting_post_diameter, h=blower_fan_mounting_post_height, $fn=fn);
        
        // Mounting
        translate([-blower_fan_radius, blower_fan_width/2-0.1, 0])
            cube([blower_fan_radius*2, wall, blower_fan_radius*2]);
    }
    else
    {
        translate([0, -blower_fan_width/2, blower_fan_radius]) {
            rotate([-90, 0, 0]) cylinder(r=blower_fan_radius, h=blower_fan_width, $fn=fn);
            translate([0, 0, blower_fan_radius - blower_out_height])
                cube([blower_fan_radius, blower_fan_width, blower_out_height]);
        }
        
        // Mounting drills
        translate([0, blower_fan_width/2 - blower_fan_mounting_post_height, blower_fan_radius])
        for (x=[0:2]) rotate([0, 45+x*90, 0]) translate([blower_fan_mounting_radius, 0, 0])
                rotate([-90, 0, 0]) drill(d=3, h=blower_fan_mounting_post_height+100, $fn=fn);
        
        // Airflow
        translate([0, -blower_fan_width/2, blower_fan_radius])
            rotate([-90, 0, 0]) cylinder(r=blower_fan_airflow_radius, h=blower_fan_width+100+0.2, $fn=fn);
    }
}
            
module hotend_geeetech_peek_of(cut=false)
{
    if (!cut)
    {
        translate([0, 0, geeetech_peek_clamp_height/2]) cube([40, 40, geeetech_peek_clamp_height], center=true);
        hull()
        {
        translate([-20, 20-1, 0]) cube([40, 1,geeetech_peek_clamp_height ]);
        // Mounting
        translate([-blower_fan_radius - geeetech_peek_bulk_diameter/2 - wall, 0, -blower_fan_radius*2])
            translate([-blower_fan_radius, blower_fan_width/2-0.1, 0])
            cube([blower_fan_radius*2, 1, blower_fan_radius*2]);
        }
        
        // Extra mounting bracket
        translate([20-0.01, -20, -10]) cube([wall, 40, 10+geeetech_peek_clamp_height]);        
    }
    else
    {
        // Cylinder drill
        translate([0, 0, -geeetech_peek_bulk_length])
            drill(d=geeetech_peek_bulk_diameter, h=geeetech_peek_bulk_length);
        
        // Mounting slot
        translate([0, 0, -0.01]) linear_extrude(height=geeetech_peek_clamp_height+0.02) hull()
        {
            circle(d=geeetech_peek_clamp_diameter + drill_tolerance*2+0.1);
            translate([0, -100, 0])
                circle(d=geeetech_peek_clamp_diameter + drill_tolerance*2+0.1);
        }
        
        // M4 mounting holes, 20mm apart
        for (r = [0:90:270]) rotate([0, 0, 45+r]) translate([20*sin(45), 0, 0]) {
            drill(h=geeetech_peek_clamp_height, d=4);
            translate([0, 0, -20])
                rotate([0, 0, 45+r]) cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=m4_nut_height/2+20+0.1, $fn=6);
        }
        
        // Extra mounting bracket drills
        translate([20-0.01, 0, -5]) {
            translate([0, -10, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
            translate([0, 10, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
        }
    }
              
    translate([-blower_fan_radius - geeetech_peek_bulk_diameter/2 - wall, 0, -blower_fan_radius*2])
        blower_fan_of(cut);
 }

module scrappy_hotend_geeetech_peek()
{
    difference()
    {
        hotend_geeetech_peek_of(cut=false);
        hotend_geeetech_peek_of(cut=true);
    }
}

scrappy_hotend_geeetech_peek();
% geeetech_jhead_peek();
// vim: set shiftwidth=4 expandtab: //
