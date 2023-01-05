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
import math
import cadquery as cq
from build123d import *
from hardware import *

MATERIAL_COLOR = {
    "metal": "steelblue",
    "mdf": "wheat",
    "plastic": "green",
}


def show_all(obj: Compound, materials=None):
    if obj is None:
        return
    color = "gray"
    if hasattr(obj, "material"):
        if materials is None or obj.material in materials:
            color = MATERIAL_COLOR.get(obj.material, "yellow")
        else:
            color = None
    assy = cq.Assembly()
    if color is not None:
        assy.add(cq.Shape.cast(obj.wrapped),
                 name=obj.label,
                 color=cq.Color(color))
    if hasattr(obj, "joints"):
        for joint in obj.joints.values():
            name = None
            if obj.label is not None:
                name = obj.label + ":" + joint.label
            assy.add(cq.Compound.cast(joint.symbol.wrapped),
                     name=name)
            for child in joint.connected_to:
                show_all(child.parent, materials=materials)
    show_object(assy, name=obj.label)


def stl_all(obj: Compound, materials=None):
    if obj is None:
        return
    color = "gray"
    if hasattr(obj, "material"):
        if materials is None or obj.material in materials:
            color = MATERIAL_COLOR.get(obj.material, "yellow")
        else:
            color = None
    if color is not None:
        obj.export_stl(f"stl/wilbur_{obj.label}.stl")
    if hasattr(obj, "joints"):
        for joint in obj.joints.values():
            for child in joint.connected_to:
                stl_all(child.parent, materials=materials)


# Rods
rod_diameter = 8 * MM
rod_length = 400 * MM

# Rails
rail_length = 500 * MM

# Stack-up from 8mm rod center


class Stackup(object):
    def __init__(self,
                 idler=GT2Idler(),
                 pulley=GT2Pulley(),
                 belt=GT2Belt(),
                 rod=Rod(rod_diameter / 2, rod_length),
                 rod_pillow=BearingSC8UU(),
                 tolerance=0.35 * MM,
                 rail=LinearRail(),
                 rail_pillow=LinearPillow(),
                 vslot = VSlot2020(),
                 nema=Nema17()):
        self.tolerance = tolerance

        # Reference objects
        self.belt = belt
        self.idler = idler
        self.pulley = pulley
        self.rod_pillow = rod_pillow
        self.rail_pillow = rail_pillow
        self.rod = rod
        self.rail = rail
        self.nema = nema
        self.vslot = vslot

        # Clearances
        self.clearance_rod = 0.25 * MM
        self.clearance_pillow = 0.25 * MM
        self.tolerance_belt = 0.35 * MM

        # Walls
        self.wall_rod = 2 * MM
        self.wall_bolt = 2 * MM
        self.wall_vslot = 2 * MM

        # Critical dimensions
        self.gap_bearing = 2 * MM
        gap_rod_by_bearing = (self.rod.shaft[0] + self.gap_bearing + self.idler.bearing[1] +
                              self.gap_bearing / 2) * 2
        gap_rod_by_pillow = (self.rod_pillow.size[0] / 2) * 2
        self.gap_pillow_pillow = 4 * MM
        self.gap_rod = max(gap_rod_by_pillow + self.gap_pillow_pillow, gap_rod_by_bearing)
        self.gap_rod_pillow = 10 * MM  # self.idler.shaft[0] + self.belt.thickness / 2

        self.gap_rail_rod = 0 * MM
        self.gap_rail_belt = 5 * MM
        self.gap_vslot_belt = 11 * MM

        self.gap_lr_tool = max(BoltM(3).knurl.inset[1],
                               self.rod_pillow.bolt.head[1] + self.wall_bolt)

        # Stackup in Z ('above' bed)

        # Stackup in X (front to back)

        # Stackup in Y (left to right)

# MDF Parts


class MDFPanel(Compound):
    def __init__(self, x: float = 100, y: float = 100, s=Stackup(), **kwargs):
        with BuildPart() as part:
            with BuildSketch() as sk:
                with Locations((0, -y)):
                    Rectangle(x, y, align=(Align.CENTER, Align.MIN))
            Extrude(amount=s.mdf_thickness, mode=Mode.ADD)
        super().__init__(part.part.wrapped, **kwargs)
        self.material = "mdf"
        self.bolt = bolt

