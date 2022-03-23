benq_ht2150st_screwholes = [
    [0, 35],
    [160, 0],
    [160 - 47, 132.9],
];

screwholes = benq_ht2150st_screwholes;

module place_screws() {
    for(point=screwholes)
    translate(point)
    children();
}

module basic_plate_2d() {
    hull()
    place_screws()
    circle(r=10, $fn=50);
}

module basic_plate() {
    linear_extrude(height=10)
    basic_plate_2d();
}

basic_plate();