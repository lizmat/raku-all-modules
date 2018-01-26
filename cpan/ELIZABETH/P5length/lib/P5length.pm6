use v6.c;
unit module P5length:ver<0.0.2>;

proto sub length(|) is export {*}
multi sub length(--> Int:D) { length(CALLERS::<$_>) }
multi sub length(Any:U $type) { $type }
multi sub length(Any:D $string --> Int:D) { length($string.Str) }
multi sub length(Str:D $string --> Int:D) { $string.chars }

=begin pod

=head1 NAME

P5length - Implement Perl 5's length() built-in

=head1 SYNOPSIS

  use P5length; # exports length()

  say length("foobar"); # 6
  say length(Str);      # Str

  $_ = "foobar";
  say length;           # 6

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<length> of Perl 5 as closely as
possible.

=head1 PORTING CAVEATS

Since the Perl 5 documentation mentions C<characters> rather than codepoints,
C<length> will return the number of characters, as seen using Normalization
Form Grapheme (NFG).

C<length> in Perl 5 is supposed to return C<undef> when given C<undef>.  Since
undefined values are type objects in Perl 6, and it looks like C<length> is
simply returning what it was given in the undefined case, it felt appropriate
to simply return the given type object rather than C<Nil>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5length . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
