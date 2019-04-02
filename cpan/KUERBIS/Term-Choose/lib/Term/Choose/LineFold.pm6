use v6;
unit module Term::Choose::LineFold;

use Term::Choose::LineFold::CharWidthDefault;


my $table = table_char_width();

my $cache = [];

sub char_width( Int $ord_char ) {
    my $min = 0;
    my $mid;
    my $max = $table.end;
    if $ord_char < $table[0][0] || $ord_char > $table[$max][1] {
        return 1;
    }
    while $max >= $min {
        $mid = ( $min + $max ) div 2;
        if $ord_char > $table[$mid][1] {
            $min = $mid + 1;
        }
        elsif $ord_char < $table[$mid][0] {
            $max = $mid - 1;
        }
        else {
            return $table[$mid][2];
        }
    }
    return 1;
}


sub to-printwidth( $str, Int $avail_w, Bool $dot=False, @cache? ) is export( :to-printwidth ) {
    # no check if char_width returns -1 because no invalid characters (s:g/<:C>//)
    my Int $width = 0;
    my @graph;
    for $str.NFC {
        my $w;
        if @cache.EXISTS-POS( $_ ) {
            $w := @cache.AT-POS( $_ );
        }
        else {
            $w := @cache.BIND-POS( $_, char_width( $_ ) );
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


sub line-fold( $str, Int $avail_w, Str $init-tab is copy = '', Str $subseq-tab is copy = '' ) is export( :line-fold ) {
    for $init-tab, $subseq-tab {
        if $_ { # .gist
            $_ = to-printwidth(
                    $_.=subst( / \t /,  ' ', :g ).=subst( / \v+ /,  '  ', :g ).=subst( / <:Cc+:Noncharacter_Code_Point+:Cs> /, '', :g ),
                    $avail_w div 2,
                    False
                ).[0];
        }
    }
    my $string = ( $str // '' );
    if $string ~~ Buf {
        $string = $string.gist; # perl
    }
    $string.subst( / \t /, ' ', :g );
    $string.=subst( / <:Cc+:Noncharacter_Code_Point+:Cs> && \V /, '' , :g ); #
    if $string !~~ / \R / && print-columns( $init-tab ~ $string ) <= $avail_w {
        return $init-tab ~ $string;
    }
    my Str @lines;

    for $string.lines -> $row {
        my Str @words;
        if $row ~~ / \S / {
            @words = $row.trim-trailing.split( / <?after \S > <?before \s > / );
        }
        else {
            @words = $row;
        }
        my Str $line = $init-tab;

        for 0 .. @words.end -> $i {
            if print-columns( $line ~ @words[$i] ) <= $avail_w {
                $line ~= @words[$i];
            }
            else {
                my Str $tmp;
                if $i == 0 {
                    $tmp = $init-tab ~ @words[$i];
                }
                else {
                    @lines.push: $line;
                    $tmp = $subseq-tab ~ @words[$i].subst( / ^ \s+ /, '' );
                }
                $line = to-printwidth( $tmp, $avail_w, False ).[0];
                my Str $remainder = $tmp.substr( $line.chars );
                while $remainder.chars {
                    @lines.push( $line );
                    $tmp = $subseq-tab ~ $remainder;
                    $line = to-printwidth( $tmp, $avail_w, False ).[0];
                    $remainder = $tmp.substr( $line.chars );
                }
            }
            if $i == @words.end {
                @lines.push( $line );
            }
        }
    }
    @lines.push( '' ) if $string.ends-with( "\n" );
    return @lines; #
}


sub print-columns( $str, @cache? ) returns Int is export( :print-columns ) {
    # no check if char_width returns -1 because invalid characters removed
    my Int $width = 0;
    for $str.NFC {
        if @cache.EXISTS-POS( $_ ) {
            $width = $width + @cache.AT-POS( $_ );
        }
        else {
            $width = $width + @cache.BIND-POS( $_, char_width( $_ ) );
        }
    }
    $width;
}