# Plastic parts


class BearingShim(Compound):
    def __init__(self, s=Stackup(), height=None, **kwargs):
        if height is None:
            height = s.bearing_gap

        with BuildPart() as part:
            with BuildSketch():
                Circle(7 * MM / 2)
                Circle(7 * MM / 2 - 0.8 * MM, mode=Mode.SUBTRACT)
            Extrude(amount=height)

        super().__init__(part.part.wrapped, **kwargs)
        self.material = "plastic"


class CarriageLR(Compound):
    """Left-to-Right carriage.

    Carries the tool head.
    Rides on the left-to-right upper and lower rods.
    """

    def __init__(self, s=Stackup(), **kwargs):
        pillow_offset = s.gap_rod_pillow
        self.offset = {
            "upper": -pillow_offset,
            "lower": pillow_offset,
        }
        upper_pillow = (-pillow_offset, s.gap_rod / 2)
        lower_pillow = (pillow_offset, -s.gap_rod / 2)
        width = (s.rod_pillow.size[1] / 2 + pillow_offset) * 2
        length = (s.rod_pillow.size[0] / 2 + s.gap_rod / 2) * 2
        belt_grip_width = (s.belt.height + s.idler.rim[1] + s.gap_bearing / 2) * 2
        belt_grip_height = 13.75 * MM

        with BuildPart(Plane.YZ, mode=Mode.PRIVATE) as part:
            Box(width / 2, length / 2, s.gap_lr_tool, align=(Align.MAX, Align.MIN, Align.MIN))
            front_face = part.faces().sort_by(Axis.X)[-1]
            back_face = part.faces().sort_by(Axis.X)[0]
            left_face = part.faces().sort_by(Axis.Y)[0]
            right_face = part.faces().sort_by(Axis.Y)[-1]
            with Workplanes(back_face):
                with Locations((0, back_face.width / 2)):
                    Box(back_face.length, s.gap_pillow_pillow / 2 - s.clearance_pillow, belt_grip_height,
                        align=(Align.CENTER, Align.MAX, Align.MIN))

            with Workplanes(left_face):
                with Locations((0, -left_face.width / 2, 0)):
                    bx = Box(s.gap_lr_tool, belt_grip_width / 2, 5 * MM, align=(Align.CENTER, Align.MIN, Align.MIN))
                back_face = bx.faces().sort_by(Axis.X)[0]
                with Workplanes(back_face):
                    bx = Box(back_face.length, back_face.width, belt_grip_height,
                             align=(Align.CENTER, Align.CENTER, Align.MIN))
                    top_face = bx.faces().sort_by(Axis.Z)[-1]
                    bottom_face = bx.faces().sort_by(Axis.Z)[0]
                    with Workplanes(top_face.offset(-s.belt.height)):
                        with Locations((-top_face.length / 2 + s.rod_pillow.mount, 0, 0)):
                            with BuildSketch():
                                with Locations(Rotation(about_z=180)):
                                    s.belt.belt(9, tolerance=s.tolerance_belt, mirror=True,
                                                align=(Align.MIN, Align.CENTER))
                                with Locations((0, -1 * MM)):
                                    Rectangle(s.belt.thickness * 2, 100 * MM, align=(Align.CENTER, Align.MIN))
                            Extrude(amount=s.belt.height, mode=Mode.SUBTRACT)

            #Mirror(part.part, about=Plane.XY)
            Mirror(part.part, about=Plane.XZ)

            with Workplanes(Plane.YZ.offset(s.gap_lr_tool)):
                # Dividing Line
                with BuildSketch():
                    with GridLocations(20, 20, 2, 2):
                        Circle(BoltM(3).knurl.inset[0])
                    Rectangle(1000, 0.25)
                Extrude(amount=-100, mode=Mode.SUBTRACT)

                with Locations(upper_pillow, lower_pillow):
                    with GridLocations(*s.rod_pillow.mount_pattern, 2, 2):
                        CounterBoreHole(radius=s.rod_pillow.bolt.shaft[0],
                                        counter_bore_radius=s.rod_pillow.bolt.head[0],
                                        counter_bore_depth=s.rod_pillow.bolt.head[1])

        super().__init__(part.part.wrapped, **kwargs)
        self.material = "plastic"

        mount_axis = (0, 90, 90)
        RigidJoint(label="upper", to_part=self,
                   joint_location=Location((0, -pillow_offset, s.gap_rod / 2), mount_axis))
        RigidJoint(label="lower", to_part=self,
                   joint_location=Location((0, pillow_offset, -s.gap_rod / 2), mount_axis))
        RigidJoint(label="tool", to_part=self,
                   joint_location=Location((s.gap_lr_tool, 0, 0)))


