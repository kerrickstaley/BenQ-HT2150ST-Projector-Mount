base_width = 50;
top_width = 100;
height = 100;
depth = 60;
thickness = 5;

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

module back_face(offset) {
    polyhedron(
        points=[
            [0, -offset, 0],
            [base_width, -offset, 0],
            [base_width / 2 + top_width / 2, -offset, height],
            [-(top_width - base_width) / 2, -offset, height]],
        faces=[[0, 1, 2, 3]]);
}

module back() {
    hull() {
        back_face(0);
        back_face(thickness);
    }
}

union() {
    translate([base_width, 0, 0])
    support();

    mirror([1, 0, 0])
    support();

    translate([0, -depth, 0])
    cube([base_width, depth, thickness]);
    
    back();
}

