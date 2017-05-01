use v6;
unit class Term::Choose::LineFold;

my $VERSION = '0.122';

use Terminal::WCWidth;



sub to-printwidth( $str, Int $avail_w, Bool $dot=False ) is export( :to-printwidth ) {
    my Int $res = 0;
    my Str @graph;
    my Int @width;
    my Str $tail = '...';
    my Int $tmp_w = $avail_w - 3;
    if ! $dot || $avail_w < 6 {
        $tail = '';
        $tmp_w = $avail_w;
    }
    for $str.NFC {
        my $w = wcwidth($_);
        #return -1 if $w < 0; # already removed with s:g/<:C>//
        if $res + $w > $avail_w {
            while $res > $tmp_w {
                @graph.pop;
                @width.pop;
                $res = [+] @width;
            }
            if $res < $tmp_w {
                return @graph.join ~ ' ' ~ $tail, $res + 1;
            }
            else {
                return @graph.join       ~ $tail, $res;
            }
        }
        $res += $w;
        @width.push: $w;
        @graph.push: .chr;
    }
    return @graph.join, $res;
}


sub line-fold ( $str, Int $avail_w, Str $init_tab is copy, Str $subseq_tab is copy ) returns Str is export( :line-fold ) {
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
    if $string !~~ / \n / && wcswidth( $init_tab ~ $string ) <= $avail_w {
        return $init_tab ~ $string;
    }
    my Str @paragraph;

    ROW: for $string.lines -> $row {
        my Str @lines;
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
            if wcswidth( $tab_and_word ) > $avail_w {
                if $i != 0 {
                    @lines.push( $line );
                }
                my Str $tab_and_cut_word = to-printwidth( $tab_and_word, $avail_w, False ).[0];
                my Str $remainder = substr( $tab_and_cut_word.chars );
                while ( $remainder.chars ) {
                    @lines.push( $tab_and_cut_word );
                    $tab_and_cut_word = to-printwidth( $subseq_tab ~ $remainder, $avail_w, False ).[0];
                    $remainder = substr( $tab_and_cut_word.chars );
                }
                if $i == @words.end {
                    @lines.push( $tab_and_cut_word );
                }
                else {
                    $line = $tab_and_cut_word;
                }
            }
            else {
                if wcswidth( $line ~ @words[$i] ) <= $avail_w {
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
        @paragraph.push( @lines.join( "\n" ) );
    }
    return @paragraph.join( "\n" ) ~ ( $str.ends-with( "\n" ) ?? "\n" !! '' );
}


sub print-columns ( $str ) returns Int is export( :print-columns ) {
    wcswidth( $str );
}


