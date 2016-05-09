// LCD case parameters
// Author: Gerhard Gappmeier <gappy1502@gmx.net>

// screws: M3
screw_diam=3;
nut_diam=5.5;
nut_height=3;
delta=0.1; // make it a little bigger
// case size
WIDTH=158; // x-dir
HEIGHT=82; // y-dir
DEPTH=22;  // z-dir
BOTTOM_WALL_THICKNESS=2;
TOP_WALL_THICKNESS=2;
BOTTOM_HEIGHT=10;
PCB_MOUNT_HEIGHT=5; // + BOTTOM_WALL_THICKNESS
TOP_HEIGHT=DEPTH-BOTTOM_HEIGHT;
ETA=0.05;
$fn=40;
// radius for rounded corners
ROUNDED_RADIUS=5;
border_height=2;
// SDCARD HOLDER
SD_HOLDER_WIDTH=26;
SD_HOLDER_HEIGHT=26.5;
SD_HOLDER_DEPTH=3;
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
show_top=1;
show_bottom=1;
// set to 1 to display LCD and PCB, 0 otherwise
show_lcd=1;

// note: The case and the main PCB are centered.
// the LCD PCB and LCD are relative to the main PCB

// rounded cube: x/y centered, z_bottom=0
module rounded_cube(w, h, d) {
    hull() {
        translate([-w/2+ROUNDED_RADIUS, -h/2+ROUNDED_RADIUS, 0]) cylinder(d, r=ROUNDED_RADIUS, center=false);
        translate([w/2-ROUNDED_RADIUS, -h/2+ROUNDED_RADIUS, 0]) cylinder(d, r=ROUNDED_RADIUS, center=false);
        translate([-w/2+ROUNDED_RADIUS, h/2-ROUNDED_RADIUS, 0]) cylinder(d, r=ROUNDED_RADIUS, center=false);
        translate([w/2-ROUNDED_RADIUS, h/2-ROUNDED_RADIUS, 0]) cylinder(d, r=ROUNDED_RADIUS, center=false);
    }
}

// rounded cube: x/y/z centered
module nut_trap(w = 5.5, h = 3) {
    cylinder(r = w / 2 / cos(180 / 6) + delta, h=h+2*delta, $fn=6, center=true);
}
// x/y centered, z=0
module nut_trap_phase(w=5.5, h=0.5) {
    w2=w+2*h;
    translate([0,0,h]) rotate([180,0,0]) linear_extrude(height=h, center=false, scale=w2/w)
        circle(r = w / 2 / cos(180 / 6) + delta, $fn=6);
}

// phased nut trap at the xy plane
// this contains a phased cutout which always makes sense when making nut traps
// on the heat bed
module phased_nut_trap(w=5.5, h=4) {
    translate([0,0,h/2]) nut_trap(w, h);
    nut_trap_phase(w, 1);
}

// nut trap cube: x/y centered, z_bottom=0
module nut_trap_cube(W=10, H=6) {
    translate([0,0,H/2]) difference() {
        cube([W,W,H], center=true);
        union() {
            translate([0,-W/2,0]) cube([nut_diam+2*delta,W,nut_height+2*delta], center=true);
            rotate([0,0,30]) nut_trap(nut_diam, nut_height);
        }
        cylinder(H+2*ETA,d=screw_diam+delta, center=true);
    }
}

module bottom_border() {
    difference() {
        rounded_cube(WIDTH+ETA, HEIGHT+ETA, border_height);
        translate([0,0,-ETA]) rounded_cube(WIDTH-3, HEIGHT-3, border_height+2*ETA);
    }
}

module bottom() {
    // PCB mounting nut traps
    xoff=PCB_WIDTH/2-PCB_HOLE_OFFSET;
    yoff=PCB_HEIGHT/2-PCB_HOLE_OFFSET;
    // TOP mounting nut traps
    xoff2=WIDTH/2-7;
    yoff2=HEIGHT/2-7;

