include <MCAD/units/metric.scad>
use <MCAD/general/utilities.scad>
use <MCAD/shapes/polyhole.scad>
use <fillet.scad>
use <arm.scad>
use <sector.scad>

// uncomment to disable filleting to speed up render
// module fillet (r=1.0,steps=3,include=true) { children (); }

function mm (x) = length_mm (x);
function centroid (a, b, c) = [
    (a[0] + b[0] + c[0]) / 3,
    (a[1] + b[1] + c[1]) / 3,
    0
];

function get_fragments_from_r (r) = (
    (r < 0.00000095367431640625) ? 3 :
    ceil (max (min (360 / $fa, r * 2 * PI / $fs), 5))
);

benq_w1070_screwholes = [
    [0, mm (115)],
    [mm (160 - 137), 0],
    [mm (160), mm (80)]
];

epson_eb101760w_screwholes = [
    [0, 0],
    [226, 0],
    [85.88716814159291, 85.231416441461]
];

epson_emp_s3_screwholes = [
    [0, 0],
    [242, 0],
    [134, 85.5]
];

epson_eb_915w_screwholes = [
    [0, 0],
    [242, 0],
    [131.43, 85.88]
];

benq_ht2150st_screwholes = [
    [0, 35],
    [160, 0],
    [160 - 47, 132.9],
];

screwholes = benq_ht2150st_screwholes;

center_orig = centroid (screwholes[0], screwholes[1], screwholes[2]);
center = [center_orig[0], center_orig[1] + 55.6, center_orig[2]];

$fs = 0.5;
$fa = 1;

clearance = mm (0.3);
screw_d = 4;
shaft_d = 5;
wall_thickness = 5;
outer_d = screw_d + wall_thickness * 2 + clearance;
plate_thickness = mm (5);
stiffener_thickness = mm (10);
stiffener_width = mm (5);

arm_distance = mm (30);
arm_thickness = mm (5);
arm_width = mm (30);
arm_height = mm (40);

fillet_r = mm (5);
fillet_steps = 8;

module place_screws () {
    for (point = screwholes)
    translate (point)
    children ();
}

module arm_hub ()
{
    translate (center)
    cylinder (d=arm_distance + arm_thickness * 2 + wall_thickness * 2, h=10);
}

module place_arm (i)
{
    translate (center)
    // rotate([0, 0, 90])
    translate ([0, i * (arm_distance + arm_thickness) / 2, 0])
    children ();
}

module single_arm ()
{
    arm (height = arm_height, width = arm_width, thickness = arm_thickness,
        shaft_d = shaft_d + clearance);
}

module basic_plate_2d ()
{
    hull ()
    place_screws ()
    circle (d=outer_d);
}

module basic_plate ()
{
    linear_extrude (height=plate_thickness)
    basic_plate_2d ();
}

module screwpolyholes ()
{
    place_screws ()
    translate ([0, 0, -epsilon])
    mcad_polyhole (d=screw_d + clearance, h=stiffener_thickness * 2);
}

module screwhub (i)
{
    screwhole = screwholes[i];

    translate (screwhole)
    cylinder (d=outer_d, h=stiffener_thickness);
}

module center_stiffener (i)
{
    screwhole = screwholes[i];

    hull () {
        translate (center)
        cylinder (d=stiffener_width, h=stiffener_thickness);

        translate (screwhole)
        cylinder (d=stiffener_width, h=stiffener_thickness);
    }
}

module center_stiffener (i) {}

module edge_stiffener (i)
{
    screwhole1 = screwholes[i];
    screwhole2 = screwholes[(i + 1) % len (screwholes)];

    dy = screwhole2[1] - screwhole1[1];
    dx = screwhole2[0] - screwhole1[0];

    length = distance2D (screwhole1, screwhole2);
    angle = 90 - angle_betweentTwoPoints2D (screwhole1, screwhole2);

