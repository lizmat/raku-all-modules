#!/usr/bin/env perl6

use Munge;

sub MAIN(Str :$cipher, Str :$MAC, Str :$zip, Int :$ttl, Str :$socket,
           Int :$uid-restriction, Int :$gid-restriction)
{
    Munge.new(:$cipher, :$MAC, :$zip, :$ttl, :$socket,
              :$uid-restriction, :$gid-restriction)
         .encode($*IN.slurp)
         .put;
}
