#!/usr/bin/env perl6
use v6;

# core modules
use Test; # test module

# external modules
use Test::META; # be able to test the META6.json file
use IO::Glob;   # be able to glob for files
use JSON::Fast; # be able to read JSON

# internal modules
use lib 'lib'; # use local lib
use Fortran::Grammar; # grammar module
use Fortran::Grammar::Test; # grammar test module

# test constants
constant $DATAFOLDER        = "t/data";
constant $SRCFOLDER         = "$DATAFOLDER/source";
constant $EXPECTEDFOLDER    = "$DATAFOLDER/expected";

# find all source files
my @sourcefiles = glob("$SRCFOLDER/*.f90");

plan 1 + @sourcefiles.elems;

meta-ok; # check META6.json

# check the grammar parsing based on 
# source files under $SRCFOLDER
# expected json output under $EXPECTEDFOLDER
for @sourcefiles -> $sourcefile { 
    say "sourcefile: ", $sourcefile;
    my Str $basename  = $sourcefile.basename; # get the basename
    my $bnmatch = $basename ~~ 
        m/ ^ $<rule>=<-[_]>+ $<ident>=[ _ <[a..zA..Z0..9-]>+ ] ? . $<extension>=\w+ $/;
    say "bnmatch: ", $bnmatch;
    $basename ~~ s/ . \w+ $/.json/; # change extension
    my IO::Path $expectedfile = IO::Path.new("$EXPECTEDFOLDER/$basename");
    my Str $source    = $sourcefile.slurp.chomp; # read (chomped) source content
    # say "source: ", $source;
    my $expected = from-json $expectedfile.slurp; # read expected json
    # say "expected: ", $expected;
    my $match = Fortran::Grammar::FortranBasic.parse: $source, 
        rule => $bnmatch<rule>, 
        actions => Fortran::Grammar::Test::TestActions.new;
    # say "match: ", $match;
    # say "match.made: ", $match.made;
    my $description = [$bnmatch<rule>,$bnmatch<ident>].join;
    # test
    my $made;
    try {
        CATCH { default { $made = {}; } }
        $made = $match.made;
        }
    is $made, $expected, $description;
    }

done-testing;
