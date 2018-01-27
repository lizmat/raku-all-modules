use v6.c;
unit module P5substr:ver<0.0.1>;

proto sub substr(|) is export {*}
multi sub substr(Str:D \s, Int:D $o, Int:D $l is copy, Str() $r --> Str:D) {
    $l = s.chars + $l if $l < 0;
    my $u := s.substr($o,$l);
    s.substr-rw($o,$l) = $r;
    $u
}
multi sub substr(Str:D \s, Int:D $o is copy, Int:D $l is copy = s.chars - $o) {
    $l = s.chars + $l - (0 max ($o < 0 ?? s.chars + $o !! $o)) if $l < 0;

    Proxy.new(
      FETCH => -> $ {
          my $offset = 0 max ($o < 0 ?? s.chars + $o !! $o);
          s.substr($offset, 0 max ($l < 0 ?? s.chars + $l - $offset !! $l));
      },
      STORE => -> $, \new {
          if $o < 0 {
              my $offset = 0 max ($o < 0 ?? s.chars + $o !! $o);
              s.substr-rw($offset,$l) = new;
              $o = $o + $l - new.chars;
          }
          else {
              s.substr-rw($o, $l) = new;
          }
          $l = new.chars;
      }
    )
}

=begin pod

=head1 NAME

P5substr - Implement Perl 5's substr() built-in

=head1 SYNOPSIS

  use P5substr; # exports substr()

  say substr("foobar",3);   # bar
  say substr("foobar",1,4); # ooba

  my $a = "foobar";
  substr($a,1,2) = "OO";
  say $a;                   # fOObar

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<substr> of Perl 5 as closely as
possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5substr . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
