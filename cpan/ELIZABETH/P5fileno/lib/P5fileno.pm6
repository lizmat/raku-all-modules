use v6.c;

unit module P5fileno:ver<0.0.1>:auth<cpan:ELIZABETH>;

proto sub fileno(|) is export {*}
multi sub fileno(IO::Handle:D $handle --> Int:D) {
    if $handle.opened {
        my $fileno;
        CATCH { default { $fileno = -1 } }
        $fileno = $handle.native-descriptor;
    }
    else {
        Nil
    }
}

=begin pod

=head1 NAME

P5fileno - Implement Perl 5's fileno() built-in

=head1 SYNOPSIS

  use P5fileno;

  say fileno $*IN;    # 0
  say fileno $*OUT;   # 1
  say fileno $*ERR;   # 2
  say fileno $foo;    # something like 16

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<fileno> of Perl 5 as closely
as possible.

=head1 PORTING CAVEATS

When calling with an unopened C<IO::Handle>, this version will return C<Nil>.
That's the closest thing there is to C<undef> in Perl 6.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5fileno . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
