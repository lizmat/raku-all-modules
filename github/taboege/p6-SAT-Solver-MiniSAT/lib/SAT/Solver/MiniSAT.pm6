=begin pod

=head1 NAME

SAT::Solver::MiniSAT - SAT solver MiniSAT

=head1 SYNOPSIS

=begin code
use SAT::Solver::MiniSAT;

say minisat "t/aim/aim-100-1_6-no-1.cnf".IO, :now;
#= False
say minisat "t/aim/aim-100-1_6-yes1-1.cnf".IO, :now;
#= True
=end code

=head1 DESCRIPTION

SAT::Solver::MiniSAT wraps the C<minisat> executable (bunled with the module)
used to decide whether a satisfying assignment for a Boolean formula given
in the C<DIMACS cnf> format exists. This is known as the C<SAT> problem
associated with the formula. MiniSAT does not produce a witness for
satisfiability.

Given a DIMACS cnf problem, it starts C<minisat>, feeds it the problem and
returns a Promise which will be kept with the C<SAT> answer found or broken
on error.

=end pod

use SAT;

# XXX: Workaround for zef stripping execute bits on resource install.
BEGIN sink with %?RESOURCES<minisat>.IO { .chmod: 0o100 +| .mode };

class SAT::Solver::MiniSAT does SAT::Solver is export {
    multi method solve (Supply $lines, $witness is rw, *% () --> Promise) {
        my $out;
        with my $proc = Proc::Async.new: :w, %?RESOURCES<minisat>, '-verb=0' {
            $out = .stdout.lines;
            .start and await .ready;
            react whenever $lines -> $line {
                .put: $line;
                LAST .close-stdin;
            }
        }

        $out.map({
            m/^ <( 'UN'? )> 'SATISFIABLE' / ??
                $/ ne "UN" !! Empty
        }).Promise.then({
            # MiniSAT sadly doesn't provide a witness.
            # TODO: Should hack that in.
            $witness = Array[Bool];
            .result
        })
    }
}

multi sub minisat (|c) is export {
    SAT::Solver::MiniSAT.new.solve(|c)
}

=begin pod

=head1 AUTHOR

Tobias Boege <tboege@ovgu.de>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Tobias Boege

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.

=end pod
