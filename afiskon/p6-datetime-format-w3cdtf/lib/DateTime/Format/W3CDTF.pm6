#!/usr/bin/env perl6

use v6;

class DateTime::Format::W3CDTF;

method parse (Str $str) of DateTime {
    my Str $date-str = $str;

    # YYYY-MM-DDThh:mm:ss.sTZD --> YYYY-MM-DDThh:mm:ssTZD
    if $date-str ~~ /^ ( .* T <[0..9]> ** 2 \: <[0..9]> ** 2 \: <[0..9]> ** 2) \. <[0..9]> + ( .*) $/  -> Match $m {
        $date-str = $m[0] ~ $m[1];
    }

    # YYYY-MM-DDThh:mmTZD --> YYYY-MM-DDThh:mm:00TZD
    if $date-str ~~ /^ ( .* T <[0..9]> ** 2 \: <[0..9]> ** 2 ) ( <[Z+-]> .* ) $/  -> $m {
        $date-str = $m[0] ~ ':00' ~ $m[1];
    }

    if $date-str ~~ / . ** 16..* <[+-]> <[0..9]> ** 4 $/ {
        die 'Invalid timezone format';
    }

    if $date-str ~~ /^ ( . ** 16..* <[+-]> <[0..9]> ** 2 ) \: ( <[0..9]> ** 2 ) $/ -> $m {
        $date-str = $m[0] ~ $m[1];
    }

    given $date-str {
        when /^ <[0..9]> ** 4 $/ {
            $date-str ~= '-01-01T00:00:00Z'; 
        }
        when /^ <[0..9]> ** 4 \- <[0..9]> ** 2 $/ {
            $date-str ~= '-01T00:00:00Z'; 
        }
        when /^ <[0..9]> ** 4 \- <[0..9]> ** 2 \- <[0..9]> ** 2 $/ {
            $date-str ~= 'T00:00:00Z'; 
        }
        when / ( Z | <[+-]> <[0..9]> ** 4 ) $/ {
            # ok, do nothing
        }
        default {
            die 'Timezone missing';
        }
    }
    return DateTime.new($date-str);
}

method format (DateTime $date) of Str {
    my Str $result = $date.Str;
    if my $m = $result ~~ /^( .* <[+-]> <[0..9]> ** 2 ) ( <[0..9]> ** 2 )$/ {
        $result = $m[0] ~ ':' ~ $m[1];
    }
    return $result;
}

=begin pod

=head1 NAME

DateTime::Format::W3CDTF - A Perl 6 module to deal with W3CDTF dates.

=head1 SYNOPSYS

=begin code
use DateTime::Format::W3CDTF;

my $w3c = DateTime::Format::W3CDTF.new;
my DateTime $datetime = $w3c.parse('2012-09-04T11:22:33.5+04:00');
say $w3c.format($datetime);
=end code
     
=head1 DESCRIPTION

A Perl 6 module to deal with W3CDTF dates.

=head1 METHODS

=head2 parse(Str $date) of DateTime

Parses the string with W3C-formatted date and returns DateTime object.
Throws an exception in case of errors.

=head2 format(DateTime $date) of String

Converts DateTime object to the W3C-formatted date string.
Throws an exception in case of errors.

=head1 AUTHOR

Alexandr Alexeev, <eax at cpan.org> (L<http://eax.me/>)

=head1 COPYRIGHT

Copyright 2012 Alexandr Alexeev

This program is free software; you can redistribute it and/or modify it
under the same terms as Rakudo Perl 6 itself.

=end pod
