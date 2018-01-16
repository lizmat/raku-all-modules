use v6;
unit class Term::Choose::LineFold;

use Terminal::WCWidth;


sub to-printwidth( $str, Int $avail_w, Bool $dot=False, @cache? ) is export( :to-printwidth ) {
    # no check if wcwidth returns -1 because no invalid characters (s:g/<:C>//)
    my Int $width = 0;
    my @graph;
    for $str.NFC {
        my $w;
        if @cache.EXISTS-POS( $_ ) {
            $w := @cache.AT-POS( $_ );
        }
        else {
            $w := @cache.BIND-POS( $_, wcwidth( $_ ) );
        }
        if $width + $w > $avail_w {
            if $dot && $avail_w > 5 {
                my \tail = '...';
                my \tail_w = 3;
                while $width > $avail_w - tail_w {
                    $width -= @cache[ @graph.pop.ord ];
                }
                return @graph.join( '' ) ~ '.' ~ tail, $width + tail_w + 1 if $width < $avail_w - tail_w;
                return @graph.join( '' )       ~ tail, $width + tail_w;
            }
            return @graph.join( '' ), $width;
        }
        $width = $width + $w;
        @graph.push: .chr;
    }
    return @graph.join( '' ), $width;
}


sub line-fold( $str, Int $avail_w, Str $init_tab is copy, Str $subseq_tab is copy ) is export( :line-fold ) {
    for $init_tab, $subseq_tab {
        if $_ {
            $_ = to-printwidth( $_.=subst( / \s /,  ' ', :g ).=subst( / <:C> /, '', :g ),  $avail_w div 2, False ).[0];
        }
        else {
            $_ = '';
        }
    }
    my $string = $str.subst( / <:White_Space-:Line_Feed> /, ' ', :g );
    $string.=subst( / <:Other-:Line_Feed> /, '' , :g );
    if $string !~~ / \n / && print-columns( $init_tab ~ $string ) <= $avail_w {
        return $init_tab ~ $string;
    }
    my Str @lines;

    for $string.lines -> $row {
        my Str @words = $row.trim-trailing.split( / <?after \S > <?before \s > / );
        my Str $line = $init_tab;

        for 0 .. @words.end -> $i {
            if print-columns( $line ~ @words[$i] ) <= $avail_w {
                $line ~= @words[$i];
            }
            else {
                my Str $tmp;
                if $i == 0 {
                    $tmp = $init_tab ~ @words[$i];
                }
                else {
                    @lines.push: $line;
                    $tmp = $subseq_tab ~ @words[$i].subst( / ^ \s+ /, '' );
                }
                $line = to-printwidth( $tmp, $avail_w, False ).[0];
                my Str $remainder = $tmp.substr( $line.chars );
                while $remainder.chars {
                    @lines.push( $line );
                    $tmp = $subseq_tab ~ $remainder;
                    $line = to-printwidth( $tmp, $avail_w, False ).[0];
                    $remainder = $tmp.substr( $line.chars );
                }
            }
            if $i == @words.end {
                @lines.push( $line );
            }
        }
    }
    @lines.push( '' ) if $str.ends-with( "\n" );
    return @lines; #
}


sub print-columns( $str, @cache? ) returns Int is export( :print-columns ) {
    # no check if wcwidth returns -1 because no invalid characters (s:g/<:C>//)
    my Int $width = 0;
    for $str.NFC {
        if @cache.EXISTS-POS( $_ ) {
            $width = $width + @cache.AT-POS( $_ );
        }
        else {
            $width = $width + @cache.BIND-POS( $_, wcwidth( $_ ) );
        }
    }
    $width;
}


