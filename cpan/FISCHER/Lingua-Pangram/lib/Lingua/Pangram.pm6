use v6.c;

unit module Lingua::Pangram:auth<github:sfischer13>:ver<0.1.1>;

our $VERSION = '0.1.1';

=begin pod

=head1 NAME

Lingua::Pangram - Check whether a string is a pangram.

=head1 SYNOPSIS

=begin code

use Lingua::Pangram;

pangram('The quick brown fox jumps over the lazy dog', 'a' .. 'z');
# OUTPUT: «True␤»

pangram('The quick brown fox jumps over the lazy dog', 'abcdefghijklmnopqrstuvwxyz');
# OUTPUT: «True␤»

pangram-de('"Fix, Schwyz!", quäkt Jürgen blöd vom Paß.');
# OUTPUT: «True␤»

pangram-en('The quick brown fox jumps over the lazy dog');
# OUTPUT: «True␤»

=end code

=head1 DESCRIPTION

Check whether a string contains all the letters of an alphabet, which can be specified. All methods are case insensitive.

=head1 FUNCTIONS

=head2 pangram

    multi sub pangram(Str $string, @graphs --> Bool)

    multi sub pangram(Str $string, Str $unigraphs --> Bool)
    multi sub pangram(Str $string, Range $unigraphs --> Bool)

    multi sub pangram(Str $string, Str $unigraphs, @multigraphs --> Bool)
    multi sub pangram(Str $string, Range $unigraphs, @multigraphs --> Bool)

=end pod

multi pangram(Str $string, @graphs --> Bool) is export {
    my $input = $string.fc;
    my @tests = @graphs.map(*.fc).grep(*.chars != 0);
    return $input.index(all(@tests)).defined;
}

multi pangram(Str $string, Str $unigraphs --> Bool) is export {
    return pangram($string, $unigraphs.comb.unique);
}

multi pangram(Str $string, Range $unigraphs --> Bool) is export {
    return pangram($string, $unigraphs.map(*.Str));
}

multi pangram(Str $string, Str $unigraphs, @multigraphs --> Bool) is export {
    return pangram($string, ($unigraphs.comb.unique, @multigraphs).flat);
}

multi pangram(Str $string, Range $unigraphs, @multigraphs --> Bool) is export {
    return pangram($string, ($unigraphs.map(*.Str), @multigraphs).flat);
}

=begin pod
=head2 pangram-de

    sub pangram-de(Str $string --> Bool)
=end pod
sub pangram-de(Str $string --> Bool) is export {
    return pangram($string, 'a' .. 'z', <ä ö ü ß>);
}

=begin pod
=head2 pangram-en

    sub pangram-en(Str $string --> Bool)
=end pod
sub pangram-en(Str $string --> Bool) is export {
    return pangram($string, 'a' .. 'z');
}

=begin pod
=head2 pangram-es

    sub pangram-es(Str $string, Bool $digraphs = False --> Bool)
=end pod
sub pangram-es(Str $string, Bool $digraphs = False --> Bool) is export {
    if $digraphs {
        return pangram($string, 'a' .. 'z', <ñ ch ll rr>);
    } else {
        return pangram($string, 'a' .. 'z', ('ñ', ));
    }
}

=begin pod
=head2 pangram-fr

    sub pangram-fr(Str $string, Bool $ligatures = False --> Bool)
=end pod
sub pangram-fr(Str $string, Bool $ligatures = False --> Bool) is export {
    if $ligatures {
        return pangram($string, 'a' .. 'z', <æ œ>);
    } else {
        return pangram($string, 'a' .. 'z');
    }
}

=begin pod
=head2 pangram-ru

    sub pangram-ru(Str $string --> Bool)
=end pod
sub pangram-ru(Str $string --> Bool) is export {
    return pangram($string, 'а' .. 'я', ('ё', ));
}

=begin pod

=head1 SEE ALSO

L<https://github.com/sfischer13/perl6-Lingua-Pangram>

=head1 AUTHOR

Stefan Fischer <sfischer13@ymail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2018 Stefan Fischer

This library is free software; you can redistribute it and/or modify it under the MIT License.

=end pod
