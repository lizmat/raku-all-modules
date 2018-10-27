#!/usr/bin/env perl6

use Test;
use Astro::Sunrise;

my @data = "t/tests.dat".IO.lines;
plan(2 + 2 * @data); # I prefer having Perl counting my tests than myself

my $test_year  = 2003;
my $test_month = 6;
my $test_day   = 21;

my ($lat, $long, $offset);
for @data {
    /
        ^
        $<city>=(<[\w-]>+) ',' \s+ $<country>=(\w+) \s+
        $<latdeg>=(\d+) \s+ $<latmin>=(\d+) \s+ $<latdir>=(\w) \s+
        $<londeg>=(\d+) \s+ $<lonmin>=(\d+) \s+ $<londir>=(\w) \s+
        'sunrise:' \s+ $<sunrise>=(\d+ ':' \d+) \s+
        'sunset:'  \s+ $<sunset>=(\d+ ':' \d+) \s*
        $
    /;
    unless ?$/ { warn "Can't parse test data!"; next; }

    $lat = sprintf( "%.3f", ( $<latdeg> + ( $<latmin> / 60 ) ) );
    $lat = -$lat if $<latdir> eq 'S';

    $long = sprintf( "%.3f", ( $<londeg> + ( $<lonmin> / 60 ) ) );
    $long = -$long if $<londir> eq 'W';

    if $long < 0    { $offset = ceiling( $long / 15 ); }
    elsif $long > 0 { $offset = floor( $long / 15 ); }

    my ($sunrise, $sunset) = sunrise( $test_year, $test_month, $test_day, $long, $lat, $offset );

    my $sunrise_str = $sunrise.hour.fmt("%02d") ~ ":" ~ $sunrise.minute.fmt("%02d");
    my $sunset_str = $sunset.hour.fmt("%02d") ~ ":" ~ $sunset.minute.fmt("%02d");

    is($sunrise_str, $<sunrise>, "Sunrise for $<city>, $<country>");
    is($sunset_str , $<sunset>, "Sunset for $<city>, $<country>");
}


my $sunrise_1 = sun_rise( -118, 33  );
my $sunrise_2 = sun_rise( -118, 33, -.833 );
my $sunrise_3 = sun_rise( -118, 33, -.833, 0 );

ok( $sunrise_1 eq $sunrise_2 , "Test W/O Alt");
ok( $sunrise_2 eq $sunrise_3 , "Test W/O offset");

# There's currently no way to tell Perl to use the default value for a
# positional parameter
#my $sunrise_4 = sun_rise( -118, 33, Nil, 0 );
#ok( $sunrise_3 eq $sunrise_4 , "Test setting Alt to undef");

# TODO: timezones (DateTime doesn't currently deal with timezones, so
# the offsets it give are bogus)

# my $then = DateTime.new( year => 2000, month => 6, day => 20, time_zone =>'America/Los_Angeles');
# $offset = ( ($then.offset) /60 /60);
# 
# my ($sunrise, $sunset) = sunrise($then.year, $then.month, $then.day, -118, 33, $offset, 0);
# is($sunrise, '05:42', "Test DateTime sunrise interface");
# is($sunset,  '20:05', "Test DateTime sunset interface");

