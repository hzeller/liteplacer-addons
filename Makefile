all : up-camera-funnel.stl down-camera-light.stl camera-bracket.stl

%.stl: %.scad
	openscad -o $@ -d $@.deps $<

%.eps: %.svg
	inkscape -E $@ $<

%.dxf: %.eps
	pstoedit -psarg "-r300x300" -dt -f dxf:-polyaslines $< $@

clean:
	rm -f up-camera-funnel.stl
