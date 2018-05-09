use v6.c;

unit module P5rand:ver<0.0.2>:auth<cpan:ELIZABETH>;

proto sub rand(|) is export {*}
multi sub rand(            --> Num:D) { 1.rand    }
multi sub rand(Cool:D $num --> Num:D) { $num.rand }

=begin pod

=head1 NAME

P5rand - Implement Perl 5's rand() built-ins

=head1 SYNOPSIS

  use P5rand;

  say rand;    # a number between 0 and 1

  say rand 42; # a number between 0 and 42

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<rand> built-in of Perl 5
as closely as possible.

=head1 PORTING CAVEATS

The version of C<srand()> that is provided by Perl 6 does not allow it to be
called without a parameter.  Rather than providing a possibly predictable
default seed value (like it does in Perl 5), it was decided to not offer thisi
capability in Perl 6.  This seems like a good idea, so this module does not
provide a replacement C<srand> function.

Currently, some Perl 6 grammar checks are a bit too overzealous with regards to
calling C<rand> with a parameter:

    say rand(42);   # Unsupported use of rand(N)

This overzealousness can be circumvented by prefixing the subroutine name with C<&>:

    say &rand(42);  # 24.948543810572648

until we have a way to curb this overzealousness.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5rand . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
