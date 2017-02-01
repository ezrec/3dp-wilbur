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

wall = 2.5;

switch_width = 25;
switch_drill = 13;

ibm_box=[19, 27];
ibm_screw_distance=34.5;

internal_width = max(switch_width, ibm_box[1]);

box=[112, 25 + internal_width + wall, 51];

wiring = [10, 5];

fn=30;

module power_box_of(cut=false)
{
    if (!cut)
    {
        translate([-box[0]/2-wall, 0, -wall])
            cube([box[0]+wall*2, box[1]+wall, box[2]+wall*2]);
    }
    else
    {
        // Bulk cutout
        translate([-box[0]/2, -0.01, 0])
            cube([box[0], box[1] + 0.01, box[2]]);
        
        // Bolt cuts
        translate([-box[0]/2-wall-0.1, 25 - 5, box[2] - 17]) {
            rotate([0, 90, 0]) cylinder(d=4.25, h=wall+0.2, $fn=fn);
            translate([0, 0, 11])
                rotate([0, 90, 0]) cylinder(d=4.25, h=wall+0.2, $fn=fn);
        }
        
        // Switch cutout
        translate([0, 25 + internal_width/2, box[2]-0.1])
            cylinder(d=switch_drill, h = wall + 0.2, $fn=fn);
        
        // Wiring cutouts
        translate([-wiring[0]/2, box[1]-0.1, box[2]/2 - wiring[1]/2])
            cube([wiring[0], wall+0.2, wiring[1]]);
        
        // Bolt-on connection
        r=20*sin(45);
        translate([0, box[1]-0.1, box[2]/2]) {
            for (b = [0:3]) {
                rotate([0, 45+90*b, 0]) rotate([-90, 0, 0]) translate([r, 0, 0]) cylinder(d=4.25, h = wall+0.2, $fn=fn);
            }
        }    
        
        
        
        // IBM connector cutout
        translate([-box[0]/2-wall-0.1, 25 + internal_width/2, box[2]/2])
        {
            translate([0, - ibm_box[0]/2, - ibm_box[1]/2])
                cube([wall+0.2, ibm_box[0], ibm_box[1]]);
            translate([0, 0, -ibm_screw_distance/2])
                rotate([0, 90, 0]) cylinder(d=3.25, h=wall+0.2, $fn=fn);
            translate([0, 0, ibm_screw_distance/2])
                rotate([0, 90, 0]) cylinder(d=3.25, h=wall+0.2, $fn=fn);
        }
    }
}
        

module scrappy_power_box()
{
    difference()
    {
        power_box_of(cut=false);
        power_box_of(cut=true);
    }
}

scrappy_power_box();

// vim: set shiftwidth=4 expandtab: //
