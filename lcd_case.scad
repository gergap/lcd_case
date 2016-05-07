// LCD case parameters
// Author: Gerhard Gappmeier <gappy1502@gmx.net>

// screws: M3
screw_diam=3;
nut_diam=5.5;
nut_height=3;
delta=0.1; // make it a little bigger
// case size
WIDTH=157; // x-dir
HEIGHT=85; // y-dir
DEPTH=22;  // z-dir
BOTTOM_WALL_THICKNESS=2;
TOP_WALL_THICKNESS=2;
BOTTOM_HEIGHT=10;
PCB_MOUNT_HEIGHT=5; // + BOTTOM_WALL_THICKNESS
TOP_HEIGHT=DEPTH-BOTTOM_HEIGHT;
ETA=0.05;
$fn=20;
// radius for rounded corners
ROUNDED_RADIUS=5;
// MAIN PCB
PCB_WIDTH=150;
PCB_HEIGHT=55.3;
PCB_OFFSET_Y=0;
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
explode=0;
show_top=0;
show_bottom=1;
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
    cylinder(r = w / 2 / cos(180 / 6) + delta, h=h+2*delta, $fn=6, center=true);
}

module nut_trap_cube(W=10, H=6) {
    difference() {
        cube([W,W,H], center=true);
        union() {
            translate([0,-W/2,0]) cube([nut_diam+2*delta,W,nut_height+2*delta], center=true);
            rotate([0,0,30]) nut_trap(nut_diam, nut_height);
        }
        cylinder(6,d=screw_diam+delta, center=true);
    }
}

border_height=2;
module bottom_border() {
    difference() {
        rounded_cube(WIDTH+ETA, HEIGHT+ETA, border_height);
        rounded_cube(WIDTH-3, HEIGHT-3, border_height+2*ETA);
    }
}

module bottom() {

    translate([0,0,BOTTOM_HEIGHT/2]) union() {
        difference() {
            rounded_cube(WIDTH, HEIGHT, BOTTOM_HEIGHT);
            translate([0,0,BOTTOM_WALL_THICKNESS]) rounded_cube(WIDTH-6, HEIGHT-6, BOTTOM_HEIGHT);
            translate([0,0,BOTTOM_HEIGHT/2-1+ETA]) bottom_border();
            // sd card cutout
            translate([-WIDTH/2,0,BOTTOM_WALL_THICKNESS-3/2]) cube([20,25,3], center=true);
        }
        // PCB mounting nut traps
        xoff=PCB_WIDTH/2-PCB_HOLE_OFFSET;
        yoff=PCB_HEIGHT/2-PCB_HOLE_OFFSET;
        translate([0,PCB_OFFSET_Y,BOTTOM_WALL_THICKNESS-PCB_MOUNT_HEIGHT/2]) {
            translate([-xoff,-yoff,0]) rotate([0,0,90]) nut_trap_cube(10, PCB_MOUNT_HEIGHT);
            translate([ xoff,-yoff,0]) rotate([0,0,-90]) nut_trap_cube(10, PCB_MOUNT_HEIGHT);
            translate([-xoff, yoff,0]) rotate([0,0,90]) nut_trap_cube(10, PCB_MOUNT_HEIGHT);
            translate([ xoff, yoff,0]) rotate([0,0,-90]) nut_trap_cube(10, PCB_MOUNT_HEIGHT);
        }
        // TOP mounting nut traps
        xoff2=WIDTH/2-15;
        yoff2=HEIGHT/2-7;
        translate([0,PCB_OFFSET_Y,BOTTOM_WALL_THICKNESS-PCB_MOUNT_HEIGHT/2]) {
            translate([-xoff2,-yoff2,0]) rotate([0,0,180]) nut_trap_cube(10, PCB_MOUNT_HEIGHT);
            translate([ xoff2,-yoff2,0]) rotate([0,0,180]) nut_trap_cube(10, PCB_MOUNT_HEIGHT);
            translate([-xoff2, yoff2,0]) rotate([0,0,0]) nut_trap_cube(10, PCB_MOUNT_HEIGHT);
            translate([ xoff2, yoff2,0]) rotate([0,0,0]) nut_trap_cube(10, PCB_MOUNT_HEIGHT);
        }
    }
}

module top() {
    translate([0,0,BOTTOM_HEIGHT+TOP_HEIGHT/2]) union() {
        difference() {
            rounded_cube(WIDTH, HEIGHT, TOP_HEIGHT);
            translate([0,0,-TOP_WALL_THICKNESS]) cube([WIDTH-6,HEIGHT-6,TOP_HEIGHT], center=true);
        }
    }
}

function main_pcb_z_offset() = BOTTOM_WALL_THICKNESS+PCB_MOUNT_HEIGHT+PCB_THICKNESS/2+ETA;

module main_pcb() {
    xoff=PCB_WIDTH/2-PCB_HOLE_OFFSET;
    yoff=PCB_HEIGHT/2-PCB_HOLE_OFFSET;
    zoff=main_pcb_z_offset();
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

function lcd_pcb_z_offset() = main_pcb_z_offset() + PCB_THICKNESS + 2.5 + ETA;

module lcd_pcb() {
    xoff=(LCD_PCB_WIDTH-PCB_WIDTH)/2+LCD_PCB_OFFSET_X;
    yoff=(PCB_HEIGHT-LCD_PCB_HEIGHT)/2-LCD_PCB_OFFSET_Y;
    zoff=lcd_pcb_z_offset();
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

// the LCD module
function lcd_z_offset() = lcd_pcb_z_offset() + LCD_THICKNESS/2 + ETA;
module lcd() {
    xoff=(LCD_WIDTH-PCB_WIDTH)/2+LCD_PCB_OFFSET_X+LCD_OFFSET_X;
    yoff=(PCB_HEIGHT-LCD_HEIGHT)/2-LCD_PCB_OFFSET_Y-LCD_OFFSET_Y;
    zoff=lcd_z_offset();
    color("gray") translate([xoff,yoff,zoff]) cube([LCD_WIDTH, LCD_HEIGHT, LCD_THICKNESS], center=true);
}

// complete LCD display including PCB
module lcd_display() {
    main_pcb();
    lcd_pcb();
    lcd();
}

// bottom part
if (show_bottom) {
    /*intersection() {*/
        translate([0,0,-explode*30]) difference() {
            bottom();
            translate([0,PCB_OFFSET_Y,0]) lcd_display();
        }
    /*    translate([-WIDTH/2,-HEIGHT/2,0]) cube([50,50,50], center=true);
    }*/
}

// top part
if (show_top) {
    translate([0,0,explode*30]) difference() {
        top();
        translate([0,PCB_OFFSET_Y,0]) lcd_display();
    }
}

// LCD display
if (show_lcd) {
    translate([0,PCB_OFFSET_Y,0]) lcd_display();
}

//translate([0,0,20]) nut_trap_cube();

