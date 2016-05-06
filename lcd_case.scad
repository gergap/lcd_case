// LCD case parameters
// Author: Gerhard Gappmeier <gappy1502@gmx.net>

// case size
WIDTH=157;
DEPTH=75;
HEIGHT=22;
BOTTOM_WALL_THICKNESS=2;
TOP_WALL_THICKNESS=2;
BOTTOM_HEIGHT=7;
TOP_HEIGHT=HEIGHT-BOTTOM_HEIGHT;
ETA=0.01;
$fn=20;
// radius for rounded corners
ROUNDED_RADIUS=5;
// MAIN PCB
PCB_WIDTH=150;
PCB_HEIGHT=55.3;
PCB_OFFSET_Y=5;
PCB_THICKNESS=1.8;
PCB_HOLE_RAD=1.5;
PCB_HOLE_OFFSET=2.5;
// LCD PCB
LCD_PCB_WIDTH=98.4;
LCD_PCB_HEIGHT=60;
LCD_PCB_HOLE_RAD=1.8;
LCD_PCB_HOLE_OFFSET=2.7;
LCD_PCB_OFFSET_X=13.4;
LCD_PCB_OFFSET_Y=3;

// LCD cutout size and offset
LCD_WIDTH=97.2;
LCD_HEIGHT=39.9;
LCD_THICKNESS=10;
LCD_OFFSET_X=0.8;
LCD_OFFSET_Y=10.2;

// set to 1 for explode view, 0 otherwise
explode=1;
// set to 1 to display LCD and PCB, 0 otherwise
show_lcd=1;

// note: The case and the main PCB are centered.
// the LCD PCB and LCD are relative to the main PCB

module rounded_cube(x, y, z) {
    hull() {
        translate([-x/2+ROUNDED_RADIUS, -y/2+ROUNDED_RADIUS, 0]) cylinder(z, r=ROUNDED_RADIUS, center=true);
        translate([x/2-ROUNDED_RADIUS, -y/2+ROUNDED_RADIUS, 0]) cylinder(z, r=ROUNDED_RADIUS, center=true);
        translate([-x/2+ROUNDED_RADIUS, y/2-ROUNDED_RADIUS, 0]) cylinder(z, r=ROUNDED_RADIUS, center=true);
        translate([x/2-ROUNDED_RADIUS, y/2-ROUNDED_RADIUS, 0]) cylinder(z, r=ROUNDED_RADIUS, center=true);
    }
}

module nut_trap(w = 5.5, h = 3) {
    cylinder(r = w / 2 / cos(180 / 6) + 0.05, h=h, $fn=6, center=true);
}

module nut_trap_cube(W=10, H=5) {
    difference() {
        cube([W,W,H], center=true);
        translate([0,-W/2,0]) cube([6.5,W,3], center=true);
        nut_trap();
        cylinder(6,r=1.5, center=true);
    }
}

module bottom() {
    // mounting hole offsets
    xoff=PCB_WIDTH/2-PCB_HOLE_OFFSET;
    yoff=PCB_HEIGHT/2-PCB_HOLE_OFFSET;

    translate([0,0,BOTTOM_HEIGHT/2]) union() {
        difference() {
            rounded_cube(WIDTH, DEPTH, BOTTOM_HEIGHT);
            translate([0,0,BOTTOM_WALL_THICKNESS]) cube([WIDTH-6,DEPTH-6,BOTTOM_HEIGHT], center=true);
            // sd card cutout
            translate([-WIDTH/2,0,2.1]) cube([20,25,3], center=true);
        }
        // PCB mounting nut traps
        translate([0,PCB_OFFSET_Y,0]) {
            translate([-xoff,-yoff,1]) rotate([0,0,90]) nut_trap_cube(10, 5);
            translate([ xoff,-yoff,1]) rotate([0,0,90]) nut_trap_cube(10, 5);
            translate([-xoff, yoff,1]) rotate([0,0,90]) nut_trap_cube(10, 5);
            translate([ xoff, yoff,1]) rotate([0,0,90]) nut_trap_cube(10, 5);
        }
    }
}

module top() {
    translate([0,0,BOTTOM_HEIGHT+TOP_HEIGHT/2]) union() {
        difference() {
            rounded_cube(WIDTH, DEPTH, TOP_HEIGHT);
            translate([0,0,-TOP_WALL_THICKNESS]) cube([WIDTH-6,DEPTH-6,TOP_HEIGHT], center=true);
        }
    }
}

