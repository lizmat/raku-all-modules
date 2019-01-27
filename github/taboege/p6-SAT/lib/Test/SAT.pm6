=begin pod

=head1 NAME

Test::SAT - SAT solver testing

=head1 SYNOPSIS

  use Test::SAT;

  # TODO

=head1 DESCRIPTION

TODO

=end pod

unit module Test::SAT;

use Test;
use Compress::Zlib;

sub maybe-gzipped ($file) {
    $file.ends-with(".gz") ??
        gzslurp($file) !! $file.IO;
}

#| Verify that the SAT::Solver in $*SAT-SOLVER makes accurate decisions.
sub sat-ok ($p (IO() :key($file), :value($answer))) is export {
    my $cnf = $file.&maybe-gzipped;
    my $yesno = $*SAT-SOLVER.new.solve: $cnf, :now;
    is $yesno, $answer, "correct decision for $file";
}

#|« Verify that the certifying SAT::Solver in $*SAT-SOLVER makes accurate
decisions and that the witness it outputs is a satisfying assignment.
»
sub witness-ok ($p (IO() :key($file), :value($answer))) is export {
    subtest "$file" => {
        plan 2;
        my $cnf = $file.&maybe-gzipped;
        my $yesno = $*SAT-SOLVER.new.solve: $cnf, my $witness, :now;
        is $yesno, $answer, "correct decision";
        if $yesno {
            if $witness.DEFINITE {
                is eval-DIMACS($cnf, $witness), $yesno, "consistent witness";
            }
            else {
                flunk "witness not delivered";
            }
        }
        else {
            pass "no short witness required for UNSAT";
        }
    }
}

sub eval-DIMACS ($file, $assignment) {
    $file = $file.IO.e ?? $file.IO !! $file;
    for $file.lines {
        next unless m/^ '-'? \d /;
        my $lits = set((m:g/ '-'? \d+ /)».Int) ∖ 0;
        return False if $assignment ∩ $lits === ∅;
    }
    return True;
}

#| Verify that the SAT::Counter in $*SAT-COUNTER produces accurate counts.
sub count-ok ($p (:key($file), :value($answer))) is export {
    my $cnf = $file.&maybe-gzipped;
    my $models = $*SAT-COUNTER.new.count: $cnf, :now;
    is $models, $answer, "correct count for $file";
}

#|« Verify that the SAT::Enumerator in $*SAT-ENUMERATOR produces the same
satisfying assignments as predicted.
»
sub enumerate-ok (
    $p (IO() :key($file), Set() :value($list)),
    &transform = { $^x },
) is export {
    subtest "$file" => {
        plan 2;
        my $cnf = $file.&maybe-gzipped;
        my @sat = $*SAT-ENUMERATOR.new.enumerate: $cnf, :now;
        is +@sat, $list.elems, "same number of answers"; # in particular no duplications!
        is-deeply @sat.map(&transform).Set, $list, "assignments match";
    }
}

=begin pod

=head1 AUTHOR

 Tobias Boege <tboege@ovgu.de>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Tobias Boege

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.

=end pod
