use v6.c;

unit module P5defined:ver<0.0.1>:auth<cpan:ELIZABETH>;

proto sub defined(|) is export {*}
multi sub defined(       --> Bool:D) { (CALLERS::<$_>).defined }
multi sub defined(\value --> Bool:D) { value.defined }

proto sub undef(|) is export {*}
multi sub undef(--> Nil) { }   # this should be a term:<undef>
multi sub undef(**@items is raw --> Nil) { undefine($_) for @items }

=begin pod

=head1 NAME

P5defined - Implement Perl 5's defined() / undef() built-ins

=head1 SYNOPSIS

    use P5defined;

    my $foo = 42;
    given $foo {
        say defined();  # True
    }

    say defined($foo);  # True

    $foo = undef();
    undef($foo);

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<defined> and C<undef> built-ins
of Perl 5 as closely as possible.

=head1 PORTING CAVEATS

Because of some overzealous checks for Perl 5isms, it is necessary to put parentheses
when using C<undef> as a value.  This may change at some point in the future.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5defined . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