module main_pcb() {
    xoff=PCB_WIDTH/2-PCB_HOLE_OFFSET;
    yoff=PCB_HEIGHT/2-PCB_HOLE_OFFSET;
    zoff=BOTTOM_HEIGHT+PCB_THICKNESS/2+ETA;
    color("red") translate([0,0,zoff]) difference() {
        cube([PCB_WIDTH, PCB_HEIGHT, PCB_THICKNESS], center=true);
        translate([-xoff, -yoff, 0]) cylinder(PCB_THICKNESS+ETA, r=PCB_HOLE_RAD, center=true);
        translate([xoff, -yoff, 0]) cylinder(PCB_THICKNESS+ETA, r=PCB_HOLE_RAD, center=true);
        translate([-xoff, yoff, 0]) cylinder(PCB_THICKNESS+ETA, r=PCB_HOLE_RAD, center=true);
        translate([xoff, yoff, 0]) cylinder(PCB_THICKNESS+ETA, r=PCB_HOLE_RAD, center=true);
    }
    // beeper
    color("gray") translate([PCB_WIDTH/2-13,PCB_HEIGHT/2-10,zoff+(PCB_THICKNESS+9.3)/2]) cylinder(9.3,r=6,center=true);
    // poti
    color("gray") translate([PCB_WIDTH/2-13,PCB_HEIGHT/2-30,zoff+(PCB_THICKNESS+4.2)/2]) {
        cube([12,12,4.2],center=true);
        cylinder(25,d=6.1,center=false);
    }
    // reset button
    color("gray") translate([PCB_WIDTH/2-13,PCB_HEIGHT/2-47,zoff+(PCB_THICKNESS+4)/2]) {
        cube([6,6,4],center=true);
        translate([0,0,2.5]) cylinder(1.5,d=3.5,center=true);
    }
    // connector
    color("gray") translate([-PCB_WIDTH/2+45,PCB_HEIGHT/2-22,(BOTTOM_HEIGHT-PCB_THICKNESS)/2]) {
        cube([21,9,9],center=true);
    }
    color("gray") translate([-PCB_WIDTH/2+68,PCB_HEIGHT/2-22,(BOTTOM_HEIGHT-PCB_THICKNESS)/2]) {
        cube([21,9,9],center=true);
    }

}

module lcd_pcb() {
    xoff=(LCD_PCB_WIDTH-PCB_WIDTH)/2+LCD_PCB_OFFSET_X;
    yoff=(PCB_HEIGHT-LCD_PCB_HEIGHT)/2-LCD_PCB_OFFSET_Y;
    zoff=BOTTOM_HEIGHT+PCB_THICKNESS*1.5+2.5+ETA*2;
    hole_xoff=LCD_PCB_WIDTH/2-LCD_PCB_HOLE_OFFSET;
    hole_yoff=LCD_PCB_HEIGHT/2-LCD_PCB_HOLE_OFFSET;

    color("green") translate([xoff,yoff,zoff]) difference() {
        cube([LCD_PCB_WIDTH, LCD_PCB_HEIGHT, PCB_THICKNESS], center=true);
        translate([-hole_xoff, -hole_yoff, 0]) cylinder(PCB_THICKNESS+ETA, r=LCD_PCB_HOLE_RAD, center=true);
        translate([ hole_xoff, -hole_yoff, 0]) cylinder(PCB_THICKNESS+ETA, r=LCD_PCB_HOLE_RAD, center=true);
        translate([-hole_xoff,  hole_yoff, 0]) cylinder(PCB_THICKNESS+ETA, r=LCD_PCB_HOLE_RAD, center=true);
        translate([ hole_xoff,  hole_yoff, 0]) cylinder(PCB_THICKNESS+ETA, r=LCD_PCB_HOLE_RAD, center=true);
    }
}

module lcd() {
    xoff=(LCD_WIDTH-PCB_WIDTH)/2+LCD_PCB_OFFSET_X+LCD_OFFSET_X;
    yoff=(PCB_HEIGHT-LCD_HEIGHT)/2-LCD_PCB_OFFSET_Y-LCD_OFFSET_Y;
    zoff=BOTTOM_HEIGHT+PCB_THICKNESS*2+2.5+LCD_THICKNESS/2;
    color("gray") translate([xoff,yoff,zoff]) cube([LCD_WIDTH, LCD_HEIGHT, LCD_THICKNESS], center=true);
}

// complete LCD display
module lcd_display() {
    main_pcb();
    lcd_pcb();
    lcd();
}

translate([0,0,-explode*30]) difference() {
    bottom();
    translate([0,PCB_OFFSET_Y,0]) lcd_display();
}
translate([0,0,explode*30]) difference() {
    top();
    translate([0,PCB_OFFSET_Y,0]) lcd_display();
}

if (show_lcd) {
    translate([0,PCB_OFFSET_Y,0]) lcd_display();
}

