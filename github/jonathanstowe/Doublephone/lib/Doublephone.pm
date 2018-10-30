use v6.c;

=begin pod

=head1 NAME

Doublephone - Implementation of the Double Metaphone phonetic encoding algorithm.

=head1 SYNOPSIS

=begin code

use Doublephone;

say double-metaphone("SMITH"); # (SM0 XMT)
say double-metaphone("SMIHT"); # (SMT XMT)


=end code

=head1 DESCRIPTION

This implements the L<Double
Metaphone|https://en.wikipedia.org/wiki/Metaphone#Double_Metaphone>
algorithm which can be used to match similar sounding words.  It is an
improved version of Metaphone (which in turn follows on from soundex,)
and was first described by Lawrence Philips in the June 2000 issue of
the C/C++ Users Journal.

It differs from some other similar algorithms in that a primary and
secondary code are returned which allows the comparison of words
(typically names,) with some common roots in different languages as
well as dealing with ambiguities.  So for instance "SMITH", "SMYTH" and
"SMYTHE" will yield (SM0 XMT) as the primary and secondary, whereas
"SCHMIDT", "SCHMIT" will yield (XMT SMT) so if a "cross language"
comparison is required then either of the primary or secondary codes can
be matched to the target primary or secondary code - this will also deal
with, for example, transpositions in typed names.

This is basically a Perl 6 binding to the original
C implementation I extracted from the Perl 5
L<Text::DoubleMetaphone|https://metacpan.org/release/Text-DoubleMetaphone>.

=head1 ROUTINE

This module exports a single routine that provides the functionality.

=head2 routine double-metaphone

    sub double-metaphone(Str $word) returns ( Str $primary-code, Str $secondary-code) is export

Given a string to be encoded returns a two element list of the primary and secondary encodings.
For any words of the same language with the same consonants in the same order the primary code
should be the same, for similar words (possibly in a different language,) the primary or the
secondary could should match.  A search function could potentially match in such a way that the
ones with the same primary code are displayed first, then the (more fuzzy,) secondary matches
afterwards.

=end pod

use NativeCall;

module Doublephone {
    constant LIB = %?RESOURCES<libraries/double_metaphone>.Str;

    sub DoubleMetaphone(Str $str, CArray[Str] $out is rw) is native(LIB) { * }

    sub double-metaphone(Str $str) is export {
        my $out = CArray[Str].new;
        $out[0] = Str;
        $out[1] = Str;
        DoubleMetaphone($str, $out);
        ($out[0], $out[1]);
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
