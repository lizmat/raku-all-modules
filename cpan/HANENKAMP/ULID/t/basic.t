use v6;

use Test;
use ULID :ulid, :time, :parts;

constant @crockford-chars = <
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H
    J K
    M N
    P Q R S T
    V W X Y Z
>;

subtest 'time' => {
    my $now-millis = (now.to-posix * 1000).floor;

    my $ulid-now = ulid-now;
    isa-ok $ulid-now, Int;
    cmp-ok $ulid-now, &infix:«>», $now-millis, 'ulid-now is what we expect';
}

my $dt = DateTime.new(year => 1996, month => 1, day => 1, hour => 10, minute => 10);
my $now = $dt.posix(:ignore-timezone);
my $millis = $now * 1000 + 123;

my @expected-time = <0 0 Q W 4 H 6 6 9 V>;

subtest 'ulid-time' => {
    my @ulid-time = ulid-time($millis);

    is @ulid-time, @expected-time, 'ulid-time matches expectation';

    my @ulid-ultimate-future = ulid-time(0xFFFF_FFFF_FFFF_FFFF);
    is @ulid-ultimate-future, <7 Z Z Z Z Z Z Z Z Z>, 'ultimate time looks okay';
}

subtest 'ulid-random' => {
    my @ulid-random = ulid-random($millis);

    is @ulid-random.elems, 16, 'random is expected length';
    for @ulid-random.kv -> $i, $byte {
        is $byte, @crockford-chars.any, "char[$i] is okay";
    }

    my %bag := bag(@ulid-random);
    cmp-ok %bag.keys, &infix:«>», 5, 'looks random-ish (this test may fail around once every 200 trillion runs, if my math is correct, which it probably is not--discreet math has always confused me)';
}

subtest 'ulid-random-monotonic' =>  {
    my sub random-function($) { state ($c, $b) = (0, 0); if ++$c %% 10 { $b += 2 } else { 0 } }

    my @ulid-random = ulid-random($millis, :&random-function);
    is @ulid-random, <0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2>, 'non-random ULID looks okay';

    @ulid-random = ulid-random($millis, :&random-function);
    is @ulid-random, <0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4>, 'non-random ULID generates the second okay';

    @ulid-random = ulid-random($millis, :&random-function, :monotonic);
    is @ulid-random, <0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5>, 'monotonic ULID generates okay';

    for ^9 {
        is random-function(0x100), 0, 'fake random-function is where we expect';
    }
    is random-function(0x100), 6, 'fake random-function is where we expect';

    @ulid-random = ulid-random($millis, :&random-function);
    is @ulid-random, <0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8>, 'non-monotonic resumes regular random';

    @ulid-random = ulid-random($millis + 1, :&random-function, :monotonic);
    is @ulid-random, <0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 A>, 'monotonic on a new milli is random again';
}

subtest 'ulid-random-monotonic-carry-bits' => {
    my sub random-function($) { state $i = 0; my @bytes = flat 0xF7, 0xFF xx 9; @bytes[$i++] }
    my @ulid-random = ulid-random($millis, :&random-function);

    is @ulid-random, <Y Z Z Z Z Z Z Z Z Z Z Z Z Z Z Z>, 'ulid-random is prepped for maximum carryover';

    @ulid-random = ulid-random($millis, :&random-function, :monotonic);
    is @ulid-random, <Z 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0>, 'ulid-random performed maximum carryover';
}

subtest 'ulid-random-monotonic-overflow' => {
    my sub random-function($) { 255 }
    my @ulid-random = ulid-random($millis, :&random-function);

    is @ulid-random, <Z Z Z Z Z Z Z Z Z Z Z Z Z Z Z Z>, 'ulid-random is prepped for overflow';

    throws-like {
        ulid-random($millis, :&random-function, :monotonic);
    }, X::ULID, message => 'monotonic ULID overflow';
};

subtest 'ulid' => {
    my $ulid = ulid($millis);

    is $ulid.chars, 26, 'ulid is the expected bytes long';
    is $ulid.substr(0, 10), @expected-time.join, 'ulid has the expected time';

    $ulid = ulid($millis, :monotonic);
    is $ulid.chars, 26, 'ulid is the expected bytes long';
    is $ulid.substr(0, 10), @expected-time.join, 'ulid has the expected time';

    $ulid = ulid;
    is $ulid.chars, 26, 'ulid is the expected bytes long';

    $ulid = ulid($millis, random-function => -> $x { 0 });
    is $ulid, ([~] flat(@expected-time, <0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0>)), 'passing a random-function works';
}

done-testing;
