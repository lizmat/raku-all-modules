#!perl6

use v6;
use Test;
use lib 'lib';
use WWW::You'reDoingItWrong;
like (you're doing it wrong),
    /^'You\'re doing it wrong: http://www.doingitwrong.com/wrong/'
        <-[/]>+ \. [jpg|png|gif]$/, 'seems like we got sane result'; # '

done-testing;
