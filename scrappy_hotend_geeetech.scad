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
use <mini_height_sensor.scad>

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

module hotend_geeetech_peek_of(cut=false)
{
    fan_angle = -14;
    
    if (!cut)
    {
        translate([-0.01, 0, geeetech_peek_clamp_height/2]) cube([40+0.02, 40, geeetech_peek_clamp_height], center=true);
        
        // Extra mounting bracket - rear
        translate([-20, 0, wall*sin(fan_angle)])
            rotate([0, fan_angle, 0]) 
                translate([0, -20, -10]) cube([wall, 40, 10+geeetech_peek_clamp_height]);        

        // Extra mounting bracket - front
        rotate([0, 0, -90]) translate([20, -15, -10]) cube([wall, 30, 10+geeetech_peek_clamp_height]);        
    }
    else
    {
        // Cylinder drill
        translate([0, 0, -geeetech_peek_bulk_length])
            drill(d=geeetech_peek_bulk_diameter, h=geeetech_peek_bulk_length);
        
        // Mounting slot
        rotate([0, 0, 90]) translate([0, 0, -0.01]) linear_extrude(height=geeetech_peek_clamp_height+0.02) hull()
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
        
        // Fan mounting bracket drills - 24mm, m3
        translate([-20, 0, wall*sin(fan_angle)]) {
            rotate([0, fan_angle, 0]) {
                translate([0, 0, -5]) {
                    translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
                    translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
                }
                translate([0, 0, -wall-30/2]) {
                    rotate([0, 90, 0]) {
                        drill(d=29, h=wall);
                        % translate([0, 0, -wall]) drill(d=29, h=wall);
                    }
                }
            }
        }
        
        // Front mounting bracket drills - 20mm, m3
        rotate([0, 0, -90]) translate([20, 0, -5]) {
            translate([0, -10, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
            translate([0, 10, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
        }
    }
}

module scrappy_hotend_geeetech_peek()
{
    difference()
    {
        hotend_geeetech_peek_of(cut=false);
        hotend_geeetech_peek_of(cut=true);
    }
}

module scrappy_sensor_geeetech_peek()
{
    height=geeetech_peek_bulk_length+geeetech_peek_nozzle_height-7;
    translate([20, 0, -height]) {
        difference()
        {
            translate([-wall, -20+5, 0])
                cube([wall, 30, height]);
            translate([-wall-0.01, 0, height-5]) {
                translate([0, -10, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
                translate([0, 10, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
            }
        }

        translate([0, 0, -5]) rotate([0, 0, 90]) mini_height_sensor_mount();
    }
}

scrappy_hotend_geeetech_peek();
rotate([0, 0, -90]) scrappy_sensor_geeetech_peek();
% geeetech_jhead_peek();
// vim: set shiftwidth=4 expandtab: //
