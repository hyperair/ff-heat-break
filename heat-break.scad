include <MCAD/units/metric.scad>
use <MCAD/fasteners/threads.scad>

$fs = 0.1;
$fa = 0.5;

module chamfer (d1, d2, angle, negative = false, bbox = [10, 10])
{
    height = abs (d1 - d2) / 2 / tan (angle);
    r_diff = abs (d2 - d1) / 2;

    if (negative) {
        difference () {
            translate ([0, 0, height / 2])
            cube (concat (bbox, [height]), center = true);

            translate ([0, 0, -epsilon * 2])
            chamfer (d1 = d2 - (d2 - d1) / height * (height + epsilon * 2),
                d2 = d1 - (d1 - d2) / height * (height + epsilon * 2),
                angle = angle);
        }
    } else {
        cylinder (d1 = d1, d2 = d2, h = height);
    }
}

module heat_break (
    upper_bore_d,
    lower_bore_d,
    lower_bore_length,
    neck_od,
    neck_length,
    thread_length
)
{
    total_length = 26.5;

    difference () {
        %difference () {
            union () {
                // smooth bore section
                translate ([0, 0, neck_length + thread_length])
                cylinder (d = 6, h = total_length - neck_length - thread_length);

                // neck
                translate ([0, 0, thread_length])
                cylinder (d = neck_od, h = neck_length);

                // thread
                metric_thread (diameter = 6, pitch = 1, length = thread_length);
            }

            // thread chamfer
            translate ([0, 0, -epsilon])
            chamfer (d1 = lower_bore_d, d2 = 6, angle = 45,
                negative = true);
        }

        translate ([0, 0, -epsilon]) {
            // upper bore
            cylinder (d = upper_bore_d, h = total_length + epsilon * 2);

            // lower bore
            cylinder (d = lower_bore_d, h = lower_bore_length + epsilon);

            // lower bore chamfer
            translate ([0, 0, lower_bore_length])
            chamfer (d1 = lower_bore_d, d2 = upper_bore_d, angle = 115 / 2);
        }
    }
}

heat_break (
    upper_bore_d = 1.9,
    lower_bore_d = 2.4,
    lower_bore_length = 8,
    neck_od = 2.8,
    neck_length = 2,
    thread_length = 5
);