    translate (conv2D_polar2cartesian ([outer_d / 2, angle - 90]))
    translate (screwhole1)
    rotate (angle, Z)
    cube ([length, stiffener_width, stiffener_thickness]);
}

module rectangle_intrusion_stiffener () {
    translate([82.9, 35 + 70.7, 0]) {
        // bottom edge
        translate([-12, -stiffener_width, 0])
        cube([12 + stiffener_width, stiffener_width, stiffener_thickness]);
        
        // right edge
        cube([stiffener_width, 9, stiffener_thickness]);
    }
}

module oval_intrusion_stiffener () {
    translate([116.8, 35 - 32.2, 0]) {
        // top edge
        translate([0, 8.7, 0])
        translate([-42.5, 0, 0])
        cube([42.5, stiffener_width, stiffener_thickness]);
        
        // right edge
        difference () {
            sector(d=2*(8.7 + stiffener_width), h=stiffener_thickness, a1=-10, a2=90);
            translate([0, 0, -1])
            cylinder(r=8.7, h=stiffener_thickness + 2);
        }
    }
}

module protuberance () {
    eps = 0.01;
    slope = 9.5 / 8.5;
    // The value of dz that I measured is 9.5. However, this results in a "roof" overhanging the protuberance that is only 0.5 mm thick. There is no point in having this roof; it doesn't improve strength of the piece.
    dz = 15;
    dxy = dz / slope;
    size = 40;
    lower_right_corner = [82.9, 35 + 70.7, 0];
    
    translate(lower_right_corner)
    hull() {
        translate([-size, 0, -eps])
        cube([size, size, eps]);
        
        translate([-size - dxy, dxy, dz])
        cube([size, size, eps]);
    }
}

// basic shape
difference () {
    union () {
        basic_plate ();

        for (i=[0:len (screwholes) - 1]) {
            center_stiffener (i);
            screwhub (i);
            edge_stiffener (i);
        }

        arm_hub ();

        // arms
        for (i=[1, -1])
        place_arm (i)
        single_arm ();
        
        // intrusion stiffeners
        rectangle_intrusion_stiffener ();
        oval_intrusion_stiffener ();

        // arm fillets
        fillet (r=fillet_r, steps=fillet_steps, include=false) {
            arm_hub ();

            place_arm (-1)
            single_arm ();
        }

        fillet (r=fillet_r, steps=fillet_steps, include=false) {
            arm_hub ();

            place_arm (1)
            single_arm ();
        }

        fillet (r=fillet_r, steps=fillet_steps, include=false) {
            basic_plate ();
            arm_hub ();

            // unrolled until openscad version with unpacked unions arrives
            center_stiffener (0);
            center_stiffener (1);
            center_stiffener (2);
        }

        // fillet the screwhubs
        for (i = [0 : len (screwholes) - 1]) {
            fillet (r=fillet_r, steps=fillet_steps, include=false) {
                basic_plate ();
                screwhub (i);
                center_stiffener (i);
            }

            fillet (r=fillet_r, steps=fillet_steps, include=false) {
                basic_plate ();
                screwhub (i);
                edge_stiffener (i);
            }

            fillet (r=fillet_r, steps=fillet_steps, include=false) {
                basic_plate ();
                screwhub (i);
                edge_stiffener ((i + len (screwholes) - 1) % len (screwholes));
            }
            
            fillet (r=fillet_r, steps=fillet_steps, include=false) {
                basic_plate ();
                rectangle_intrusion_stiffener ();
            }
            
            fillet (r=fillet_r, steps=fillet_steps, include=false) {
                basic_plate ();
                oval_intrusion_stiffener ();
            }
        }
    }

    {
        screwpolyholes ();
        
        protuberance ();

        translate([116.8, 35 - 32.2, -20]) {
            cylinder(r=8.7, h=40);
            translate([-50, -40, 0])
            translate([0, 8.7, 0])
            cube([50, 40, 40]);
        }
    }
}
