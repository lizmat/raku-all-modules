use v6.c;
use Test;
use Timer::Breakable;

my $timer1-run = False;
my $timer2-run = False;
my $timer1 = Timer::Breakable.start( 0.5, { $timer1-run = True } );
my $timer2 = Timer::Breakable.start( 0.5, { $timer2-run = True } );
$timer1.stop;

is $timer1.status, Broken, "Timer 1 has been stopped";
is $timer2.status, Planned, "Timer 2 still running";

await( $timer2.promise );

is $timer1-run, False, "Timer 1 didn't run";
is $timer2-run, True, "Timer 2 did run";

done-testing;
