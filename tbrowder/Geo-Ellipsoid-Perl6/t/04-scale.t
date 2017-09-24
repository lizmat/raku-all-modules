# Test Geo::Ellipsoid scale

use v6;
use Test;

plan 180;

use Geo::Ellipsoid;

# This original Perl 5 test used the following test functions (the
# resulting Perl 6 versions are shown after the fat comma):
#
#   delta_ok => is-approx($a, $b, :$rel-tol)
#
#  From the Perl 5 test file:
#    use Test::Number::Delta relative => 1e-6;
#  which translates to:
my $rel-tol = 1e-6;

my $e = Geo::Ellipsoid.new(units => 'degrees');
my ($xs, $ys);

($ys, $xs) = $e.scales(0);
is-approx($xs, 111319.490793274, :$rel-tol);
is-approx($ys, 110574.275821594, :$rel-tol);

($ys, $xs) = $e.scales(1);
is-approx($xs, 111302.649769732, :$rel-tol);
is-approx($ys, 110574.614016816, :$rel-tol);

($ys, $xs) = $e.scales(2);
is-approx($xs, 111252.131520103, :$rel-tol);
is-approx($ys, 110575.628200778, :$rel-tol);

($ys, $xs) = $e.scales(3);
is-approx($xs, 111167.950506731, :$rel-tol);
is-approx($ys, 110577.317168814, :$rel-tol);

($ys, $xs) = $e.scales(4);
is-approx($xs, 111050.130831399, :$rel-tol);
is-approx($ys, 110579.678914611, :$rel-tol);

($ys, $xs) = $e.scales(5);
is-approx($xs, 110898.706232127, :$rel-tol);
is-approx($ys, 110582.710632409, :$rel-tol);

($ys, $xs) = $e.scales(6);
is-approx($xs, 110713.720078689, :$rel-tol);
is-approx($ys, 110586.408720072, :$rel-tol);

($ys, $xs) = $e.scales(7);
is-approx($xs, 110495.225366811, :$rel-tol);
is-approx($ys, 110590.768783042, :$rel-tol);

($ys, $xs) = $e.scales(8);
is-approx($xs, 110243.284711052, :$rel-tol);
is-approx($ys, 110595.785639154, :$rel-tol);

($ys, $xs) = $e.scales(9);
is-approx($xs, 109957.970336344, :$rel-tol);
is-approx($ys, 110601.453324332, :$rel-tol);

($ys, $xs) = $e.scales(10);
is-approx($xs, 109639.364068153, :$rel-tol);
is-approx($ys, 110607.765099137, :$rel-tol);

($ys, $xs) = $e.scales(11);
is-approx($xs, 109287.557321245, :$rel-tol);
is-approx($ys, 110614.713456187, :$rel-tol);

($ys, $xs) = $e.scales(12);
is-approx($xs, 108902.651087025, :$rel-tol);
is-approx($ys, 110622.290128422, :$rel-tol);

($ys, $xs) = $e.scales(13);
is-approx($xs, 108484.755919402, :$rel-tol);
is-approx($ys, 110630.486098225, :$rel-tol);

($ys, $xs) = $e.scales(14);
is-approx($xs, 108033.991919153, :$rel-tol);
is-approx($ys, 110639.291607378, :$rel-tol);

($ys, $xs) = $e.scales(15);
is-approx($xs, 107550.488716736, :$rel-tol);
is-approx($ys, 110648.696167862, :$rel-tol);

($ys, $xs) = $e.scales(16);
is-approx($xs, 107034.385453513, :$rel-tol);
is-approx($ys, 110658.688573475, :$rel-tol);

($ys, $xs) = $e.scales(17);
is-approx($xs, 106485.830761325, :$rel-tol);
is-approx($ys, 110669.256912276, :$rel-tol);

($ys, $xs) = $e.scales(18);
is-approx($xs, 105904.982740377, :$rel-tol);
is-approx($ys, 110680.388579831, :$rel-tol);

($ys, $xs) = $e.scales(19);
is-approx($xs, 105292.008935377, :$rel-tol);
is-approx($ys, 110692.070293263, :$rel-tol);