class CarriageFB(Compound):
    """Front-to-Back carriage.

    Carries the left-to-right upper and lower rods.
    Rides on the front-to-back rails.
    """

    def __init__(self, s=Stackup(), side="left", level="upper", **kwargs):
        mount_to_rail_base = 28 * MM
        rod_wall = s.wall_rod
        mount_wall = s.rail_pillow.bolt.head[1] + s.wall_rod
        bulk_width = 24 * MM
        bulk_length = s.rail_pillow.mount[1]
        cutout_depth = 28 * MM - 4 * MM + 0.5 * MM
        cutout_height = 7 * MM

        inset = 2.5 * MM

        rod_offset = mount_to_rail_base + s.gap_rail_rod
        belt_offset = mount_to_rail_base + s.gap_rail_belt
        outer_x_offset = belt_offset + s.idler.shaft[0]
        inner_x_offset = belt_offset + s.idler.shaft[0] * 2 + s.belt.thickness + s.idler.shaft[0]

        outer_y_offset = -s.idler.shaft[0] - s.belt.thickness / 2
        inner_y_offset = s.idler.shaft[0] + s.belt.thickness / 2

        idler_inner = Vertex(inner_x_offset, inner_y_offset, 0)
        idler_outer = Vertex(outer_x_offset, outer_y_offset, 0)

        offset_z = s.gap_bearing / 2 + s.idler.bearing[1] + s.gap_bearing / 2
        height_z = s.gap_rod / 2 + s.rod.shaft[0] + s.wall_rod
        bulk_height = height_z - offset_z

        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            # Bulk of the part
            with BuildSketch() as sk:
                with Locations((-mount_wall, 0, 0)):
                    Rectangle(bulk_width + mount_wall * 2, bulk_length, align=(Align.MIN, Align.CENTER))
                with Locations(idler_inner, idler_outer):
                    Circle(s.idler.bolt.head[0] + s.wall_bolt)
                MakeHull(mode=Mode.REPLACE)
            with Locations((0, 0, offset_z)):
                Extrude(*sk.faces(), amount=bulk_height)
            rear_face = part.faces().sort_by(Axis.X)[0]

            # Rear mount
            with Workplanes(rear_face.offset(-mount_wall)):
                Box(s.rail_pillow.mount[1], s.rail_pillow.mount[0] / 2 - 1 * MM,
                    mount_wall,
                    align=(Align.CENTER, Align.MIN, Align.MIN))

            # Cutout for rail pillow
            with Workplanes(rear_face.offset(-cutout_depth - mount_wall)):
                with Locations((0, rear_face.width / 2 - cutout_height, 0)):
                    Box(s.rail_pillow.mount[1], cutout_height, cutout_depth,
                        align=(Align.CENTER, Align.MIN, Align.MIN),
                        mode=Mode.SUBTRACT)
            Fillet(*part.edges().filter_by(Axis.Z), radius=1)

            # Top bolts locations
            with Workplanes(Plane.XY):
                with Locations(idler_inner, idler_outer):
                    with Locations((0, 0, offset_z + bulk_height)):
                        Hole(radius=s.idler.bolt.shaft[0])

            # Rear drills
            with Workplanes(rear_face):
                with Locations((0, rear_face.width / 2 - inset, 0)):
                    with GridLocations(*s.rail_pillow.mount_pattern, 2, 1):
                        CounterBoreHole(radius=s.rail_pillow.bolt.shaft[0],
                                        depth=mount_wall,
                                        counter_bore_radius=s.rail_pillow.bolt.head[0],
                                        counter_bore_depth=s.rail_pillow.bolt.head[1])

            # Rod drill
            with Workplanes(Plane.YZ.offset(26 * MM)):
                with Locations((0, s.gap_rod / 2)):
                    Cylinder(s.rod.shaft[0] + s.clearance_rod, s.rod.shaft[1],
                             align=(Align.CENTER, Align.CENTER, Align.MIN),
                             mode=Mode.SUBTRACT)
        
        if level == "lower":
            with BuildPart(mode=Mode.PRIVATE) as mirrored:
                Mirror(part.part, about=Plane.XY)
            part = mirrored

        if side == "right":
            with BuildPart(mode=Mode.PRIVATE) as mirrored:
                Mirror(part.part, about=Plane.YZ)
            part = mirrored

        super().__init__(part.part.wrapped, **kwargs)
        self.material = "plastic"

        mount_rotation = None
        low_z = -s.gap_bearing / 2 - s.idler.bearing[1]
        high_z = s.gap_bearing / 2
        if side == "left":
            mount_rotation = Rotation(about_x=90, about_z=90)
            sign = 1
            inner_z = low_z
            outer_z = high_z
            inner_level = "lower"
            outer_level = "upper"
        elif side == "right":
            mount_rotation = Rotation(about_x=90, about_z=-90)
            sign = -1
            inner_z = high_z
            outer_z = low_z
            inner_level = "upper"
            outer_level = "lower"

        idler_axis = (90, 0, 0)
        RigidJoint(label=f"idler_{inner_level}", to_part=self,
                   joint_location=Location((sign * inner_x_offset, inner_y_offset, inner_z), idler_axis))
        RigidJoint(label=f"idler_{outer_level}", to_part=self,
                   joint_location=Location((sign * outer_x_offset, outer_y_offset, outer_z), idler_axis))

        RigidJoint(label="mount", to_part=self, joint_location=mount_rotation)

        RigidJoint(label="upper", to_part=self,
                   joint_location=Location((sign * rod_offset, 0, s.gap_rod / 2)))
        RigidJoint(label="lower", to_part=self,
                   joint_location=Location((sign * rod_offset, 0, -s.gap_rod / 2)))