    difference() {
        union() {
            difference() {
                rounded_cube(WIDTH, HEIGHT, BOTTOM_HEIGHT);
                translate([0,0,BOTTOM_WALL_THICKNESS]) rounded_cube(WIDTH-6, HEIGHT-6, BOTTOM_HEIGHT);
                translate([0,0,BOTTOM_HEIGHT-border_height+ETA]) bottom_border();
                // sd card cutout
                translate([-WIDTH/2-SD_HOLDER_WIDTH/2,8.4-PCB_HEIGHT/2,main_pcb_z_offset()-SD_HOLDER_DEPTH]) 
                    cube([SD_HOLDER_WIDTH,SD_HOLDER_HEIGHT,SD_HOLDER_DEPTH], center=false);
            }
            translate([0,PCB_OFFSET_Y,3.5]) {
                translate([-xoff,-yoff,0]) cube([8,8,7], center=true);
                translate([ xoff,-yoff,0]) cube([8,8,7], center=true);
                translate([-xoff, yoff,0]) cube([8,8,7], center=true);
                translate([ xoff, yoff,0]) cube([8,8,7], center=true);
            }
            translate([0,PCB_OFFSET_Y,5]) {
                translate([-xoff2,-yoff2,0]) cube([8,8,10], center=true);
                translate([ xoff2,-yoff2,0]) cube([8,8,10], center=true);
                translate([-xoff2, yoff2,0]) cube([8,8,10], center=true);
                translate([ xoff2, yoff2,0]) cube([8,8,10], center=true);
            }
        }
        // PCB mount nut traps
        translate([0,PCB_OFFSET_Y,-ETA]) {
            translate([-xoff2,-yoff2,0]) { phased_nut_trap(); cylinder(12+ETA,d=screw_diam+delta, center=false); }
            translate([ xoff2,-yoff2,0]) { phased_nut_trap(); cylinder(12+ETA,d=screw_diam+delta, center=false); }
            translate([-xoff2, yoff2,0]) { phased_nut_trap(); cylinder(12+ETA,d=screw_diam+delta, center=false); }
            translate([ xoff2, yoff2,0]) { phased_nut_trap(); cylinder(12+ETA,d=screw_diam+delta, center=false); }
        }
        // TOP mount nut traps
        translate([0,PCB_OFFSET_Y,-ETA]) {
            translate([-xoff,-yoff,0]) { phased_nut_trap(); cylinder(12+ETA,d=screw_diam+delta, center=false); }
            translate([ xoff,-yoff,0]) { phased_nut_trap(); cylinder(12+ETA,d=screw_diam+delta, center=false); }
            translate([-xoff, yoff,0]) { phased_nut_trap(); cylinder(12+ETA,d=screw_diam+delta, center=false); }
            translate([ xoff, yoff,0]) { phased_nut_trap(); cylinder(12+ETA,d=screw_diam+delta, center=false); }
        }
    }
}

/* Screw:
 * d1: screw diameter
 * d2: screw head diameter
 * h : head height
 * l : screw length
 */
module screw(d1,d2,h,l) {
    cylinder(h=l+ETA,d=d1+delta, center=false);
    translate([0,0,l]) cylinder(h=h+delta,d=d2+delta, center=false);
}

module top() {
    // TOP mounting nut traps
    xoff2=WIDTH/2-7;
    yoff2=HEIGHT/2-7;

    difference() {
        union() {
            translate([0,0,BOTTOM_HEIGHT]) difference() {
                union() {
                    rounded_cube(WIDTH, HEIGHT, TOP_HEIGHT);
                    translate([0,0,-border_height+ETA]) bottom_border();
                }
                translate([0,0,-BOTTOM_WALL_THICKNESS]) rounded_cube(WIDTH-6, HEIGHT-6, TOP_HEIGHT);
            }
            translate([0,PCB_OFFSET_Y,DEPTH-TOP_WALL_THICKNESS-5+ETA]) {
                translate([-xoff2,-yoff2,0]) { cube(10,10,10, center=true); }
                translate([ xoff2,-yoff2,0]) { cube(10,10,10, center=true); }
                translate([-xoff2, yoff2,0]) { cube(10,10,10, center=true); }
                translate([ xoff2, yoff2,0]) { cube(10,10,10, center=true); }
            }
        }
        // beeper holes
        translate([PCB_WIDTH/2-13,PCB_HEIGHT/2-10,DEPTH-5]) {
            cylinder(10,d=1,center=false);
            translate([-3,0,0]) cylinder(10,d=1,center=false);
            translate([3,0,0]) cylinder(10,d=1,center=false);
        }
        // TOP mount holes
        translate([0,PCB_OFFSET_Y,DEPTH-22.3+ETA]) {
            translate([-xoff2,-yoff2,0]) { screw(screw_diam, 5.4, 2.3, 20); }
            translate([ xoff2,-yoff2,0]) { screw(screw_diam, 5.4, 2.3, 20); }
            translate([-xoff2, yoff2,0]) { screw(screw_diam, 5.4, 2.3, 20); }
            translate([ xoff2, yoff2,0]) { screw(screw_diam, 5.4, 2.3, 20); }
        }
    }
}

// same as cube, but x/y centered, z_bottom=0
module pcb(w,h,d) {
    translate([0,0,d/2]) cube([w,h,d], center=true);
}

function main_pcb_z_offset() = BOTTOM_WALL_THICKNESS+PCB_MOUNT_HEIGHT+ETA;

