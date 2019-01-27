# Overview

Silly script to let you take unicode input and transform it, e.g.

    $ perl6 bin/mangle.p6 'Perl 6' #defaults to circle
    Ⓟⓔⓡⓛ ⑥

    $ perl6 bin/mangle.p6 --hack=invert 'Hello, github!'
    ¡quɥʇıƃ ,oʃʃǝH

    $ perl6 bin/mangle.p6 --hack=bold 'A bird, a plane.'
    𝐀 𝐛𝐢𝐫𝐝, 𝐚 𝐩𝐥𝐚𝐧𝐞.
   
    $ perl6 bin/mangle.p6 --hack=paren 'lisplike'
    ⒧⒤⒮⒫⒧⒤⒦⒠

    $ perl6 bin/mangle.p6 --hack=combo 'combo breaker'
    c̩͘o̍ͧmͮ͠b̄͋o̸̫ ̣͚b͠ͅř̗ẻ͔aͪ͢k̥̀e̒͋r͎̦

    $ perl6 bin/mangle.p6 --hack=outline 'Butterflies'
    𝔹𝕦𝕥𝕥𝕖𝕣𝕗𝕝𝕚𝕖𝕤

    $perl6 bin/mangle.p6 --hack=random 'Happy Birthday!'
    Ⓗ⒜ⓟ𝐩𝐲 𐐒⒤𝐫⒯⒣pɐ⒴¡

## Combining Characters

Where possible, preserve input combining marks:

    $ perl6 bin/mangle.p6 --hack=outline 'përl'
    𝕡𝕖̈𝕣𝕝
