#!/usr/bin/env perl6

use v6.c;
use BSON::Document;

my BSON::Document $req .= new: (
  insert => 'cll',
  documents => [
    (:name('n1'), :test(0)),  (:name('n2'), :test(0)),
    (:name('n3'), :test(0)),  (:name('n4'), :test(0)),
    (:name('n5'), :test(0)),  (:name('n6'), :test(0))
  ]
);

say "D: ", $req.perl;