($ys, $xs) = $e.scales(20);
is-approx($xs, 104647.086309862, :$rel-tol);
is-approx($ys, 110704.288106085, :$rel-tol);

($ys, $xs) = $e.scales(21);
is-approx($xs, 103970.401218673, :$rel-tol);
is-approx($ys, 110717.027423818, :$rel-tol);

($ys, $xs) = $e.scales(22);
is-approx($xs, 103262.149378494, :$rel-tol);
is-approx($ys, 110730.273020361, :$rel-tol);

($ys, $xs) = $e.scales(23);
is-approx($xs, 102522.535836412, :$rel-tol);
is-approx($ys, 110744.00905512, :$rel-tol);

($ys, $xs) = $e.scales(24);
is-approx($xs, 101751.774936417, :$rel-tol);
is-approx($ys, 110758.21909087, :$rel-tol);

($ys, $xs) = $e.scales(25);
is-approx($xs, 100950.090283789, :$rel-tol);
is-approx($ys, 110772.88611234, :$rel-tol);

($ys, $xs) = $e.scales(26);
is-approx($xs, 100117.714707292, :$rel-tol);
is-approx($ys, 110787.992545504, :$rel-tol);

($ys, $xs) = $e.scales(27);
is-approx($xs, 99254.890219118, :$rel-tol);
is-approx($ys, 110803.520277558, :$rel-tol);

($ys, $xs) = $e.scales(28);
is-approx($xs, 98361.8679724994, :$rel-tol);
is-approx($ys, 110819.450677574, :$rel-tol);

($ys, $xs) = $e.scales(29);
is-approx($xs, 97438.9082169266, :$rel-tol);
is-approx($ys, 110835.764617804, :$rel-tol);

($ys, $xs) = $e.scales(30);
is-approx($xs, 96486.2802508965, :$rel-tol);
is-approx($ys, 110852.442495617, :$rel-tol);

($ys, $xs) = $e.scales(31);
is-approx($xs, 95504.2623721221, :$rel-tol);
is-approx($ys, 110869.464256056, :$rel-tol);

($ys, $xs) = $e.scales(32);
is-approx($xs, 94493.1418251297, :$rel-tol);
is-approx($ys, 110886.809414981, :$rel-tol);

($ys, $xs) = $e.scales(33);
is-approx($xs, 93453.2147461739, :$rel-tol);
is-approx($ys, 110904.457082788, :$rel-tol);

($ys, $xs) = $e.scales(34);
is-approx($xs, 92384.7861053995, :$rel-tol);
is-approx($ys, 110922.385988675, :$rel-tol);

($ys, $xs) = $e.scales(35);
is-approx($xs, 91288.1696461796, :$rel-tol);
is-approx($ys, 110940.574505431, :$rel-tol);

($ys, $xs) = $e.scales(36);
is-approx($xs, 90163.6878215616, :$rel-tol);
is-approx($ys, 110959.000674728, :$rel-tol);

($ys, $xs) = $e.scales(37);
is-approx($xs, 89011.6717277532, :$rel-tol);
is-approx($ys, 110977.642232884, :$rel-tol);

($ys, $xs) = $e.scales(38);
is-approx($xs, 87832.461034582, :$rel-tol);
is-approx($ys, 110996.476637075, :$rel-tol);

($ys, $xs) = $e.scales(39);
is-approx($xs, 86626.4039128637, :$rel-tol);
is-approx($ys, 111015.481091969, :$rel-tol);

($ys, $xs) = $e.scales(40);
is-approx($xs, 85393.8569586184, :$rel-tol);
is-approx($ys, 111034.632576751, :$rel-tol);

($ys, $xs) = $e.scales(41);
is-approx($xs, 84135.1851140718, :$rel-tol);
is-approx($ys, 111053.907872507, :$rel-tol);

($ys, $xs) = $e.scales(42);
is-approx($xs, 82850.7615853864, :$rel-tol);
is-approx($ys, 111073.283589948, :$rel-tol);

