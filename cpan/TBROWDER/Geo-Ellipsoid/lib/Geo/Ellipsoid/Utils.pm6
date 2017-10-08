#	Geo::Ellipsoid::Utils
#
#	This package implements an Ellipsoid class to perform latitude
#	and longitude calculations on the surface of an ellipsoid.
#
#	This is a Perl conversion of existing Fortran code (see
#	ACKNOWLEDGEMENTS) and the author of this class makes no
#	claims of originality. Nor can he even vouch for the
#	results of the calculations, although they do seem to
#	work for him and have been tested against other methods.

use v6;

#use Math::Trig;

unit module Geo::Ellipsoid::Utils:auth<github:tbrowder>;

# constants for export
constant $degrees_per_radian is export = 180/pi;
constant $twopi is export              = 2 * pi;
constant $halfpi is export             = pi/2;

my $DEBUG = %*ENV<GEO_ELLIPSOID_DEBUG>:exists && %*ENV<GEO_ELLIPSOID_DEBUG> ne '0' ?? True !! False;


#	normalize_input_angles
#
#	Normalize a set of input angle values by converting to
#	radians if given in degrees and by converting to the
#	range [0,2pi), i.e., greater than or equal to zero and
#	less than two pi.
#       Angles are returned in the original units.
#
sub normalize-input-angles($units, *@angles) is export
{
    my @angs = map {
	$_ = deg2rad($_) if $units eq 'degrees';
        # use sub normalize-angle for following code:
	while $_ < 0       { $_ += $twopi }
	while $_ >= $twopi { $_ -= $twopi }
        # convert back to input unit
        $_ = rad2deg($_) if $units eq 'degrees';
	$_
    }, @angles;

    return (|@angs);
} # normalize-input-angles

#	normalize-output-angle
#
#	Normalize an output angle value by converting to
#	degrees if needed and by converting to the range [-pi,+pi) or
#	[0,2pi) as needed.
#       Output angle is converted to the input unit.
#
sub normalize-output-angle($ang is copy, Bool :$symmetric = False, Str :$units!) is export
{
    if $DEBUG {
	say "DEBUG (normalize-output-angle)";
	say "  \$symmetric = '$symmetric'";
    }

    # adjust input value
    say "  input \$ang = '$ang'; units = '$units'" if $DEBUG;
    # the caller declares whether the symmetric or complete range is wanted
    $ang = deg2rad($ang) if $units eq 'degrees';
    if $symmetric {
        say "    # normalize to range [-pi,pi)" if $DEBUG;
        # normalize to range [-pi,pi)
        # use sub normalize-angle for following code:
        while $ang < -pi { $ang += $twopi }
        while $ang >= pi { $ang -= $twopi }
    }
    else {
        say "    # normalize to range [0,2*pi)" if $DEBUG;
        # normalize to range [0,2*pi)
        # use sub normalize-angle for following code:
        while $ang <  0       { $ang += $twopi }
        while $ang >= $twopi  { $ang -= $twopi }
    }

    say "    # converting rad back to degrees" if $DEBUG && $units eq 'degrees';
    $ang = rad2deg($ang) if $units eq 'degrees';
    say "  output \$ang = '$ang'; units = '{ $units }'" if $DEBUG;
    return $ang;
}

# convert latitude in degrees, minutes, seconds to degrees
sub lat-hms2deg($hmsdata --> Real) is export {
    # Allowable entries must be in one of the forms:
    #   D or DM or DMS
    # where a missing element is taken to be zero.
    # Enter data as a string with commas or spaces between the DMS entries.

    # latitude entries:
    # Hemisphere h = (blank,N,n,+   or  S,s,-)
    # Nominal : degrees, minutes & seconds ( hDD MM SS.sssss )
    # The result will retain the resulting numerical sign of the D entry.

    # copy input
    my $str = $hmsdata;
    say "DEBUG: input = '$str'" if $DEBUG;

    # substitute spaces for any commas
    $str ~~ s:g/','/' '/;
    say "DEBUG: input after subs spaces for commas = '$str'" if $DEBUG;

    my @v = $str.words;
    my $D = shift @v;
    my ($d, $m, $s) = (0, 0, 0);
    $m = shift @v if @v;
    $s = shift @v if @v;

    my $sign = +1;
    if $D ~~ m:i/
                (<[NS+-]>?)  # sign of degrees, optional
                (\d+)        # degrees, mandatory
                /
    {
        say "DEBUG: 0: $0, 1: $1" if $DEBUG;
        my $c0 = $0;
        my $c1 = $1;
        if $c0 {
           if $c0 ~~ m:i/<[N+]>/ {
               # positive values
               ; # ok: $sign *= +1;
           }
           elsif $c0 ~~ m:i/<[S-]>/ {
               # negative values
               $sign = -1;
           }
           else {
               # error
               die "Unexpected error!";
           }
           say "DEBUG: \$c0 = '$c0'" if $DEBUG;
        }

        if $c1 {
            say "DEBUG: \$c1 = '$c1'" if $DEBUG;
            $d = $c1;
        }
        else {
            die "unexpected error: undef \$1 (\$D = '$D'; \$str = '$str')";
        }

	my $degrees = extract-hms-match-values($d, $m, $s, :$sign);
	return $degrees:
    }
    die "unexpected error: \$D = '$D'; \$str = '$str')";

}

