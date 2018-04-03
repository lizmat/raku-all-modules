use v6.c;

unit module Lingua::Palindrome:auth<github:sfischer13>:ver<0.1.0>;

our $VERSION = '0.1.0';

=begin pod

=head1 NAME

Lingua::Palindrome - Check whether a string is a palindrome.

=head1 SYNOPSIS

=begin code

use Lingua::Palindrome;

char-palindrome('Madam');
# OUTPUT: «True␤»

char-palindrome('Madam', :case(True));
# OUTPUT: «False␤»

char-palindrome('Was it a car or a cat I saw?');
# OUTPUT: «True␤»

char-palindrome('Was it a car or a cat I saw?', :punct(True));
# OUTPUT: «False␤»

word-palindrome('Fall leaves after leaves fall.');
# OUTPUT: «True␤»

word-palindrome('Fall leaves after leaves fall.', :case(True));
# OUTPUT: «False␤»

line-palindrome(q:to/END/);
Abc
def
abc
END
# OUTPUT: «True␤»

line-palindrome(q:to/END/, :case(True));
Abc
def
abc
END
# OUTPUT: «False␤»

=end code

=head1 DESCRIPTION

Check whether a string or a file forms a palindrome.

=head1 FUNCTIONS

=head2 char-palindrome

    sub char-palindrome(Str $string, Bool :$case = False, Bool :$alpha = True, Bool :$digit = True, Bool :$punct = False, Bool :$space = False --> Bool)

=head2 word-palindrome

    sub word-palindrome(Str $string, Bool :$case = False, Bool :$alpha = True, Bool :$digit = True, Bool :$punct = False --> Bool)

=head2 line-palindrome

    multi sub line-palindrome(IO::Path $path, Bool :$case = False, Bool :$alpha = True, Bool :$digit = True, Bool :$punct = False, :$space = False --> Bool)
    multi sub line-palindrome(Str $string, Bool :$case = False, Bool :$alpha = True, Bool :$digit = True, Bool :$punct = False, Bool :$space = False --> Bool)

=end pod

sub char-palindrome(Str $string, Bool :$case = False, Bool :$alpha = True, Bool :$digit = True, Bool :$punct = False, Bool :$space = False --> Bool) is export {
	my $s = clean-string($string, $case, $alpha, $digit, $punct, $space);
	return $s eq $s.flip;
}

sub word-palindrome(Str $string, Bool :$case = False, Bool :$alpha = True, Bool :$digit = True, Bool :$punct = False --> Bool) is export {
	my @words = map { clean-string($_, $case, $alpha, $digit, $punct, True) }, $string.words;
    return check-sequence(@words);
}

multi line-palindrome(IO::Path $path, Bool :$case = False, Bool :$alpha = True, Bool :$digit = True, Bool :$punct = False, Bool :$space = False --> Bool) is export {
    return line-palindrome($path.slurp, :$case, :$alpha, :$digit, :$punct, :$space);
}

multi line-palindrome(Str $string, Bool :$case = False, Bool :$alpha = True, Bool :$digit = True, Bool :$punct = False, Bool :$space = False --> Bool) is export {
	my @lines = map { clean-string($_, $case, $alpha, $digit, $punct, $space) }, $string.lines;
    return check-sequence(@lines);
}

sub check-sequence(@sequence where {$_.all ~~ Str} --> Bool) {
    my @equal = map {$_[0] eq $_[1]}, (@sequence Z @sequence.reverse);
    return ?all(@equal);
}

sub clean-string(Str $string, Bool $case, Bool $alpha, Bool $digit, Bool $punct, Bool $space --> Str) {
	my $s = $string;
    $s = $s.fc unless $case;
	$s ~~ s:g/<alpha>// unless $alpha;
	$s ~~ s:g/<digit>// unless $digit;
	$s ~~ s:g/<punct>// unless $punct;
	$s ~~ s:g/\s// unless $space;
	return $s;
}

=begin pod

=head1 SEE ALSO

L<https://github.com/sfischer13/perl6-Lingua-Palindrome>

=head1 AUTHOR

Stefan Fischer <sfischer13@ymail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2018 Stefan Fischer

This library is free software; you can redistribute it and/or modify it under the MIT License.

=end pod
