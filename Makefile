
MKDIR ?= mkdir -p
OPENSCAD ?= openscad

SCAD := \
	wilbur.scad \
	wilbur_power_box.scad \
	wilbur_hotend_e3d.scad \

MODELS := \
    wilbur_bearing_cap.stl \
    wilbur_bearing_sleeve.stl \
    wilbur_y_motor_min.stl \
    wilbur_y_motor_max.stl \
    wilbur_z_motor.stl \
    wilbur_z_edge.stl \
    wilbur_z_center.stl \
    wilbur_z_foot.stl \
    wilbur_z_cap.stl \
    wilbur_x_cap.stl \
    wilbur_sled.stl \
    wilbur_block.stl \
    wilbur_y_rail_min.stl \
    wilbur_y_rail_max.stl \
    wilbur_power_box.stl \
    wilbur_control_box.stl \
    wilbur_control_box_base.stl \
    wilbur_control_box_lid.stl \
    wilbur_hotend_e3d_v6.stl \
    wilbur_sensor_e3d_v6.stl \
    wilbur_fan_e3d_v6.stl


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
	$(OPENSCAD) -o $@ -D hardware=false $^
