#  'Wilbur' Core-XY and MDF framed FDM printer.
#
#  Copyright (C) 2023, Jason S. McMullan <jason.mcmullan@gmail.com>
#  All rights reserved.
#
#  Licensed under the MIT License:
#
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the "Software"),
#  to deal in the Software without restriction, including without limitation
#  the rights to use, copy, modify, merge, publish, distribute, sublicense,
#  and/or sell copies of the Software, and to permit persons to whom the
#  Software is furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included
#  in all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#  DEALINGS IN THE SOFTWARE.
#
import copy
import math
from build123d import *
import cadquery as cq

import OCP
import OCP.BRep
import OCP.TopoDS


class StlFaces(Compound):
    def __init__(self, filename: str, **kwargs):
        face = OCP.TopoDS.TopoDS_Face()
        stl = OCP.RWStl.RWStl.ReadFile_s(filename)
        brep = OCP.BRep.BRep_Builder()
        brep.MakeFace(face, stl)
        super().__init__(face, **kwargs)

# HarmitCrab


class HermitCrab(StlFaces):
    def __init__(self, **kwargs):
        super().__init__("HermitCrab/STL/HERMIT CRAB.stl", **kwargs)
        self.material = "metal"
        RigidJoint(label="mount", to_part=self,
                   joint_location=Location((29.5, 6, 24), (0, 0, -90)))


# Metal parts
class KnurlM(object):
    M3_INSET_DIAMETER = 3.7 * MM
    M3_INSET_HEIGHT = 4.5 * MM
    M3_OUTSET_DIAMETER = 5.5 * MM

    M4_INSET_DIAMETER = 5.3 * MM
    M4_INSET_HEIGHT = 8.5 * MM
    M4_OUTSET_DIAMETER = 6.4 * MM

    M5_INSET_DIAMETER = 6.1 * MM
    M5_INSET_HEIGHT = 9.5 * MM
    M5_OUTSET_DIAMETER = 6.5 * MM

    M = {
        30: (M3_INSET_DIAMETER, M4_INSET_HEIGHT, M3_OUTSET_DIAMETER),
        40: (M4_INSET_DIAMETER, M4_INSET_HEIGHT, M4_OUTSET_DIAMETER),
        50: (M5_INSET_DIAMETER, M5_INSET_HEIGHT, M5_OUTSET_DIAMETER),
    }

    def __init__(self, size: int):
        self.inset = (0, 0)
        self.outset = (0, 0)
        if int(size * 10) in self.M:
            m = self.M[int(size * 10)]
            self.inset = (m[0] / 2, math.ceil(m[1]))
            self.outset = (m[2] / 2, math.ceil(m[1]))
        else:
            raise ValueError(f"Unknown diameter {size}")


class BoltM(Compound):
    def __init__(self, size: float, length=0, **kwargs):
        self.shaft = (size / 2, length)
        self.head = (size * 2 / 2, size * 1.1)
        self.knurl = KnurlM(size)
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            Cylinder(*self.head)
            with Locations((0, 0, -length)):
                Cylinder(*self.shaft)
        super().__init__(part.part.wrapped, **kwargs)
        self.material = "metal"
        CylindricalJoint(label="head", to_part=self)


class Nema(Compound):
    def __init__(self, width=0, height=0,
                 shaft_diameter=0, shaft_height=0,
                 mount_radius=0, mount_bolt=BoltM(3),
                 **kwargs):
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            Box(width, height, width)
            box_top = part.faces().sort_by(Axis.Y)[-1]
            with Workplanes(box_top):
                Cylinder(shaft_diameter / 2, shaft_height, align=(Align.CENTER, Align.CENTER, Align.MIN))
            plane = Plane(box_top).rotated((0, 0, 45))
            with BuildSketch(plane):
                with PolarLocations(mount_radius, 4):
                    Circle(mount_bolt.shaft[0])
            Extrude(amount=height, mode=Mode.SUBTRACT)
        super().__init__(part.part.wrapped, **kwargs)
        self.material = "metal"
        self.width = width
        self.mount_bolt = mount_bolt
        self.mount_radius = mount_radius
        self.mount_wall = 3 * MM
        self.shaft = (shaft_diameter / 2, shaft_height)
        RigidJoint(label="axis", to_part=self,
                   joint_location=Location((0, height / 2, 0)))


