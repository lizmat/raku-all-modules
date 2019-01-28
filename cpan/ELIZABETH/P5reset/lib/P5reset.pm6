use v6.c;

unit module P5reset:ver<0.0.3>:auth<cpan:ELIZABETH>;

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
        if '$@%'.contains(key.substr(0,1)) {
            if $letters.contains(key.substr(1,1)) {
                value = value ~~ Iterable || value ~~ Associative
                  ?? Empty
                  !! Nil
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

This module tries to mimic the behaviour of the C<reset> function of Perl 5
as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    reset EXPR
    reset   Generally used in a "continue" block at the end of a loop to clear
            variables and reset "??" searches so that they work again. The
            expression is interpreted as a list of single characters (hyphens
            allowed for ranges). All variables and arrays beginning with one
            of those letters are reset to their pristine state. If the
            expression is omitted, one-match searches ("?pattern?") are reset
            to match again. Only resets variables or searches in the current
            package. Always returns 1. Examples:

                reset 'X';      # reset all X variables
                reset 'a-z';    # reset lower case variables
                reset;          # just reset ?one-time? searches

            Resetting "A-Z" is not recommended because you'll wipe out your
            @ARGV and @INC arrays and your %ENV hash. Resets only package
            variables; lexical variables are unaffected, but they clean
            themselves up on scope exit anyway, so you'll probably want to use
            them instead. See "my".

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