class IdlerBlock(Compound):
    def __init__(self, s: Stackup = Stackup(), side="left", **kwargs):

        wall = 4 * MM
        idler_span = (s.gap_bearing/2 + s.idler.bearing[1] + s.gap_bearing/2)*2
        part_height = idler_span + wall * 2
        low_z = -s.gap_bearing / 2 - s.idler.bearing[1]
        high_z = s.gap_bearing / 2
        idler_rail_offset = s.gap_rail_belt + s.idler.shaft[0]
        idler_vslot_offset = s.gap_vslot_belt + s.idler.shaft[0]
        vslot_wall = s.wall_vslot + s.vslot.bolt.head[1]

        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            Box(idler_rail_offset*2, vslot_wall, part_height/2, align = (Align.CENTER, Align.MIN, Align.MIN))
            with Workplanes(Plane.XY.offset(idler_span/2)):
                with BuildSketch() as sk:
                    Rectangle(idler_rail_offset*2, vslot_wall, align = (Align.CENTER, Align.MIN))
                    with Locations((0, idler_vslot_offset)):
                        Circle(s.idler.bolt.head[0] + s.wall_bolt)
                    MakeHull()
                Extrude(amount = wall)
            Mirror(part.part, about=Plane.XY)
            with Workplanes(Plane.ZX.offset(vslot_wall)):
                with GridLocations(1, 10, 1, 2):
                    CounterBoreHole(radius = s.vslot.bolt.shaft[0],
                                    counter_bore_radius = s.vslot.bolt.head[0],
                                    counter_bore_depth = s.vslot.bolt.head[1])
            with Workplanes(Plane.XY):
                with Locations((0, idler_vslot_offset)):
                    Hole(s.idler.bolt.shaft[0])
        super().__init__(part.part.wrapped, **kwargs)
        self.material = "plastic"

        side_offset = -idler_rail_offset
        if side == "right":
            side_offset *= -1

        rail_axis = (0, 90, 0)
        RigidJoint(label=f"vslot", to_part=self,
                   joint_location=Location((side_offset, 0, 0), rail_axis))

        idler_axis = (90, 0, 0)
        RigidJoint(label=f"idler_lower", to_part=self,
                   joint_location=Location((0, idler_vslot_offset, low_z), idler_axis))
        RigidJoint(label=f"idler_upper", to_part=self,
                   joint_location=Location((0, idler_vslot_offset, high_z), idler_axis))


