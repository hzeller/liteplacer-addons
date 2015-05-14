// totally quick and dirty.
$fn=64;

w=42;
height=14;
epsilon=0.02;
screw_dia=5.2;
tight_screw_dia=3.2;
extension=33;   // how far the bracket extends out.

holder_thick=2.25;
tight_screw_nut_depth=holder_thick;   // how much nut sinks in.

nut_dia=6.5;
camera_hole_distance=20;
camera_max=10.5;
block=camera_max;  // holding block width.
adjust_x=1.5;     // adjust down from camera max.
adjust_y=3;       // for print_adjust()

module tight_screw() {
    rotate([0,90,0]) {
	cylinder(r=tight_screw_dia/2,h=w);
    }
}

module tight_screw_nut() {
    rotate([0,90,0]) {
	cylinder(r=nut_dia/2,h=(w-block)/2-holder_thick+tight_screw_nut_depth,$fn=6);
    }
}

module tight_pair(wiggle_room=0) {
    hull() {
	translate([-w/2,camera_hole_distance+(camera_max+tight_screw_dia)/2+3,height/2]) tight_screw();
	translate([-w/2,camera_hole_distance+(camera_max+tight_screw_dia)/2+3+wiggle_room,height/2]) tight_screw();
    }
    translate([-w/2,camera_hole_distance+(camera_max+tight_screw_dia)/2+3,height/2]) tight_screw_nut();
    
    hull() {
	translate([-w/2,camera_hole_distance-(camera_max+tight_screw_dia)/2-3,height/2]) tight_screw();
	translate([-w/2,camera_hole_distance-(camera_max+tight_screw_dia)/2-3+wiggle_room,height/2]) tight_screw();
    }
    translate([-w/2,camera_hole_distance-(camera_max+tight_screw_dia)/2-3,height/2]) tight_screw_nut();
}

module left_bracket() {
    difference() {
	translate([-42/2,0,0]) union() {
	    cube([w,3,height]);   // backplane
	    cube([(w-adjust_x)/2,6,height]);   // thick part
	    
	    translate([-block/2,0,0]) translate([w/2-holder_thick,0,0]) cube([holder_thick,extension,height]);
	}
	translate([-16, -1, height/2]) rotate([-90,0,0]) cylinder(r=screw_dia/2, h=10);
	translate([16, -1, height/2]) rotate([-90,0,0]) cylinder(r=screw_dia/2, h=10);
    }
}

module right_bracket() {
    difference() {
	union() {
	    translate([adjust_x/2,3,0]) cube([(w-adjust_x)/2,3,height]);
	    translate([block/2,3,0]) cube([holder_thick,extension-3,height]);
	}
	hull() {
	    translate([16, -1, height/2]) rotate([-90,0,0]) cylinder(r=screw_dia/2, h=10);
	    translate([16+adjust_x , -1, height/2]) rotate([-90,0,0]) cylinder(r=screw_dia/2, h=10);
	}
    }
}

module holder(left=true,shorter=0) {
    difference() {
	if (left) {
	    translate([-block/2,6+shorter,0]) cube([(block-adjust_x)/2,extension-6-shorter,height]);
	} else {
	    translate([adjust_x/2,6+shorter,0]) cube([(block-adjust_x)/2,extension-6-shorter,height]);
	}
	translate([0,camera_hole_distance,-epsilon]) cylinder(r=camera_max/2, h=height+2*epsilon);
    }
}

module non_adjust_left() {
    difference() {
	union() {
	    left_bracket();
	    color("red") holder(left=true);
	}
	tight_pair();
    }
}

module non_adjust_right() {
    difference() {
	union() {
	    color("blue") right_bracket();
	    color("green") holder(left=false);
	}
	tight_pair();
    }
}

module print_non_adjust() {
    non_adjust_left();
    translate([5,5,0]) non_adjust_right();
}

module adjust_left_bracket() {
    difference() {
	left_bracket();
	tight_pair();
    }
}
module adjust_right_bracket() {
    difference() {
	right_bracket();
	tight_pair();
    }
}

module adjust_left_holder() {
    difference() {
	holder(left=true,shorter=adjust_y);
	tight_pair(wiggle_room=adjust_y);
    }
}

module adjust_right_holder() {
    difference() {
	holder(left=false,shorter=adjust_y);
	tight_pair(wiggle_room=adjust_y);
    }
}

//
module print_adjust() {
    adjust_left_bracket();
    translate([2,0,0]) color("green") adjust_left_holder();

    translate([10,5,0]) color("blue") adjust_right_bracket();
    translate([2,0,0]) color("red") adjust_right_holder();
}

/* For adjustable bracket */
/*
camera_hole_distance=21;
holder_thick=3;           // needs to be stronger
extension=36;
block=camera_max + 1.5;  // holding block width.
tight_screw_nut_depth=holder_thick/2;   // how much nut sinks in.
print_adjust();
*/
/* end adjustable bracket */

// Non adjustable bracket.
print_non_adjust();
