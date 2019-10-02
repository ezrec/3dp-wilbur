
mm = 1.0;
in = 25.4;

fn = 120;

module bearing_surface(od = 10 * mm, id = 5 * mm, surfaces = 4)
{
    difference()
    {
        union()
        {
            // Outer wall
            difference()
            {
                circle(d = od, $fn=fn);
                circle(d = od - (od - id) * 1 / 3, $fn=fn);
            }

            // Surfaces
            for (a = [0:surfaces-1])
            {
                a1 = a * 360/surfaces;
                a2 = a1 + 360/surfaces/2;
                polygon([[0,0], [od/2 * cos(a1), od/2 * sin(a1)], [od/2 * cos(a2), od/2 * sin(a2)]]);
            }
        }
        
        circle(d = id, $fn = fn);
    }
}

module lm_bearing(h=10, id=5, od=10, surfaces=6)
{
    linear_extrude(height=h/2, twist = h)
    {
        bearing_surface(od=od, id=id * 0.975, surfaces = surfaces);
    }
    mirror([0, 0, 1]) linear_extrude(height=h/2, twist = h)
    {
        bearing_surface(od=od, id=id * 0.975, surfaces = surfaces);
    }
}

module lm8uu()
{
    lm_bearing(h=24*mm, od=15*mm, id=8*mm, surfaces=13);
}

module lm10uu()
{
    lm_bearing(h=29*mm, od=19*mm, id=10*mm, surfaces=15);
}

lm8uu();