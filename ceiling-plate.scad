use <fillet.scad>

include <MCAD/units/metric.scad>
use <MCAD/shapes/polyhole.scad>

$fa = 1;
$fs = 0.5;

plate_thickness = 5;
plate_d = 90;
hub_d = 50;
hub_thickness = 15;
hollow_d = 25;
hollow_h = 10;
n_holes = 12;
hole_orbit_r = 35;

module fillet2d (r)
{
    difference () {
        square ([r, r]);

        translate ([r + epsilon, r + epsilon])
        circle (r=r + epsilon);
    }
}

difference () {
    union () {
        // base plante
        cylinder (d=plate_d, h=plate_thickness);

        // hub
        cylinder (d=hub_d, h=hub_thickness);
    }

    // hollow portion
    translate ([0, 0, -epsilon])
    mcad_polyhole (d=hollow_d, h=hollow_h + epsilon);

    // main screw hole
    translate ([0, 0, hollow_h + 1])
    mcad_polyhole (d=5, h=300);

    for (i=[0:n_holes]) {
        rotate (i / n_holes * 360, Z)
        translate ([hole_orbit_r, 0, -epsilon])
        mcad_polyhole (d=5.3, h=plate_thickness * 2);
    }
}

translate ([0, 0, plate_thickness - epsilon])
rotate_extrude ()
translate ([hub_d / 2 - epsilon, 0])
fillet2d (5 + epsilon * 2);

translate ([0, 0, 10])
mirror (Z)
rotate_extrude ()
translate ([-(hollow_d / 2 - epsilon), 0])
fillet2d (5 + epsilon * 2);
