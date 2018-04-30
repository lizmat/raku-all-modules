use v6.c;

unit module P5chomp:ver<0.0.4>:auth<cpan:ELIZABETH>;

proto sub chomp(|) is export {*}
multi sub chomp() { chomp CALLERS::<$_>     }
multi sub chomp(*@a is raw) { chomp(@a) }
multi sub chomp(%h) { chomp(%h.values) }
multi sub chomp(@a) {
    my $chars = 0;
    $chars += chomp($_) for @a;
    $chars
}
multi sub chomp(\s) {
    my $chars = s.chars;
    s .= chomp;
    $chars - s.chars
}

proto sub chop(|) is export {*}
multi sub chop() { chop CALLERS::<$_>     }
multi sub chop(*@a is raw) { chop(@a) }
multi sub chop(%h) { chop(%h.values) }
multi sub chop(@a) {
    if @a {
        my $char = @a[*-1].substr(*-1);
        $_ .= chop for @a;
        $char
    }
    else {
        Nil
    }
}
multi sub chop(\s) {
    my $char = s.substr(*-1);
    s .= chop;
    $char
}

=begin pod

=head1 NAME

P5chomp - Implement Perl 5's chomp() / chop() built-ins

=head1 SYNOPSIS

  use P5chomp; # exports chomp() and chop()

  chomp $a;
  chomp @a;
  chomp %h;
  chomp($a,$b);
  chomp();   # bare chomp may be compilation error to prevent P5isms in Perl 6

  chop $a;
  chop @a;
  chop %h;
  chop($a,$b);
  chop();      # bare chop may be compilation error to prevent P5isms in Perl 6

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<chomp> and C<chop> built-ins
of Perl 5 as closely as possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chomp . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
