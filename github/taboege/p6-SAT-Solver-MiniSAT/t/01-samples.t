use Test;
use Test::SAT;
use SAT::Solver::MiniSAT;

my $*SAT-SOLVER = MiniSAT;

# AIM test set by Kazuo Iwama, Eiji Miyano and Yuichi Asahiro,
# QG test set by Hantao Zhang, both found through
# https://www.cs.ubc.ca/~hoos/SATLIB/benchm.html

plan 2;

subtest "AIM" => {
    my @tests = 't/aim'.IO.dir(test => /^ 'aim-' .* '.cnf' $/);
    plan +@tests;
    for @tests -> $file {
        my $answer = so $file ~~ m/yes/;
        sat-ok $file => $answer;
    }
}

if %*ENV<MINISAT_INTENSE_TESTING> {
    subtest "QG" => {
        my @tests = 't/qg'.IO.dir(test => /^ 'qg' .* '.cnf' $/);
        plan +@tests;
        for @tests -> $file {
            my $answer = so $file ~~ m/yes/;
            sat-ok $file => $answer;
        }
    }
}
else {
    skip 'MINISAT_INTENSE_TESTING is not set';
}