module main_pcb(cutout=0) {
    xoff=PCB_WIDTH/2-PCB_HOLE_OFFSET;
    yoff=PCB_HEIGHT/2-PCB_HOLE_OFFSET;
    zoff=main_pcb_z_offset();
    color("red") translate([0,0,zoff]) difference() {
        pcb(PCB_WIDTH, PCB_HEIGHT, PCB_THICKNESS);
        translate([-xoff, -yoff, -ETA]) cylinder(PCB_THICKNESS+2*ETA, r=PCB_HOLE_RAD, center=false);
        translate([xoff, -yoff, -ETA]) cylinder(PCB_THICKNESS+2*ETA, r=PCB_HOLE_RAD, center=false);
        translate([-xoff, yoff, -ETA]) cylinder(PCB_THICKNESS+2*ETA, r=PCB_HOLE_RAD, center=false);
        translate([xoff, yoff, -ETA]) cylinder(PCB_THICKNESS+2*ETA, r=PCB_HOLE_RAD, center=false);
    }
    // beeper
    color("gray") translate([PCB_WIDTH/2-13,PCB_HEIGHT/2-10,zoff+PCB_THICKNESS]) cylinder(9.3,r=6,center=false);
    // front knob
    color("gray") translate([PCB_WIDTH/2-13,PCB_HEIGHT/2-30,zoff+PCB_THICKNESS]) {
        pcb(12,12,4.2);
        translate([0,0,4.2]) cylinder(25,d=6.1,center=false);
    }
    // reset button
    color("gray") translate([PCB_WIDTH/2-13,PCB_HEIGHT/2-47,zoff+PCB_THICKNESS]) {
        pcb(6,6,4);
        translate([0,0,4]) cylinder(1.5,d=3.5,center=false);
    }
    // sd card holder
    color("gray") translate([-PCB_WIDTH/2,8.4-PCB_HEIGHT/2,zoff-SD_HOLDER_DEPTH]) {
        cube([SD_HOLDER_WIDTH,SD_HOLDER_HEIGHT,SD_HOLDER_DEPTH], center=false);
    }
    // connectors
    cw=21.3; // connector width
    ch=10;   // connector height
    cd=9;    // connector depth
    cx1=45.5; // connector1 x offset
    cx2=68.8; // connector2 x offset
    cy=21.7; // connector y offset
    translate([-PCB_WIDTH/2+cx1,PCB_HEIGHT/2-ch-cy,zoff-cd]) {
        color("gray") cube([cw,ch,cd+cutout], center=false);
    }
    translate([-PCB_WIDTH/2+cx2,PCB_HEIGHT/2-ch-cy,zoff-cd]) {
        color("gray") cube([cw,ch,cd+cutout], center=false);
    }
    // rear poti
    color("gray") translate([-PCB_WIDTH/2+16.5,PCB_HEIGHT/2-14.2,zoff-8-cutout]) {
        cylinder(8+cutout,d=7,center=false);
    }
    // rear transistor
    color("gray") translate([-PCB_WIDTH/2+75.5,PCB_HEIGHT/2-14.2,zoff-7-cutout]) {
        cylinder(7+cutout,d=5,center=false);
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
        pcb(LCD_PCB_WIDTH, LCD_PCB_HEIGHT, PCB_THICKNESS);
        translate([-hole_xoff, -hole_yoff, -ETA]) cylinder(PCB_THICKNESS+2*ETA, r=LCD_PCB_HOLE_RAD, center=false);
        translate([ hole_xoff, -hole_yoff, -ETA]) cylinder(PCB_THICKNESS+2*ETA, r=LCD_PCB_HOLE_RAD, center=false);
        translate([-hole_xoff,  hole_yoff, -ETA]) cylinder(PCB_THICKNESS+2*ETA, r=LCD_PCB_HOLE_RAD, center=false);
        translate([ hole_xoff,  hole_yoff, -ETA]) cylinder(PCB_THICKNESS+2*ETA, r=LCD_PCB_HOLE_RAD, center=false);
    }

    color("black") translate([-30,21.25,zoff-2.5]) pcb(40.6,2.5,2.5);
}

// the LCD module
function lcd_z_offset() = lcd_pcb_z_offset() + PCB_THICKNESS + ETA;
module lcd() {
    xoff=(LCD_WIDTH-PCB_WIDTH)/2+LCD_PCB_OFFSET_X+LCD_OFFSET_X;
    yoff=(PCB_HEIGHT-LCD_HEIGHT)/2-LCD_PCB_OFFSET_Y-LCD_OFFSET_Y;
    zoff=lcd_z_offset();
    color("gray") translate([xoff,yoff,zoff]) pcb(LCD_WIDTH, LCD_HEIGHT, LCD_THICKNESS);
}

// complete LCD display including PCB
module lcd_display(cutout=0) {
    main_pcb(cutout);
    lcd_pcb();
    lcd();
}

// bottom part
module bottom_stl() {
    difference() {
        bottom();
        translate([0,PCB_OFFSET_Y,0]) lcd_display(1);
    }
}
if (show_bottom) {
    translate([0,0,-explode*30]) bottom_stl();
}

// top part
module top_stl() {
    difference() {
        top();
        translate([0,PCB_OFFSET_Y,0]) lcd_display();
    }
}
if (show_top) {
    translate([0,0,explode*30]) top_stl();
}

// LCD display
if (show_lcd) {
    translate([0,PCB_OFFSET_Y,0]) lcd_display();
}

