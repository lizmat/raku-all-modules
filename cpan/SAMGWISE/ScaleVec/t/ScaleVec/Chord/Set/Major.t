#! /usr/bin/env perl6
use v6;
use Test;
plan 8;

use-ok 'ScaleVec::Chord::Set::Major';
use ScaleVec::Chord::Set::Major;

my ScaleVec::Chord::Set::Major $major .= new();

is $major.defined, True, "Major chord set instantiated.";
is $major.chords.keys.elems, 7, "Major has 7 triads.";
is $major.chords.values.map( *.defined ).all, True, "All triads are defined values.";

# test adding chords after init
$major.chords<V7> = $major.chords<V>.append(10);
is $major.chords.keys.elems, 8, "Major has 8 triads.";
is $major.chords.values.map( *.defined ).all, True, "All triads are defined values.";

# test adding chords during init
$major .= new: :chords({ V7 => $major.chords<V>.append(10), });
is $major.chords.keys.elems, 8, "Major has 8 triads.";
is $major.chords.values.map( *.defined ).all, True, "All triads are defined values.";
