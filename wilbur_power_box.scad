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

use <Geeetech_LCD2004A.scad>;

hardware = true;

wall = 2.5;

switch_width = 25;
switch_drill = 13;

ibm_box=[19, 27];
ibm_screw_distance=34.5;

internal_width = max(switch_width, ibm_box[1]);

power_box_size=[112, 25 + internal_width + wall, 51];

wiring = [10, 5];

m4_nut_height = 3;
m4_nut_flat = 7;

fn=30;

module power_box_of(cut=false)
{
    box = power_box_size;
    
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
        

module wilbur_power_box()
{
    difference()
    {
        power_box_of(cut=false);
        power_box_of(cut=true);
    }
    
    if (hardware) %union()
    {
        r=20*sin(45);
        translate([0, power_box_size[1], power_box_size[2]/2]) {
            for (b = [0:3]) {
                rotate([0, 45+90*b, 0]) rotate([-90, 0, 0]) translate([r, 0, -m4_nut_height]) 
                {
                    cylinder(r=m4_nut_flat/sqrt(3), h = m4_nut_height, $fn=6);
                    translate([0, 0, wall+m4_nut_height]) cylinder(r=m4_nut_flat/sqrt(3), h = m4_nut_height, $fn=6);
                    cylinder(d=4, h = m4_nut_height+wall+15+0.2, $fn=fn);
                }
            }
        }    
    }
}

// Arduino board clearance 2D pattern
module arduino_clearance()
{
    tolerance = 0.5;
    
    lcd_clearance=10;
    ramps_clearance=60;
    
    h=40;
    
    width=101.6+lcd_clearance+tolerance*2;
    
    {
        // Arduino base board
        linear_extrude(height=h) 
            translate([0, ramps_clearance-53.3]) square([width, 53.3+tolerance*2]);
        
        translate([0, 0, 1]) linear_extrude(height=11.5) translate([0, ramps_clearance-53.3]) {
            // DIN Power connector (unused)
            * translate([tolerance-wall*2, 3])
                square([wall*2, 9]);
            
            // USB connector
            translate([tolerance-wall*2, 31.5])
                square([wall*2, 12.5]);
        }
        
        translate([0, 0, 12.5]) {
            // RAMPs board
            linear_extrude(height=h-12.5) 
                square([width, ramps_clearance+tolerance*2]);
            
            translate([0, 0, 1]) {
                // Power in
                linear_extrude(height=10.5) translate([tolerance-wall*2, 2])
                    square([wall*2, 22]);
                
            }
        }
    }
}

module arduino_post(d=3, wall=4, height=10)
{
    holes=[[14.0, 2.5],
           [15.3, 15.2+27.9+5.1+2.5],
           [14.0+1.3+50.8+24.1, 15.2+27.9+5.1+2.5],
           [14.0+1.3+50.8, 2.5+5.1+27.9],
           [14.0+1.3+50.8, 2.5+5.1],
           [14.0+82.5, 2.5]];
    
    lcd_clearance=10;
    
    translate([0, 60-53.3]) for (h=[0:5])
    {
        translate(holes[h]) cylinder(d1=d+wall*4, d2=d+wall, h=height, $fn=30);
    }
}

module arduino_drill(d=3, tolerance=0.5)
{
    holes=[[14.0, 2.5],
           [15.3, 15.2+27.9+5.1+2.5],
           [14.0+1.3+50.8+24.1, 15.2+27.9+5.1+2.5],
           [14.0+1.3+50.8, 2.5+5.1+27.9],
           [14.0+1.3+50.8, 2.5+5.1],
           [14.0+82.5, 2.5]];
    
    lcd_clearance=10;
    
