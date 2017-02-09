
MKDIR ?= mkdir -p
OPENSCAD ?= openscad

SCAD := \
	scrappy.scad \
	scrappy_z_bracket.scad \
	scrappy_z_clip.scad \
	scrappy_power_box.scad \
	scrappy_hotend_e3d.scad \
	scrappy_hotend_geeetech.scad

MODELS := \
    scrappy_bearing_cap.stl \
    scrappy_bearing_sleeve.stl \
    scrappy_y_motor_min.stl \
    scrappy_y_motor_max.stl \
    scrappy_x_cap.stl \
    scrappy_sled.stl \
    scrappy_block.stl \
    scrappy_y_rail_cap.stl \
    scrappy_z_bracket_left.stl \
    scrappy_z_bracket_right.stl \
    scrappy_z_clip.stl \
    scrappy_z_standoff.stl \
    scrappy_z_endstop_holder.stl \
    scrappy_power_box.stl \
    scrappy_hotend_geeetech_peek.stl \
    scrappy_sensor_geeetech_peek.stl \
    scrappy_hotend_e3d_v6.stl \
    scrappy_sensor_e3d_v6.stl \
    scrappy_stiffener_clip.stl


all: $(MODELS:%=stl/%)

clean:
	$(RM) $(MODELS:%=stl/%)

stl-%.scad: $(SCAD)

stl-%.scad:
	echo >$@
	for d in $(SCAD); do echo "use <$$d>" >>$@; done
	echo "$*();" >>$@

stl/%.stl: stl-%.scad
	@$(MKDIR) stl
	openscad -o $@ -D hardware=false $^
