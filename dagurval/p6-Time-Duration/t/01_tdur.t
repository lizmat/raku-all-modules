use v6;
use Test;
plan 135;


BEGIN { @*INC.unshift: '../lib'; }

use Time::Duration;
ok 1;

constant $MINUTE =   60;
constant $HOUR   = 3600;
constant $DAY    =   24 * $HOUR;
constant $YEAR   =  365 * $DAY;

 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print "# Basic tests...\n";
is( duration(   0), '0 seconds');
is( duration(   1), '1 second');
is( duration(  -1), '1 second');
is( duration(   2), '2 seconds');
is( duration(  -2), '2 seconds');
  
is( later(   0), 'right then');
is( later(   2), '2 seconds later');
is( later(  -2), '2 seconds earlier');
is( earlier( 0), 'right then');
is( earlier( 2), '2 seconds earlier');
is( earlier(-2), '2 seconds later');
  
is( ago(      0), 'right now');
is( ago(      2), '2 seconds ago');
is( ago(     -2), '2 seconds from now');
is( from_now( 0), 'right now');
is( from_now( 2), '2 seconds from now');
is( from_now(-2), '2 seconds ago');

 
 #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print "# Advanced tests...\n";

my $v;  #scratch var

$v = 0;
is(later(       $v   ), 'right then');
is(later(       $v, 3), 'right then');
is(later_exact( $v   ), 'right then');

$v = 1;
is(later(       $v   ), '1 second later');
is(later(       $v, 3), '1 second later');
is(later_exact( $v   ), '1 second later');

$v = 30;
is(later(       $v   ), '30 seconds later');
is(later(       $v, 3), '30 seconds later');
is(later_exact( $v   ), '30 seconds later');

$v = 46;
is(later(       $v   ), '46 seconds later');
is(later(       $v, 3), '46 seconds later');
is(later_exact( $v   ), '46 seconds later');

$v = 59;
is(later(       $v   ), '59 seconds later');
is(later(       $v, 3), '59 seconds later');
is(later_exact( $v   ), '59 seconds later');

$v = 61;
is(later(       $v   ), '1 minute and 1 second later');
is(later(       $v, 3), '1 minute and 1 second later');
is(later_exact( $v   ), '1 minute and 1 second later');

$v = 3599;
is(later(       $v   ), '59 minutes and 59 seconds later');
is(later(       $v, 3), '59 minutes and 59 seconds later');
is(later_exact( $v   ), '59 minutes and 59 seconds later');

$v = 3600;
is(later(       $v   ), '1 hour later');
is(later(       $v, 3), '1 hour later');
is(later_exact( $v   ), '1 hour later');

$v = 3601;
is(later(       $v   ), '1 hour and 1 second later');
is(later(       $v, 3), '1 hour and 1 second later');
is(later_exact( $v   ), '1 hour and 1 second later');

$v = 3630;
is(later(       $v   ), '1 hour and 30 seconds later');
is(later(       $v, 3), '1 hour and 30 seconds later');
is(later_exact( $v   ), '1 hour and 30 seconds later');

$v = 3800;
is(later(       $v   ), '1 hour and 3 minutes later');
is(later(       $v, 3), '1 hour, 3 minutes, and 20 seconds later');
is(later_exact( $v   ), '1 hour, 3 minutes, and 20 seconds later');

$v = 3820;
is(later(       $v   ), '1 hour and 4 minutes later');
is(later(       $v, 3), '1 hour, 3 minutes, and 40 seconds later');
is(later_exact( $v   ), '1 hour, 3 minutes, and 40 seconds later');

$v = $DAY + - $HOUR + -28;
is(later(       $v   ), '23 hours later');
is(later(       $v, 3), '22 hours, 59 minutes, and 32 seconds later');
is(later_exact( $v   ), '22 hours, 59 minutes, and 32 seconds later');

$v = $DAY + - $HOUR + $MINUTE;
is(later(       $v   ), '23 hours and 1 minute later');
is(later(       $v, 3), '23 hours and 1 minute later');
is(later_exact( $v   ), '23 hours and 1 minute later');

$v = $DAY + - $HOUR + 29 * $MINUTE + 1;
is(later(       $v   ), '23 hours and 29 minutes later');
is(later(       $v, 3), '23 hours, 29 minutes, and 1 second later');
is(later_exact( $v   ), '23 hours, 29 minutes, and 1 second later');

$v = $DAY + - $HOUR + 29 * $MINUTE + 31;
is(later(       $v   ), '23 hours and 30 minutes later');
is(later(       $v, 3), '23 hours, 29 minutes, and 31 seconds later');
is(later_exact( $v   ), '23 hours, 29 minutes, and 31 seconds later');

$v = $DAY + - $HOUR + 30 * $MINUTE + 31;
is(later(       $v   ), '23 hours and 31 minutes later');
is(later(       $v, 3), '23 hours, 30 minutes, and 31 seconds later');
is(later_exact( $v   ), '23 hours, 30 minutes, and 31 seconds later');

$v = $DAY + - $HOUR + -28 + $YEAR;
is(later(       $v   ), '1 year and 23 hours later');
is(later(       $v, 3), '1 year and 23 hours later');
is(later_exact( $v   ), '1 year, 22 hours, 59 minutes, and 32 seconds later');

