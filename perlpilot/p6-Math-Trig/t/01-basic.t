use Test;

plan 22;

use-ok 'Math::Trig';

{
    need Math::Trig;
    import Math::Trig;

    ok try { EVAL("&rad2rad") },    'rad2rad sub is exported by :DEFAULT';
    ok try { EVAL("&deg2deg") },    'deg2deg sub is exported by :DEFAULT';
    ok try { EVAL("&grad2grad") },  'grad2grad sub is exported by :DEFAULT';
    ok try { EVAL("&rad2deg") },    'rad2deg sub is exported by :DEFAULT';
    ok try { EVAL("&deg2rad") },    'deg2rad sub is exported by :DEFAULT';
    ok try { EVAL("&grad2deg") },   'grad2deg sub is exported by :DEFAULT';
    ok try { EVAL("&deg2grad") },   'deg2grad sub is exported by :DEFAULT';
    ok try { EVAL("&rad2grad") },   'rad2grad sub is exported by :DEFAULT';
    ok try { EVAL("&grad2rad") },   'grad2rad sub is exported by :DEFAULT';
}

{
    need Math::Trig;
    import Math::Trig :radial;

	ok try { EVAL("&cartesian-to-spherical") },     'cartesian-to-spherical is exported by :radial';
	ok try { EVAL("&spherical-to-cartesian") },     'spherical-to-cartesian is exported by :radial';
	ok try { EVAL("&cartesian-to-cylindrical") },   'cartesian-to-cylindrical is exported by :radial';
	ok try { EVAL("&spherical-to-cylindrical") },   'spherical-to-cylindrical is exported by :radial';
	ok try { EVAL("&cylindrical-to-cartesian") },   'cylindrical-to-cartesian is exported by :radial';
	ok try { EVAL("&cylindrical-to-spherical") },   'cylindrical-to-spherical is exported by :radial';
}

{
    need Math::Trig;
    import Math::Trig :great-circle;

	ok try { EVAL("&great-circle-distance") },      'great-circle-distance is exported by :great-circle';
	ok try { EVAL("&great-circle-bearing") },       'great-circle-bearing is exported by :great-circle';
	ok try { EVAL("&great-circle-direction") },     'great-circle-direction is exported by :great-circle';
	ok try { EVAL("&great-circle-waypoint") },      'great-circle-waypoint is exported by :great-circle';
	ok try { EVAL("&great-circle-midpoint") },      'great-circle-midpoint is exported by :great-circle';
	ok try { EVAL("&great-circle-destination") },   'great-circle-destination is exported by :great-circle';
}
