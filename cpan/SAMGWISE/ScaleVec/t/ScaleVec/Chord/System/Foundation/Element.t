#! /usr/bin/env perl6
use v6;
use Test;

plan 5;

use-ok('ScaleVec::Chord::System::Foundation::Element');
use ScaleVec::Chord::System::Foundation::Element;
use ScaleVec;
use ScaleVec::Chord::Set::Major;
use ScaleVec::Chord::System;

my ScaleVec %pitch-spaces = (
  C => ScaleVec.new(:vector(0, 2, 4, 5, 7, 9, 11, 12)),
);

my $element = ScaleVec::Chord::System::Foundation::Element.new(
  :%pitch-spaces
  :chord-set(ScaleVec::Chord::Set::Major.new)
);

is $element.defined, True, "Element is defined.";

is $element.to-map<pitch-spaces chord-set>:exists,
  (True, True),
  ".to-map produces required keys.";

is $element.from-map($element.to-map).to-map,
  $element.to-map,
  "Element round-trip mapping.";

is $element.build-system.ok('Failed constructing ScaleVec::Chord::System.').so,
  True,
  "Element builds chord system.";
