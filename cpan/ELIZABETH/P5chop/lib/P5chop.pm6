use v6.c;
unit module P5chop:ver<0.0.1>;

proto sub chop(|) is export {*}
multi sub chop() { chop CALLERS::<$_>     }
multi sub chop(*@a is raw) { chop(@a) }
multi sub chop(%h) { chop(%h.values) }
multi sub chop(@a) {
    if @a {
        my $char = @a[*-1].substr(*-1);
        $_ .= substr(0,*-1) for @a;
        $char
    }
    else {
        Nil
    }
}
multi sub chop(\s) {
    my $char = s.substr(*-1);
    s .= substr(0,*-1);
    $char
}

=begin pod

=head1 NAME

P5chop - Implement Perl 5's chop() built-in

=head1 SYNOPSIS

  use P5chop; # exports chop()

  chop $a;
  chop @a;
  chop %h;
  chop($a,$b);
  chop();      # bare chop may be compilation error to prevent P5isms in Perl 6

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<chop> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5chop . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
