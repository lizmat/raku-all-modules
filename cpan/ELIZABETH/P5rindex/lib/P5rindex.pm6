use v6.c;
unit module P5rindex:ver<0.0.1>;

sub rindex(Str() $string, Str() $needle, Int() $position = $string.chars - 1) is export {
    $position < 0
      ?? -1
      !! $string.rindex($needle,$string.chars - 1 min $position) // -1
}

=begin pod

=head1 NAME

P5rindex - Implement Perl 5's rindex() built-in

=head1 SYNOPSIS

  use P5rindex; # exports rindex()

  say rindex("foobar", "bar");    # 3
  say rindex("foofoo", "foo", 4); # 3
  say rindex("foofoo", "bar");    # -1

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<rindex> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5rindex . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