($ys, $xs) = $e.scales(43);
is-approx($xs, 81540.9677570662, :$rel-tol);
is-approx($ys, 111092.736197432, :$rel-tol);

($ys, $xs) = $e.scales(44);
is-approx($xs, 80206.1931029833, :$rel-tol);
is-approx($ys, 111112.242049253, :$rel-tol);

($ys, $xs) = $e.scales(45);
is-approx($xs, 78846.8350939781, :$rel-tol);
is-approx($ys, 111131.777414176, :$rel-tol);

($ys, $xs) = $e.scales(46);
is-approx($xs, 77463.2991019873, :$rel-tol);
is-approx($ys, 111151.318504168, :$rel-tol);

($ys, $xs) = $e.scales(47);
is-approx($xs, 76055.9983006586, :$rel-tol);
is-approx($ys, 111170.841503309, :$rel-tol);

($ys, $xs) = $e.scales(48);
is-approx($xs, 74625.3535624143, :$rel-tol);
is-approx($ys, 111190.322596824, :$rel-tol);

($ys, $xs) = $e.scales(49);
is-approx($xs, 73171.7933519306, :$rel-tol);
is-approx($ys, 111209.738000236, :$rel-tol);

($ys, $xs) = $e.scales(50);
is-approx($xs, 71695.753616003, :$rel-tol);
is-approx($ys, 111229.063988562, :$rel-tol);

($ys, $xs) = $e.scales(51);
is-approx($xs, 70197.6776697733, :$rel-tol);
is-approx($ys, 111248.276925556, :$rel-tol);

($ys, $xs) = $e.scales(52);
is-approx($xs, 68678.0160792985, :$rel-tol);
is-approx($ys, 111267.353292927, :$rel-tol);

($ys, $xs) = $e.scales(53);
is-approx($xs, 67137.2265404469, :$rel-tol);
is-approx($ys, 111286.269719523, :$rel-tol);

($ys, $xs) = $e.scales(54);
is-approx($xs, 65575.7737541096, :$rel-tol);
is-approx($ys, 111305.003010423, :$rel-tol);

($ys, $xs) = $e.scales(55);
is-approx($xs, 63994.1292977257, :$rel-tol);
is-approx($ys, 111323.530175906, :$rel-tol);

($ys, $xs) = $e.scales(56);
is-approx($xs, 62392.7714931183, :$rel-tol);
is-approx($ys, 111341.828460265, :$rel-tol);

($ys, $xs) = $e.scales(57);
is-approx($xs, 60772.1852706498, :$rel-tol);
is-approx($ys, 111359.875370412, :$rel-tol);

($ys, $xs) = $e.scales(58);
is-approx($xs, 59132.8620297075, :$rel-tol);
is-approx($ys, 111377.64870425, :$rel-tol);

($ys, $xs) = $e.scales(59);
is-approx($xs, 57475.2994955351, :$rel-tol);
is-approx($ys, 111395.12657876, :$rel-tol);

($ys, $xs) = $e.scales(60);
is-approx($xs, 55800.0015724362, :$rel-tol);
is-approx($ys, 111412.287457779, :$rel-tol);

($ys, $xs) = $e.scales(61);
is-approx($xs, 54107.4781933752, :$rel-tol);
is-approx($ys, 111429.110179413, :$rel-tol);

($ys, $xs) = $e.scales(62);
is-approx($xs, 52398.2451660134, :$rel-tol);
is-approx($ys, 111445.573983052, :$rel-tol);

($ys, $xs) = $e.scales(63);
is-approx($xs, 50672.8240152185, :$rel-tol);
is-approx($ys, 111461.65853596, :$rel-tol);

($ys, $xs) = $e.scales(64);
is-approx($xs, 48931.7418220956, :$rel-tol);
is-approx($ys, 111477.343959384, :$rel-tol);

($ys, $xs) = $e.scales(65);
is-approx($xs, 47175.5310595919, :$rel-tol);
is-approx($ys, 111492.610854148, :$rel-tol);

($ys, $xs) = $e.scales(66);
is-approx($xs, 45404.7294247327, :$rel-tol);
is-approx($ys, 111507.440325702, :$rel-tol);

