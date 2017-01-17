
MKDIR ?= mkdir -p
OPENSCAD ?= openscad

SCAD := \
	scrappy.scad

MODELS := \
    scrappy_bearing_cap.stl \
    scrappy_y_motor.stl \
    scrappy_y_cap.stl \
    scrappy_x_cap.stl \
    scrappy_sled.stl \
    scrappy_block.stl


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
