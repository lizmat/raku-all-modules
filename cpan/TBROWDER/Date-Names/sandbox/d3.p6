#!/usr/bin/env perl6

# two questions:

# assigning a list as a hash element
say "===============================";
say "testing hash/list assignment";

my @m = <a b c>;
my %h;
%h<0> = @m;
%h<1> = |@m;
%h<2> = @m.flat;
for %h.keys.sort -> $k {
    my $v = %h{$k};
    say "key $k:";
    say "  $_" for $v;
}

# testing existence of a a hash key (with no or some value)
say "===============================";
say "testing hash key existence";
%h<1> = 0;

# test 1
if %h<1> { say "hash \%h<0> exists with value zero WITH BASIC IF TEST"; }
else     { say "hash \%h<0> does NOT exist with value zero WITH BASIC IF TEST"; }

# test 2
if %h<1>:exists { say "hash \%h<0> exists with value zero WITH EXISTS TEST"; }
else            { say "hash \%h<0> does NOT exist with value zero WITH EXISTS TEST"; }