class Nema17(Nema):
    def __init__(self, **kwargs):
        super().__init__(width=44 * MM,
                         height=44 * MM,
                         shaft_diameter=5 * MM,
                         shaft_height=22 * MM,
                         mount_radius=22 * MM,
                         mount_bolt=BoltM(3), **kwargs)


class Rod(Compound):
    def __init__(self, radius: float, length: float, **kwargs):
        self.shaft = (radius, length)
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as rod:
            with Locations(Rotation(about_y=90)):
                Cylinder(*self.shaft)
        super().__init__(rod.part.wrapped, **kwargs)
        self.material = "metal"
        RigidJoint(label="left",
                   to_part=self,
                   joint_location=Location((-length / 2, 0)))
        RigidJoint(label="right",
                   to_part=self,
                   joint_location=Location((length / 2, 0)))
        CylindricalJoint(label="slide",
                         to_part=self,
                         axis=Axis((0, 0, 0), (1, 0, 0)),
                         angle_reference=(0, 0, 1),
                         linear_range=(-length / 2, length / 2))


BEARING_SC8UU = Compound.import_step("SC8UU_6061.step").moved(Rotation(about_z=90)).moved(Rotation(about_y=90))


class BearingSC8UU(Compound):
    def __init__(self, **kwargs):
        super().__init__(copy.copy(BEARING_SC8UU).wrapped, **kwargs)
        self.material = "metal"
        self.mount = 11 * MM
        self.size = (34, 30)
        self.bolt = BoltM(4)
        self.mount_pattern = (18, 24)
        RigidJoint(label="slide", to_part=self,
                   joint_location=Rotation(about_y=90))
        RigidJoint(label="mount",
                   to_part=self,
                   joint_location=Location((0, 0, self.mount)))


class GT2Belt(object):
    def __init__(self):
        self.height = 6.5 * MM
        self.thickness = 1.38 * MM
        self.clearance = 2 * MM
        self.pulley_thickness = self.thickness - 0.75
        self.pitch = 2 * MM

        self.profile = [
            (-1, -0.63),
            (-1, 0),

            (-0.648009, 0.037218),
            (-0.598311, 0.130528),
            (-0.578605, 0.238423),
            (-0.547291, 0.343077),
            (-0.504797, 0.443762),
            (-0.451556, 0.53975),
            (-0.358229, 0.636924),
            (-0.2484, 0.707276),
            (-0.127259, 0.750044),
            (0, 0.76447),
            (0.127259, 0.750044),
            (0.2484, 0.707276),
            (0.358229, 0.636924),
            (0.451556, 0.53975),
            (0.504649, 0.443762),
            (0.547158, 0.343077),
            (0.578556, 0.238423),
            (0.598311, 0.130528),
            (0.647876, 0.037218),
            (1, 0),
            (1, -0.63),

        ]

    def belt(self, teeth: int, mirror=False, tolerance=0 * MM, **kwargs):
        profile = list(self.profile)
        profile[0] = (profile[0][0], profile[0][1] - tolerance)
        profile[len(profile) - 1] = (profile[len(profile) - 1][0], profile[len(profile) - 1][1] - tolerance)

        profiles = []
        sign = -1 if mirror else 1
        for n in range(teeth):
            x = (-self.pitch * teeth / 2 + self.pitch * (n + 0.5))
            profiles += [(p[0] + x, sign * p[1]) for p in profile]
        Polygon(*profiles, **kwargs)

    def pulley(self, teeth: int = 0, radius: float = 0):
        assert((teeth > 0 and not radius > 0) or
               (not teeth > 0 and radius > 0))

        # Shrink radius to fit.
        if radius > 0:
            teeth = int(math.pi / math.asin(self.pitch / 2 / radius))

        radius = self.pitch / 2 / math.sin(math.radians(180 / teeth))
        Circle(radius)
        with PolarLocations(radius, teeth):
            with Locations(Rotation(about_z=90)):
                Polygon(*self.profile, mode=Mode.SUBTRACT)


