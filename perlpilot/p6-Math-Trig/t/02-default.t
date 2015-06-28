use Test;
use Math::Trig;

plan 9;

is-approx(rad2rad(pi * 3), pi, '3 * pi radians is normalized to pi radians');
is-approx(deg2deg(405), 45, '405 degrees is normalized to 45 degrees');
is-approx(grad2grad(405), 5, '405 gradians is normalized to 5 gradians');

is-approx(rad2deg(pi), 180, 'pi radians is 180 degrees');
is-approx(deg2rad(90), pi/2, '90 degrees is pi/2 radians');

is-approx(grad2deg(200), 180, '200 gradiens is 180 degrees');
is-approx(deg2grad(180), 200, '180 degrees is pi radians');

is-approx(rad2grad(pi), 200, '200 gradiens is 180 degrees');
is-approx(grad2rad(200), pi, '200 gradiens is 180 degrees');

