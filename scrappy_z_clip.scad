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

inch = 25.4;

mdf_width = 16;
mdf_length = 405;
mdf_tolerance = 0.2*2;

clip_tolerance = 0.2*3;

// Wall size (structural)
wall = 4;

module scanner_clip_cut()
{
    scale([inch, inch]) {
        polygon([[0,0],[-100,-0],[-100,-100],[0.12 + clip_tolerance/inch,-100],[0.12+clip_tolerance/inch,0],[0.15+clip_tolerance/inch,1], [0.05, 1]]);
        translate([0.1 + clip_tolerance/inch/2, 1]) circle(d=0.1 + clip_tolerance/inch, $fn=30);
    }
}

module mdf_cut()
{
   translate([-mdf_tolerance, -mdf_tolerance])
        square([mdf_width + mdf_tolerance*2, 100]);
}

module scrappy_z_clip(h=1*inch)
{
    linear_extrude(height=h) difference()
    {
        union()
        {
            translate([-wall-0.15*inch-wall, -wall])
                square([wall+0.15*inch+wall+wall+mdf_width+wall, wall+1*inch+wall]);
            translate([-0.15*inch/2-wall*0.5, 1*inch+wall])
                scale([1, 0.75]) circle(d=0.15*inch+wall*3, $fn=30);
        }
        translate([-0.15*inch-wall*1.25, -0.01])
            scanner_clip_cut();
        translate([wall, 0])
            mdf_cut();
    }
}

scrappy_z_clip(h=1*inch);

// vim: set shiftwidth=4 expandtab: //
