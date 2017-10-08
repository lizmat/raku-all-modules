#!/usr/bin/env perl6

use v6.c;

for '9.0/PropList.txt'.IO.lines -> $line is copy {

  $line ~~ m/ \s* '#' \s* (.*) $/;
  my Str $comment = $/ ?? $/.Str !! '';

  $line ~~ s/ \s* '#' .* $//;
  next if $line ~~ m/^ \h* $/;
  
  ( my Str $cpr, my Str $property) = $line.split( /\s* ';' \s*/);
  if $cpr ~~ m/ '..' / {
    ( my Str $f, my Str $l) = $cpr.split('..');
    my Range $r = :16($f) .. :16($l);
    for @$r -> $codepoint {
      say "$codepoint.fmt('0x%04x') $property: ",
          $codepoint.uniprop($property),
          ', ', $codepoint.uniprop('General_Category')
      unless $codepoint.uniprop($property);
    }
  }
  
  else {
    my $codepoint = :16($cpr);
    say "$codepoint.fmt('0x%04x') $property: ",
        $codepoint.uniprop($property),
        ', ', $codepoint.uniprop('General_Category')
      unless $codepoint.uniprop($property);
  }
}
