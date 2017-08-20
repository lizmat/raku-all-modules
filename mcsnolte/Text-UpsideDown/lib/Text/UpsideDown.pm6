use v6;

unit module Text::UpsideDown:ver<1.0.0>:auth<github:mcsnolte>;

=begin pod

=head1 NAME

Text::UpsideDown - Flip text upside-down using Unicode

=head1 SYNOPSIS

 use Text::UpsideDown;
 say upside_down("foo");
 # prints "ɟoo"

=head1 DESCRIPTION

This module will flip text upside-down using Unicode.

=head1 AUTHOR

This software is copyright (c) 2007 by Marcel Grünauer and Mike Doherty.
perl6 port: 2016 Steve Nolte

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod

my %upside_down_map = (
	'A' => "\c[FOR ALL]",
	'B' => "\c[GREEK SMALL LETTER XI]",
	'C' => "\c[ROMAN NUMERAL REVERSED ONE HUNDRED]",
	'D' => "\c[LEFT HALF BLACK CIRCLE]",
	'E' => "\c[LATIN CAPITAL LETTER REVERSED E]",
	'F' => "\c[TURNED CAPITAL F]",
	'G' => "\c[TURNED SANS-SERIF CAPITAL G]",
	'J' => "\c[LATIN SMALL LETTER LONG S]",
	'K' => "\c[RIGHT NORMAL FACTOR SEMIDIRECT PRODUCT]",
	'L' => "\c[TURNED SANS-SERIF CAPITAL L]",
	'M' => 'W',
	'N' => "\c[LATIN LETTER SMALL CAPITAL REVERSED N]",
	'P' => "\c[CYRILLIC CAPITAL LETTER KOMI DE]",
	'Q' => "\c[GREEK CAPITAL LETTER OMICRON WITH TONOS]",
	'R' => "\c[LATIN LETTER SMALL CAPITAL TURNED R]",
	'T' => "\c[UP TACK]",
	'U' => "\c[INTERSECTION]",
	'V' => "\c[GREEK LETTER SMALL CAPITAL LAMDA]",
	'Y' => "\c[TURNED SANS-SERIF CAPITAL Y]",
	'a' => "\c[LATIN SMALL LETTER TURNED A]",
	'b' => 'q',
	'c' => "\c[LATIN SMALL LETTER OPEN O]",
	'd' => 'p',
	'e' => "\c[LATIN SMALL LETTER TURNED E]",
	'f' => "\c[LATIN SMALL LETTER DOTLESS J WITH STROKE]",
	'g' => "\c[LATIN SMALL LETTER B WITH TOPBAR]",
	'h' => "\c[LATIN SMALL LETTER TURNED H]",
	'i' => "\c[LATIN SMALL LETTER DOTLESS I]",
	'j' => "\c[LATIN SMALL LETTER R WITH FISHHOOK]",
	'k' => "\c[LATIN SMALL LETTER TURNED K]",
	'l' => "\c[LATIN SMALL LETTER ESH]",
	'm' => "\c[LATIN SMALL LETTER TURNED M]",
	'n' => 'u',
	'r' => "\c[LATIN SMALL LETTER TURNED R]",
	't' => "\c[LATIN SMALL LETTER TURNED T]",
	'v' => "\c[LATIN SMALL LETTER TURNED V]",
	'w' => "\c[LATIN SMALL LETTER TURNED W]",
	'y' => "\c[LATIN SMALL LETTER TURNED Y]",

	'!' => "\c[INVERTED EXCLAMATION MARK]",
	'"' => "\c[DOUBLE LOW-9 QUOTATION MARK]",
	'&' => "\c[TURNED AMPERSAND]",
	q{'} => ',',
	'.' => "\c[DOT ABOVE]",
	'^' => "\c[LOGICAL OR]",
	'*' => "\c[LOW ASTERISK]",
	'1' => "\c[DOWNWARDS HARPOON WITH BARB RIGHTWARDS]",
	'3' => "\c[LATIN CAPITAL LETTER OPEN E]",
	'6' => '9',
	'7' => "\c[BOPOMOFO LETTER ENG]",
	';' => "\c[ARABIC SEMICOLON]",
	'?' => "\c[INVERTED QUESTION MARK]",
	'(' => ')',
	'[' => ']',
	'{' => '}',
	'<' => '>',
	'_' => "\c[OVERLINE]",
	"\c[UNDERTIE]"  => "\c[CHARACTER TIE]",
	"\c[LEFT SQUARE BRACKET WITH QUILL]" => "\c[RIGHT SQUARE BRACKET WITH QUILL]",
	"\c[THEREFORE]" => "\c[BECAUSE]",
	"\c[BOX DRAWINGS HEAVY DOWN AND HORIZONTAL]" => "\c[BOX DRAWINGS HEAVY UP AND HORIZONTAL]",
	"\c[BOX DRAWINGS LIGHT DOWN AND HORIZONTAL]" => "\c[BOX DRAWINGS LIGHT UP AND HORIZONTAL]",
);

my %upside_down_map_all = ( %upside_down_map, %upside_down_map.invert.hash );

sub upside_down ( Str $s ) is export {
	return $s.flip.comb.map({ %upside_down_map_all{$_} // $_ }).join;
}

# vim: ft=perl6