# convert longitude in degrees, minutes, seconds to degrees
sub long-hms2deg($hmsdata) is export {
    return lon-hms2deg($hmsdata);
}
sub lon-hms2deg($hmsdata --> Real) is export {
    # Allowable entries must be in one of the forms:
    #   D or DM or DMS
    # where a missing element is taken to be zero.
    # Enter data as a string with commas or spaces between the DMS entries.

    # longitude entries:
    # Hemisphere h = (E,e,+   or  blank,W,w,-)
    # Nominal : degrees, minutes & seconds ( hDDD MM SS.sssss )
    # The result will retain the resulting numerical sign of the D entry.

    # copy input
    my $str = $hmsdata;
    say "DEBUG: input = '$str'" if $DEBUG;

    # substitute spaces for any commas
    $str ~~ s:g/','/' '/;
    say "DEBUG: input after subs spaces for commas = '$str'" if $DEBUG;

    my @v = $str.words;
    my $D = shift @v;
    my ($d, $m, $s) = (0, 0, 0);
    $m = shift @v if @v;
    $s = shift @v if @v;

    my $sign = -1; # default for NO sign
    if $D ~~ m:i/
                (<[EW+-]>?)  # sign of degrees, optional
                (\d+)                # degrees, mandatory
                /
    {
        say "DEBUG: 0: $0, 1: $1" if $DEBUG;
        my $c0 = $0;
        my $c1 = $1;
        if $c0 {
           if $c0 ~~ m:i/<[E+]>/ {
               # positive values
               $sign = +1;
           }
           elsif $c0 ~~ m:i/<[W-]>/ {
               # negative values
               $sign = -1;
           }
           else {
               # error
               die "Unexpected error!";
           }
        }

        if $c1 {
            say "DEBUG: \$c1 = '$c1'" if $DEBUG;
            $d = $c1;
        }
        else {
            die "unexpected error: undef \$1 (\$D = '$D'; \$str = '$str')";
        }

        my $degrees = extract-hms-match-values(:$sign, $s, $m, $s, :$sign);
        return $degrees:
    }
    die "unexpected error: \$D = '$D'; \$str = '$str')";
}

=begin comment
# convert degrees in DMS to decimal degrees
sub hms2deg($h, $m, $sec) is export {
    # Allowable entries must be in one of the forms:
    #   D or DM or DMS
    # where a missing element is taken to be zero.
    # Commas must be used between the DMS entries.
    # The result will retain the numerical sign of the D entry.

    # The result is NOT constrained to any range. For that, pass
    # the result to the normalize-angle function.

    my $deg = $h + $m / 60 + $sec / 3600;
    return $deg;
}
=end comment

sub extract-hms-match-values($h, $m, $s, :$sign!) {
        my $degrees = 0;
        if $h {
           $degrees = +$h;
        }
        else {
            # error
        }

        my $minutes = 0;
        if $m {
           $minutes = +$m;
        }
        else {
            # error
        }

        my $seconds = 0;
        if $s {
           $seconds = +$s;
        }
        else {
            # error
        }

        $degrees += $minutes / 60.0;
        $degrees += $seconds / 3600.0;

        # now apply the sign
        $degrees *= $sign;

        return $degrees;
}

enum AngUnits  ( Degrees => 1, Radians => 2 );
enum RangeType ( OnePi => 1, TwoPi => 2 );

