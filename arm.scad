include <MCAD/units/metric.scad>
use <MCAD/shapes/polyhole.scad>

module arm (height, width, thickness, shaft_d)
{
    module place_arm_screwhole ()
    translate ([0, 0, height - width / 2])
    rotate (90, X)
    children ();

    difference () {
        hull () {
            place_arm_screwhole ()
            cylinder (d=width, h=thickness, center=true);

            translate ([0, 0, epsilon / 2])
            cube ([width, thickness, epsilon], center=true);
        }

        place_arm_screwhole ()
        translate ([0, 0, -width])
        mcad_polyhole (d=shaft_d, h=width * 2);
    }
}
