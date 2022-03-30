use <fillet.scad>

base_width = 50;
top_width = 100;
height = 100;
depth = 60;
thickness = 5;
fillet_steps = 8;
fillet_r = 5;

module clean_up_ugly_corners_face(offset) {
    polyhedron(
        points=[
            [-100, depth - offset, 2 * height + offset],
            [100, depth - offset, 2 * height + offset],
            [-100, -2 * depth - offset, - height + offset],
            [100, -2 * depth - offset, - height + offset]],
        faces=[[0, 1, 2, 3]]);
}

module clean_up_ugly_corners() {
    difference() {
        union() {
            children();
        }
        
        hull() {
            clean_up_ugly_corners_face(0);
            clean_up_ugly_corners_face(20);
        }
    }
}

module support_face(offset) {
    polyhedron(
        points=[
            [-offset, 0, 0],
            [-offset, -depth, 0],
            [(top_width - base_width) / 2 - offset, 0, height]],
        faces=[[0, 1, 2]]);
}

module support() {
    hull() {
        support_face(0);
        support_face(thickness);
    }
}

module left_support() {
    mirror([1, 0, 0])
    support();
}

module right_support() {
    translate([base_width, 0, 0])
    support();
}

module back_face(offset) {
    polyhedron(
        points=[
            [0, -offset, 0],
            [base_width, -offset, 0],
            [(top_width + base_width) / 2, -offset, height],
            [-(top_width - base_width) / 2, -offset, height]],
        faces=[[0, 1, 2, 3]]);
}

module back() {
    clean_up_ugly_corners()
    hull() {
        back_face(0);
        back_face(thickness);
    }
}

module base() {
    clean_up_ugly_corners()
    translate([0, -depth, 0])
    cube([base_width, depth, thickness]);
}


fillet(r=fillet_r, steps=fillet_steps) {
    left_support();
    right_support();
    base();
    back();
}
