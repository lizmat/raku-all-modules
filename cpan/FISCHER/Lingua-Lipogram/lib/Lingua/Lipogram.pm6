use v6.c;

unit module Lingua::Lipogram:auth<github:sfischer13>:ver<0.1.0>;

our $VERSION = '0.1.0';

=begin pod

=head1 NAME

Lingua::Lipogram - Check whether a string is a lipogram.

=head1 SYNOPSIS

=begin code

use Lingua::Lipogram;

lipogram('The quick brown fox jumps over the lazy dog.', 's');
# OUTPUT: «False␤»

lipogram('The quick brown fox jumped over the lazy dog.', 's');
# OUTPUT: «True␤»

=end code

=head1 DESCRIPTION

Check whether a string or a file does not contain specific letters. All methods are case insensitive.

=head1 FUNCTIONS

=head2 lipogram

    multi sub lipogram(Str $string, @letters --> Bool)

    multi sub lipogram(IO::Path $path, Str $letters --> Bool)
    multi sub lipogram(IO::Path $path, Range $letters --> Bool)

    multi sub lipogram(Str $string, Str $letters --> Bool)
    multi sub lipogram(Str $string, Range $letters --> Bool)

=end pod

multi lipogram(Str $string, @letters --> Bool) is export {
    my $input = $string.fc;
    my @tests = @letters.map(*.fc).grep(*.chars != 0);
    return $input.index(none(@tests)).defined;
}

multi lipogram(IO::Path $path, Str $letters --> Bool) is export {
    return lipogram($path.slurp, $letters.comb.unique);
}

multi lipogram(IO::Path $path, Range $letters --> Bool) is export {
    return lipogram($path.slurp, $letters.map(*.Str));
}

multi lipogram(Str $string, Str $letters --> Bool) is export {
    return lipogram($string, $letters.comb.unique);
}

multi lipogram(Str $string, Range $letters --> Bool) is export {
    return lipogram($string, $letters.map(*.Str));
}

=begin pod

=head1 SEE ALSO

L<https://github.com/sfischer13/perl6-Lingua-Lipogram>

=head1 AUTHOR

Stefan Fischer <sfischer13@ymail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2018 Stefan Fischer

This library is free software; you can redistribute it and/or modify it under the MIT License.

=end pod