$v = $DAY + - $HOUR + $MINUTE + $YEAR;
is(later(       $v   ), '1 year and 23 hours later');
is(later(       $v, 3), '1 year, 23 hours, and 1 minute later');
is(later_exact( $v   ), '1 year, 23 hours, and 1 minute later');

$v = $DAY + - $HOUR + 29 * $MINUTE + 1 + $YEAR;
is(later(       $v   ), '1 year and 23 hours later');
is(later(       $v, 3), '1 year, 23 hours, and 29 minutes later');
is(later_exact( $v   ), '1 year, 23 hours, 29 minutes, and 1 second later');

$v = $DAY + - $HOUR + 29 * $MINUTE + 31 + $YEAR;
is(later(       $v   ), '1 year and 23 hours later');
is(later(       $v, 3), '1 year, 23 hours, and 30 minutes later');
is(later_exact( $v   ), '1 year, 23 hours, 29 minutes, and 31 seconds later');

$v = $YEAR + 2 * $HOUR + -1;
is(later(       $v   ), '1 year and 2 hours later');
is(later(       $v, 3), '1 year and 2 hours later');
is(later_exact( $v   ), '1 year, 1 hour, 59 minutes, and 59 seconds later');

$v = $YEAR + 2 * $HOUR + 59;
is(later(       $v   ), '1 year and 2 hours later');
is(later(       $v, 3), '1 year, 2 hours, and 59 seconds later');
is(later_exact( $v   ), '1 year, 2 hours, and 59 seconds later');

$v = $YEAR + $DAY + 2 * $HOUR + -1;
is(later(       $v   ), '1 year and 1 day later');
is(later(       $v, 3), '1 year, 1 day, and 2 hours later');
is(later_exact( $v   ), '1 year, 1 day, 1 hour, 59 minutes, and 59 seconds later');

$v = $YEAR + $DAY + 2 * $HOUR + 59;
is(later(       $v   ), '1 year and 1 day later');
is(later(       $v, 3), '1 year, 1 day, and 2 hours later');
is(later_exact( $v   ), '1 year, 1 day, 2 hours, and 59 seconds later');

$v = $YEAR + - $DAY + - 1;
is(later(       $v   ), '364 days later');
is(later(       $v, 3), '364 days later');
is(later_exact( $v   ), '363 days, 23 hours, 59 minutes, and 59 seconds later');

$v = $YEAR + - 1;
is(later(       $v   ), '1 year later');
is(later(       $v, 3), '1 year later');
is(later_exact( $v   ), '364 days, 23 hours, 59 minutes, and 59 seconds later');



print "# And an advanced one to put duration thru its paces...\n";
$v = $YEAR + $DAY + 2 * $HOUR + 59;
is(duration(       $v   ), '1 year and 1 day');
is(duration(       $v, 3), '1 year, 1 day, and 2 hours');
is(duration_exact( $v   ), '1 year, 1 day, 2 hours, and 59 seconds');
is(duration(      -$v   ), '1 year and 1 day');
is(duration(      -$v, 3), '1 year, 1 day, and 2 hours');
is(duration_exact(-$v   ), '1 year, 1 day, 2 hours, and 59 seconds');


#~~~~~~~~

print "# Some tests of concise() ...\n";

is(concise(duration(   0)), '0s');
is(concise(duration(   1)), '1s');
is(concise(duration(  -1)), '1s');
is(concise(duration(   2)), '2s');
is(concise(duration(  -2)), '2s');
  
is(concise(later(   0)), 'right then');
is(concise(later(   2)), '2s later');
is(concise(later(  -2)), '2s earlier');
is(concise(earlier( 0)), 'right then');
is(concise(earlier( 2)), '2s earlier');
is(concise(earlier(-2)), '2s later');
  
is(concise(ago(      0)), 'right now');
is(concise(ago(      2)), '2s ago');
is(concise(ago(     -2)), '2s from now');
is(concise(from_now( 0)), 'right now');
is(concise(from_now( 2)), '2s from now');
is(concise(from_now(-2)), '2s ago');

$v = $YEAR + $DAY + 2 * $HOUR + -1;
is(concise(later(       $v   )), '1y1d later');
is(concise(later(       $v, 3)), '1y1d2h later');
is(concise(later_exact( $v   )), '1y1d1h59m59s later');

$v = $YEAR + $DAY + 2 * $HOUR + 59;
is(concise(later(       $v   )), '1y1d later');
is(concise(later(       $v, 3)), '1y1d2h later');
is(concise(later_exact( $v   )), '1y1d2h59s later');

$v = $YEAR + - $DAY + - 1;
is(concise(later(       $v   )), '364d later');
is(concise(later(       $v, 3)), '364d later');
is(concise(later_exact( $v   )), '363d23h59m59s later');

$v = $YEAR + - 1;
is(concise(later(       $v   )), '1y later');
is(concise(later(       $v, 3)), '1y later');
is(concise(later_exact( $v   )), '364d23h59m59s later');



# That's it.
print "# And one for the road.\n";
ok 1;
#print "# Done with of ", __FILE__, "\n";

