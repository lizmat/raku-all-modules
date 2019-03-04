use v6.c;
unit module Random::Choice:ver<0.0.2>:auth<cpan:TITSUKI>;

my class AliasTable {
    has @.prob;
    has Int @.alias;
    has Int $.n;

    submethod BUILD(:@p where { abs(1 - sum(@p)) < 1e-3 }) {
        $!n = +@p;
        my @np = @p.map(* * $!n);
        my (@large, @small);
        for ^@np -> $i {
            if @np[$i] < 1 {
                @small.push: (@np[$i], $i);
            } else {
                @large.push: (@np[$i], $i);
            }
        }

        while @large and @small {
            my ($pl, $l) = @small.shift;
            my ($pg, $g) = @large.shift;
            @!prob[$l] = $pl;
            @!alias[$l] = $g;
            $pg := $pg + $pl - 1;
            if $pg < 1 {
                @small.push: ($pg, $g);
            } else {
                @large.push: ($pg, $g);
            }
        }

        while @large {
            my ($pg, $g) = @large.shift;
            @!prob[$g] = 1;
        }

        while @small {
            my ($pl, $l) = @small.shift;
            @!prob[$l] = 1;
        }
    }
}

multi sub choice(:@p! --> Int) is export {
    my AliasTable $table .= new(:@p);

    my Int $i = (^$table.n).roll;
    if $table.prob[$i] > rand {
        return $i;
    } else {
        return $table.alias[$i];
    }
}

multi sub choice(Int :$size!, :@p! --> List) {
    my AliasTable $table .= new(:@p);

    gather for ^$size {
        my Int $i = (^$table.n).roll;
        if $table.prob[$i] > rand {
            take $i;
        } else {
            take $table.alias[$i];
        }
    }.List
}

=begin pod

=head1 NAME

Random::Choice - A Perl 6 alias method implementation

=head1 SYNOPSIS

=begin code :lang<perl6>

use Random::Choice;
    
say choice(:size(5), :p([0.1, 0.1, 0.1, 0.7])); # (3 3 3 0 1)
say choice(:p([0.1, 0.1, 0.1, 0.7])); # 3

=end code

=head1 DESCRIPTION

Random::Choice is a Perl 6 alias method implementation. Alias method is an efficient algorithm for sampling from a discrete probability distribution.

=head2 METHODS

=head3 choice

Defined as:

    multi sub choice(:@p! --> Int) is export
    multi sub choice(Int :$size!, :@p! --> List)

Returns a sample which is an Int value or a List.
Where C<:@p> is the probabilities associated with each index and C<:$size> is the sample size.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 titsuki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

The algorithm is from:

=item Vose, Michael D. "A linear algorithm for generating random numbers with a given distribution." IEEE Transactions on software engineering 17.9 (1991): 972-975.

=end pod
