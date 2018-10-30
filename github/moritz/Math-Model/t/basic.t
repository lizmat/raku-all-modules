use v6;
use lib 'lib';
use Test;
use Math::Model;

my $m;
lives-ok {
    $m = Math::Model.new(
        derivatives => {
            a   => 'b',
        },
        variables   => {
            a   => { 2 },
        },
        initials    => {
            b   => 0,
        },
        captures    => <time b>,
    );
}, 'can initialize a Math::Model';

my %res;
lives-ok { %res = $m.integrate(:from(0), :to(3)) }, 'can integrate the model';
diag "result: %res.perl()";

is %res<time>[0],   0, 'time starts at 0';
is %res<time>[*-1], 3, '... and it integrated up to the end time';

is        %res<b>[0],   0, 'b starts with the right initial value';
is-approx %res<b>[*-1], 6, '... and got a roughly working result';

# TODO: test various error conditions

done-testing;
