# Test Geo::Ellipsoid to

use v6;
use Test;

plan 476;

use Geo::Ellipsoid;

# This original Perl 5 test used the following test functions (the
# resulting Perl 6 versions are shown after the fat comma):
#
#   delta_ok     => is-approx($a, $b, :$rel-tol)
#   delta_within => is-approx($a, $b, :abs-tol<?>)
#
#  From the Perl 5 test file:
#    use Test::Number::Delta relative => 1e-6;
#  which translates to:
my $rel-tol = 1e-6;

my $e = Geo::Ellipsoid.new(units=>'degrees');
my ($r, $a);

($r, $a) = $e.to(-88.000000, 1.000000,-88.000000, 1.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(-88.000000, 1.000000,-88.000000, 90.000000);
is-approx($r, 313115.736403696, :$rel-tol); # perl 5: delta_ok
is-approx($a, 134.482545961512, :abs-tol<0.0001>); #delta_within($a, 134.482545961512, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,-88.000000, 179.000000);
is-approx($r, 446706.01076052, :$rel-tol); # perl 5: delta_ok
is-approx($a, 178.999390582928, :abs-tol<0.0001>); #delta_within($a, 178.999390582928, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,-88.000000, 268.000000);
is-approx($r, 324047.278966276, :$rel-tol); # perl 5: delta_ok
is-approx($a, 223.517433140781, :abs-tol<0.0001>); #delta_within($a, 223.517433140781, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,0.000000, 1.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,0.000000, 90.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 89.011158607559, :abs-tol<0.0001>); #delta_within($a, 89.011158607559, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,0.000000, 179.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 177.999150742584, :abs-tol<0.0001>); #delta_within($a, 177.999150742584, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,0.000000, 268.000000);
is-approx($r, 10013675.0566307, :$rel-tol); # perl 5: delta_ok
is-approx($a, 266.991287566797, :abs-tol<0.0001>); #delta_within($a, 266.991287566797, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,88.000000, 1.000000);
is-approx($r, 19557157.3743612, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,88.000000, 90.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 44.5248574511054, :abs-tol<0.0001>); #delta_within($a, 44.5248574511054, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,88.000000, 179.000000);
is-approx($r, 19996176.9000454, :$rel-tol); # perl 5: delta_ok
is-approx($a, 89.011158607592, :abs-tol<0.0001>); #delta_within($a, 89.011158607592, 0.0001);

($r, $a) = $e.to(-88.000000, 1.000000,88.000000, 268.000000);
is-approx($r, 19696447.0104273, :$rel-tol); # perl 5: delta_ok
is-approx($a, 313.474906296863, :abs-tol<0.0001>); #delta_within($a, 313.474906296863, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,-88.000000, 1.000000);
is-approx($r, 313115.736403696, :$rel-tol); # perl 5: delta_ok
is-approx($a, 225.517454038488, :abs-tol<0.0001>); #delta_within($a, 225.517454038488, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,-88.000000, 90.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(-88.000000, 90.000000,-88.000000, 179.000000);
is-approx($r, 313115.736403696, :$rel-tol); # perl 5: delta_ok
is-approx($a, 134.482545961512, :abs-tol<0.0001>); #delta_within($a, 134.482545961512, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,-88.000000, 268.000000);
is-approx($r, 446706.01076052, :$rel-tol); # perl 5: delta_ok
is-approx($a, 178.999390582928, :abs-tol<0.0001>); #delta_within($a, 178.999390582928, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,0.000000, 1.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270.988841392441, :abs-tol<0.0001>); #delta_within($a, 270.988841392441, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,0.000000, 90.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,0.000000, 179.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 89.011158607559, :abs-tol<0.0001>); #delta_within($a, 89.011158607559, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,0.000000, 268.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 177.999150742584, :abs-tol<0.0001>); #delta_within($a, 177.999150742584, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,88.000000, 1.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 315.475142548895, :abs-tol<0.0001>); #delta_within($a, 315.475142548895, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,88.000000, 90.000000);
is-approx($r, 19557157.3743612, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,88.000000, 179.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 44.5248574511054, :abs-tol<0.0001>); #delta_within($a, 44.5248574511054, 0.0001);

($r, $a) = $e.to(-88.000000, 90.000000,88.000000, 268.000000);
is-approx($r, 19996176.9000454, :$rel-tol); # perl 5: delta_ok
is-approx($a, 89.011158607592, :abs-tol<0.0001>); #delta_within($a, 89.011158607592, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,-88.000000, 1.000000);
is-approx($r, 446706.01076052, :$rel-tol); # perl 5: delta_ok
is-approx($a, 181.000609417072, :abs-tol<0.0001>); #delta_within($a, 181.000609417072, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,-88.000000, 90.000000);
is-approx($r, 313115.736403696, :$rel-tol); # perl 5: delta_ok
is-approx($a, 225.517454038488, :abs-tol<0.0001>); #delta_within($a, 225.517454038488, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,-88.000000, 179.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(-88.000000, 179.000000,-88.000000, 268.000000);
is-approx($r, 313115.736403696, :$rel-tol); # perl 5: delta_ok
is-approx($a, 134.482545961512, :abs-tol<0.0001>); #delta_within($a, 134.482545961512, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,0.000000, 1.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 182.000849257416, :abs-tol<0.0001>); #delta_within($a, 182.000849257416, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,0.000000, 90.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270.988841392441, :abs-tol<0.0001>); #delta_within($a, 270.988841392441, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,0.000000, 179.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,0.000000, 268.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 89.011158607559, :abs-tol<0.0001>); #delta_within($a, 89.011158607559, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,88.000000, 1.000000);
is-approx($r, 19996176.9000454, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270.988841392408, :abs-tol<0.0001>); #delta_within($a, 270.988841392408, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,88.000000, 90.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 315.475142548895, :abs-tol<0.0001>); #delta_within($a, 315.475142548895, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,88.000000, 179.000000);
is-approx($r, 19557157.3743612, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(-88.000000, 179.000000,88.000000, 268.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 44.5248574511054, :abs-tol<0.0001>); #delta_within($a, 44.5248574511054, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,-88.000000, 1.000000);
is-approx($r, 324047.278966276, :$rel-tol); # perl 5: delta_ok
is-approx($a, 136.482566859219, :abs-tol<0.0001>); #delta_within($a, 136.482566859219, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,-88.000000, 90.000000);
is-approx($r, 446706.01076052, :$rel-tol); # perl 5: delta_ok
is-approx($a, 181.000609417072, :abs-tol<0.0001>); #delta_within($a, 181.000609417072, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,-88.000000, 179.000000);
is-approx($r, 313115.736403696, :$rel-tol); # perl 5: delta_ok
is-approx($a, 225.517454038488, :abs-tol<0.0001>); #delta_within($a, 225.517454038488, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,-88.000000, 268.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(-88.000000, 268.000000,0.000000, 1.000000);
is-approx($r, 10013675.0566307, :$rel-tol); # perl 5: delta_ok
is-approx($a, 93.0087124332033, :abs-tol<0.0001>); #delta_within($a, 93.0087124332033, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,0.000000, 90.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 182.000849257416, :abs-tol<0.0001>); #delta_within($a, 182.000849257416, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,0.000000, 179.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270.988841392441, :abs-tol<0.0001>); #delta_within($a, 270.988841392441, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,0.000000, 268.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,88.000000, 1.000000);
is-approx($r, 19696447.0104273, :$rel-tol); # perl 5: delta_ok
is-approx($a, 46.5250937031367, :abs-tol<0.0001>); #delta_within($a, 46.5250937031367, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,88.000000, 90.000000);
is-approx($r, 19996176.9000454, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270.988841392408, :abs-tol<0.0001>); #delta_within($a, 270.988841392408, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,88.000000, 179.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 315.475142548895, :abs-tol<0.0001>); #delta_within($a, 315.475142548895, 0.0001);

($r, $a) = $e.to(-88.000000, 268.000000,88.000000, 268.000000);
is-approx($r, 19557157.3743612, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,-88.000000, 1.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,-88.000000, 90.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 177.99357628514, :abs-tol<0.0001>); #delta_within($a, 177.99357628514, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,-88.000000, 179.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 179.929950967799, :abs-tol<0.0001>); #delta_within($a, 179.929950967799, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,-88.000000, 268.000000);
is-approx($r, 10013675.0566307, :$rel-tol); # perl 5: delta_ok
is-approx($a, 182.003955421895, :abs-tol<0.0001>); #delta_within($a, 182.003955421895, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,0.000000, 1.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(0.000000, 1.000000,0.000000, 90.000000);
is-approx($r, 9907434.68060135, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90, :abs-tol<0.0001>); #delta_within($a, 90, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,0.000000, 179.000000);
is-approx($r, 19814869.3612027, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90, :abs-tol<0.0001>); #delta_within($a, 90, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,0.000000, 268.000000);
is-approx($r, 10352712.6437744, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270, :abs-tol<0.0001>); #delta_within($a, 270, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,88.000000, 1.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,88.000000, 90.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 2.00642371485969, :abs-tol<0.0001>); #delta_within($a, 2.00642371485969, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,88.000000, 179.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0.0700490322014982, :abs-tol<0.0001>); #delta_within($a, 0.0700490322014982, 0.0001);

($r, $a) = $e.to(0.000000, 1.000000,88.000000, 268.000000);
is-approx($r, 10013675.0566307, :$rel-tol); # perl 5: delta_ok
is-approx($a, 357.996044578105, :abs-tol<0.0001>); #delta_within($a, 357.996044578105, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,-88.000000, 1.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 182.00642371486, :abs-tol<0.0001>); #delta_within($a, 182.00642371486, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,-88.000000, 90.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,-88.000000, 179.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 177.99357628514, :abs-tol<0.0001>); #delta_within($a, 177.99357628514, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,-88.000000, 268.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 179.929950967799, :abs-tol<0.0001>); #delta_within($a, 179.929950967799, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,0.000000, 1.000000);
is-approx($r, 9907434.68060135, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270, :abs-tol<0.0001>); #delta_within($a, 270, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,0.000000, 90.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(0.000000, 90.000000,0.000000, 179.000000);
is-approx($r, 9907434.68060135, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90, :abs-tol<0.0001>); #delta_within($a, 90, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,0.000000, 268.000000);
is-approx($r, 19814869.3612027, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90, :abs-tol<0.0001>); #delta_within($a, 90, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,88.000000, 1.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 357.99357628514, :abs-tol<0.0001>); #delta_within($a, 357.99357628514, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,88.000000, 90.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,88.000000, 179.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 2.00642371485969, :abs-tol<0.0001>); #delta_within($a, 2.00642371485969, 0.0001);

($r, $a) = $e.to(0.000000, 90.000000,88.000000, 268.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0.0700490322014982, :abs-tol<0.0001>); #delta_within($a, 0.0700490322014982, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,-88.000000, 1.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180.070049032201, :abs-tol<0.0001>); #delta_within($a, 180.070049032201, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,-88.000000, 90.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 182.00642371486, :abs-tol<0.0001>); #delta_within($a, 182.00642371486, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,-88.000000, 179.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,-88.000000, 268.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 177.99357628514, :abs-tol<0.0001>); #delta_within($a, 177.99357628514, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,0.000000, 1.000000);
is-approx($r, 19814869.3612027, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270, :abs-tol<0.0001>); #delta_within($a, 270, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,0.000000, 90.000000);
is-approx($r, 9907434.68060135, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270, :abs-tol<0.0001>); #delta_within($a, 270, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,0.000000, 179.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(0.000000, 179.000000,0.000000, 268.000000);
is-approx($r, 9907434.68060135, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90, :abs-tol<0.0001>); #delta_within($a, 90, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,88.000000, 1.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 359.929950967799, :abs-tol<0.0001>); #delta_within($a, 359.929950967799, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,88.000000, 90.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 357.99357628514, :abs-tol<0.0001>); #delta_within($a, 357.99357628514, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,88.000000, 179.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(0.000000, 179.000000,88.000000, 268.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 2.00642371485969, :abs-tol<0.0001>); #delta_within($a, 2.00642371485969, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,-88.000000, 1.000000);
is-approx($r, 10013675.0566307, :$rel-tol); # perl 5: delta_ok
is-approx($a, 177.996044578105, :abs-tol<0.0001>); #delta_within($a, 177.996044578105, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,-88.000000, 90.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180.070049032201, :abs-tol<0.0001>); #delta_within($a, 180.070049032201, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,-88.000000, 179.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 182.00642371486, :abs-tol<0.0001>); #delta_within($a, 182.00642371486, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,-88.000000, 268.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,0.000000, 1.000000);
is-approx($r, 10352712.6437744, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90, :abs-tol<0.0001>); #delta_within($a, 90, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,0.000000, 90.000000);
is-approx($r, 19814869.3612027, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270, :abs-tol<0.0001>); #delta_within($a, 270, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,0.000000, 179.000000);
is-approx($r, 9907434.68060135, :$rel-tol); # perl 5: delta_ok
is-approx($a, 270, :abs-tol<0.0001>); #delta_within($a, 270, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,0.000000, 268.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(0.000000, 268.000000,88.000000, 1.000000);
is-approx($r, 10013675.0566307, :$rel-tol); # perl 5: delta_ok
is-approx($a, 2.00395542189512, :abs-tol<0.0001>); #delta_within($a, 2.00395542189512, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,88.000000, 90.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 359.929950967799, :abs-tol<0.0001>); #delta_within($a, 359.929950967799, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,88.000000, 179.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 357.99357628514, :abs-tol<0.0001>); #delta_within($a, 357.99357628514, 0.0001);

($r, $a) = $e.to(0.000000, 268.000000,88.000000, 268.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 0, :abs-tol<0.0001>); #delta_within($a, 0, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,-88.000000, 1.000000);
is-approx($r, 19557157.3743612, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,-88.000000, 90.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 135.475142548896, :abs-tol<0.0001>); #delta_within($a, 135.475142548896, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,-88.000000, 179.000000);
is-approx($r, 19996176.9000454, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90.9888413924734, :abs-tol<0.0001>); #delta_within($a, 90.9888413924734, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,-88.000000, 268.000000);
is-approx($r, 19696447.0104273, :$rel-tol); # perl 5: delta_ok
is-approx($a, 226.525093703136, :abs-tol<0.0001>); #delta_within($a, 226.525093703136, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,0.000000, 1.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,0.000000, 90.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90.988841392441, :abs-tol<0.0001>); #delta_within($a, 90.988841392441, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,0.000000, 179.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 2.00084925741569, :abs-tol<0.0001>); #delta_within($a, 2.00084925741569, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,0.000000, 268.000000);
is-approx($r, 10013675.0566307, :$rel-tol); # perl 5: delta_ok
is-approx($a, 273.008712433203, :abs-tol<0.0001>); #delta_within($a, 273.008712433203, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,88.000000, 1.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(88.000000, 1.000000,88.000000, 90.000000);
is-approx($r, 313115.736403702, :$rel-tol); # perl 5: delta_ok
is-approx($a, 45.5174540384878, :abs-tol<0.0001>); #delta_within($a, 45.5174540384878, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,88.000000, 179.000000);
is-approx($r, 446706.010760529, :$rel-tol); # perl 5: delta_ok
is-approx($a, 1.00060941707181, :abs-tol<0.0001>); #delta_within($a, 1.00060941707181, 0.0001);

($r, $a) = $e.to(88.000000, 1.000000,88.000000, 268.000000);
is-approx($r, 324047.278966282, :$rel-tol); # perl 5: delta_ok
is-approx($a, 316.482566859219, :abs-tol<0.0001>); #delta_within($a, 316.482566859219, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,-88.000000, 1.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 224.524857451104, :abs-tol<0.0001>); #delta_within($a, 224.524857451104, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,-88.000000, 90.000000);
is-approx($r, 19557157.3743612, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,-88.000000, 179.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 135.475142548896, :abs-tol<0.0001>); #delta_within($a, 135.475142548896, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,-88.000000, 268.000000);
is-approx($r, 19996176.9000454, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90.9888413924734, :abs-tol<0.0001>); #delta_within($a, 90.9888413924734, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,0.000000, 1.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 269.011158607559, :abs-tol<0.0001>); #delta_within($a, 269.011158607559, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,0.000000, 90.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,0.000000, 179.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90.988841392441, :abs-tol<0.0001>); #delta_within($a, 90.988841392441, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,0.000000, 268.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 2.00084925741569, :abs-tol<0.0001>); #delta_within($a, 2.00084925741569, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,88.000000, 1.000000);
is-approx($r, 313115.736403702, :$rel-tol); # perl 5: delta_ok
is-approx($a, 314.482545961512, :abs-tol<0.0001>); #delta_within($a, 314.482545961512, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,88.000000, 90.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(88.000000, 90.000000,88.000000, 179.000000);
is-approx($r, 313115.736403702, :$rel-tol); # perl 5: delta_ok
is-approx($a, 45.5174540384878, :abs-tol<0.0001>); #delta_within($a, 45.5174540384878, 0.0001);

($r, $a) = $e.to(88.000000, 90.000000,88.000000, 268.000000);
is-approx($r, 446706.010760529, :$rel-tol); # perl 5: delta_ok
is-approx($a, 1.00060941707181, :abs-tol<0.0001>); #delta_within($a, 1.00060941707181, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,-88.000000, 1.000000);
is-approx($r, 19996176.9000454, :$rel-tol); # perl 5: delta_ok
is-approx($a, 269.011158607527, :abs-tol<0.0001>); #delta_within($a, 269.011158607527, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,-88.000000, 90.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 224.524857451104, :abs-tol<0.0001>); #delta_within($a, 224.524857451104, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,-88.000000, 179.000000);
is-approx($r, 19557157.3743612, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,-88.000000, 268.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 135.475142548896, :abs-tol<0.0001>); #delta_within($a, 135.475142548896, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,0.000000, 1.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 357.999150742584, :abs-tol<0.0001>); #delta_within($a, 357.999150742584, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,0.000000, 90.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 269.011158607559, :abs-tol<0.0001>); #delta_within($a, 269.011158607559, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,0.000000, 179.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,0.000000, 268.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90.988841392441, :abs-tol<0.0001>); #delta_within($a, 90.988841392441, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,88.000000, 1.000000);
is-approx($r, 446706.010760529, :$rel-tol); # perl 5: delta_ok
is-approx($a, 358.999390582928, :abs-tol<0.0001>); #delta_within($a, 358.999390582928, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,88.000000, 90.000000);
is-approx($r, 313115.736403702, :$rel-tol); # perl 5: delta_ok
is-approx($a, 314.482545961512, :abs-tol<0.0001>); #delta_within($a, 314.482545961512, 0.0001);

($r, $a) = $e.to(88.000000, 179.000000,88.000000, 179.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(88.000000, 179.000000,88.000000, 268.000000);
is-approx($r, 313115.736403702, :$rel-tol); # perl 5: delta_ok
is-approx($a, 45.5174540384878, :abs-tol<0.0001>); #delta_within($a, 45.5174540384878, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,-88.000000, 1.000000);
is-approx($r, 19696447.0104273, :$rel-tol); # perl 5: delta_ok
is-approx($a, 133.474906296864, :abs-tol<0.0001>); #delta_within($a, 133.474906296864, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,-88.000000, 90.000000);
is-approx($r, 19996176.9000454, :$rel-tol); # perl 5: delta_ok
is-approx($a, 269.011158607527, :abs-tol<0.0001>); #delta_within($a, 269.011158607527, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,-88.000000, 179.000000);
is-approx($r, 19685321.6740635, :$rel-tol); # perl 5: delta_ok
is-approx($a, 224.524857451104, :abs-tol<0.0001>); #delta_within($a, 224.524857451104, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,-88.000000, 268.000000);
is-approx($r, 19557157.3743612, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,0.000000, 1.000000);
is-approx($r, 10013675.0566307, :$rel-tol); # perl 5: delta_ok
is-approx($a, 86.9912875667967, :abs-tol<0.0001>); #delta_within($a, 86.9912875667967, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,0.000000, 90.000000);
is-approx($r, 10225216.6599337, :$rel-tol); # perl 5: delta_ok
is-approx($a, 357.999150742584, :abs-tol<0.0001>); #delta_within($a, 357.999150742584, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,0.000000, 179.000000);
is-approx($r, 9998088.45002268, :$rel-tol); # perl 5: delta_ok
is-approx($a, 269.011158607559, :abs-tol<0.0001>); #delta_within($a, 269.011158607559, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,0.000000, 268.000000);
is-approx($r, 9778578.68718058, :$rel-tol); # perl 5: delta_ok
is-approx($a, 180, :abs-tol<0.0001>); #delta_within($a, 180, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,88.000000, 1.000000);
is-approx($r, 324047.278966282, :$rel-tol); # perl 5: delta_ok
is-approx($a, 43.5174331407808, :abs-tol<0.0001>); #delta_within($a, 43.5174331407808, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,88.000000, 90.000000);
is-approx($r, 446706.010760529, :$rel-tol); # perl 5: delta_ok
is-approx($a, 358.999390582928, :abs-tol<0.0001>); #delta_within($a, 358.999390582928, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,88.000000, 179.000000);
is-approx($r, 313115.736403702, :$rel-tol); # perl 5: delta_ok
is-approx($a, 314.482545961512, :abs-tol<0.0001>); #delta_within($a, 314.482545961512, 0.0001);

($r, $a) = $e.to(88.000000, 268.000000,88.000000, 268.000000);
is-approx($r, 0, :abs-tol<0.1>); #delta_within($r, 0, 0.1);

($r, $a) = $e.to(-57.934266, 269.464909,-71.038589, 313.367482);
is-approx($r, 2478983.26981422, :$rel-tol); # perl 5: delta_ok
is-approx($a, 143.395603607968, :abs-tol<0.0001>); #delta_within($a, 143.395603607968, 0.0001);

($r, $a) = $e.to(13.605417, 282.316135,33.826171, 132.755857);
is-approx($r, 13850451.7048934, :$rel-tol); # perl 5: delta_ok
is-approx($a, 329.412475743044, :abs-tol<0.0001>); #delta_within($a, 329.412475743044, 0.0001);

($r, $a) = $e.to(65.807118, 267.744045,-9.495920, 127.342153);
is-approx($r, 13064794.3870629, :$rel-tol); # perl 5: delta_ok
is-approx($a, 314.966396589062, :abs-tol<0.0001>); #delta_within($a, 314.966396589062, 0.0001);

($r, $a) = $e.to(40.923455, 94.159476,-18.604296, 279.644382);
is-approx($r, 17475952.9859877, :$rel-tol); # perl 5: delta_ok
is-approx($a, 346.682016294252, :abs-tol<0.0001>); #delta_within($a, 346.682016294252, 0.0001);

($r, $a) = $e.to(60.726184, 207.132176,37.934793, 29.881529);
is-approx($r, 9065819.55603936, :$rel-tol); # perl 5: delta_ok
is-approx($a, 357.809015839191, :abs-tol<0.0001>); #delta_within($a, 357.809015839191, 0.0001);

($r, $a) = $e.to(-7.774777, 40.360959,7.960132, 140.647165);
is-approx($r, 11262132.6431769, :$rel-tol); # perl 5: delta_ok
is-approx($a, 83.4278273130909, :abs-tol<0.0001>); #delta_within($a, 83.4278273130909, 0.0001);

($r, $a) = $e.to(12.071034, 344.345789,64.718561, 58.748224);
is-approx($r, 8059002.00518262, :$rel-tol); # perl 5: delta_ok
is-approx($a, 25.6350676733314, :abs-tol<0.0001>); #delta_within($a, 25.6350676733314, 0.0001);

($r, $a) = $e.to(-39.510429, 94.209272,74.640675, 156.932149);
is-approx($r, 13463843.6928142, :$rel-tol); # perl 5: delta_ok
is-approx($a, 16.0430701128036, :abs-tol<0.0001>); #delta_within($a, 16.0430701128036, 0.0001);

($r, $a) = $e.to(50.945112, 46.686892,-73.531799, 338.631126);
is-approx($r, 14726732.6094757, :$rel-tol); # perl 5: delta_ok
is-approx($a, 201.007479159506, :abs-tol<0.0001>); #delta_within($a, 201.007479159506, 0.0001);

($r, $a) = $e.to(-83.498813, 56.207513,-20.735893, 55.705212);
is-approx($r, 6982046.80533501, :$rel-tol); # perl 5: delta_ok
is-approx($a, 359.4713992725, :abs-tol<0.0001>); #delta_within($a, 359.4713992725, 0.0001);

($r, $a) = $e.to(5.162682, 314.911760,-12.212387, 95.006241);
is-approx($r, 15580306.134578, :$rel-tol); # perl 5: delta_ok
is-approx($a, 102.90535353589, :abs-tol<0.0001>); #delta_within($a, 102.90535353589, 0.0001);

($r, $a) = $e.to(-32.807368, 276.692824,-69.099205, 277.575212);
is-approx($r, 4037491.56639158, :$rel-tol); # perl 5: delta_ok
is-approx($a, 179.466380802463, :abs-tol<0.0001>); #delta_within($a, 179.466380802463, 0.0001);

($r, $a) = $e.to(36.114418, 79.272998,46.075743, 148.216696);
is-approx($r, 5712966.86704551, :$rel-tol); # perl 5: delta_ok
is-approx($a, 56.1362395061731, :abs-tol<0.0001>); #delta_within($a, 56.1362395061731, 0.0001);

($r, $a) = $e.to(26.193521, 333.924339,0.425668, 247.478645);
is-approx($r, 9639530.83300946, :$rel-tol); # perl 5: delta_ok
is-approx($a, 268.930507164728, :abs-tol<0.0001>); #delta_within($a, 268.930507164728, 0.0001);

($r, $a) = $e.to(-11.247993, 218.771725,13.474320, 227.743816);
is-approx($r, 2908081.0984665, :$rel-tol); # perl 5: delta_ok
is-approx($a, 20.1557316624214, :abs-tol<0.0001>); #delta_within($a, 20.1557316624214, 0.0001);

($r, $a) = $e.to(-6.437086, 227.343277,-63.660092, 345.874110);
is-approx($r, 10716663.132942, :$rel-tol); # perl 5: delta_ok
is-approx($a, 156.867043901473, :abs-tol<0.0001>); #delta_within($a, 156.867043901473, 0.0001);

($r, $a) = $e.to(-62.590000, 160.912539,-30.873135, 342.930268);
is-approx($r, 9642768.3047107, :$rel-tol); # perl 5: delta_ok
is-approx($a, 181.732680684942, :abs-tol<0.0001>); #delta_within($a, 181.732680684942, 0.0001);

($r, $a) = $e.to(-24.959632, 143.558544,-70.174449, 343.830865);
is-approx($r, 9331596.49998794, :$rel-tol); # perl 5: delta_ok
is-approx($a, 186.797641578604, :abs-tol<0.0001>); #delta_within($a, 186.797641578604, 0.0001);

($r, $a) = $e.to(85.292583, 207.197289,64.400817, 53.955321);
is-approx($r, 3334743.62344139, :$rel-tol); # perl 5: delta_ok
is-approx($a, 337.012768638466, :abs-tol<0.0001>); #delta_within($a, 337.012768638466, 0.0001);

($r, $a) = $e.to(72.010476, 234.148398,-76.760490, 343.799779);
is-approx($r, 17966012.0923903, :$rel-tol); # perl 5: delta_ok
is-approx($a, 136.471695744589, :abs-tol<0.0001>); #delta_within($a, 136.471695744589, 0.0001);

($r, $a) = $e.to(82.062247, 282.224532,53.709008, 205.651325);
is-approx($r, 3925232.39059218, :$rel-tol); # perl 5: delta_ok
is-approx($a, 267.548713448222, :abs-tol<0.0001>); #delta_within($a, 267.548713448222, 0.0001);

($r, $a) = $e.to(-38.264913, 345.593277,13.987962, 157.269106);
is-approx($r, 17193609.7687517, :$rel-tol); # perl 5: delta_ok
is-approx($a, 161.114003589302, :abs-tol<0.0001>); #delta_within($a, 161.114003589302, 0.0001);

($r, $a) = $e.to(-21.923233, 331.579924,-82.948909, 276.789592);
is-approx($r, 7136933.98147936, :$rel-tol); # perl 5: delta_ok
is-approx($a, 186.41943112575, :abs-tol<0.0001>); #delta_within($a, 186.41943112575, 0.0001);

($r, $a) = $e.to(39.266792, 212.567027,-13.043617, 231.171501);
is-approx($r, 6104433.98020838, :$rel-tol); # perl 5: delta_ok
is-approx($a, 157.632255571465, :abs-tol<0.0001>); #delta_within($a, 157.632255571465, 0.0001);

($r, $a) = $e.to(43.430240, 25.708641,-78.620089, 278.752912);
is-approx($r, 15067414.5790259, :$rel-tol); # perl 5: delta_ok
is-approx($a, 195.703317974022, :abs-tol<0.0001>); #delta_within($a, 195.703317974022, 0.0001);

($r, $a) = $e.to(35.816613, 44.413390,-34.595103, 26.822827);
is-approx($r, 8006275.94631107, :$rel-tol); # perl 5: delta_ok
is-approx($a, 195.212777836564, :abs-tol<0.0001>); #delta_within($a, 195.212777836564, 0.0001);

($r, $a) = $e.to(33.063322, 131.654287,40.382161, 70.051002);
is-approx($r, 5452116.89026308, :$rel-tol); # perl 5: delta_ok
is-approx($a, 297.235375347757, :abs-tol<0.0001>); #delta_within($a, 297.235375347757, 0.0001);

($r, $a) = $e.to(-60.791775, 58.921675,58.472988, 198.337306);
is-approx($r, 17744632.7153385, :$rel-tol); # perl 5: delta_ok
is-approx($a, 78.646083333167, :abs-tol<0.0001>); #delta_within($a, 78.646083333167, 0.0001);

($r, $a) = $e.to(-32.182827, 189.929621,-11.752936, 76.924247);
is-approx($r, 11405061.5799716, :$rel-tol); # perl 5: delta_ok
is-approx($a, 247.228653711236, :abs-tol<0.0001>); #delta_within($a, 247.228653711236, 0.0001);

($r, $a) = $e.to(40.410413, 1.490210,15.171991, 171.877678);
is-approx($r, 13771611.4326195, :$rel-tol); # perl 5: delta_ok
is-approx($a, 11.1215097915429, :abs-tol<0.0001>); #delta_within($a, 11.1215097915429, 0.0001);

($r, $a) = $e.to(77.415003, 273.852765,-65.518823, 5.320166);
is-approx($r, 16984526.9730499, :$rel-tol); # perl 5: delta_ok
is-approx($a, 114.317943803113, :abs-tol<0.0001>); #delta_within($a, 114.317943803113, 0.0001);

($r, $a) = $e.to(-0.001169, 303.428210,61.978146, 32.763058);
is-approx($r, 9970926.02740749, :$rel-tol); # perl 5: delta_ok
is-approx($a, 28.100737553144, :abs-tol<0.0001>); #delta_within($a, 28.100737553144, 0.0001);

($r, $a) = $e.to(62.964471, 283.438450,13.811810, 35.816077);
is-approx($r, 9733041.79438803, :$rel-tol); # perl 5: delta_ok
is-approx($a, 63.9173979767126, :abs-tol<0.0001>); #delta_within($a, 63.9173979767126, 0.0001);

($r, $a) = $e.to(57.757522, 268.496370,71.873398, 184.371272);
is-approx($r, 3887427.27158255, :$rel-tol); # perl 5: delta_ok
is-approx($a, 327.17462331126, :abs-tol<0.0001>); #delta_within($a, 327.17462331126, 0.0001);

($r, $a) = $e.to(67.683592, 345.377181,11.705901, 170.600523);
is-approx($r, 11188758.804159, :$rel-tol); # perl 5: delta_ok
is-approx($a, 354.806955928828, :abs-tol<0.0001>); #delta_within($a, 354.806955928828, 0.0001);

($r, $a) = $e.to(-14.509993, 233.823561,66.915477, 210.936486);
is-approx($r, 9223027.54994791, :$rel-tol); # perl 5: delta_ok
is-approx($a, 351.122612522391, :abs-tol<0.0001>); #delta_within($a, 351.122612522391, 0.0001);

($r, $a) = $e.to(-48.837869, 358.766092,-59.984409, 250.415053);
is-approx($r, 6331138.72714117, :$rel-tol); # perl 5: delta_ok
is-approx($a, 214.601548309314, :abs-tol<0.0001>); #delta_within($a, 214.601548309314, 0.0001);

($r, $a) = $e.to(35.469166, 354.061624,26.153177, 235.757036);
is-approx($r, 10606793.2549714, :$rel-tol); # perl 5: delta_ok
is-approx($a, 307.54615644259, :abs-tol<0.0001>); #delta_within($a, 307.54615644259, 0.0001);

($r, $a) = $e.to(60.579911, 245.073600,82.746095, 119.397052);
is-approx($r, 3807870.32524918, :$rel-tol); # perl 5: delta_ok
is-approx($a, 349.456168279081, :abs-tol<0.0001>); #delta_within($a, 349.456168279081, 0.0001);

($r, $a) = $e.to(52.814462, 58.052386,63.937125, 216.992405);
is-approx($r, 6929484.96260079, :$rel-tol); # perl 5: delta_ok
is-approx($a, 10.2919524401595, :abs-tol<0.0001>); #delta_within($a, 10.2919524401595, 0.0001);

($r, $a) = $e.to(-14.087235, 352.325834,64.925852, 167.053343);
is-approx($r, 14344572.4591005, :$rel-tol); # perl 5: delta_ok
is-approx($a, 2.87132324469977, :abs-tol<0.0001>); #delta_within($a, 2.87132324469977, 0.0001);

($r, $a) = $e.to(-44.555528, 303.380598,60.410717, 265.142366);
is-approx($r, 12142365.0295713, :$rel-tol); # perl 5: delta_ok
is-approx($a, 341.013133837574, :abs-tol<0.0001>); #delta_within($a, 341.013133837574, 0.0001);

($r, $a) = $e.to(-64.733717, 171.696178,50.043309, 179.133361);
is-approx($r, 12743611.5768642, :$rel-tol); # perl 5: delta_ok
is-approx($a, 5.27317915617838, :abs-tol<0.0001>); #delta_within($a, 5.27317915617838, 0.0001);

($r, $a) = $e.to(12.112040, 159.973637,-81.799749, 119.465377);
is-approx($r, 10640434.6234949, :$rel-tol); # perl 5: delta_ok
is-approx($a, 185.36408498589, :abs-tol<0.0001>); #delta_within($a, 185.36408498589, 0.0001);

($r, $a) = $e.to(-12.913136, 209.560123,-72.500921, 242.959763);
is-approx($r, 6973908.49631601, :$rel-tol); # perl 5: delta_ok
is-approx($a, 169.226215342821, :abs-tol<0.0001>); #delta_within($a, 169.226215342821, 0.0001);

($r, $a) = $e.to(15.388763, 85.383404,43.057681, 345.007357);
is-approx($r, 9674590.63953447, :$rel-tol); # perl 5: delta_ok
is-approx($a, 313.920881630087, :abs-tol<0.0001>); #delta_within($a, 313.920881630087, 0.0001);

($r, $a) = $e.to(64.108958, 27.645978,7.006558, 137.813405);
is-approx($r, 10265664.1927237, :$rel-tol); # perl 5: delta_ok
is-approx($a, 68.7123060867185, :abs-tol<0.0001>); #delta_within($a, 68.7123060867185, 0.0001);

($r, $a) = $e.to(-87.675134, 257.547959,-78.556203, 7.576067);
is-approx($r, 1388279.96503049, :$rel-tol); # perl 5: delta_ok
is-approx($a, 120.008321576532, :abs-tol<0.0001>); #delta_within($a, 120.008321576532, 0.0001);

($r, $a) = $e.to(45.506762, 226.167856,75.858502, 197.258652);
is-approx($r, 3642825.04801401, :$rel-tol); # perl 5: delta_ok
is-approx($a, 347.342287196448, :abs-tol<0.0001>); #delta_within($a, 347.342287196448, 0.0001);

($r, $a) = $e.to(-15.130062, 141.680058,-53.226032, 110.910346);
is-approx($r, 5012011.5716539, :$rel-tol); # perl 5: delta_ok
is-approx($a, 205.717239120564, :abs-tol<0.0001>); #delta_within($a, 205.717239120564, 0.0001);

($r, $a) = $e.to(-51.171998, 219.770710,-22.538592, 57.834091);
is-approx($r, 11650461.6034958, :$rel-tol); # perl 5: delta_ok
is-approx($a, 197.174001590393, :abs-tol<0.0001>); #delta_within($a, 197.174001590393, 0.0001);

($r, $a) = $e.to(-7.000668, 288.466856,-55.716970, 258.457540);
is-approx($r, 6017359.40295353, :$rel-tol); # perl 5: delta_ok
is-approx($a, 200.419276815272, :abs-tol<0.0001>); #delta_within($a, 200.419276815272, 0.0001);

($r, $a) = $e.to(-4.103181, 51.748045,23.523933, 87.322753);
is-approx($r, 4923654.59463329, :$rel-tol); # perl 5: delta_ok
is-approx($a, 49.9333838628388, :abs-tol<0.0001>); #delta_within($a, 49.9333838628388, 0.0001);

($r, $a) = $e.to(-66.149558, 312.989638,-69.799797, 271.586522);
is-approx($r, 1743562.46751605, :$rel-tol); # perl 5: delta_ok
is-approx($a, 238.030177426519, :abs-tol<0.0001>); #delta_within($a, 238.030177426519, 0.0001);

($r, $a) = $e.to(-21.017857, 200.311309,-74.230046, 135.855002);
is-approx($r, 7005716.26957978, :$rel-tol); # perl 5: delta_ok
is-approx($a, 196.029492653125, :abs-tol<0.0001>); #delta_within($a, 196.029492653125, 0.0001);

($r, $a) = $e.to(22.032424, 283.684581,-13.840647, 296.727744);
is-approx($r, 4215876.49472136, :$rel-tol); # perl 5: delta_ok
is-approx($a, 159.073330859259, :abs-tol<0.0001>); #delta_within($a, 159.073330859259, 0.0001);

($r, $a) = $e.to(9.137311, 261.695802,-1.968743, 94.386354);
is-approx($r, 18415518.434645, :$rel-tol); # perl 5: delta_ok
is-approx($a, 299.740904431686, :abs-tol<0.0001>); #delta_within($a, 299.740904431686, 0.0001);

($r, $a) = $e.to(-0.367684, 176.265124,-1.495746, 305.845852);
is-approx($r, 14421564.897997, :$rel-tol); # perl 5: delta_ok
is-approx($a, 92.2533762539934, :abs-tol<0.0001>); #delta_within($a, 92.2533762539934, 0.0001);

($r, $a) = $e.to(73.726080, 130.581316,8.059198, 217.631502);
is-approx($r, 9055964.88324431, :$rel-tol); # perl 5: delta_ok
is-approx($a, 90.4838402750219, :abs-tol<0.0001>); #delta_within($a, 90.4838402750219, 0.0001);

($r, $a) = $e.to(19.299877, 158.813658,36.382896, 77.814439);
is-approx($r, 7978668.24478752, :$rel-tol); # perl 5: delta_ok
is-approx($a, 303.044909439054, :abs-tol<0.0001>); #delta_within($a, 303.044909439054, 0.0001);

($r, $a) = $e.to(46.759530, 110.686586,50.379077, 32.324924);
is-approx($r, 5522070.40672904, :$rel-tol); # perl 5: delta_ok
is-approx($a, 304.786480351645, :abs-tol<0.0001>); #delta_within($a, 304.786480351645, 0.0001);

($r, $a) = $e.to(70.152840, 335.224848,82.259265, 222.676574);
is-approx($r, 2664806.26132369, :$rel-tol); # perl 5: delta_ok
is-approx($a, 342.089448894924, :abs-tol<0.0001>); #delta_within($a, 342.089448894924, 0.0001);

($r, $a) = $e.to(-76.222244, 41.464968,22.995327, 26.717480);
is-approx($r, 11054300.8320442, :$rel-tol); # perl 5: delta_ok
is-approx($a, 346.229809972732, :abs-tol<0.0001>); #delta_within($a, 346.229809972732, 0.0001);

($r, $a) = $e.to(10.103669, 84.844998,19.705372, 336.438821);
is-approx($r, 11523412.006604, :$rel-tol); # perl 5: delta_ok
is-approx($a, 293.284547184865, :abs-tol<0.0001>); #delta_within($a, 293.284547184865, 0.0001);

($r, $a) = $e.to(12.619602, 206.584638,-6.260003, 43.507509);
is-approx($r, 18046314.1453549, :$rel-tol); # perl 5: delta_ok
is-approx($a, 289.873007821456, :abs-tol<0.0001>); #delta_within($a, 289.873007821456, 0.0001);

($r, $a) = $e.to(-46.431748, 358.501506,10.070717, 310.960507);
is-approx($r, 7840004.49282381, :$rel-tol); # perl 5: delta_ok
is-approx($a, 309.499327919992, :abs-tol<0.0001>); #delta_within($a, 309.499327919992, 0.0001);

($r, $a) = $e.to(-37.466916, 262.319964,56.541387, 175.943954);
is-approx($r, 13175801.2840537, :$rel-tol); # perl 5: delta_ok
is-approx($a, 321.047143676273, :abs-tol<0.0001>); #delta_within($a, 321.047143676273, 0.0001);

($r, $a) = $e.to(16.376357, 41.153536,-60.139286, 251.664078);
is-approx($r, 14563419.7032954, :$rel-tol); # perl 5: delta_ok
is-approx($a, 199.553357833555, :abs-tol<0.0001>); #delta_within($a, 199.553357833555, 0.0001);

($r, $a) = $e.to(16.688504, 317.111550,-12.125937, 75.628131);
is-approx($r, 13409094.6209134, :$rel-tol); # perl 5: delta_ok
is-approx($a, 94.363475724486, :abs-tol<0.0001>); #delta_within($a, 94.363475724486, 0.0001);

($r, $a) = $e.to(-55.936936, 247.119658,-49.609989, 95.206424);
is-approx($r, 8019595.70546293, :$rel-tol); # perl 5: delta_ok
is-approx($a, 198.711523711379, :abs-tol<0.0001>); #delta_within($a, 198.711523711379, 0.0001);

($r, $a) = $e.to(-48.734356, 177.370827,-40.864142, 160.579825);
is-approx($r, 1585126.11176859, :$rel-tol); # perl 5: delta_ok
is-approx($a, 297.197389057407, :abs-tol<0.0001>); #delta_within($a, 297.197389057407, 0.0001);

($r, $a) = $e.to(-46.420266, 107.250326,26.510982, 269.915143);
is-approx($r, 17322878.3638282, :$rel-tol); # perl 5: delta_ok
is-approx($a, 139.796923668858, :abs-tol<0.0001>); #delta_within($a, 139.796923668858, 0.0001);

($r, $a) = $e.to(33.895806, 153.110909,45.681845, 143.422437);
is-approx($r, 1546932.16434011, :$rel-tol); # perl 5: delta_ok
is-approx($a, 330.633136925071, :abs-tol<0.0001>); #delta_within($a, 330.633136925071, 0.0001);

($r, $a) = $e.to(-22.177541, 230.512649,5.952076, 323.707746);
is-approx($r, 10591953.1790129, :$rel-tol); # perl 5: delta_ok
is-approx($a, 85.7970967849502, :abs-tol<0.0001>); #delta_within($a, 85.7970967849502, 0.0001);

($r, $a) = $e.to(27.348830, 334.178805,-86.270375, 62.080991);
is-approx($r, 13006113.218666, :$rel-tol); # perl 5: delta_ok
is-approx($a, 175.799365534158, :abs-tol<0.0001>); #delta_within($a, 175.799365534158, 0.0001);

($r, $a) = $e.to(25.235341, 275.242036,31.035045, 277.375893);
is-approx($r, 676004.612711586, :$rel-tol); # perl 5: delta_ok
is-approx($a, 17.5689229834593, :abs-tol<0.0001>); #delta_within($a, 17.5689229834593, 0.0001);

($r, $a) = $e.to(44.964609, 321.744934,-49.665325, 229.175856);
is-approx($r, 13769363.5529944, :$rel-tol); # perl 5: delta_ok
is-approx($a, 231.396822356016, :abs-tol<0.0001>); #delta_within($a, 231.396822356016, 0.0001);

($r, $a) = $e.to(17.105270, 223.789909,-23.725503, 25.530801);
is-approx($r, 17989959.0909754, :$rel-tol); # perl 5: delta_ok
is-approx($a, 114.55421109574, :abs-tol<0.0001>); #delta_within($a, 114.55421109574, 0.0001);

($r, $a) = $e.to(-43.562030, 130.274241,-2.881152, 181.334105);
is-approx($r, 6743615.83724109, :$rel-tol); # perl 5: delta_ok
is-approx($a, 63.1354501704683, :abs-tol<0.0001>); #delta_within($a, 63.1354501704683, 0.0001);

($r, $a) = $e.to(-36.975702, 86.458774,28.597533, 323.170028);
is-approx($r, 14709618.4240825, :$rel-tol); # perl 5: delta_ok
is-approx($a, 276.991231019081, :abs-tol<0.0001>); #delta_within($a, 276.991231019081, 0.0001);

($r, $a) = $e.to(30.175209, 16.459075,59.419522, 205.929510);
is-approx($r, 10036719.5388652, :$rel-tol); # perl 5: delta_ok
is-approx($a, 355.197249821978, :abs-tol<0.0001>); #delta_within($a, 355.197249821978, 0.0001);

($r, $a) = $e.to(-55.644950, 10.465550,-4.344329, 202.739897);
is-approx($r, 13260281.1799076, :$rel-tol); # perl 5: delta_ok
is-approx($a, 194.001768323124, :abs-tol<0.0001>); #delta_within($a, 194.001768323124, 0.0001);

($r, $a) = $e.to(-58.450106, 219.537369,25.011231, 110.301202);
is-approx($r, 13454859.3055112, :$rel-tol); # perl 5: delta_ok
is-approx($a, 267.595411116428, :abs-tol<0.0001>); #delta_within($a, 267.595411116428, 0.0001);

($r, $a) = $e.to(80.393984, 275.211192,23.935568, 24.731901);
is-approx($r, 7745665.22175974, :$rel-tol); # perl 5: delta_ok
is-approx($a, 66.7895730503046, :abs-tol<0.0001>); #delta_within($a, 66.7895730503046, 0.0001);

($r, $a) = $e.to(-65.005040, 272.050479,-3.463969, 257.290127);
is-approx($r, 6929926.85789333, :$rel-tol); # perl 5: delta_ok
is-approx($a, 343.292530540849, :abs-tol<0.0001>); #delta_within($a, 343.292530540849, 0.0001);

($r, $a) = $e.to(-67.713271, 230.359203,-17.890516, 254.265464);
is-approx($r, 5790460.28705559, :$rel-tol); # perl 5: delta_ok
is-approx($a, 29.3042376067398, :abs-tol<0.0001>); #delta_within($a, 29.3042376067398, 0.0001);

($r, $a) = $e.to(49.977476, 253.413450,-40.736808, 280.971459);
is-approx($r, 10404674.0369978, :$rel-tol); # perl 5: delta_ok
is-approx($a, 159.351345995222, :abs-tol<0.0001>); #delta_within($a, 159.351345995222, 0.0001);

($r, $a) = $e.to(-64.390959, 100.137796,-73.699237, 76.773535);
is-approx($r, 1377371.39603648, :$rel-tol); # perl 5: delta_ok
is-approx($a, 211.403175640332, :abs-tol<0.0001>); #delta_within($a, 211.403175640332, 0.0001);

($r, $a) = $e.to(-53.488147, 222.676284,18.783198, 197.750208);
is-approx($r, 8357066.17548392, :$rel-tol); # perl 5: delta_ok
is-approx($a, 335.565188497479, :abs-tol<0.0001>); #delta_within($a, 335.565188497479, 0.0001);

($r, $a) = $e.to(11.886353, 45.880034,-75.325990, 317.821511);
is-approx($r, 11219022.8120392, :$rel-tol); # perl 5: delta_ok
is-approx($a, 194.994234182454, :abs-tol<0.0001>); #delta_within($a, 194.994234182454, 0.0001);

($r, $a) = $e.to(-61.023376, 203.548199,-32.274576, 120.526333);
is-approx($r, 6560175.49592739, :$rel-tol); # perl 5: delta_ok
is-approx($a, 258.557806173273, :abs-tol<0.0001>); #delta_within($a, 258.557806173273, 0.0001);

($r, $a) = $e.to(-51.815775, 243.103403,-81.006002, 15.254084);
is-approx($r, 4980459.53607217, :$rel-tol); # perl 5: delta_ok
is-approx($a, 170.496737342413, :abs-tol<0.0001>); #delta_within($a, 170.496737342413, 0.0001);

($r, $a) = $e.to(55.609307, 24.137667,36.573196, 147.424699);
is-approx($r, 8467114.65823862, :$rel-tol); # perl 5: delta_ok
is-approx($a, 43.7496416993868, :abs-tol<0.0001>); #delta_within($a, 43.7496416993868, 0.0001);

($r, $a) = $e.to(68.261410, 337.404883,-87.468266, 126.278650);
is-approx($r, 17814444.0832232, :$rel-tol); # perl 5: delta_ok
is-approx($a, 176.099040884626, :abs-tol<0.0001>); #delta_within($a, 176.099040884626, 0.0001);

($r, $a) = $e.to(77.163243, 355.929440,-24.865636, 351.624329);
is-approx($r, 11323314.1064423, :$rel-tol); # perl 5: delta_ok
is-approx($a, 183.999262418074, :abs-tol<0.0001>); #delta_within($a, 183.999262418074, 0.0001);

($r, $a) = $e.to(-83.363412, 123.109687,60.930467, 157.757983);
is-approx($r, 16129090.5382028, :$rel-tol); # perl 5: delta_ok
is-approx($a, 29.0390517827566, :abs-tol<0.0001>); #delta_within($a, 29.0390517827566, 0.0001);

($r, $a) = $e.to(35.819668, 205.275583,-69.790147, 65.110415);
is-approx($r, 15535352.6980755, :$rel-tol); # perl 5: delta_ok
is-approx($a, 200.069364324033, :abs-tol<0.0001>); #delta_within($a, 200.069364324033, 0.0001);

($r, $a) = $e.to(-45.720757, 245.961448,85.378805, 184.898940);
is-approx($r, 14801887.1990009, :$rel-tol); # perl 5: delta_ok
is-approx($a, 354.425186265008, :abs-tol<0.0001>); #delta_within($a, 354.425186265008, 0.0001);

($r, $a) = $e.to(70.557651, 168.120919,-4.512946, 146.711647);
is-approx($r, 8481627.39707062, :$rel-tol); # perl 5: delta_ok
is-approx($a, 202.024485782197, :abs-tol<0.0001>); #delta_within($a, 202.024485782197, 0.0001);

($r, $a) = $e.to(45.494490, 42.178744,-62.327500, 251.688039);
is-approx($r, 17356605.1087735, :$rel-tol); # perl 5: delta_ok
is-approx($a, 214.442967212505, :abs-tol<0.0001>); #delta_within($a, 214.442967212505, 0.0001);
