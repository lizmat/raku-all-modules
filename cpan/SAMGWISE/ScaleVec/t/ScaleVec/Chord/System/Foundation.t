#! /usr/bin/env perl6
use v6;
use Test;

plan 7;

use-ok('ScaleVec::Chord::System::Foundation');
use ScaleVec::Chord::System::Foundation;
use ScaleVec::Chord::System::Foundation::Element;
use ScaleVec;
use ScaleVec::Chord::Set::Major;
use ScaleVec::Chord::Set::Minor::Nat;
use ScaleVec::Chord::System;

my ScaleVec %pitch-spaces1 = (
  C => ScaleVec.new(:vector(0, 2, 4, 5, 7, 9, 11, 12)),
);

my $element1 = ScaleVec::Chord::System::Foundation::Element.new(
  :%pitch-spaces1
  :chord-set(ScaleVec::Chord::Set::Major.new)
);

is $element1.defined, True, "Element1 is defined.";

my ScaleVec %pitch-spaces2 = (
  a => ScaleVec.new(:vector(0, 2, 3, 5, 7, 8, 10, 12)),
);

my $element2 = ScaleVec::Chord::System::Foundation::Element.new(
  :%pitch-spaces2
  :chord-set(ScaleVec::Chord::Set::Minor::Nat.new)
);

is $element2.defined, True, "Element2 is defined.";

my ScaleVec::Chord::System::Foundation $foundation .= new(
  :chord-system($element1, $element2)
);

is $foundation.defined, True, "Foundation is defined.";

is $foundation.to-map<chord-system>:exists,
  True,
  ".to-map produces required key.";

is $foundation.from-map($foundation.to-map).to-map,
  $foundation.to-map,
  "Foundation round-trip mapping.";

is $foundation.build-system.ok('Failed constructing ScaleVec::Chord::System.').so,
  True,
  "Foundation builds chord system.";