class Nema17Plate(Compound):
    def __init__(self, **kwargs):
        length = 75 * MM
        width = 42 * MM
        height = 3 * MM
        nema_inset = width / 2
        bolt_inset = 31 * MM + 15 * MM / 2
        nema_radius = 22 * MM / 2
        mount_radius = 22 * MM
        with BuildPart(Plane.XY, mode=Mode.PRIVATE) as part:
            with BuildSketch() as sk:
                with Locations((0, length / 2 - nema_inset)):
                    Rectangle(width, length)
                    Fillet(*sk.vertices(), radius=3)
                Circle(nema_radius, mode=Mode.SUBTRACT)
                with PolarLocations(mount_radius, 4, start_angle=45, stop_angle=360 + 45):
                    Circle(3.2 * MM / 2, mode=Mode.SUBTRACT)
                with Locations((0, bolt_inset)):
                    gl = GridLocations(12.5 * MM, 15 * MM, 3, 2)
                    mount_grid = gl.locations
                    with gl:
                        Circle(5.1 * MM / 2, mode=Mode.SUBTRACT)
            Extrude(amount=height)

        super().__init__(part.part.wrapped, **kwargs)
        self.material = "metal"

        axis = (90, 0, 0)
        RigidJoint(label=f"mount_nema", to_part=self,
                   joint_location=Location((0, 0, 0), axis))

        axis = (0, 90, 0)
        for n in range(len(mount_grid)):
            location = mount_grid[n] * Location((0, 0, height), axis)
            RigidJoint(label=f"mount_{n}", to_part=self, joint_location=location)


