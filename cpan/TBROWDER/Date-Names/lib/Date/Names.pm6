unit class Date::Names;

# Languages currently available:
#
#   de - German
#   es - Spanish
#   fr - French
#   it - Italian
#   nb - Norwegian
#   nl - Dutch
#   ru - Russian

# a list of the language two-letter codes currently considered
# in this module:
our @langs = <de en es fr it nb nl ru>;

# lists of the eight standard data set names for each language:
our @msets = <mon mon2 mon3 mona>;
our @dsets = <dow dow2 dow3 dowa>;

# the language-specfic data
use Date::Names::de;
use Date::Names::en;
use Date::Names::es;
use Date::Names::fr;
use Date::Names::it;
use Date::Names::nb;
use Date::Names::nl;
use Date::Names::ru;

# the class (beta)
enum Period <yes no keep-p>;
enum Case <tc uc lc keep-c>;

#class Date::Names {

    has Str $.lang is rw = 'en';  # default: English
    has Str $.mset is rw = 'mon'; # default: full names
    has Str $.dset is rw = 'dow'; # default: full names

    # these take the value of the chosen name of each type of data  set
    has $.d is rw;
    has $.m is rw;
    has %.s is rw; # this an auto-generated hash of the names of all non-empty data sets and values of that array

    has Period $.period = keep-p; # add, remove, or keep a period to end abbreviations
                                  # (True or False; default -1 means use the
                                  # native value as is)
    has UInt $.trunc    = 0;      # truncate to N chars if N > 0
    has Case $.case     = keep-c; # use native case (or choose: tc, lc, uc)
    has $.pad           = False;  # used with trunc to fill short values with
                                  # spaces on the right

    submethod TWEAK() {
        # this sets the class var to the desired
        # dow and mon name sets (lang and value width)
        =begin comment
        $!m = $::("Date::Names::{$!lang}::{$!mset}");
        $!d = $::("Date::Names::{$!lang}::{$!dset}");
        =end comment
        # convenience string vars
        my $L = $!lang;
        my $M = $!mset;
        my $D = $!dset;

        =begin comment
        my $mm = "{$L}::{$M}";
        my $dd = "{$L}::{$D}";
        =end comment
        my $mm = "Date::Names::{$L}::{$M}";
        my $dd = "Date::Names::{$L}::{$D}";
        $!m = $::($mm);
        $!d = $::($dd);

        # create hash of non-empty sets:
        for @msets, @dsets -> $n {
            =begin comment
            my $nn = "{$L}::{$n}";
            =end comment

            my $nn = "Date::Name::{$L}::{$n}";
            my $s = $::($nn);
            note "DEBUG: lang $L, set $n, elems {$s.elems}";
            next if !$s.elems;
            %!s{$n} = $s;
        }

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
                note "WARNING: lang {$!lang}, data set '$n' has $nhas elements, but it should have $nreq";
            }
            else {
                ++$mo if $n eq 'mon';
                ++$do if $n eq 'dow';
            }
        }

        my $ma = 0;
        my $da = 0;
        for @msets, @dsets -> $n  {
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

    method !handle-val-attrs(Str $val, :$is-abbrev!) {
        if !defined $val {
            die "FATAL: undefined \$val '{$val.^name}'";
        }
        # check for any changes that are to be made
        my $has-period = 0;
        my $nchars = $val.chars; # includes an ending period
        if $val ~~ /^(\s+) '.'$/ {
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

        return $val;

    }

    method dow(UInt $n is copy where { $n > 0 && $n < 8 }, $trunc = 0) {
        # CRITICAL for proper array indexing internally:
        --$n;

        my $val = $.d[$n];
        my $is-abbrev = $.dset eq 'dow' ?? False !! True;
        if $trunc && !$is-abbrev {
            return $val.substr(0, $trunc);
        }

        $val = self!handle-val-attrs($val, :$is-abbrev);
        return $val;
    }

    method mon(UInt $n is copy where { $n > 0 && $n < 13 }, $trunc = 0) {
        # CRITICAL for proper array indexing internally:
        --$n;

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

    # a class method
    method show {
        # loop over all langs and show all available sets:
        for @langs -> $L {
            say "DEBUG, method show, lang $L";
            # loop over the non-empty sets 
            #die "tom fix this";
            #my $s = $::("Date::Names::{$L}
        }
    }
        
    method dump(:$fh) {
        my $L = $!lang;
        my $M = $!mset;
        my $D = $!dset;

        if $fh {
        }
        else {
            say "============================================";
            say qq:to/HERE/;
            Dumping Date::Names instance:
              lang '{$L}'
              mset '{$M}'
              dset '{$D}'
            HERE

            say "  non-empty sets (%.s.elems} total):";
            say "    $_" for %.s.keys.sort;
            say "============================================";
        }
    }
#}
