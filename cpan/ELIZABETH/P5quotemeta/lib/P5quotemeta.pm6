use v6.c;
unit module P5quotemeta:ver<0.0.2>;

proto sub quotemeta(|) is export {*}
multi sub quotemeta(--> Str:D) { quotemeta CALLERS::<$_> }
multi sub quotemeta(Str() $string --> Str:D) {
    given $string {
        S:g/ ( <[
          \x[34f]
          \x[0]..\x[2f]
          \x[3a]..\x[40]
          \x[5b]..\x[5e]
          \x[60]
          \x[7b]..\x[a7]
          \x[a9]
          \x[ab]..\x[ae]
          \x[b0]..\x[b1]
          \x[b6]
          \x[bb]
          \x[bf]
          \x[d7]
          \x[f7]
          \x[115f]..\x[1160]
          \x[61c]
          \x[1680]
          \x[17b4]..\x[17b5]
          \x[180b]..\x[180e]
          \x[2000]..\x[203e]
          \x[2041]..\x[2053]
          \x[2055]..\x[206f]
          \x[2190]..\x[245f]
          \x[2500]..\x[2775]
          \x[2794]..\x[2bff]
          \x[2e00]..\x[2e7f]
          \x[3000]..\x[3003]
          \x[3008]..\x[3020]
          \x[3030]
          \x[3164]
          \x[fd3e]..\x[fd3f]
          \x[fe00]..\x[fe0f]
          \x[fe45]..\x[fe46]
          \x[feff]
          \x[ffa0]
          \x[fff0]..\x[fff8]
          \x[1bca0]..\x[1bca3]
          \x[1d173]..\x[1d17a]
          \x[e0000]..\x[e0fff]
          \x[2adc]
        ]> ) /\\$0/
    }
}

=begin pod

=head1 NAME

P5quotemeta - Implement Perl 5's quotemeta() built-in

=head1 SYNOPSIS

  use P5quotemeta; # exports quotemeta()

  my $a = "abc";
  say quotemeta $a;

  $_ = "abc";
  say quotemeta;

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<quotemeta> of Perl 5 as closely
as possible.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5quotemeta . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Stolen from Zoffix Znet's unpublished String::Quotemeta, as found at:

  https://github.com/zoffixznet/perl6-String-Quotemeta

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
