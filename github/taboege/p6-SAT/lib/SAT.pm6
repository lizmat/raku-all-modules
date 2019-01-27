=begin pod

=head1 NAME

SAT - Generic SAT solver interfaces

=head1 SYNOPSIS

  use SAT;

  # TODO

=head1 DESCRIPTION

TODO

=end pod

unit module SAT;

role Solver {
    multi method solve (:$now where *.so, |c --> Bool) {
        await self.solve: |c
    }

    multi method solve (IO::Path $file, |c --> Promise) {
        self.solve: $file.lines, |c
    }

    multi method solve (Str $DIMACS, |c --> Promise) {
        self.solve: $DIMACS.lines, |c
    }

    multi method solve (List $lines, |c --> Promise) {
        self.solve: $lines.Supply, |c
    }

    multi method solve (Seq $lines, |c --> Promise) {
        self.solve: $lines.Supply, |c
    }

    multi method solve (Supply $lines, |c --> Promise) {
        self.solve: $lines, my $dummy, |c
    }

    # The `*% ()` stops this candidate from swallowing the :now
    # adverb because methods normally accept any named arguments.
    # So if this candidate (without the `*% ()`) would be
    # implemented the Solver class, as required by the role,
    # it would take precedence and eat every method call with
    # a Supply positional, even those with :now. b2gills++ for
    # explaining that.
    #
    # By using `*% ()`, we force the class using this role to
    # supply a candidate which doesn't interfere with :now calling.
    # They can still choose to provide a candidate that swallows
    # :now as well, if they don't like how :now is handled here.
    multi method solve (Supply $lines, $witness is rw, *% () --> Promise) { … }
}

# TODO: Support approximate counters
role Counter {
    multi method count (:$now where *.so, |c --> Int) {
        await self.count: |c
    }

    multi method count (IO::Path $file, |c --> Promise) {
        self.count: $file.lines, |c
    }

    multi method count (Str $DIMACS, |c --> Promise) {
        self.count: $DIMACS.lines, |c
    }

    multi method count (List $lines, |c --> Promise) {
        self.count: $lines.Supply, |c
    }

    multi method count (Seq $lines, |c --> Promise) {
        self.count: $lines.Supply, |c
    }

    multi method count (Supply $lines, *% () --> Promise) { … }
}

role Enumerator {
    multi method enumerate (:$now where *.so, |c --> List) {
        self.enumerate(|c).List
    }

    multi method enumerate (IO::Path $file, |c --> Supply) {
        self.enumerate: $file.lines, |c
    }

    multi method enumerate (Str $DIMACS, |c --> Supply) {
        self.enumerate: $DIMACS.lines, |c
    }

    multi method enumerate (List $lines, |c --> Supply) {
        self.enumerate: $lines.Supply, |c
    }

    multi method enumerate (Seq $lines, |c --> Supply) {
        self.enumerate: $lines.Supply, |c
    }

    multi method enumerate (Supply $lines, *% () --> Supply) { … }
}

# TODO
# role Maximizer { }

# All the dynamic variables $*SAT-SOLVER, $*SAT-COUNTER, $*SAT-ENUMERATOR
# have precendence over lookup in the packages.
#
# NOTE: Detection of the SAT::Solver etc. roles might fail if the solver
# does these roles via parameterized roles, R#2551.

sub sat-solve (|c) is export {
    my $solvers := gather {
        take $*SAT-SOLVER if try $*SAT-SOLVER ~~ SAT::Solver;
        take $_ for SAT::Solver::.values.grep(* ~~ SAT::Solver);
    }
    for $solvers {
        return .new.solve(|c);
        CATCH {
            when X::Multi::NoMatch { .resume  }
            default                { .rethrow }
        }
    }
    die "no suitable SAT::Solver found";
}

sub sat-count (|c) is export {
    my $counters := gather {
        take $*SAT-COUNTER if try $*SAT-COUNTER ~~ SAT::Counter;
        take $_ for SAT::Counter::.values.grep(* ~~ SAT::Counter);
    }
    for $counters {
        return .new.count(|c);
        CATCH {
            when X::Multi::NoMatch { .resume  }
            default                { .rethrow }
        }
    }
    die "no suitable SAT::Counter found";
}

sub sat-enumerate (|c) is export {
    my $enumerators := gather {
        take $*SAT-ENUMERATOR if try $*SAT-ENUMERATOR ~~ SAT::Enumerator;
        take $_ for SAT::Enumerator::.values.grep(* ~~ SAT::Enumerator);
    }
    for $enumerators {
        return .new.enumerate(|c);
        CATCH {
            when X::Multi::NoMatch { .resume  }
            default                { .rethrow }
        }
    }
    die "no suitable SAT::Enumerator found";
}

=begin pod

=head1 AUTHOR

 Tobias Boege <tboege@ovgu.de>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Tobias Boege

This library is free software; you can redistribute it and/or modify it
under the Artistic License 2.0.

=end pod
