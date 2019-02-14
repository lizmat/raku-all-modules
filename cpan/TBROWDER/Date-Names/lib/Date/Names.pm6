unit module Date::Names;

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
constant @lang is export = <de en es fr it nb nl ru>;

#  lists of the eight standard hash names for each language:
constant @mnames is export = <mon mon2 mon3 mona>;
constant @dnames is export = <dow dow2 dow3 dowa>;

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
class Date::Names {
    has Str $.lang = 'en';  # default: English
    has Str $.dset = 'dow'; # default: full names
    has Str $.mset = 'mon'; # default: full names

    # these take the value of the chosen name set
    has $.d;
    has $.m;
    has $.s;

    has Period $.period = keep-p; # add, remove, or keep a period to end abbreviations
                                  # (True or False; default -1 means use the
                                  # native value as is)
    has UInt $.trunc    = 0;      # truncate to N chars if N > 0
    has Case $.case     = keep-c; # use native case (or choose: tc, lc, uc)
    has $.pad           = False;  # used with trunc to fill short values with
                                  # spaces on the right

    submethod TWEAK() {
        # this sets the class var to the desired
        # dow and mon hashes (lang and value width)
        $!d = $::("Date::Names::{$!lang}::{$!dset}");
        $!m = $::("Date::Names::{$!lang}::{$!mset}");
        # list of non-empty sets:
        $!s = $::("Date::Names::{$!lang}::sets");

        die "no \$sets set for this lang" if !$!.s.elems;
    }

    method !handle-val-attrs($val, :$is-abbrev!) {
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

    method dow(UInt $n where { $n > 0 && $n < 8 }, $trunc = 0) {
        my $val = $.d{$n};
        my $is-abbrev = $.dset eq 'dow' ?? False !! True;
        if $trunc && !$is-abbrev {
            return $val.substr(0, $trunc);
        }

        $val = self!handle-val-attrs($val, :$is-abbrev);
        return $val;
    }

    method mon(UInt $n where { $n > 0 && $n < 13 }, $trunc = 0) {
        my $val = $.m{$n};
        my $is-abbrev = $.mset eq 'mon' ?? False !! True;
        if $trunc && !$is-abbrev {
            return $val.substr(0, $trunc);
        }

        $val = self!handle-val-attrs($val, :$is-abbrev);
        return $val;
    }

    # allow changing attributes on an instance
    method set-dset() {
    }
    method set-mset() {
    }
    method set-lang() {
    }

    # save changing others for later

    # utility methods
    method sets {
        say "name sets with values:";
        say "  $_" for $.s.keys.sort;
    }
    method nsets {
        return $.s.elems;
    }

}
