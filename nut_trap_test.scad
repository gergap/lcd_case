use<lcd_case.scad>;

ETA=0.01;
DELTA=0.1;
$fn=50;

difference() {
    translate([0,0,4]) cube([15,15,8], center=true);
    translate([0,0,1.5]) nut_trap(5.5, 3);
    translate([0,0,-ETA]) nut_trap_phase(5.5,0.5);
    cylinder(11, d=3+DELTA, center=false);
}

