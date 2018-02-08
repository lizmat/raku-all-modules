#! /usr/bin/env perl6
use v6;
use Test;
plan 8;

use-ok 'ScaleVec::Chord::Set::Minor::Nat';
use ScaleVec::Chord::Set::Minor::Nat;

my ScaleVec::Chord::Set::Minor::Nat $minor .= new();

is $minor.defined, True, "Minor chord set instantiated.";
is $minor.chords.keys.elems, 7, "Minor has 7 triads.";
is $minor.chords.values.map( *.defined ).all, True, "All triads are defined values.";

# test adding chords after init
$minor.chords<v7> = $minor.chords<v>.append(10);
is $minor.chords.keys.elems, 8, "Minor has 8 triads.";
is $minor.chords.values.map( *.defined ).all, True, "All triads are defined values.";

# test adding chords during init
$minor .= new: :chords({ v7 => $minor.chords<v>.append(10), });
is $minor.chords.keys.elems, 8, "Minor has 8 triads.";
is $minor.chords.values.map( *.defined ).all, True, "All triads are defined values.";
