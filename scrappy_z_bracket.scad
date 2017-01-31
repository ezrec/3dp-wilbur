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
// vim: set shiftwidth=4 expandtab: //

inch = 25.4;

top_screw_distance = 5 * inch;

bottom_screw_distance = (9 + 7/8) * inch;

vertical_screw_distance = 2 * inch;

bottom_screw_height = 1.5 * inch;

top_margin = (5 + 5/8) * inch;
bottom_height = (1 + 3/4) * inch;
middle_margin = 7.75 * inch;
middle_height = (3 + 3/8) * inch;
total_height = 3.75 * inch;
total_width = 10.25 * inch;
total_length = 150;

drill_tolerance = 0.25;

screw_diameter = 1/8 * inch;

wall = 3;

fn=30;

module drill(d=3, h=1, tolerance=drill_tolerance)
{
    translate([0, 0, -0.1]) cylinder(d=d + tolerance*2, h=h+0.2, $fn =fn);
}


module screw_holes()
{
    translate([0, wall, bottom_screw_height])
    {
        translate([-top_screw_distance/2, 0, vertical_screw_distance])
            rotate([90, 0, 0]) drill(d=screw_diameter, h=20);
        translate([top_screw_distance/2, 0, vertical_screw_distance])
            rotate([90, 0, 0]) drill(d=screw_diameter, h=20);
        translate([-bottom_screw_distance/2, 0, 0])
            rotate([90, 0, 0]) drill(d=screw_diameter, h=20);
        translate([bottom_screw_distance/2, 0, 0])
            rotate([90, 0, 0]) drill(d=screw_diameter, h=20);
    }
}

mounting_diameter = 1 * inch;

hardware=true;

module mounting_rods()
{
    distance = sqrt(pow((bottom_screw_distance - top_screw_distance)/2, 2) +
                    pow(vertical_screw_distance, 2));
    angle = atan(vertical_screw_distance / (bottom_screw_distance - top_screw_distance) * 2);
    linear_extrude(center=false, height=total_length, twist=40, slices=100)
            translate([-bottom_screw_distance/2, bottom_screw_height]) rotate([0, 0, angle])
            translate([distance * 0.1, -wall*2.5]) circle(d=wall*4);
    linear_extrude(center=false, height=total_length, twist=25, slices=100)
        translate([-bottom_screw_distance/2, bottom_screw_height]) rotate([0, 0, angle])
            translate([distance * 0.9, -wall*2.5]) circle(d=wall*4);
}

module mounting_bracket_of(cut=false)
{
    if (!cut) {
        // Bulk of the bracket
        rotate([90, 0, 0])
        {
            translate([0, 0, -wall]) linear_extrude(height=wall) intersection()
            {
                union() {
                    translate([-total_width/2, 0])
                        square([total_width, bottom_height]);
                    translate([-middle_margin/2, 0])
                        square([middle_margin, middle_height]);
                    translate([-top_margin/2, 0])
                        square([top_margin, total_height]);
                }
                translate([0, bottom_screw_height]) hull()
                {
                    translate([-top_screw_distance/2, vertical_screw_distance])
                        circle(d = mounting_diameter);
                    translate([-bottom_screw_distance/2, 0])
                        circle(d = mounting_diameter);
                }
            }
        
            distance = sqrt(pow((bottom_screw_distance - top_screw_distance)/2, 2) +
                            pow(vertical_screw_distance, 2));
            angle = atan(vertical_screw_distance / (bottom_screw_distance - top_screw_distance) * 2);
            
            // Stiffening ridge
            hull()
            {
                translate([-bottom_screw_distance/2, bottom_screw_height]) rotate([0, 0, angle])
                    translate([distance * 0.1, -wall*2.5]) cylinder(d2=wall, d1=wall*4, h=wall*4);
                translate([-bottom_screw_distance/2, bottom_screw_height]) rotate([0, 0, angle])
                    translate([distance * 0.9, -wall*2.5]) cylinder(d2=wall, d1=wall*4, h=wall*4);
            }
            
            // Lip
            linear_extrude(height=wall*3) 
                translate([-top_margin/2, total_height-wall]) square([mounting_diameter, wall*3]);
            
            // Mounting
            mounting_rods();
            
            rotate([-90, 0, 0]) translate([0, 0, total_height-wall]) linear_extrude(height=wall) hull() {
                projection(cut=true) translate([0, 0, -total_height]) rotate([90, 0, 0]) mounting_rods();
            }
        }
    }
    else
    {
        translate([-total_width, -total_width*2-wall*3, total_height])
            cube([total_width*2, total_width*2, total_height]);
        translate([-total_width, -total_width*2-wall, total_height])
            cube([total_width*2, total_width*2, 1/8 * inch]);
    } 
        
}

module mounting_bracket()
{
    difference()
    {
        mounting_bracket_of(cut=false);
        mounting_bracket_of(cut=true);
        screw_holes();
    }

}

module scrappy_z_bracket_left()
{
    mounting_bracket();
}

module scrappy_z_bracket_right()
{
    mirror([1, 0, 0]) mounting_bracket();
}

module scrappy_z_standoff()
{
    difference()
    {
        cylinder(d=1/4 * inch, h = 1/8 * inch, $fn = fn);
        translate([0, 0, -0.1]) cylinder(d=1/8 * inch, h = 1/8 * inch + 0.2, $fn = fn);
    }
}

scrappy_z_bracket_left();

scrappy_z_bracket_right();

if (hardware)
{
    % translate([-total_width/2, -12*inch-wall, total_height])
        cube([total_width, 12*inch, wall]);
}