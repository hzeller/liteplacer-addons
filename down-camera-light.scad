// quite hacky ...

$fn=96;
epsilon=0.02;

// TODO: these values are guesses; we need measurements.

led_dia=40 + 0.3;     // Diameter of LED ring.
led_inner=28;         // Inner diameter (for display purposes only)
led_pcb_edge=1;       // Free edge around LEDs to hold around the board

led_thick=4;          // thickness of led ring.
led_pcb_thick=1.8;

led_holder_thick = led_thick + 2;
led_holder_wall_thick=1;

cone_len=30;           // <= camera length
diffusor_pos=[10,20];  // position from top for diffusor inserts

mount_hole_distance=30;  // Distance between mounting holes
mount_hole_dia=6;
mount_bracket_wide = mount_hole_distance + mount_hole_dia + 6;

wall_thickness=0.4;
mount_wall_thickness=2;

hood_widening = 10;   // how much hood is wider on the bottom than LED
brim_width=2;        // slight widening at the very bottom.

// for reference: the led ring.
module led_ring() {
    difference() {
	cylinder(r=led_dia/2,h=led_pcb_thick);
	translate([0,0,-epsilon]) cylinder(r=led_inner/2,h=3+2*epsilon);
    }
}

module led_holder() {
    difference() {
	hull() {
	    // Outer frame
	    cylinder(r=led_dia/2 + led_holder_wall_thick,h=led_holder_thick);
	    // square back
	    translate([0, -led_dia/2-led_holder_wall_thick, 0]) mount_bracket_base(height=led_holder_thick);
	}

	// Cut the inner diameter
	translate([0,0,-epsilon]) cylinder(r=led_dia/2 - led_pcb_edge,h=led_holder_thick+2*epsilon);
	// Cut the slide-in for the LED pcb.
	translate([0, 0, (led_holder_thick-led_pcb_thick)/2+1]) cylinder(r=led_dia/2,h=led_pcb_thick);
	
	// Only leave back part, cut away front.
	translate([-led_dia/2 - led_holder_wall_thick,0,-epsilon]) cube([led_dia + 2*led_holder_wall_thick + 2*epsilon, led_dia/2+led_holder_wall_thick+epsilon, led_thick+4]);
    }

    // Display LED ring for reference.
    %translate([0, 0, (led_holder_thick-led_pcb_thick)/2+1]) led_ring();
}

// Making a rectangle with a rounded corner.
module rounded_corner_rect(w=10,h=10,r=5,height=1) {
    hull() {
	translate([(w-2*r)/2,(h-2*r)/2,0]) cylinder(r=r,h=height);
	translate([(w-2*r)/2,-(h-2*r)/2,0]) cylinder(r=r,h=height);
	translate([-(w-2*r)/2,(h-2*r)/2,0]) cylinder(r=r,h=height);
	translate([-(w-2*r)/2,-(h-2*r)/2,0]) cylinder(r=r,h=height);
    }
}

module filled_cone(extra=0) {
    hull() {
	// top
	translate([0,0,extra]) cylinder(r=led_dia/2+led_holder_wall_thick-wall_thickness, h=epsilon);
	// bottom
	translate([0,0,-cone_len-extra]) rounded_corner_rect(led_dia + hood_widening, led_dia+hood_widening, height=epsilon);
    }
}

module outer_cone(thick=wall_thickness) {
    minkowski() {
	filled_cone();
	cylinder(r=thick,h=epsilon,$fn=12);
    }
}

module cone() {
    difference() {
	union() {
	    hull() {
		translate([0, -led_dia/2-led_holder_wall_thick, 0]) mount_bracket_base(height=epsilon);
		outer_cone();
	    }
	    // Now, let's add a little stabilizing apron at the bottom
	    hull() {
		translate([0,0,-cone_len]) rounded_corner_rect(led_dia + hood_widening+brim_width, led_dia+hood_widening+brim_width, height=epsilon);
		translate([0,0,-cone_len+brim_width]) cut_at_height_inner(cone_len - brim_width);
	    }
	}
	filled_cone(extra=2*epsilon);
    }
}

module mount_bracket_base(wide=mount_bracket_wide, height=2) {
    translate([-wide/2, 0, 0]) cube([wide, mount_wall_thickness, height]);
}

module mount_bracket(height=20) {  // we have 20mm profile
    difference() {
	mount_bracket_base(height=height);
	rotate([-90,0,0]) translate([0,0,-epsilon]) {
	    translate([mount_hole_distance/2,-height/2,0]) cylinder(r=mount_hole_dia/2,h=mount_wall_thickness+2*epsilon);
	    translate([-mount_hole_distance/2,-height/2,0]) cylinder(r=mount_hole_dia/2,h=mount_wall_thickness+2*epsilon);
	}
    }
}

module diffusor_cutout() {
    cube([100,5,1], center=true);
    cube([5,100,1], center=true);
}

module assembly_without_diffusor() {
    led_holder();
    cone();
    translate([0, -led_dia/2-led_holder_wall_thick, led_holder_thick-epsilon]) mount_bracket();
}

module assembly() {
    difference() {
	assembly_without_diffusor();
	for (i = diffusor_pos) {
	    translate([0,0,-i]) diffusor_cutout();
	}
    }
}

// More for visual
module cut_at_height_inner(pos=10) {
    translate([0,0,pos]) intersection() {
	filled_cone();
	translate([0,0,-pos]) cube([100,100,epsilon], center=true);
    }
}

module inner_led_transition(length=3) {
    // Fill..
    difference() {
	hull() {
	    translate([0,0,-length]) cut_at_height_inner(pos=length);
	    cylinder(r=led_dia/2 + led_holder_wall_thick,h=epsilon);
	}
	// cut away the transition to cone
	hull() {
	    translate([0,0,-length-epsilon]) cut_at_height_inner(pos=length);
	    translate([0,0,epsilon]) cylinder(r=led_dia/2 - led_pcb_edge, h=epsilon);
	}
    }
}
module print() {
    assembly();
    inner_led_transition(5);
}

print();
//translate([0,0,-29]) cut_at_height(29);