use v6;
use Test;

plan 19;

lives-ok
{
    use Color::Scheme;
    use Color;

    my $color   = Color.new( "#1A3CFA" );

    for keys Color::Scheme::color-scheme-angles -> $scheme {
        my @x = color-scheme( $color, $scheme );
        ok @x.defined && @x.elems > 2;
    }

    my @palette = color-scheme( $color, 'five-tone-b' );
    ok @palette.elems == 5;
}



done-testing;
