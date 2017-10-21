=begin pod

=head1 NAME

Color::Scheme - Generate color schemes from a base color

=head1 SYNOPSIS

    use Color::Scheme;

    my $color   = Color.new( "#1A3CFA" );

    # this is the sugar
    my @palette = color-scheme( $color, 'six-tone-ccw' );

    # for this
    my @palette = color-scheme( $color, color-scheme-angles<six-tone-ccw'> );

    # debug flag, to visually inspect the colors
    # creates "colors.html" in the current directory
    my @palette = color-scheme( $color, 'triadic', :debug );

=head1 DESCRIPTION

With Color::Scheme you can create schemes/palettes of colors that
work well together.

You pick a base color and one of sixteen schemes and the module will
generate a list of colors that harmonize. How many colors depends on the
scheme.

There are 16 schemes available:

=item split-complementary (3 colors)
=item split-complementary-cw (3 colors)
=item split-complementary-ccw (3 colors)
=item triadic (3 colors)
=item clash (3 colors)
=item tetradic (4 colors)
=item four-tone-cw (4 colors)
=item four-tone-ccw (4 colors)
=item five-tone-a (5 colors)
=item five-tone-b (5 colors)
=item five-tone-cs (5 colors)
=item five-tone-ds (5 colors)
=item five-tone-es (5 colors)
=item analogous (6 colors)
=item neutral (6 colors)
=item six-tone-ccw (6 colors)
=item six-tone-cw (6 colors)

Those schemes are just lists of angles in a hash ( C<Color::Scheme::color-scheme-angles>).

You can use the second form of the color-scheme sub to pass in your own angles if you have to.

=head1 AUTHOR

 holli.holzer@gmail.com

=head1 COPYRIGHT AND LICENSE

Copyright ©  holli.holzer@gmail.com

License GPLv3: The GNU General Public License, Version 3, 29 June 2007
<https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

=end pod

use v6;

use Color;

unit module Color::Scheme;

our constant \color-scheme-angles =%= %(
    :split-complementary([0,150,320]),
    :split-complementary-cw([0,150,300]),
    :split-complementary-ccw([0,60,210]),
    :triadic([0,120,240]),
    :clash([0,90,270]),
    :tetradic([0,90,180,270]),
    :four-tone-cw([0,60,180,240]),
    :four-tone-ccw([0,120,180,300]),
    :five-tone-a([0,115,155,205,245]),
    :five-tone-b([0,40,90,130,245]),
    :five-tone-cs([0,50,90,205,320]),
    :five-tone-ds([0,40,155,270,310]),
    :five-tone-es([0,115,230,270,320]),
    :six-tone-cw([0,30,120,150,240,270]),
    :six-tone-ccw([0,90,120,210,240,330]),
    :neutral([0,15,30,45,60,75]),
    :analogous([0,30,60,90,120,150])
);

multi sub color-scheme( Color:D $color, Str:D $scheme, Bool :$debug = False ) is export
{
    die "Unknown color scheme: $scheme"
        unless $scheme ~~ color-scheme-angles;

    return color-scheme( $color, color-scheme-angles{$scheme}, :$debug );
}

multi sub color-scheme( Color:D $color, @angles, Bool :$debug = False ) is export
{
    my @palette =  @angles.map({ $color.rotate: $_ });

    save-debug-html( @palette )
        if $debug;

    return @palette;
}

sub save-debug-html( @palette, $file = "colors.html" )
{
    quietly
    {
        my $html = qq[
        <html>
        <body>
        <div style="height:80px; background-color:{@palette[0]};">0</div>
        <div style="height:80px; background-color:{@palette[1]};">1</div>
        <div style="height:80px; background-color:{@palette[2]};">2</div>
        <div style="height:80px; background-color:{@palette[3]};">3</div>
        <div style="height:80px; background-color:{@palette[4]};">4</div>
        <div style="height:80px; background-color:{@palette[5]};">5</div>
        <div style="height:80px; background-color:{@palette[6]};">6</div>
        </body>
        </html>
        ];

        $file.IO.spurt( $html );
    }
}
