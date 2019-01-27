use Test;
use SAT;

use lib 't/lib';
use SAT::Dummy;

my $TEST-FILE = 't/01.cnf'.IO;

sub act ($_) {
    if m/^ [ $<var>=[\d+] \s+ ]+ 0 $/ {
        slip gather {
            take $_;
            for $<var> -> $negate {
                take $<var>».Str.map(-> $n {
                    $n == $negate ?? -$n !! $n
                }).join(' ') ~ " 0";
            }
        }
    }
    elsif m/^ 'p cnf' \s $<vars>=[\d+] \s $<clauses>=[\d+] / {
        "p cnf $<vars> { $<clauses> * (1 + $<vars>) }"
    }
    else {
        $_
    }
}

my $DIMACS = q:to/EOF/;
c the answer is 42
p cnf 9 1
1 2 3 4 5 6 7 8 9 0
EOF
my $SEQ    = -> { $DIMACS.lines.map(&act) };
my $LIST   = cache $SEQ();
my $SUPPLY = $LIST.Supply.throttle(1, 0.2);

plan 4;

subtest "convenience methods detect solvers" => {
    isa-ok sat-solve\   ($TEST-FILE, :show-yourself), SAT::Solver::Dummy,     "solver";
    isa-ok sat-count\   ($TEST-FILE, :show-yourself), SAT::Counter::Dummy,    "counter";
    isa-ok sat-enumerate($TEST-FILE, :show-yourself), SAT::Enumerator::Dummy, "enumerator";
    # TODO: Should also check if it tries to find a fitting solver for the
    # given arguments correctly, with a second dummy solver.
}

subtest "solver dispatch" => {
    plan 11;

    is sat-solve(:now, $TEST-FILE),           10, "IO dispatch";
    is sat-solve(:now, slurp $TEST-FILE),     10, "Str dispatch";
    is sat-solve(:now, $TEST-FILE.lines),     10, "Seq dispatch";
    is sat-solve(:now, $DIMACS),              42, "Str dispatch";
    is sat-solve(:now, $SEQ()),               42, "Seq dispatch";
    is sat-solve(:now, $LIST),                42, "List dispatch";
    is sat-solve(:now, $SUPPLY),              42, "Supply dispatch";

    isa-ok sat-solve(      $TEST-FILE),  Promise, "normally a Promise";
    isa-ok sat-solve(:now, $TEST-FILE),     Bool, ":now a Bool";

    is sat-solve(:now, $SUPPLY, my $witness), 42, "witness 1/2";
    is $witness,                              21, "witness 2/2";
}

subtest "counter dispatch" => {
    plan 9;

    is sat-count(:now, $TEST-FILE),          10, "IO dispatch";
    is sat-count(:now, slurp $TEST-FILE),    10, "Str dispatch";
    is sat-count(:now, $TEST-FILE.lines),    10, "Seq dispatch";
    is sat-count(:now, $DIMACS),             42, "Str dispatch";
    is sat-count(:now, $SEQ()),              42, "Seq dispatch";
    is sat-count(:now, $LIST),               42, "List dispatch";
    is sat-count(:now, $SUPPLY),             42, "Supply dispatch";

    isa-ok sat-count(      $TEST-FILE), Promise, "normally a Promise";
    isa-ok sat-count(:now, $TEST-FILE),     Int, ":now an Int";
}

subtest "enumerator dispatch" => {
    plan 9;

    is sat-enumerate(:now, $TEST-FILE),         10, "IO dispatch";
    is sat-enumerate(:now, slurp $TEST-FILE),   10, "Str dispatch";
    is sat-enumerate(:now, $TEST-FILE.lines),   10, "Seq dispatch";
    is sat-enumerate(:now, $DIMACS),            42, "Str dispatch";
    is sat-enumerate(:now, $SEQ()),             42, "Seq dispatch";
    is sat-enumerate(:now, $LIST),              42, "List dispatch";
    is sat-enumerate(:now, $SUPPLY),            42, "Supply dispatch";

    isa-ok sat-enumerate(      $TEST-FILE), Supply, "normally a Promise";
    isa-ok sat-enumerate(:now, $TEST-FILE),   List, ":now a List";
}
