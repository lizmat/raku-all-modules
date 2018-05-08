use v6.c;
unit module P5reset:ver<0.0.1>:auth<cpan:ELIZABETH>;

proto sub reset(|) is export {*}
multi sub reset(--> 1) { }
multi sub reset(Str() $pattern --> 1) {

    my $start;
    sub start-from() { my $value = $start; $start = Nil; $value }

    my $letters;
    for $pattern.comb -> $letter {
        $letter eq '-'
          ?? ($start = $letters.chop if $letters)
          !! $letters ~= $start
            ?? (start-from() .. $letter).join
            !! $letter;
    }

    for CALLER::OUR::.kv -> \key, \value {
        with '$@%'.index(key.substr(0,1)) {
            with $letters.index(key.substr(1,1)) {
                value = value ~~ Iterable || value ~~ Associative ?? Empty !! Nil
            }
        }
    }
}

=begin pod

=head1 NAME

P5reset - Implement Perl 5's reset() built-in

=head1 SYNOPSIS

  use P5reset;

  reset("a");   # reset all "our" variables starting with "a"

  reset("a-z"); # reset all "our" variables starting with lowercase letter

  reset;        # does not reset any variables

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<reset> of Perl 5 as closely as
possible.

=head1 PORTING CAVEATS

Since Perl 6 doesn't have the concept of C<?one time searches?>, the no-argument
form of C<reset> will not reset any variables at all.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5reset . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