sub normalize-angle($ang, AngUnits :$ang-units, RangeType :$range-type) is export {
    # make the named args enums:
    #   ang-units an enum for degrees or radians (or?)
    #   range-type an enum for pi or two-pi
}


=begin pod
    # allowable input (from NOAA/NGS code

    Some example latitude inputs are :

     Hemisphere h = (blank,N,n,+   or  S,s,-)
     Commas or blanks may be used between the D,M,S entries.

     Keyed Input :                              Converted latitude :

     Nominal : degrees, minutes & seconds ( hDD MM SS.sssss )
     =========
     hDD MM SS.sssss                            Latitude :
     <cr>                   ( h default = N )     0  0  0.00000 North
     0                             "                     "
     0 0 0                         "                     "
     0,0,0.0                       "                     "
     0d 0m 0s                      "                     "
     00d 00m 00.000s               "                     "
     10 0 1.00001                  "             10  0  1.00001 North
     10d 0m 1.00001s               "             10  0  1.00001 North
     +0                                           0  0  0.00000 North
     +0 0 0.0                                     0  0  0.00000 North
     +0,0,0.1                                     0  0  0.10000 North
     N0                                           0  0  0.00000 North
     N20                                         20  0  0.00000 North
     n20d20m22s                                  20 20 22.00000 North
     n020d  20m 0022s                            20 20 22.00000 North
     n10 0 10.00001                              10  0 10.00001 North
     -0 0 1.00001                                 0  0  1.00001 South
     -10 0 10.00001                              10  0 10.00001 South
     S26 37 48.26371                             26 37 48.26371 South

     Packed : degrees-minutes-seconds ( hDDMMSS.sssss )
     ========
     hDDMMSS.sssss                              Latitude :
     N000000.000                                  0  0  0.00000 North
     N100010.00001                               10  0 10.00001 North
     S263748.26371                               26 37 48.26371 South

     Decimal : degrees ( hDD.dddddddd )
     =========
     hDD.dddddddd                               Latitude :
     20.0                   ( h default = N )    20  0  0.00000 North
     10.002777781                  "             10  0 10.00001 North
     s26.630073253                               26 37 48.26371 South

=======================================================================
Some example longitude inputs are :

     Hemisphere h = (E,e,+   or  blank,W,w,-)
     Commas or blanks may be used between the D,M,S entries.

     Keyed Input :                              Converted longitude :

     Nominal : degrees, minutes & seconds ( hDDD MM SS.sssss )
     =========
     hDDD MM SS.sssss                           Longitude :
     <cr>                   ( h default = W )     0  0  0.00000 West
     0                             "                     "
     0 0 0                         "                     "
     0,0,0.0                       "                     "
     0d 0m 0s                      "                     "
     00d 00m 00.000s               "                     "
     10 0 1.00001                  "             10  0  1.00001 West
     10d 0m 1.00001s               "             10  0  1.00001 West
     -1                                           1  0  0.00000 West
     -0 0 1.00001                                 0  0  1.00001 West
     -10 0 10.00001                              10  0 10.00001 West
     W0                                           0  0  0.00000 West
     W20                                         20  0  0.00000 West
     w20d20m22s                                  20 20 22.00000 West
     w020d  20m 0022s                            20 20 22.00000 West
     w10 0 10.00001                              10  0 10.00001 West
     +0                                           0  0  0.00000 East
     +0 0 0.0                                     0  0  0.00000 East
     +0,0,0.1                                     0  0  0.10000 East
     E26 37 48.26371                             26 37 48.26371 East

     Packed : degrees-minutes-seconds ( hDDDMMSS.sssss )
     ========
     hDDDMMSS.sssss                             Longitude :
     W0000000.000                                 0  0  0.00000 West
     W0100010.00001                              10  0 10.00001 West
     E0263748.26371                              26 37 48.26371 East

     Decimal : degrees ( hDDD.dddddddd )
     =========
     hDDD.dddddddd                              Longitude :
     20.0                   ( h default = W )    20  0  0.00000 West
     10.002777781                  "             10  0 10.00001 West
     -10.002777781                               10  0 10.00001 West
     +10.002777781                               10  0 10.00001 East
     e26.630073253                               26 37 48.26371 East
=end pod


#=begin pod
# the following two functions are provided by module Math::Trig
# but, as of 2016-09-03, it causes a rakudo exception
sub rad2deg($rad) is export {
    return $rad * 180 / pi;
}
sub deg2rad($deg) is export {
    return $deg * pi / 180;
}
#=end pod
