from build123d import *


class RatchetTeeth(Compound):
    def __init__(self, radius: float,
                 teeth: int,
                 height: float,
                 overlap: float = 0.5,
                 inner_radius=0,
                 lefthand=False, **kwargs):
        angle = 360 / teeth
        sign = 1
        if lefthand:
            sign = -1

        self.size = (radius, height)
        self.teeth = teeth

        flat_angle = angle * 0.25
        # Thick lower face
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            with BuildSketch() as sk1:
                with BuildLine() as lines:
                    l1 = Line((0, 0), (radius, 0))
                    l2 = JernArc(start=l1 @ 1,
                                 tangent=Vector((0, 1, 0)),
                                 radius=radius,
                                 arc_size=angle - flat_angle)
                    l3 = Line(l2 @ 1, l1 @ 0)
                MakeFace()
                if inner_radius > 0:
                    Circle(inner_radius, mode=Mode.SUBTRACT)
            # Thin upper face
            with BuildSketch() as sk2:
                with BuildLine() as lines:
                    l1 = Line((0, 0, height), (radius, 0, height))
                    l2 = JernArc(start=l1 @ 1,
                                 tangent=Vector((0, 1, 0)),
                                 radius=radius,
                                 arc_size=flat_angle)
                    l3 = Line(l2 @ 1, l1 @ 0)
                rotation = -overlap
                if lefthand:
                    rotation = 0 * overlap
                MakeFace(*[l.rotate(Axis.Z, rotation) for l in lines.wires()])
                if inner_radius > 0:
                    with Locations((0, 0, height)):
                        Circle(inner_radius, mode=Mode.SUBTRACT)
            # Generate tooth
            loft = Loft(mode=Mode.PRIVATE)
            with PolarLocations(0, teeth):
                Add(*loft.solids())

        super().__init__(part.part.wrapped)


class BeltRatchet(object):
    def __init__(self, teeth: int, height: float, increment: float, lefthand: bool = False, belt=GT2Belt()):
        self.belt = belt
        radius = teeth * increment / 2 / math.pi

        shaft = radius * 0.7
        self.teeth = RatchetTeeth(radius, teeth, height, inner_radius=shaft,
                                  lefthand=lefthand)
        self.size = self.teeth.size
        self.shaft = (shaft, self.size[1])

    def mount(self, lefthand=True):
        with Locations((0, 0, -self.size[1])):
            Cylinder(self.size[0], 1000, mode=Mode.SUBTRACT,
                     align=(Align.CENTER, Align.CENTER, Align.MIN))
            Add(self.teeth)
            Hole(self.shaft[0])
        with Locations((0, 0, 0)):
            with Locations((0, -self.size[0]),
                           (0, self.size[0] - self.belt.clearance)):
                with BuildSketch():
                    Rectangle(1000, self.belt.clearance, align=(Align.MAX, Align.MIN))
            Extrude(amount=self.belt.height + self.size[1], mode=Mode.SUBTRACT)


class ExampleBox(Compound):
    def __init__(self, s=Stackup(), teeth: int = 18, lefthand: bool = False):
        ratchet = BeltRatchet(teeth=teeth,
                              height=1.0 * MM,
                              increment=3.5 * MM,
                              belt=s.belt,
                              lefthand=lefthand)

        with BuildPart() as part:
            Box(ratchet.size[0] * 2 + 5 * MM,
                ratchet.size[0] * 2 + 5 * MM,
                4 * MM + ratchet.size[1] + s.belt.height + 3 * MM)
            top_face = part.faces().sort_by(Axis.Z)[-1]
            ratchet.mount()
            with Workplanes(top_face):
                Cone(ratchet.size[0], ratchet.size[0] + 2 * MM, 3 * MM,
                     align=(Align.CENTER, Align.CENTER, Align.MAX),
                     mode=Mode.SUBTRACT)
        super().__init__(part.part.wrapped, label=f"example_block")


class ExamplePeg(Compound):
    def __init__(self, s=Stackup(), teeth: int = 18, lefthand: bool = False):
        belt = s.belt

        tooth_height = 1 * MM
        increment = 3.5 * MM
        tolerance = 0.3 * MM
        radius = teeth * increment / 2 / math.pi
        ratchet = RatchetTeeth(radius=radius - tolerance,
                               teeth=teeth,
                               height=tooth_height,
                               inner_radius=0.6 * radius,
                               lefthand=lefthand)
        disk = 1 * MM

        pulley_radius = radius - belt.pulley_thickness
        with BuildPart() as part:
            Cylinder(ratchet.size[0], disk)
            top_face = part.faces().sort_by(Axis.Z)[-1]
            bottom_face = part.faces().sort_by(Axis.Z)[0]
            with Workplanes(bottom_face):
                Add(ratchet)
                Cylinder(0.6 * radius, ratchet.size[1], align=(Align.CENTER, Align.CENTER, Align.MIN))
            with Workplanes(top_face):
                with BuildSketch():
                    s.belt.pulley(radius=pulley_radius)
                    RegularPolygon(5 / math.sqrt(3) + 0.2 * MM, 6, mode=Mode.SUBTRACT)
                Extrude(amount=belt.height)

        super().__init__(part.part.wrapped, label=f"example_peg")