class GT2Idler(Compound):
    def __init__(self, **kwargs):
        self.bearing = (18 * MM / 2, 8.5)
        disk_width = 1 * MM
        self.shaft = (12 * MM / 2, self.bearing[1] - disk_width * 2)
        mount_diameter = 5 * MM
        self.rim = (self.bearing[0], disk_width)
        self.bolt = BoltM(5)
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            Cylinder(self.bearing[0], disk_width, align=(Align.CENTER, Align.CENTER, Align.MIN))
            with Locations((0, 0, disk_width)):
                Cylinder(*self.shaft, align=(Align.CENTER, Align.CENTER, Align.MIN))
            with Locations((0, 0, disk_width + self.shaft[1])):
                Cylinder(self.bearing[0], disk_width, align=(Align.CENTER, Align.CENTER, Align.MIN))
            with Workplanes(part.faces().sort_by(Axis.Z)[-1]):
                Hole(mount_diameter / 2)
        super().__init__(part.part.wrapped, **kwargs)
        self.material = "metal"
        RigidJoint(label="mount", to_part=self,
                   joint_location=Location((0, 0, 0), (90, 0, 0)))


class GT2Pulley(Compound):
    def __init__(self, **kwargs):
        self.size = (13 * MM / 2, 14 * MM)
        disk_width = 1 * MM
        self.shaft = (11 * MM / 2, 6 * MM)
        mount_diameter = 5 * MM
        self.bolt = BoltM(5)
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            Cylinder(self.size[0], disk_width, align=(Align.CENTER, Align.CENTER, Align.MIN))
            with Locations((0, 0, disk_width)):
                Cylinder(*self.shaft, align=(Align.CENTER, Align.CENTER, Align.MIN))
            with Locations((0, 0, disk_width + self.shaft[1])):
                Cylinder(self.size[0], self.size[1] - (disk_width + self.shaft[1]),
                         align=(Align.CENTER, Align.CENTER, Align.MIN))
            Hole(mount_diameter / 2)
        super().__init__(part.part.wrapped, **kwargs)
        self.material = "metal"
        RigidJoint(label="mount", to_part=self)


