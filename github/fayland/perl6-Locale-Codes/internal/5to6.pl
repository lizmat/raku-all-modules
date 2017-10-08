#!/usr/bin/perl

use v5.10;
use strict;
use warnings;
use YAML::Syck qw(LoadFile);
use FindBin qw/$Bin/;
use Data::Dumper;

# curr.yaml is from perl5 Locale::Codes internal
my $data = LoadFile("$Bin/curr.yaml");

{
    my $country = $data->{language};
    open(my $fh, '>', $Bin . '/../lib/Locale/Codes/Language_Codes.pm');
    print $fh 'unit module Locale::Codes::Language_Codes;' . "\n\n";
    print $fh 'my $data = q{' . "\n";
    foreach my $code (sort keys %{ $country->{'alpha-2'}->{code} }) {
        my $name = $country->{'alpha-2'}->{code}->{$code};
        my $alpha3 = $country->{'alpha-3'}->{name}->{lc $name}->[0];
        my $term = $country->{'term'}->{name}->{lc $name}->[0];
        # print Dumper([$code, $alpha3, $term, $name]);
        # die unless $dom eq $code;
        print $fh join(':', uc$code, uc($alpha3 // ''), uc($term // ''), $name) . "\n";
    }
    print $fh '};' . "\n";
    print $fh <<'CODE';

our %data;
for $data.trim.split("\n") -> $line {
    my @parts = $line.split(':');
    %data<code><alpha-2>{@parts[0]} = @parts[3];
    %data<code><alpha-3>{@parts[1]} = @parts[3] if @parts[1].chars;
    %data<code><term>{@parts[2]}    = @parts[3] if @parts[2].chars;
    %data<name><alpha-2>{lc @parts[3]} = @parts[0];
    %data<name><alpha-3>{lc @parts[3]} = @parts[1] if @parts[1].chars;
    %data<name><term>{lc @parts[3]}    = @parts[2] if @parts[2].chars;
}

CODE
    close($fh);
}

{
    my $currency = $data->{currency};
    open(my $fh, '>', $Bin . '/../lib/Locale/Codes/Currency_Codes.pm');
    print $fh 'unit module Locale::Codes::Currency_Codes;' . "\n\n";
    print $fh 'my $data = q{' . "\n";
    foreach my $code (sort keys %{ $currency->{alpha}->{code} }) {
        my $name = $currency->{alpha}->{code}->{$code};
        my $numeric = $currency->{'num'}->{name}->{lc $name}->[0];
        # print Dumper([$code, $numeric, $name]);
        # die unless $dom eq $code;
        print $fh join(':', uc $code, $numeric, $name) . "\n";
    }
    print $fh '};' . "\n";
    print $fh <<'CODE';

our %data;
for $data.trim.split("\n") -> $line {
    my @parts = $line.split(':');
    %data<code><alpha>{@parts[0]} = @parts[2];
    %data<code><num>{@parts[1]} = @parts[2];
    %data<name><alpha>{lc @parts[2]} = @parts[0];
    %data<name><num>{lc @parts[2]} = @parts[1];
}

CODE
    close($fh);
}

{
    my $country = $data->{country};
    open(my $fh, '>', $Bin . '/../lib/Locale/Codes/Country_Codes.pm');
    print $fh 'unit module Locale::Codes::Country_Codes;' . "\n\n";
    print $fh 'my $data = q{' . "\n";
    foreach my $code (sort keys %{ $country->{'alpha-2'}->{code} }) {
        my $name = $country->{'alpha-2'}->{code}->{$code};
        my $alpha3 = $country->{'alpha-3'}->{name}->{lc $name}->[0];
        my $dom = $country->{'dom'}->{name}->{lc $name}->[0];
        my $numeric = $country->{'numeric'}->{name}->{lc $name}->[0];
        # print Dumper([$code, $alpha3, $dom, $numeric, $name]);
        # die unless $dom eq $code;
        print $fh join(':', uc $code, uc $alpha3, $numeric, $name) . "\n";
    }
    print $fh '};' . "\n";
    print $fh <<'CODE';

our %data;
for $data.trim.split("\n") -> $line {
    my @parts = $line.split(':');
    %data<code><alpha-2>{@parts[0]} = @parts[3];
    %data<code><alpha-3>{@parts[1]} = @parts[3];
    %data<code><numeric>{@parts[2]} = @parts[3];
    %data<name><alpha-2>{lc @parts[3]} = @parts[0];
    %data<name><alpha-3>{lc @parts[3]} = @parts[1];
    %data<name><numeric>{lc @parts[3]} = @parts[2];
}

CODE
    close($fh);
}

{
    my $script = $data->{script};
    open(my $fh, '>', $Bin . '/../lib/Locale/Codes/Script_Codes.pm');
    print $fh 'unit module Locale::Codes::Script_Codes;' . "\n\n";
    print $fh 'my $data = q{' . "\n";
    foreach my $code (sort keys %{ $script->{alpha}->{code} }) {
        my $name = $script->{alpha}->{code}->{$code};
        my $numeric = $script->{'num'}->{name}->{lc $name}->[0];
        # print Dumper([$code, $numeric, $name]);
        # die unless $dom eq $code;
        print $fh join(':', $code, ($numeric // ''), $name) . "\n";
    }
    print $fh '};' . "\n";
    print $fh <<'CODE';

our %data;
for $data.trim.split("\n") -> $line {
    my @parts = $line.split(':');
    %data<code><alpha>{@parts[0]} = @parts[2];
    %data<code><num>{@parts[1]} = @parts[2] if @parts[1].chars;
    %data<name><alpha>{lc @parts[2]} = @parts[0];
    %data<name><num>{lc @parts[2]} = @parts[1] if @parts[1].chars;
}

CODE
    close($fh);
}