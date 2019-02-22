unit class Date::Names;

# Languages currently available:
#
#   de - German
#   en - English
#   es - Spanish
#   fr - French
#   id - Indonesian
#   it - Italian
#   nb - Norwegian
#   nl - Dutch
#   ru - Russian

# a list of the language two-letter codes currently considered
# in this module:
our @langs = <de en es fr id it nb nl ru>;

# lists of the eight standard data set names for each language:
our @msets = <mon mon2 mon3 mona>;
our @dsets = <dow dow2 dow3 dowa>;
our @allsets;
@allsets.append($_) for @msets;
@allsets.append($_) for @dsets;

# the language-specfic data
use Date::Names::de;
use Date::Names::en;
use Date::Names::es;
use Date::Names::fr;
use Date::Names::id;
use Date::Names::it;
use Date::Names::nb;
use Date::Names::nl;
use Date::Names::ru;

# the class (beta)
enum Period <yes no keep>;
enum Case <tc uc lc nc>; # 'nc' no change

has Str $.lang is rw = 'en';  # default: English
has Str $.mset is rw = 'mon'; # default: full names
has Str $.dset is rw = 'dow'; # default: full names

has Period $.period = keep;  # add, remove, or keep a period to end abbreviations
has UInt $.trunc    = 0;     # truncate to N chars if N > 0
has Case $.case     = nc;    # use native case (or choose: tc, lc, uc)
has $.pad           = False; # used with trunc to fill short values with
                             # spaces on the right
has $.debug is rw   = 0;

# these objects take the value of the chosen name of each type of data
# set:
has $.d is rw;
has $.m is rw;
# this an auto-generated hash of the names of
# all non-empty data sets and values of that array
has %.s is rw;

submethod TWEAK() {
    # this sets the class var to the desired
    # dow and mon name sets (lang and value width)
    # convenience string vars
    my $L = $!lang;
    my $M = $!mset;
    my $D = $!dset;

    $!m = self!define-attr-mset($L, $M);
    $!d = self!define-attr-dset($L, $D);
    %!s = self!define-attr-sets($L);

    =begin comment
    my $mm = "Date::Names::{$L}::{$M}";
    my $dd = "Date::Names::{$L}::{$D}";
    $!m = $::($mm);
    $!d = $::($dd);

    # create hash of non-empty sets:
    # TODO make private method to use with a deep clone method
    %!s = self!define-objects;
    =end comment

    =begin comment
    for @allsets -> $n {
        my $nn = "Date::Names::{$L}::{$n}";
        #my $nn = "{$L}::{$n}";
        #my $nn = "{$n}";
        my $s = $::($nn);
        #next if !$s;
        say $s.gist if $!debug;;
        note "DEBUG: lang $L, set $n, elems {$s.elems}" if $!debug;
        next if !$s.elems;
        %!s{$n} = $s;
    }
    =end comment

    =begin comment
    die "no \$sets set for this lang {$!lang}" if !%!s.elems;

    # other requirements for a valid lang class
    # must have at least four total data sets:
    #   mon
    #   dow
    #   mowX - one month abbreviation data set
    #   dowX - one weekday abbreviation data set
    my $mo = 0;
    my $do = 0;
    for <mon dow> -> $n  {
        my $nhas = %!s{$n}.elems;
        my $nreq = $n eq 'mon' ?? 12 !! 7;
        if $nhas != $nreq {
            note "WARNING: lang {$!lang}, data set '$n' has $nhas elements,\n  but it should have $nreq";
        }
        else {
            ++$mo if $n eq 'mon';
            ++$do if $n eq 'dow';
        }
    }

    my $ma = 0;
    my $da = 0;
    for @allsets -> $n  {
        # already checked mon and dow
        next if $n ~~ /^mon|dow$/;

        my $nhas = %!s{$n}.elems;
        my $nreq = $n eq 'mon' ?? 12 !! 7;
        if $nhas != $nreq {
            note "WARNING: lang {$!lang}, data set '$n' has $nhas elements, but it should have $nreq";
        }
        else {
            my $c = $n.comb[0];
            ++$ma if $c eq 'm';
            ++$da if $c eq 'd';
        }
    }
    my $totreq = $mo + $do + $ma + $da;

    if $totreq != 4 {
        note "FATAL: Minimum data requirements not satisfied.";
        note "TODO: be specific";
        exit;
    }
    =end comment
}

