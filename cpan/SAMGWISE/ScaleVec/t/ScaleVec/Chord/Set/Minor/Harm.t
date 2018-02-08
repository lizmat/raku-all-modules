#! /usr/bin/env perl6
use v6;
use Test;
plan 8;

use-ok 'ScaleVec::Chord::Set::Minor::Harm';
use ScaleVec::Chord::Set::Minor::Harm;

my ScaleVec::Chord::Set::Minor::Harm $minor .= new();

is $minor.defined, True, "Minor chord set instantiated.";
is $minor.chords.keys.elems, 7, "Minor has 7 triads.";
is $minor.chords.values.map( *.defined ).all, True, "All triads are defined values.";

# test adding chords after init
$minor.chords<V7> = $minor.chords<V>.append(10);
is $minor.chords.keys.elems, 8, "Minor has 8 triads.";
is $minor.chords.values.map( *.defined ).all, True, "All triads are defined values.";

# test adding chords during init
$minor .= new: :chords({ V7 => $minor.chords<V>.append(10), });
is $minor.chords.keys.elems, 8, "Minor has 8 triads.";
is $minor.chords.values.map( *.defined ).all, True, "All triads are defined values.";
