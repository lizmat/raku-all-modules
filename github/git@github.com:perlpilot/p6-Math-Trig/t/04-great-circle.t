use Test;
use Math::Trig :DEFAULT, :great-circle;

plan 28;

{
    is-approx(great-circle-distance(0, 0, 0, pi/2), pi/2, '');
    is-approx(great-circle-distance(0, 0, pi, pi), pi, '');

    # London to Tokyo.
    my @L = (deg2rad(-0.5),  deg2rad(90 - 51.3));
    my @T = (deg2rad(139.8), deg2rad(90 - 35.7));
 
    my $km = great-circle-distance(|@L, |@T, 6378);
 
    is-approx($km, 9605.26637021388, 'correct distance from London to Tokyo');
}

{
    is-approx(great-circle-direction(0, 0, 0, pi/2), pi, '');
 
    my @London  = (deg2rad( -0.167), deg2rad(90 - 51.3));
    my @Tokyo   = (deg2rad(  139.5), deg2rad(90 - 35.7));
    my @Berlin  = (deg2rad( 13.417), deg2rad(90 - 52.533));
    my @Paris   = (deg2rad(  2.333), deg2rad(90 - 48.867));
 
    is-approx(rad2deg(great-circle-direction(|@London, |@Tokyo)), 31.791945393073, 'great-circle-direction: London to Tokyo');
 
    is-approx(rad2deg(great-circle-direction(|@Tokyo, |@London)), 336.069766430326, 'great-circle-direction: Tokyo to London');
 
    is-approx(rad2deg(great-circle-direction(|@Berlin, |@Paris)), 246.800348034667, 'great-circle-direction: Berlin to Paris');
     
    is-approx(rad2deg(great-circle-direction(|@Paris, |@Berlin)), 58.2079877553156, 'great-circle-direction: Paris to Berlin');
 

    is-approx(rad2deg(great-circle-bearing(|@Paris, |@Berlin)), 58.2079877553156, '');

    my ($lon, $lat) = great-circle-waypoint(|@London, |@Tokyo, 0.0);
    is-approx($lon, @London[0], '');
    is-approx($lat, @London[1], '');

    ($lon, $lat) = great-circle-waypoint(|@London, |@Tokyo, 1.0);
    is-approx($lon, @Tokyo[0], '');
    is-approx($lat, @Tokyo[1], '');

    ($lon, $lat) = great-circle-waypoint(|@London, |@Tokyo, 0.5);
    is-approx($lon, 1.55609593577679, '');  # 89.16 E
    is-approx($lat, 0.36783532946162, '');  # 68.93 N

    ($lon, $lat) = great-circle-midpoint(|@London, |@Tokyo);
    is-approx($lon, 1.55609593577679, '');  # 89.16 E
    is-approx($lat, 0.36783532946162, '');  # 68.93 N

    ($lon, $lat) = great-circle-waypoint(|@London, |@Tokyo, 0.25);
    is-approx($lon, 0.516073562850837, '');  # 29.57 E
    is-approx($lat, 0.400231313403387, '');  # 67.07 N

    ($lon, $lat) = great-circle-waypoint(|@London, |@Tokyo, 0.75);
    is-approx($lon, 2.17494903805952, '');  # 124.62 E
    is-approx($lat, 0.617809294053591, '');  # 54.60 N



    my $dir1 = great-circle-direction(|@London, |@Tokyo);
    my $dst1 = great-circle-distance(|@London,  |@Tokyo);
 
    ($lon, $lat) = great-circle-destination(|@London, $dir1, $dst1);
 
    is-approx($lon, @Tokyo[0], '');
 
    is-approx($lat, pi/2 - @Tokyo[1], '');
 
    my $dir2 = great-circle-direction(|@Tokyo, |@London);
    my $dst2 = great-circle-distance(|@Tokyo,  |@London);
 
    ($lon, $lat) = great-circle-destination(|@Tokyo, $dir2, $dst2);
 
    is-approx($lon, @London[0], '');
 
    is-approx($lat, pi/2 - @London[1], '');
 
    my $dir3 = (great-circle-destination(|@London, $dir1, $dst1))[2];
 
    is-approx($dir3, 2.69379263839118, ''); # about 154.343 deg
 
    my $dir4 = (great-circle-destination(|@Tokyo,  $dir2, $dst2))[2];
 
    is-approx($dir4, 3.6993902625701, ''); # about 211.959 deg
 
    is-approx($dst1, $dst2, '');
}
