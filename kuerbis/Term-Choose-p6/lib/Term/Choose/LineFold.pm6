use v6;
unit class Term::Choose::LineFold;

use Terminal::WCWidth;


sub to-printwidth( $str, Int $avail_w, Bool $dot=False ) is export( :to-printwidth ) {
    # expects a $str with no invalid characters (s:g/<:C>//)
    # hence no check if wcwidth returns -1
    my $res = 0;
    my @graph;
    my %cache;
    for $str.NFC {
        my \char = .chr;
        my $w;
        if %cache{char}:exists {
            $w := %cache{char};
        }
        else {
            $w := %cache{char} := wcwidth( $_ );
        }
        if $res + $w > $avail_w {
            if $dot && $avail_w > 5 {
                my \tail = '...';
                my \tail_len = 3;
                while $res > $avail_w - tail_len {
                    $res -= %cache{ @graph.pop };
                }
                return @graph.join ~ '.' ~ tail, $res + tail_len + 1 if $res < $avail_w - tail_len;
                return @graph.join       ~ tail, $res + tail_len;
            }
            return @graph.join, $res;
        }
        $res += $w;
        @graph.push: char;
    }
    return @graph.join, $res;
}


sub line-fold( $str, Int $avail_w, Str $init_tab is copy, Str $subseq_tab is copy ) is export( :line-fold ) {
    for $init_tab, $subseq_tab {
        if $_ {
            $_.=subst( / \s /,  ' ', :g );
            $_.=subst( / <:C> /, '', :g );
            if $_.chars > $avail_w / 4 {
                $_ = to-printwidth( $_, $avail_w div 2, False ).[0];
            }
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

    ROW: for $string.lines -> $row {
        my Str @words = $row.trim-trailing.split( / <?after \S > <?before \s > / );
        my Str $line = $init_tab;

        WORD: for 0 .. @words.end -> $i {
            my Str $tab_and_word;
            if $i == 0 {
                $tab_and_word = $init_tab ~ @words[$i];
            }
            else {
                $tab_and_word = $subseq_tab ~ @words[$i].subst( / ^ \s+ /, '' );
            }
            if print-columns( $tab_and_word ) > $avail_w {
                if $i != 0 {
                    @lines.push( $line );
                }
                my Str $tab_and_cut_word = to-printwidth( $tab_and_word, $avail_w, False ).[0];
                my Str $remainder = $tab_and_word.substr( $tab_and_cut_word.chars );
                while ( $remainder.chars ) {
                    @lines.push( $tab_and_cut_word );
                    $tab_and_word = $subseq_tab ~ $remainder;
                    $tab_and_cut_word = to-printwidth( $tab_and_word, $avail_w, False ).[0];
                    $remainder = $tab_and_word.substr( $tab_and_cut_word.chars );
                }
                if $i == @words.end {
                    @lines.push( $tab_and_cut_word );
                }
                else {
                    $line = $tab_and_cut_word;
                }
            }
            else {
                if print-columns( $line ~ @words[$i] ) <= $avail_w {
                    $line ~= @words[$i];
                }
                else {
                    @lines.push( $line );
                    $line = $subseq_tab ~ @words[$i].subst( / ^ \s+ /, '' );
                }
                if $i == @words.end {
                    @lines.push( $line );
                }
            }
        }
    }
    @lines.push( '' ) if $str.ends-with( "\n" );
    return @lines; #
}


sub print-columns( $str ) returns Int is export( :print-columns ) {
    # expects a $str with no invalid characters (s:g/<:C>//)
    # hence no check if wcwidth returns -1
    my %cache;
    my Int $res = 0;
    for $str.NFC {
        my \char = .chr;
        if %cache{char}:exists {
            $res += %cache{char};
        }
        else {
            $res += %cache{char} := wcwidth( $_ );
        }
    }
    $res;
}


