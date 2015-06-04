use v6;

use Test;

use Form;

use LacunaCookbuk::Logic::IntelCritic;
    
plan 2;


my Str $f1 = form(
    $LacunaCookbuk::IntelCritic::limited_format,
    $LacunaCookbuk::IntelCritic::summary_header);


ok($f1.chars == $LacunaCookbuk::IntelCritic::TERM_SIZE, 'Spy summary length');


my Str $f2 = form(
    $LacunaCookbuk::IntelCritic::spy_format,
    $LacunaCookbuk::IntelCritic::spy_header);

ok($f2.chars == $LacunaCookbuk::IntelCritic::TERM_SIZE, "Spy listing length");