def Wilbur():
    s = Stackup()

    # Toolhead
    tool_position = (-140, 150, 0)

    children = list()

    # Hardware
    tool = HermitCrab(label="toolhead")
    children += [tool]

    rod = {}
    for level in ("upper", "lower"):
        rod[level] = Rod(rod_diameter / 2, rod_length, label=f"rod_{level}")
        children += [rod[level]]

    rail = {}
    for side in ("left", "right"):
        rail[side] = LinearRail(label=f"rail_{side}")
        children += [rail[side]]

    rail_pillow = {}
    for side in ("left", "right"):
        rail_pillow[side] = LinearPillow(label=f"rail_pillow_{side}")
        children += [rail_pillow[side]]

    rod_bearing = {}
    for side in ("upper", "lower"):
        bearing = BearingSC8UU(label=f"sc8uu_rod_{side}")
        children += [bearing]
        rod_bearing[side] = bearing

    # FB carriage idlers
    fb_idler = {}
    for side in ("right", "left"):
        fb_idler[side] = {}
        for level in ("upper", "lower"):
            fb_idler[side][level] = GT2Idler(label=f"idler_fb_{side}_{level}")
            children += [fb_idler[side][level]]

    # Rail end idler block idlers
    ib_idler = {}
    for side in ("right", "left"):
        ib_idler[side] = {}
        for level in ("upper", "lower"):
            ib_idler[side][level] = GT2Idler(label=f"idler_ib_{side}_{level}")
            children += [ib_idler[side][level]]

    # V-slot extrusions
    fb_vslot = {}
    for endp in ("front", "back"):
        fb_vslot[endp] = VSlot2020(length=400 * MM, label=f"vslot_{endp}")
        children += [fb_vslot[endp]]

    # Nema17 steppers
    nema = {}
    for side in ("right", "left"):
        nema[side] = Nema17(label=f"nema_{side}")
        children += [nema[side]]

    # Nema17 mounting plate
    nema_plate = {}
    for side in ("right", "left"):
        nema_plate[side] = Nema17Plate(label=f"nema_plate_{side}")
        children += [nema_plate[side]]

    # Plastics
    carriage_lr = CarriageLR(label=f"carriage_lr")
    children += [carriage_lr]

    carriage_fb_u = {}
    for side in ("right", "left"):
        carriage_fb_u[side] = CarriageFB(side=side, level="upper", label=f"carriage_fb_u_{side}")
        children += [carriage_fb_u[side]]

    carriage_fb_l = {}
    for side in ("right", "left"):
        carriage_fb_l[side] = CarriageFB(side=side, level="lower", label=f"carriage_fb_l_{side}")
        children += [carriage_fb_l[side]]

    idler_block = {}
    for side in ("right", "left"):
        idler_block[side] = IdlerBlock(side=side, label=f"idler_block_{side}")
        children += [idler_block[side]]

    # Joint Attachments

    # Attach tool to L-R carriage
    carriage_lr.joints["tool"].connect_to(tool.joints["mount"])

    # Attach SC8UU bearings to L-R carriage
    for side, bearing in rod_bearing.items():
        carriage_lr.joints[side].connect_to(bearing.joints["mount"])

    # Attach upper and lower tods to SC8UU bearings
    for side, bearing in rod_bearing.items():
        bearing.joints["slide"].connect_to(rod[side].joints["slide"],
                                           angle=270,
                                           position=tool_position[0] + carriage_lr.offset[side])

    # Attach left and right F-B carriages to upper rod.
    for side in ("right", "left"):
        level = "upper"
        rod[level].joints[side].connect_to(carriage_fb_u[side].joints[level])

        # Attach left and right rail pillows to F-B carriages
        carriage_fb_u[side].joints["mount"].connect_to(rail_pillow[side].joints["mount"])
        rail_pillow[side].joints["mount"].connect_to(carriage_fb_l[side].joints["mount"])

        # Attach left and right rails to left and right rail pillows
        rail_pillow[side].joints["slide"].connect_to(rail[side].joints["slide"], position=tool_position[1])

        # Attach upper and lower idlers
        for level in ("upper", "lower"):
            carriage_fb_u[side].joints[f"idler_{level}"].connect_to(fb_idler[side][level].joints["mount"])

    # Attach right side to extrusions
    rail["right"].joints["right"].connect_to(fb_vslot["front"].joints["right"])
    rail["right"].joints["left"].connect_to(fb_vslot["back"].joints["right"])

    for side in ("right", "left"):
        # Attach V-slot front ends to idler blocks
        slot_position = fb_vslot["front"].length / 2
        if side == "left":
            slot_position *= -1
        fb_vslot["front"].joints[f"north"].connect_to(idler_block[side].joints["vslot"], position=slot_position)

        for level in ("upper", "lower"):
            idler_block[side].joints[f"idler_{level}"].connect_to(ib_idler[side][level].joints["mount"])

    # Attach Nema17 to mounting plate
    for side in ("right", "left"):
        slot_position = fb_vslot["back"].length / 2 - s.gap_rail_belt - s.pulley.shaft[0]
        if side == "right":
            slot_position *= -1
        fb_vslot["back"].joints[f"east"].connect_to(nema_plate[side].joints["mount_2"], position=slot_position)
        nema_plate[side].joints["mount_nema"].connect_to(nema[side].joints["axis"])

    return carriage_lr


if "show_object" in locals():
    materials = None
    result = None
    if False:
        result = IdlerBlock()
    elif False:
        rod = Rod(4, 80).moved(Location((0, 0, 30)))
        pillow = BearingSC8UU()
        rod.joints["slide"].connect_to(pillow.joints["slide"])
        result = rod
    else:
        result = Wilbur()

    if result is not None:
        show_all(result, materials)
else:
    stl_all(Wilbur(), materials=["plastic"])
