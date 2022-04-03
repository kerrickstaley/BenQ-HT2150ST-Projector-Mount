use <arm.scad>
use <fillet.scad>
use <MCAD/shapes/polyhole.scad>
include <MCAD/units/metric.scad>

$fs = 0.5;
$fa = 1;

fillet_r = 10;
base_thickness = 7;

module single_arm ()
rotate (90, Z)
arm (height=35 + base_thickness, width=30, thickness=5, shaft_d=5.3);

module place_arm (i)
{
    translate ([i * 17.5, 0, 0])
    children ();
}

module base_plate ()
difference () {
    cylinder (d=50, h=base_thickness);

    translate ([0, 0, -epsilon])
    mcad_polyhole (d=5.3, h=base_thickness + epsilon * 2);
}

fillet (r=fillet_r, steps=20) {
    place_arm (1)
    single_arm ();

    base_plate ();
}

fillet (r=fillet_r, steps=20) {
    place_arm (-1)
    single_arm ();

    base_plate ();
}
