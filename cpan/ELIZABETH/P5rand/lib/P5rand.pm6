use v6.c;

unit module P5rand:ver<0.0.1>:auth<cpan:ELIZABETH>;

proto sub rand(|) is export {*}
multi sub rand(            --> Num:D) { 1.rand    }
multi sub rand(Cool:D $num --> Num:D) { $num.rand }

my $srand is default(Nil);
proto sub srand(|) is export {*}
multi sub srand() { $srand }
multi sub srand(Int() $rand) { $srand = &CORE::srand($rand) }

=begin pod

=head1 NAME

P5rand - Implement Perl 5's rand() / srand() built-ins

=head1 SYNOPSIS

  use P5rand;

  say rand;    # a number between 0 and 1

  say rand 42; # a number between 0 and 42

  srand(666);

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<rand> and C<srand> built-ins
of Perl 5 as closely as possible.

=head1 PORTING CAVEATS

It is currently impossible to get the default C<srand()> value, but this may
change in a future version of Perl 6.  Until that time, C<srand()> will return
C<Nil> if C<srand> was never called with a value before.

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
