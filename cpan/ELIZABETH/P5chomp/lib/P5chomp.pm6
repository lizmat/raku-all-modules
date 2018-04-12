use v6.c;
unit module P5chomp:ver<0.0.2>;

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

=begin pod

=head1 NAME

P5chomp - Implement Perl 5's chomp() built-in

=head1 SYNOPSIS

  use P5chomp; # exports chomp()

  chomp $a;
  chomp @a;
  chomp %h;
  chomp($a,$b);
  chomp();      # bare chomp may be compilation error to prevent P5isms in Perl 6

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<chomp> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chomp . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
