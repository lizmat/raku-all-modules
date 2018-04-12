use v6.c;
unit module P5index:ver<0.0.2>;

sub index(Str() $string, Str() $needle, Int() $position = 0) is export {
    $string.index($needle,0 max $position) // -1
}

=begin pod

=head1 NAME

P5index - Implement Perl 5's index() built-in

=head1 SYNOPSIS

  use P5index; # exports index()

  say index("foobar", "bar");    # 3
  say index("foofoo", "foo", 1); # 3
  say index("foofoo", "bar");    # -1

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<index> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5index . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
