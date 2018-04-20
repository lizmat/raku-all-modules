use v6.c;
use lib 'lib';
use Test;
use Slang::AltTernary;

plan 4;

sub run_altTern($compare) {
    $compare < 100 ?⁈ 
        Yes "Good" 
        No  "Bad"  ;
}

sub run_altTern_do_block($compare) {
    my @chunks ;
    $compare < 100 ?⁈ 
        Yes do { push @chunks, "Hello" }
        No  do { 
            push @chunks, "Goodbye" ;
            push @chunks, "Cruel"   ;
        }
    push @chunks, "World!" ;
    join " " , @chunks
}

is run_altTern(12) , "Good", '12 is less than 100' ;
is run_altTern(112), "Bad", '112 is more than 100' ;

is run_altTern_do_block(12) , "Hello World!", '12 is less than 100 (do block)' ;
is run_altTern_do_block(112), "Goodbye Cruel World!", '112 is more than 100 (do block)' ;
