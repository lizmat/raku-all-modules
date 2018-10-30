#!perl6

use v6.c;
use Test;

use Chronic;

my @tests = start {
    my $dt = DateTime.new(now + 6);
    await Chronic.at($dt).then({ ok $_.result.truncated-to('second') == $dt.truncated-to('second'), "got run at $dt (Object)" });
}, start {
    my $dt = DateTime.new(now + 5);
    await Chronic.at($dt.Str).then({ ok $_.result.truncated-to('second') == $dt.truncated-to('second'), "got run at $dt (String)" });
}, start {
    my $dt = DateTime.new(now + 4);
    await Chronic.at($dt.Instant).then({ ok $_.result.truncated-to('second') == $dt.truncated-to('second'), "got run at $dt (Instant)" });
}, start {
    my $dt = DateTime.new(now + 3);
    await Chronic.at($dt.posix).then({ ok $_.result.truncated-to('second') == $dt.truncated-to('second'), "got run at $dt (Int)" });
};

;

await Promise.allof(@tests);

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
