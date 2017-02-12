#!/usr/bin/env perl6
use v6;

unit module Fortran::Grammar::Test;

# taken from http://stackoverflow.com/a/42039566/5433146
# thanks to smls
class TestActions is export { 
    #| Fallback action method that produces a Hash tree from named captures.
    method FALLBACK ($name, $/) {

        # Unless an embedded { } block in the grammar already called make()...
        unless $/.made.defined {

            # If the Match has named captures, produce a hash with one entry
            # per capture:
            if $/.hash -> %captures {
                make hash do for %captures.kv -> $k, $v {

                    # The key of the hash entry is the capture's name.
                    $k => $v ~~ Array 

                        # If the capture was repeated by a quantifier, the
                        # value becomes a list of what each repetition of the
                        # sub-rule produced:
                        ?? $v.map(*.made).cache 

                        # If the capture wasn't quantified, the value becomes
                        # what the sub-rule produced:
                        !! $v.made
                }
            }

            # If the Match has no named captures, produce the string it matched:
            else { make ~$/ }
        }
    }
}


