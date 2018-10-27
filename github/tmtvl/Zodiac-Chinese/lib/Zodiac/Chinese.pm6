use v6.c;

unit module Zodiac::Chinese:ver<0.0.1>:auth<cpan:tmtvl>;

constant @directions = <yang yin>;
constant @elements   = ('metal' xx 2, 'water' xx 2, 'wood' xx 2, 'fire' xx 2, 'earth' xx 2).flat;
constant @signs      = <monkey rooster dog pig rat ox tiger rabbit dragon snake horse sheep>;

class ChineseZodiac is export {
    has $!direction;
    has $!element;
    has $!sign;

    method new(DateTime $dt where { $dt.year.defined }) {
        my $year = $dt.year;

        if ($dt.month.defined && $dt.month < 2) {
            $year = $year - 1;
        }

        my $direction = @directions[$year % 2];
        my $element   = @elements[$year % 10];
        my $sign      = @signs[$year % 12];

        return self.bless(:$direction, :$element, :$sign);
    }

    submethod BUILD(:$!direction, :$!element, :$!sign) { }

    method direction() {
        return $!direction;
    }

    method element() {
        return $!element;
    }

    method sign() {
        return $!sign;
    }
}

=begin pod

=head1 NAME

Zodiac::Chinese - Generate Chinese Zodiac

=head1 SYNOPSIS

    use Zodiac::Chinese;

    my ChineseZodiac $zodiac .= new(DateTime.new(year => 2018, month => 2));

=head1 DESCRIPTION

The Zodiac::Chinese module provides a ChineseZodiac class, which generates a Chinese zodiac sign from a given date. It currently doesn't account for differences between the lunar calendar and Gregorian calendar, so signs generated for late January or early February may be off.

=head1 AUTHOR

Tim Van den Langenbergh <tmt_vdl@gmx.com>

Source can be located at: https://github.com/tmtvl/Chinese-Zodiac. Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Original author: Lady_Aleena. Re-imagined from Perl 5.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
