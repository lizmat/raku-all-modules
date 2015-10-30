use v6;

class CSS::Writer::BaseTypes {

    use CSS::Grammar::CSS3;

    # -- numbers -- #
    proto method write-num( Numeric $, $? --> Str) {*};

    multi method write-num( 1, 'em' ) { 'em' }
    multi method write-num( 1, 'ex' ) { 'ex' }
    multi method write-num( Numeric $num, Str $units ) {
	$.write-num($num) ~ $units.lc;
    }
    multi method write-num( Numeric $num, Mu $units? ) {
        my $int = $num.Int;
        $int == $num ?? $int !! $num;
    }

    multi method write-num( *@args) is default {
        die "unable to .write-num({@args.perl})";
    }

    # -- strings -- #
    method write-string( Str $str --> Str) {
        [~] flat ("'",
             $str.comb.map({
                 when /<CSS::Grammar::CSS3::stringchar-regular>|\"/ {$_}
                 when /<CSS::Grammar::CSS3::regascii>/ {'\\' ~ $_}
                 default { .ord.fmt("\\%X ") }
             }),
             "'");
    }

    # -- colors -- #
    multi method coerce-color(Int :$int!)         {$int}
    multi method coerce-color(Numeric :$num!)     {+sprintf "%d", $num}
    multi method coerce-color(Numeric :$percent!) {+sprintf "%d", $percent * 2.55}
    multi method coerce-color is default          {Any}

    method color-channel($node) {
        my $num = $.coerce-color(|%$node)
            // return;
        $num = 0   if $num < 0 ;
        $num = 255 if $num > 255;
        $num;
    }

    method write-rgb-mask( @mask ) {
        # can we reduce to the three hex digit form?
        # #aa77ff => #a7f
        my $reducable = [&&] @mask.map: { $_ %% 17 };
        my @hex-digits = $reducable
            ?? @mask.map: {sprintf "%X", $_ / 17}
            !! @mask.map: {sprintf "%02X", $_ };

        [~] flat '#', @hex-digits;
    }

    proto write-color(List $ast, Str $units --> Str) {*}

    multi method write-color(List $ast, 'rgb') {

        my @mask = $ast.map: { $.color-channel($_) };

        return if +@mask != 3 || @mask.first: {!.defined}

        if %.color-names {
            # map to a color name, if possible
            my $idx = 256 * (256 * @mask[0]  +  @mask[1])  + @mask[2];
            return %.color-names{ $idx}
                if %.color-names{ $idx }:exists;
        }

        my $out = $.write-rgb-mask(@mask)
            if $.color-masks;

        $out // sprintf 'rgb(%s, %s, %s)', $ast.map: { $.write( $_ )};
    }

    multi method write-color( List $ast, 'rgba' ) {

        # drop the alpha channel when a == 1.0
        return $.write-color( [ $ast[0..2] ], 'rgb' )
            if $ast[3]<num> && $ast[3]<num> == 1.0
            || $ast[3]<percent> && $ast[3]<percent> == 100.0;

        sprintf 'rgba(%s, %s, %s, %s)', $ast.map: {$.write( $_ )};
    }

    multi method write-color(List $ast, 'hsl') {
        sprintf 'hsl(%s, %s, %s)', $ast.map: {$.write( $_ )};
    }

    multi method write-color(List $ast, 'hsla') {
        sprintf 'hsla(%s, %s, %s, %s)', $ast.map: {$.write( $_ )};
    }

    multi method write-color(Str $ast, Any $) {
        # e.g. 'transparent', 'currentcolor'
        $ast.lc;
    }

    multi method write-color( Any $color, Any $units ) is default {
        die "unable to handle color: {$color.perl}, units: {$units.perl}"
    }

}
