use v6.c;
unit class Text::Sift4:ver<0.0.4>;

sub sift4(Str $lhs, Str $rhs, Int :$max-offset = 5 --> Int:D) is export {
    if not $lhs.defined or $lhs.chars == 0 {
        return 0 unless $rhs.defined;
        return $rhs.chars;
    }

    if not $rhs.defined or $rhs.chars == 0 {
        return $lhs.chars;
    }

    my Int $lhs-len = $lhs.chars;
    my Int $rhs-len = $rhs.chars;

    my Int $lhs-cursor = 0;
    my Int $rhs-cursor = 0;
    my Int $largest-common-subsequence = 0;
    my Int $local-common-substring = 0;

    while ($lhs-cursor < $lhs-len) && ($rhs-cursor < $rhs-len) {
        if $lhs.substr($lhs-cursor,1) eq $rhs.substr($rhs-cursor,1) {
            $local-common-substring++;
        } else {
            $largest-common-subsequence += $local-common-substring;
            $local-common-substring = 0;
            if $lhs-cursor != $rhs-cursor {
                $lhs-cursor = $rhs-cursor = max($lhs-cursor, $rhs-cursor);
            }

            my $i = 0;
            while $i < $max-offset && ($lhs-cursor + $i < $lhs-len) || ($rhs-cursor + $i < $rhs-len) {
                if ($lhs-cursor + $i < $lhs-len) && ($lhs.substr($lhs-cursor + $i, 1) eq $rhs.substr($rhs-cursor, 1)) {
                    $lhs-cursor += $i;
                    $local-common-substring++;
                    last;
                }
                if ($rhs-cursor + $i < $rhs-len) && ($lhs.substr($lhs-cursor, 1) eq $rhs.substr($rhs-cursor + $i, 1)) {
                    $rhs-cursor += $i;
                    $local-common-substring++;
                    last;
                }
                $i++;
            }
        }
        $lhs-cursor++;
        $rhs-cursor++;
    }
    $largest-common-subsequence += $local-common-substring;
    max($lhs-len, $rhs-len) - $largest-common-subsequence;
}

=begin pod

=head1 NAME

Text::Sift4 - A Perl 6 Sift4 (Super Fast and Accurate string distance algorithm) implementation

=head1 SYNOPSIS

  use Text::Sift4;

  say sift4("abc", "ab");  # OUTPUT: «1␤»
  say sift4("ab", "abc");  # OUTPUT: «1␤»
  say sift4("abc", "xxx"); # OUTPUT: «3␤»

=head1 DESCRIPTION

Text::Sift4 is a Perl 6 Sift4 implementation.
Sift4 computes approximate results of Levenshtein Distance.

=head1 METHODS

=head2 sift4

Defined as:

  sub sift4(Str $lhs, Str $rhs, Int :$max-offset = 5 --> Int:D) is export

returns approximation of Levenshtein Distance.

=item Str C<$lhs> is one side of the strings to compare.

=item Str C<$rhs> is one side of the strings to compare.

=item Int C<:$max-offset> is the maximum offset value. The value is default to 5.

=head1 AUTHOR

Itsuki Toyota <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Itsuki Toyota

Sift4 Algorithm was invented by Siderite, and is from: https://siderite.blogspot.com/2014/11/super-fast-and-accurate-string-distance.html

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