($ys, $xs) = $e.scales(67);
is-approx($xs, 43619.8796675553, :$rel-tol);
is-approx($ys, 111521.814008585, :$rel-tol);

($ys, $xs) = $e.scales(68);
is-approx($xs, 41821.5294168082, :$rel-tol);
is-approx($ys, 111535.714090256, :$rel-tol);

($ys, $xs) = $e.scales(69);
is-approx($xs, 40010.2310024944, :$rel-tol);
is-approx($ys, 111549.12333427, :$rel-tol);

($ys, $xs) = $e.scales(70);
is-approx($xs, 38186.5412753387, :$rel-tol);
is-approx($ys, 111562.025102756, :$rel-tol);

($ys, $xs) = $e.scales(71);
is-approx($xs, 36351.0214232683, :$rel-tol);
is-approx($ys, 111574.403378166, :$rel-tol);

($ys, $xs) = $e.scales(72);
is-approx($xs, 34504.2367849983, :$rel-tol);
is-approx($ys, 111586.242784253, :$rel-tol);

($ys, $xs) = $e.scales(73);
is-approx($xs, 32646.7566608212, :$rel-tol);
is-approx($ys, 111597.52860626, :$rel-tol);

($ys, $xs) = $e.scales(74);
is-approx($xs, 30779.1541207048, :$rel-tol);
is-approx($ys, 111608.246810274, :$rel-tol);

($ys, $xs) = $e.scales(75);
is-approx($xs, 28902.0058098066, :$rel-tol);
is-approx($ys, 111618.38406172, :$rel-tol);

($ys, $xs) = $e.scales(76);
is-approx($xs, 27015.8917515192, :$rel-tol);
is-approx($ys, 111627.927742966, :$rel-tol);

($ys, $xs) = $e.scales(77);
is-approx($xs, 25121.3951481649, :$rel-tol);
is-approx($ys, 111636.865970013, :$rel-tol);

($ys, $xs) = $e.scales(78);
is-approx($xs, 23219.1021794639, :$rel-tol);
is-approx($ys, 111645.187608236, :$rel-tol);

($ys, $xs) = $e.scales(79);
is-approx($xs, 21309.6017989022, :$rel-tol);
is-approx($ys, 111652.882287157, :$rel-tol);

($ys, $xs) = $e.scales(80);
is-approx($xs, 19393.4855281322, :$rel-tol);
is-approx($ys, 111659.940414223, :$rel-tol);

($ys, $xs) = $e.scales(81);
is-approx($xs, 17471.3472495414, :$rel-tol);
is-approx($ys, 111666.35318757, :$rel-tol);

($ys, $xs) = $e.scales(82);
is-approx($xs, 15543.7829971289, :$rel-tol);
is-approx($ys, 111672.112607742, :$rel-tol);

($ys, $xs) = $e.scales(83);
is-approx($xs, 13611.3907458309, :$rel-tol);
is-approx($ys, 111677.211488361, :$rel-tol);

($ys, $xs) = $e.scales(84);
is-approx($xs, 11674.7701994437, :$rel-tol);
is-approx($ys, 111681.64346572, :$rel-tol);

($ys, $xs) = $e.scales(85);
is-approx($xs, 9734.52257729095, :$rel-tol);
is-approx($ys, 111685.403007281, :$rel-tol);

($ys, $xs) = $e.scales(86);
is-approx($xs, 7791.25039978636, :$rel-tol);
is-approx($ys, 111688.485419075, :$rel-tol);

($ys, $xs) = $e.scales(87);
is-approx($xs, 5845.55727304685, :$rel-tol);
is-approx($ys, 111690.886851982, :$rel-tol);

($ys, $xs) = $e.scales(88);
is-approx($xs, 3898.04767271025, :$rel-tol);
is-approx($ys, 111692.604306881, :$rel-tol);

($ys, $xs) = $e.scales(89);
is-approx($xs, 1949.32672711493, :$rel-tol);
is-approx($ys, 111693.635638667, :$rel-tol);
