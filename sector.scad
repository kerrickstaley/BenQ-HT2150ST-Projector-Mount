// from https://gist.github.com/plumbum/78e3c8281e1c031601456df2aa8e37c6
translate([0,0,0]) sector(30, 20, 10, 90);
translate([22,0,0]) sector(30, 20, 300, 30);
translate([0,22,0]) sector(30, 20, 30, 300);
translate([22,22,0]) sector(30, 20, 10, 190);

module sector(h, d, a1, a2) {
    if (a2 - a1 > 180) {
        difference() {
            cylinder(h=h, d=d);
            translate([0,0,-0.5]) sector(h+1, d+1, a2-360, a1); 
        }
    } else {
        difference() {
            cylinder(h=h, d=d);
            rotate([0,0,a1]) translate([-d/2, -d/2, -0.5])
                cube([d, d/2, h+1]);
            rotate([0,0,a2]) translate([-d/2, 0, -0.5])
                cube([d, d/2, h+1]);
        }
    }
}    
