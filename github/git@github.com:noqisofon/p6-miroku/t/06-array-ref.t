# -*- mode: perl6; -*-
use v6;

use Test;


plan 1;

my  %already  = (
    authors => ['John Due']
);

{
    my @authors = do if %already<authors>:exists {
        |%already<authors>
    } else {
        []
    };

    is %already<authors>, @authors;
}

done-testing;
