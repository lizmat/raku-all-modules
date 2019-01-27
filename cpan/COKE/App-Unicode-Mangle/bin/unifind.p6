#!/usr/bin/env perl6

# always pass in search criteria, optionally specify 
# -w to indicate it should be on word boundaries as well.

sub MAIN($search, :w($word)) {
    my $regex = $word ?? "<< '$search' >>" !! $search;

    (0..0x10FFFF)
        .map(*.chr)
        .grep({$_.uninames ~~ m:i/<$regex>/})
        .map({say "$_ : U+{$_.ord} {$_.uninames}"})
}
