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

use <E3D/v6_lite.scad>
use <mini_height_sensor.scad>

hardware=true;

e3d_v6_clamp_diameter = 12;
e3d_v6_clamp_height = 5.75;
e3d_v6_bulk_diameter = 16;

e3d_v6_bulk_length = 35.5;
e3d_v6_nozzle_height = 17;

m3_nut_flat=5.5;
m3_nut_height=2.25;

m4_nut_flat=7;
m4_nut_height=3.5;

drill_tolerance = 0.25;

wall = 3;

fn=30;

module drill(d=3, h=1, tolerance=drill_tolerance, fn=fn)
{
    translate([0, 0, -0.1]) rotate([0, 0, 30]) cylinder(d=d + tolerance*2, h=h+0.2, $fn =fn);
}

module e3d_v6_duct()
{
    import("E3D/V6.6_Duct.stl");
}

module hotend_e3d_v6_of(cut=false)
{
    if (!cut)
    {
        translate([-0.01, 0, e3d_v6_clamp_height/2]) cube([40+0.02, 40, e3d_v6_clamp_height], center=true);
        
        // Extra mounting bracket - front
        rotate([0, 0, -90]) translate([20-wall, -20, -10]) cube([wall, 40, 10+e3d_v6_clamp_height]);        
        
        rotate([0, 0, -180]) translate([20-wall, -20, -10]) cube([wall, 40, 10+e3d_v6_clamp_height]);        
        
        // Extra mounting bracket - rear
        rotate([0, 0, -90]) translate([-20, -20, -10]) cube([wall, 40, 10+e3d_v6_clamp_height]);        
    }
    else
    {
        // Cylinder drill
        translate([0, 0, -e3d_v6_bulk_length])
            drill(d=e3d_v6_bulk_diameter, h=e3d_v6_bulk_length);
        
        // Mounting slot
        rotate([0, 0, 90]) translate([0, 0, -0.01]) linear_extrude(height=e3d_v6_clamp_height+0.02) hull()
        {
            circle(d=e3d_v6_clamp_diameter + drill_tolerance*2+0.1);
            translate([0, -100, 0])
                circle(d=e3d_v6_clamp_diameter + drill_tolerance*2+0.1);
        }
        
        // M4 mounting holes, 20mm apart
        for (r = [0:90:270]) rotate([0, 0, 45+r]) translate([20*sin(45), 0, 0]) {
            drill(h=e3d_v6_clamp_height, d=4);
            translate([0, 0, -20])
                rotate([0, 0, 45+r]) cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=m4_nut_height/2+20+0.1, $fn=6);
        }
        
        // Front mounting bracket drills - 24mm, m3
        rotate([0, 0, -90]) translate([20-wall, 0, -5]) {
            translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
            translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
        }
        
        // Rear mounting bracket drills - 24mm, m3
        rotate([0, 0, 180]) translate([20-wall, 0, -5]) {
            translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
            translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
        }
        
        // Front mounting bracket drills - 24mm, m3
        rotate([0, 0, -90]) translate([-20, 0, -5]) {
            translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
            translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=5, d=3);
        }
        
        % translate([0, 0, -7.25]) rotate([0, 0, 180]) rotate([-90, 0, 0]) e3d_v6_duct();
    }
}

module scrappy_hotend_e3d_v6()
{
    difference()
    {
        hotend_e3d_v6_of(cut=false);
        hotend_e3d_v6_of(cut=true);
    }
}

module scrappy_sensor_e3d_v6()
{
    height=e3d_v6_bulk_length+e3d_v6_nozzle_height-7;
    translate([20+wall, 0, -height]) {
        difference()
        {
            translate([-wall, -20, 0])
                cube([wall, 40, height]);
            translate([-wall-0.01, 0, height-5]) {
                translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
                translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
            }
            translate([-wall, 0, 0])
                scale([wall, 40-wall/2, height*1.75]) sphere(r=0.5, $fn=fn*2);
        }

        translate([0, 0, -5]) rotate([0, 0, 90]) mini_height_sensor_mount();
    }
}

module fan_40mm_drill(h=11, d=3, fn=fn)
{
    translate([20-16, 20-16, 0]) drill(d=d, h=h, fn=fn);
    translate([20+16, 20-16, 0]) drill(d=d, h=h, fn=fn);
    translate([20-16, 20+16, 0]) drill(d=d, h=h, fn=fn);
    translate([20+16, 20+16, 0]) drill(d=d, h=h, fn=fn);
}

module fan_40mm_of(cut=false)
{
    if (!cut)
    {
        cube([40, 40, 11]);
    }
    else
    {
        translate([20, 20, 0]) drill(d=37.5, h = 11);
        fan_40mm_drill(h=11);
    }
}

module fan_e3d_v6_of(cut=false)
{
    angle = 55;
    fan_height = 2;
    fan_gap = 1.5;
    
    height=e3d_v6_bulk_length+e3d_v6_nozzle_height-7;
    translate([-20, 0, -height]) 
    {
        if (!cut)
        {
            translate([-wall, -20, 0]) {
                cube([wall, 40, height]);
                hull() {
                    translate([0, 0, -(7-fan_height)]) cube([wall, 40, -(40+(7-fan_height))*sin(-angle)]);
                    translate([-40*cos(-angle), 0, 0]) cube([40*cos(-angle), 40, 0.01]);
                }
            }
            translate([-wall-0.01, 0, height-5]) {
                translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
                translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
            }
        }
        else
        {
            translate([-wall-0.01, 0, height-5]) {
                translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
                translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
            }
            
            translate([-wall-40*cos(-angle), -20, 0]) rotate([0, -angle, 0])
            {
                translate([0, 0, -11]) fan_40mm_drill(h=22);
                translate([0, 0, -wall*2-m3_nut_height]) fan_40mm_drill(h=m3_nut_height, d=m3_nut_flat/sqrt(3)*2, fn=6);
            }
            
            hull()
            {
                translate([-wall-40*cos(-angle), -20, 0]) rotate([0, -angle, 0])
                {
                    translate([20, 20, 0]) cylinder(d=37.5, h=0.1);
                }
                translate([0, -20+2, -(7-fan_height)+1.5]) cube([0.1, 40-4, fan_gap]);
            }
        }
    
        if (hardware && !cut)
        {
            % translate([-wall-40*cos(-angle), -20, 0]) rotate([0, -angle, 0]) difference()
            {
                fan_40mm_of(false);
                fan_40mm_of(true);
            }
        }
    }
}    

module scrappy_fan_e3d_v6()
{
    difference()
    {
        fan_e3d_v6_of(cut=false);
        fan_e3d_v6_of(cut=true);
    }
}

scrappy_hotend_e3d_v6();
rotate([0, 0, -90]) scrappy_sensor_e3d_v6();
rotate([0, 0, -90]) scrappy_fan_e3d_v6();
if (hardware) %e3d_v6_lite();
// vim: set shiftwidth=4 expandtab: //
