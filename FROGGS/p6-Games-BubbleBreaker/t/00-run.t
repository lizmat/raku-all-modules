use strict;
use warnings;
use Time::HiRes;
use Capture::Tiny;
use Test::Most 'bail';

my $time                   = Time::HiRes::time;
$ENV{'BUBBLEBREAKER_TEST'} = 1;

ok( -e 'bin/bubble-breaker.p6',             'bin/bubble-breaker.p6 exists' );
is( system("$^X -e 1"),                  0, "we can execute perl as $^X" );
my ($stdout, $stderr) = Capture::Tiny::capture { system("$^X bin/bubble-breaker.p6") };
ok( !$stderr, 'bubble-breaker ran ' . (Time::HiRes::time - $time) . ' seconds' );

$stdout ||= '';

if($stderr) {
    diag( "\$^X   = $^X");
    diag( "STDERR = $stderr");
}

pass 'Are we still alive? Checking for segfaults';

done_testing();
