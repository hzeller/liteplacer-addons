// Funnel for the up-facing camera, to be mounted in the table.
// Right now, this is pretty quick and dirty, but works.
$fn=96;
epsilon=0.02;

wall_thick=1;           // Wall thickness of all parts
rounded_corner=10;      // radius of the rounded corner of the opening box
                        // Should be large enough to accomodate the router bit
camera_opening_per_distance = 40/50;  // Essentially the lens angle.
table_thick=50;
routed_edge=12;

led_dia=40;
led_inner=28;
led_opening=led_dia + 2;
second_diffusor=10;   // camera plane. Also second diffusor place; dist from LED.
M3_dia=3.2;

router_flush_bit_extra=0;  // Extra diameter of bearing around router flush bit.

diffusor_mount_dia=58;
diffusor_mount_hole_distance=diffusor_mount_dia/2 - 3;

// The camera starts at the second diffusor, so the opening should be
// so wide that from there to the top the table we have unobstructed view.
// But also, at least the diameter of the LED ring, so that we don't loose
// light.
width=max((table_thick - second_diffusor)*camera_opening_per_distance, led_opening);

// let's just make it square and don't worry about 1920/1080: The led-opening
// is the limiting part anyway.
height=width;


// For reference, the rough mount
module mount() {
    translate([-10,20,-40]) cube([100,20,40]);
    difference() {
	translate([-10,-10,-15-2]) cube([20,30,15]);
	translate([0,0,-20]) cylinder(r=10/2,h=20);
    }
    // The camera.
    translate ([0,0,second_diffusor]) {
	translate([0,0,-50]) cylinder(r=10/2,h=50);  // camera
	hull() {
	    cube([1,1*1080/1920,epsilon], center=true);
	    translate([0,0,60]) cube([60*camera_opening_per_distance,60*camera_opening_per_distance*1080/1920,epsilon], center=true);
	}
    }
}

// for reference: the led ring.
module led_ring() {
    translate([0,0,-3]) difference() {
	cylinder(r=led_dia/2,h=3);
	translate([0,0,-epsilon]) cylinder(r=led_inner/2,h=3+2*epsilon);
    }
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

module m3_screw() {
    cylinder(r=M3_dia/2+2,h=10);
    translate([0,0,-10+epsilon]) cylinder(r=M3_dia/2,h=10);
}

module support_cylinder(h=40) {
    intersection() {
	cylinder(r1=diffusor_mount_dia/2,r2=10,h=h);
	for (i = [0:10:360]) {
	    rotate([0,0,i]) cube([wall_thick, 100,100],center=true);
	}
    }
}

module filled_funnel(extra=0) {
    hull() {
	translate([0,0,-extra]) cylinder(r=led_opening/2,h=1);
	translate([0,0,table_thick+extra]) rounded_corner_rect(w=width, h=height, r=rounded_corner);
    }
}

module outer_funnel(thick=1) {
    minkowski() {
	filled_funnel();
	cylinder(r=thick,h=epsilon,$fn=12);
    }
}

module second_diffusor_mount() {
    // The wider block in the middle
    translate([0,0,second_diffusor-wall_thick]) cylinder(r=diffusor_mount_dia/2,h=2*wall_thick);
    translate([0,0,second_diffusor+wall_thick]) support_cylinder();
}

module diffusor_mount_with_holes() {
    difference() {
	color("blue") second_diffusor_mount();
	translate([0,0,second_diffusor]) {
	    for (i = [0:360/6:360]) {
		translate([cos(i)*diffusor_mount_hole_distance,
			   sin(i)*diffusor_mount_hole_distance,
			   wall_thick]) m3_screw();
	    }
	}
    }
}

module table_frame(h=wall_thick,extra=0) {
    rounded_corner_rect(width+2*routed_edge+extra,height+2*routed_edge+extra,r=rounded_corner,height=h);
}

module funnel_shell() {
    difference() {
	union() {
	    outer_funnel(thick=wall_thick);
	    diffusor_mount_with_holes();
	    translate([0,0,table_thick]) table_frame();
	}
	filled_funnel(extra=2*epsilon);
    }
}

// We do two funnel shells, but cut them apart at the second diffusor
// point. This is where we mount the second diffusor foil
module upper_part() {
    difference() {
	funnel_shell();
	translate([0,0,-50+second_diffusor]) cube([100,100,100], center=true);
    }
}

module lower_part() {
    difference() {
	funnel_shell();
	translate([0,0,+50+second_diffusor]) cube([100,100,100], center=true);
    }
}

module print() {
    translate([0,0,table_thick-second_diffusor+wall_thick]) rotate([180,0,0]) translate([0,0,-second_diffusor]) upper_part();
    rotate([180,0,0]) translate([70,0,-second_diffusor]) lower_part();
}

module assembled() {
    lower_part();
    upper_part();
    %led_ring();
    %mount();
}


// helper template to route out the space for the funnel to sit in the table.
module outer_router_template(height=4) {
    difference() {
	translate([0,0,height/2]) cube([80,80,height],center=true);
	translate([0,0,-1]) minkowski() {
	    table_frame(h=height+2);
	    cylinder(r=router_flush_bit_extra);
	}
    }
}

module inner_router_template(height=4) {
    difference() {
	minkowski() {
	    // -0.3 to fit 
	    table_frame(h=height,extra=2*-0.3);
	    cylinder(r=router_flush_bit_extra,h=epsilon);
	}
	translate([0,0,-1]) cylinder(r=diffusor_mount_dia/2,h=height+2);
    }
}

module router_templates(height=4) {
    color("blue") outer_router_template(height=height);
    // We print it next to each other to avoid sticking while printing.
    color("red") translate([82,0,0]) inner_router_template(height=height);
}

// One of these is useful.

//router_templates(height=19);  // 19mm ~ 3/4inch for the router bit we have.
print();
//assembled();