    translate([0, 60-53.3]) for (h=[0:5])
    {
        translate(holes[h]) circle(d=d, $fn=30);
    }
}

control_box_size = [geeetech_lcd2004a_size()[0], 65, power_box_size[2]];

module lip_drill(d=3, h=5)
{
    linear_extrude(height=h) {
        translate([-control_box_size[0]/2+wall, wall])
            circle(d=d, $fn=30);
        translate([control_box_size[0]/2-wall, wall])
            circle(d=d, $fn=30);
        translate([-control_box_size[0]/2+wall, control_box_size[1]-wall])
            circle(d=d, $fn=30);
        translate([control_box_size[0]/2-wall, control_box_size[1]-wall])
            circle(d=d, $fn=30);
    }
}

arduino_x_clearance=1;
    
module control_box_of(cut=false)
{
    translate([0, wall, 0]) if (!cut)
    {
        difference()
        {
            union()
            {
                translate([-control_box_size[0]/2-wall, -wall, -wall])
                    cube([control_box_size[0]+wall*2, control_box_size[1]+wall, control_box_size[2]+wall*2]);
                translate([0, control_box_size[1]*2+wall*2-0.01, -wall]) 
                    rotate([0, 0, 180]) geeetech_lcd2004a_holder(wall=wall, height=control_box_size[2]+wall*2, width = control_box_size[1]+wall*2);
            }
            translate([-control_box_size[0]/2, 0, -wall-0.1])
                cube([control_box_size[0], control_box_size[1]+wall+0.01, control_box_size[2]+0.2]);
            translate([-control_box_size[0]/2, 0, 0])
                cube([control_box_size[0], control_box_size[1], control_box_size[2]+wall*2+0.1]);
        }
        
        lip_drill(d=3+wall*2, h=control_box_size[2]);
    }
    else
    {
        // Wiring cutouts
        translate([-wiring[0]/2, -wall-0.1, power_box_size[2]/2 - wiring[1]/2])
            cube([wiring[0], wall+0.2, power_box_size[2]]);
        
        
        translate([-control_box_size[0]/2+arduino_x_clearance, 5, wall*2])
            arduino_clearance();
        
        r=20*sin(45);
        translate([0, -wall, power_box_size[2]/2]) {
            for (b = [0:3]) {
                rotate([0, 45+90*b, 0]) rotate([-90, 0, 0]) translate([r, 0, 0]) 
                {
                    cylinder(d=4, h = wall+0.2, $fn=fn);
                }
            }

        }
        
        lip_drill(d=3.0, h=control_box_size[2]);
    }
}

module wilbur_control_box_base()
{
    translate([0, wall, 0]) difference()
    {
        union()
        {
            translate([-control_box_size[0]/2+0.25, 0.25, -wall])
                        cube([control_box_size[0]-0.5, control_box_size[1]+wall, wall]);
            translate([-control_box_size[0]/2+arduino_x_clearance, 5, -0.1])
                arduino_post(d=5, height=wall*2+0.1, wall=1);      
        }
        translate([-control_box_size[0]/2+arduino_x_clearance, 5, -wall])
            linear_extrude(height=wall*3+0.2) arduino_drill(d=2.8);
    
        translate([0, 0, -wall-0.1])
            lip_drill(d=3.25, h=wall+0.2);
    }

}

module wilbur_control_box()
{
    difference()
    {
        control_box_of(cut=false);
        control_box_of(cut=true);
    }
    
    if (hardware)
    {
        % translate([-control_box_size[0]/2+arduino_x_clearance, wall+5, wall*2]) arduino_clearance();
    }
}

module wilbur_control_box_lid()
{
    gap = 0.5;
    translate([0, 0, control_box_size[2]]) difference()
    {
        union()
        {
            // translate([0, 35, wall-0.01]) scale([0.5, 0.5, 0.5]) import("minion-dave.stl");
            translate([-control_box_size[0]/2+gap, wall + gap, -0.1])
                cube([control_box_size[0]-gap*2, control_box_size[1]-gap*2, wall+0.1]);
        }
        translate([0, wall, -0.1]) lip_drill(d=3.25, h=wall+1.2);
        translate([-control_box_size[0]/2, wall, -50])
            cube([control_box_size[0], control_box_size[1], 50]);
    }
}



wilbur_power_box();

translate([0, power_box_size[1]+wall+m4_nut_height*2, 0])
{
    wilbur_control_box();
    wilbur_control_box_base();
    wilbur_control_box_lid();    
}

// vim: set shiftwidth=4 expandtab: //