class LinearRail(Compound):
    PROFILE_NOMINAL = [(4.76, -8.44),
                       (4.76, -6.88),
                       (4.88, -6.6),
                       (5.1, -6.38),
                       (5.21, -6.15),
                       (6.74, -4.74),
                       (7.5, -3.98),
                       (7.5, -2.45),
                       (6.73, -1.68),
                       (5.21, -0.28),
                       (5.1, -0.05),
                       (5.04, 0.0),
                       (-5.04, 0.0),
                       (-5.1, -0.05),
                       (-5.21, -0.28),
                       (-6.73, -1.68),
                       (-7.5, -2.45),
                       (-7.5, -3.98),
                       (-6.74, -4.74),
                       (-5.21, -6.15),
                       (-5.1, -6.38),
                       (-4.88, -6.6),
                       (-4.76, -6.88),
                       (-4.76, -8.44),
                       (-4.88, -8.72),
                       (-7.2, -11.04),
                       (-7.5, -11.75),
                       (-7.49, -14.29),
                       (-6.79, -15.0),
                       (6.8, -15.0),
                       (7.5, -14.3),
                       (7.5, -11.75),
                       (7.2, -11.04),
                       (4.88, -8.72)]
    PROFILE = [(v[0], v[1] + 7.5) for v in PROFILE_NOMINAL]

    def __init__(self, h=15 * MM, length=500 * MM,
                 bolt_spacing=60 * MM,
                 bolt=BoltM(4),
                 **kwargs):
        self.bolt = bolt
        bolt_holes = (length // bolt_spacing) + 1
        bolt_offset = (length - (bolt_holes - 1) * bolt_spacing) / 2
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            with BuildSketch() as part_sk:
                with Locations((0, -7.5)):
                    Polygon(*LinearRail.PROFILE, align=None)
            Extrude(amount=length)
            with Workplanes(part.faces().sort_by(Axis.Y)[-1]):
                with GridLocations(0, bolt_spacing, 1, bolt_holes):
                    CounterBoreHole(radius=bolt.shaft[0],
                                    counter_bore_radius=bolt.head[0],
                                    counter_bore_depth=bolt.head[1],
                                    mode=Mode.SUBTRACT)
        super().__init__(part.part.wrapped, **kwargs)
        self.material = "metal"
        self.bolt_spacing = bolt_spacing
        self.size = (h, h)
        RigidJoint(label="left", to_part=self,
                   joint_location=Location((0, -h, bolt_offset)))
        RigidJoint(label="right", to_part=self,
                   joint_location=Location((0, -h, length - bolt_offset)))
        LinearJoint(label="slide", to_part=self,
                    axis=Axis((0, 0, length / 2), (0, 0, 1)),
                    linear_range=(-length / 2, length / 2))


# hsr15r
class LinearPillow(Compound):
    def __init__(self, width=34 * MM, length=60 * MM, height=24 * MM, offset=13 * MM,
                 bolt_pattern=(26 * MM, 26 * MM),
                 bolt=BoltM(4),
                 **kwargs):
        self.size = (width, length)
        self.bolt = bolt
        self.mount_pattern = bolt_pattern
        self.mount = (width, 39.6 * MM)
        top_face_inset = 4.6 * MM
        top_face_length = self.mount[1]
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            with Locations((0, -height + offset, 0)):
                Box(width, height - top_face_inset, length, align=(Align.CENTER, Align.MIN, Align.CENTER))
            with Workplanes(part.faces().sort_by(Axis.Y)[-1]):
                Box(top_face_length, width, top_face_inset, align=(Align.CENTER, Align.CENTER, Align.MIN))
            left_face = part.faces().sort_by(Axis.Z)[-1]
            top_face = part.faces().sort_by(Axis.Y)[-1]
            with Workplanes(left_face):
                with Locations((0, -height / 2 - (28 * MM - height) / 2 + 7.5)):
                    with BuildSketch() as sketch:
                        Polygon(*LinearRail.PROFILE)
                    Extrude(amount=-length, mode=Mode.SUBTRACT)
            with Workplanes(top_face):
                with GridLocations(*bolt_pattern, 2, 2):
                    Hole(bolt.shaft[0])
        super().__init__(part.part.wrapped, **kwargs)
        self.material = "metal"
        RigidJoint(label="slide", to_part=self)
        RigidJoint(label="mount", to_part=self,
                   joint_location=Location((0, offset, 0)))


class VSlot2020(Compound):
    def __init__(self, length=400 * MM, **kwargs):
        x_offset = -4.2 * MM / 2
        profile = cq.importers.importDXF("extra/v-slot-2020.dxf").wires().toPending().extrude(length).val()
        super().__init__(profile.wrapped, **kwargs)
        self.length = length
        self.material = "metal"
        self.bolt = BoltM(4)
        axis = (90, 0, 0)
        LinearJoint(label=f"north", to_part=self,
                    axis=Axis((x_offset + 0, 10, length / 2), (0, 0, 1)),
                    linear_range=(-length / 2, length / 2))
        LinearJoint(label=f"south", to_part=self,
                    axis=Axis((x_offset + 0, -10, length / 2), (0, 0, 1)),
                    linear_range=(-length / 2, length / 2))
        LinearJoint(label=f"east", to_part=self,
                    axis=Axis((x_offset + 10, 0, length / 2), (0, 0, 1)),
                    linear_range=(-length / 2, length / 2))
        LinearJoint(label=f"west", to_part=self,
                    axis=Axis((x_offset + -10, 0, length / 2), (0, 0, 1)),
                    linear_range=(-length / 2, length / 2))
        RigidJoint(label="left", to_part=self,
                   joint_location=Location((x_offset, 0, 0), axis))
        RigidJoint(label="right", to_part=self,
                   joint_location=Location((x_offset, 0, length), axis))