# private methods ================================
method !define-attr-mset($L, $M) {
    my $mm = "Date::Names::{$L}::{$M}";
    my $m  =  $::($mm);
    return $m;
}

method !define-attr-dset($L, $D) {
    my $dd = "Date::Names::{$L}::{$D}";
    my $d  =  $::($dd);
    return $d;
}

method !define-attr-sets($L) {
    my $M = $!mset;
    my $D = $!dset;

    my %h;
    for @allsets -> $n {
        my $nn = "Date::Names::{$L}::{$n}";
        my $s = $::($nn);
        if !$s {
            say "DEBUG: lang $L, empty set '$n'...skipping" if $!debug;
            next;
        }
        if $!debug {
            #say $s.gist if $!debug;;
            say "DEBUG: lang $L, set $n, elems {$s.elems}: '{$s.gist}'";
        }
        next if !$s.elems;
        %h{$n} = $s;
    }
    return %h;
}

method !handle-val-attrs(Str $val is copy, :$is-abbrev!) {
    if !defined $val {
        die "FATAL: undefined \$val '{$val.^name}'";
    }
    # check for any changes that are to be made
    my $has-period = 0;
    my $nchars = $val.chars; # includes an ending period
    if $val ~~ /^(\S+) '.'$/ {
        die "FATAL: found ending period in val $val (not an abbreviation)"
            if !$is-abbrev;

        # remove the period and return it later if required
        $val = ~$0;
        $has-period = 1;
    }
    elsif $val ~~ /'.'/ {
        die "FATAL: found INTERIOR period in val $val";
    }

    if $.trunc && $val.chars > $.trunc {
        $val .= substr(0, self.trunc);
    }
    elsif $.trunc && $.pad && $val.chars < $.trunc {
        $val .= substr(0, $.trunc);
    }

    if $.case !~~ /keep/ {
        # more checks needed
    }

    if $.trunc && $val.chars > self.trunc {
        $val .= substr(0, $.trunc);
    }
    elsif $.trunc && $.pad && $val.chars < $.truncx {
        $val .= substr(0, $.trunc);
    }
    if $.case !~~ /keep/ {
        # more checks needed
    }

    # treat the period carefully, it may or may not
    # have been removed by now
    if $val !~~ /'.'$/ && $has-period {
        $val ~= '.';
    }

    return $val;

}

=begin comment
# TOTO get this working!!
method clone {
    =begin comment
    my %h = self!define-objects;
    nextwith :s(%h), |%_;
    =end comment

    my $L = $!lang;
    my $M = $!mset;
    my $D = $!dset;

    my $m = self!define-attr-mset($L, $M);
    my $d = self!define-attr-dset($L, $D);
    my %h = self!define-attr-sets($L);
    nextwith :lang($L), :mset($M), :dset($D), :m($m), :d($d), :s(%h), |%_;

}
=end comment

method dow(UInt $n is copy where { $n > 0 && $n < 8 }, $trunc = 0) {
    --$n; # <-- CRITICAL for proper array indexing internally

    my $val = $.d[$n];
    my $is-abbrev = $.dset eq 'dow' ?? False !! True;
    if $trunc && !$is-abbrev {
        return $val.substr(0, $trunc);
    }

    $val = self!handle-val-attrs($val, :$is-abbrev);
    return $val;
}

method mon(UInt $n is copy where { $n > 0 && $n < 13 }, $trunc = 0) {
    --$n; # <-- CRITICAL for proper array indexing internally

    my $val = $.m[$n];
    my $is-abbrev = $.mset eq 'mon' ?? False !! True;
    if $trunc && !$is-abbrev {
        return $val.substr(0, $trunc);
    }

    $val = self!handle-val-attrs($val, :$is-abbrev);
    return $val;
}

# utility methods
method sets {
    say "name sets with values:";
    say "  $_" for %.s.keys.sort;
}

method nsets {
    return %.s.elems;
}

# could make tests!
method show {
    say "Language {$!lang}";
    say "  non-empty sets ({%.s.elems} total):";
    for %.s.keys.sort -> $k {
        printf "  %-4s:", $k;
        my $arr = %.s{$k};
        print " '$_'" for @($arr);
        say "";
    }
}

method show-all {
    # loop over all langs and show all available sets:
    say "Available languages and name sets:";
    for @langs -> $L {
        my $d = Date::Names.new: :lang($L);
        #say "Language: $L";
        $d.show;
    }
}
