use v6;
unit class Term::Choose;

my $VERSION = '0.105';

use Term::Choose::NCurses :all;
use Term::Choose::LineFold :all;


constant R  = 0;
constant C  = 1;
constant OK = 0;

constant CONTROL_SPACE = 0x00;
constant CONTROL_A     = 0x01;
constant CONTROL_B     = 0x02;
constant CONTROL_D     = 0x04;
constant CONTROL_E     = 0x05;
constant CONTROL_F     = 0x06;
constant CONTROL_H     = 0x08;
constant KEY_TAB       = 0x09;
constant KEY_RETURN    = 0x0a;
constant KEY_SPACE     = 0x20;
constant KEY_h         = 0x68;
constant KEY_j         = 0x6a;
constant KEY_k         = 0x6b;
constant KEY_l         = 0x6c;
constant KEY_q         = 0x71;

#my int32 constant LC_ALL = 6; # From locale.h
#setlocale( LC_ALL, "" );

has @!orig_list;
has @!list;

has %.o_global;
has %!o;

has Term::Choose::NCurses::WINDOW $.g_win;
has Term::Choose::NCurses::WINDOW $!win;

has Int   $!multiselect;
has Int   $!term_w;
has Int   $!term_h;
has Int   $!avail_w;
has Int   $!avail_h;
has Int   $!col_w;
has Int   @!length;
has Int   $!layout;
has Int   $!rest;
has Int   $!pp_row;
has Str   $!pp_line_fmt;
has Int   $!nr_prompt_lines;
has Str   $!prompt_copy;
has Int   $!p_begin;
has Int   $!p_end;
has Array $!rc2idx;
has Array $!pos;
has Int   $!row_on_top;
has Int   $!cursor_row;
has Array $!marked;


method new ( %o_global?, $g_win=Term::Choose::NCurses::WINDOW ) { ##
    _validate_options( %o_global );
    _set_defaults( %o_global );
    self.bless( :%o_global, :$g_win ); ## opt
}


sub _set_defaults ( %opt ) {
    %opt<beep>          //= 0;
    %opt<default>       //= 0;
    %opt<empty>         //= '<empty>';
    %opt<index>         //= 0;
    %opt<justify>       //= 0;
    %opt<keep>          //= 5;
    %opt<layout>        //= 1;
    %opt<lf>            //= Array;
    %opt<ll>            //= Int;
    %opt<mark>          //= Array;
    %opt<max_height>    //= Int;
    %opt<max_width>     //= Int;
    %opt<mouse>         //= 0;
    %opt<no_spacebar>   //= Array;
    %opt<order>         //= 1;
    %opt<pad>           //= 2;
    %opt<pad_one_row>   //= %opt<pad>;
    %opt<page>          //= 1;
    %opt<undef>         //= '<undef>';
}


sub _valid_options {
    return {
        beep            => '<[ 0 1 ]>',
        index           => '<[ 0 1 ]>',
        mouse           => '<[ 0 1 ]>',
        order           => '<[ 0 1 ]>',
        page            => '<[ 0 1 ]>',
        justify         => '<[ 0 1 2 ]>',
        layout          => '<[ 0 1 2 ]>',
        keep            => '<[ 1 .. 9 ]><[ 0 .. 9 ]>*',
        ll              => '<[ 1 .. 9 ]><[ 0 .. 9 ]>*',
        max_height      => '<[ 1 .. 9 ]><[ 0 .. 9 ]>*',
        max_width       => '<[ 2 .. 9 ]><[ 0 .. 9 ]>*',
        default         => '<[ 0 .. 9 ]>+',
        pad             => '<[ 0 .. 9 ]>+',
        pad_one_row     => '<[ 0 .. 9 ]>+',
        lf              => 'Array',
        mark            => 'Array',
        no_spacebar     => 'Array',
        empty           => 'Str',
        prompt          => 'Str',
        undef           => 'Str',
    };
};

sub _validate_options ( %opt, Int $list_end? ) {
    my $valid = _valid_options();
    for %opt.kv -> $key, $value {
        when $valid{$key}:!exists { #
            die "'$key' is not a valid option name";
        }
        when ! $value.defined {
            next;
        }
        when $valid{$key} eq 'Array' {
            die "$key => not an ARRAY reference."     if ! $value.isa( Array );
            die "$key => invalid array element"       if $value.grep( { / <-[0..9]> / } ); # Int;
            if $key eq 'lf' {
                die "$key => too many array elemnts." if $value.elems > 2;
            }
            else {
                die "$key => value out of range."     if $list_end.defined && $value.any > $list_end;
            }
        }
        when $valid{$key} eq 'Str' {
            die "$key => not a string." if ! $value.isa( Str );
        }
        when $value !~~ / ^ <{$valid{$key}}> $ / {
            die "$key => '$value' is not a valid value.";
        }
    }
}

submethod DESTROY () { #
    self!_end_term();
}

method !_prepare_new_copy_of_list {
    @!list = @!orig_list;
    my Str $dots   = $!avail_w > 5 ?? '...' !! '';
    my Int $dots_w = $dots.chars;
    if %!o<ll> {
        if %!o<ll> > $!avail_w {
            for @!list {
                $_ = cut_to_printwidth( $_, $!avail_w - $dots_w ) ~ $dots;
            }
            $!col_w = $!avail_w;
        }
        else {
            $!col_w = %!o<ll>;
        }
        @!length = $!col_w xx @!list.elems;
    }
    else {
        my Int $longest = 0;
        for 0 .. @!list.end -> $i {
            @!list[$i] //= %!o<undef>;
            if @!list[$i] eq '' {
                @!list[$i] = %!o<empty>;
            }
            @!list[$i].=subst(   / \s /, ' ', :g );  # replace, but don't squash sequences of spaces
            @!list[$i].=subst( / <:C> /, '',  :g );
            @!list[$i] = @!list[$i].gist; 
            my Int $length = print_columns( @!list[$i] );
            if $length > $!avail_w {
                @!list[$i] = cut_to_printwidth( @!list[$i], $!avail_w - $dots_w ) ~ $dots;
                @!length[$i] = $!avail_w;
            }
            else {
                @!length[$i] = $length;
            }
            $longest = @!length[$i] if @!length[$i] > $longest;
        }
        $!col_w = $longest;
    }
}



sub choose       ( @list, %opt? ) is export { return Term::Choose.new().choose(       @list, %opt ) }
sub choose_multi ( @list, %opt? ) is export { return Term::Choose.new().choose_multi( @list, %opt ) }
sub pause        ( @list, %opt? ) is export { return Term::Choose.new().pause(        @list, %opt ) }

method choose       ( @list, %opt? ) { return self!_choose( @list, %opt, 0   ) }
method choose_multi ( @list, %opt? ) { return self!_choose( @list, %opt, 1   ) }
method pause        ( @list, %opt? ) { return self!_choose( @list, %opt, Int ) }



method !_init_term {
    my int32 constant LC_ALL = 6; # From locale.h
    setlocale( LC_ALL, "" );
    if $!g_win {
        $!win = $!g_win;
    }
    else {
        #my int32 constant LC_ALL = 6;
        #setlocale( LC_ALL, "" );
        $!win = initscr;
    }
    noecho();
    cbreak;
    keypad( $!win, True );
    my Array[int32] $old;
    my $s = mousemask( ALL_MOUSE_EVENTS +| REPORT_MOUSE_POSITION, $old );
    curs_set( 0 );
}

method !_end_term {
    return if $!g_win;
    endwin();
}


method !_choose ( @!orig_list, %!o, Int $!multiselect ) {
    if ! @!orig_list.elems {
        return;
    }
    _validate_options( %!o, @!orig_list.end );
    for %!o_global.kv -> $key, $value {
        %!o{$key} //= $value;
    }
    if ! %!o<prompt>.defined {
        %!o<prompt> = $!multiselect.defined ?? 'Your choice' !! 'Continue with ENTER';
    }
    self!_init_term;
    self!_wr_first_screen;
    my Int $pressed; #

    GET_KEY: loop {
        my $key = getch();
        my Int $new_term_w = getmaxx( $!win );
        my Int $new_term_h = getmaxy( $!win );
        if $new_term_w != $!term_w || $new_term_h != $!term_h {
            if %!o<ll> {
                return -1;
            }
            %!o<default> = $!rc2idx[$!pos[R]][$!pos[C]];
            if $!marked.elems {
                %!o<mark> = self!_marked_to_idx;
            }
            clear();
            self!_wr_first_screen;
            next GET_KEY;
        }

        # $!rc2idx holds the new list (AoA) formated in "_index_to_rowcol" appropirate to the chosen layout.
        # $!rc2idx does not hold the values dircetly but the respective list indexes from the original list.
        # If the original list would be ( 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' ) and the new formated list should be
        #     a d g
        #     b e h
        #     c f
        # then the $!rc2idx would look like this
        #     0 3 6
        #     1 4 7
        #     2 5
        # So e.g. the second value in the second row of the new list would be @!list[ $!rc2idx[1][1] ].
        # On the other hand the index of the last row of the new list would be $!rc2idx.end
        # or the index of the last column in the first row would be $!rc2idx[0].end.

        given $key {
            #when KEY_RESIZE {
            #}
            when KEY_DOWN | KEY_j {
                if ! $!rc2idx[$!pos[R]+1] || ! $!rc2idx[$!pos[R]+1][$!pos[C]] {
                    self!_beep;
                }
                else {
                    $!pos[R]++;
                    if $!pos[R] <= $!p_end {
                        self!_wr_cell( $!pos[R] - 1, $!pos[C] );
                        self!_wr_cell( $!pos[R],     $!pos[C] );
                    }
                    else {
                        $!row_on_top = $!pos[R];
                        $!p_begin = $!p_end + 1;
                        $!p_end   = $!p_end + $!avail_h;
                        $!p_end   = $!rc2idx.end if $!p_end > $!rc2idx.end;
                        self!_wr_screen;
                    }
                }
            }
            when KEY_UP | KEY_k {
                if $!pos[R] == 0 {
                    self!_beep;
                }
                else {
                    $!pos[R]--;
                    if $!pos[R] >= $!p_begin {
                        self!_wr_cell( $!pos[R] + 1, $!pos[C] );
                        self!_wr_cell( $!pos[R]    , $!pos[C] );
                    }
                    else {
                        $!row_on_top = $!pos[R] - ( $!avail_h - 1 );
                        $!p_end   = $!p_begin - 1;
                        $!p_begin = $!p_begin - $!avail_h;
                        $!p_begin = 0 if $!p_begin < 0;
                        self!_wr_screen;
                    }
                }
            }
            when KEY_TAB {
                if $!pos[R] == $!rc2idx.end && $!pos[C] == $!rc2idx[$!pos[R]].end {
                    self!_beep;
                }
                else {
                    if $!pos[C] < $!rc2idx[$!pos[R]].end {
                        $!pos[C]++;
                        self!_wr_cell( $!pos[R], $!pos[C] - 1 );
                        self!_wr_cell( $!pos[R], $!pos[C] );
                    }
                    else {
                        $!pos[R]++;
                        if $!pos[R] <= $!p_end {
                            $!pos[C] = 0;
                            self!_wr_cell( $!pos[R] - 1, $!rc2idx[$!pos[R]-1].end );
                            self!_wr_cell( $!pos[R]    , $!pos[C] );
                        }
                        else {
                            $!row_on_top = $!pos[R];
                            $!p_begin = $!p_end + 1;
                            $!p_end   = $!p_end + $!avail_h;
                            $!p_end   = $!rc2idx.end if $!p_end > $!rc2idx.end;
                            $!pos[C] = 0;
                            self!_wr_screen;
                        }
                    }
                }
            }
            when KEY_BACKSPACE | CONTROL_H | KEY_BTAB {
                if $!pos[C] == 0 && $!pos[R] == 0 {
                    self!_beep;
                }
                else {
                    if $!pos[C] > 0 {
                        $!pos[C]--;
                        self!_wr_cell( $!pos[R], $!pos[C] + 1 );
                        self!_wr_cell( $!pos[R], $!pos[C] );
                    }
                    else {
                        $!pos[R]--;
                        if $!pos[R] >= $!p_begin {
                            $!pos[C] = $!rc2idx[$!pos[R]].end;
                            self!_wr_cell( $!pos[R] + 1, 0 );
                            self!_wr_cell( $!pos[R]    , $!pos[C] );
                        }
                        else {
                            $!row_on_top = $!pos[R] - ( $!avail_h - 1 );
                            $!p_end   = $!p_begin - 1;
                            $!p_begin = $!p_begin - $!avail_h;
                            $!p_begin = 0 if $!p_begin < 0;
                            $!pos[C] = $!rc2idx[$!pos[R]].end;
                            self!_wr_screen;
                        }
                    }
                }
            }
            when KEY_RIGHT | KEY_l {
                if $!pos[C] == $!rc2idx[$!pos[R]].end {
                    self!_beep;
                }
                else {
                    $!pos[C]++;
                    self!_wr_cell( $!pos[R], $!pos[C] - 1 );
                    self!_wr_cell( $!pos[R], $!pos[C] );
                }
            }
            when KEY_LEFT | KEY_h {
                if $!pos[C] == 0 {
                    self!_beep;
                }
                else {
                    $!pos[C]--;
                    self!_wr_cell( $!pos[R], $!pos[C] + 1 );
                    self!_wr_cell( $!pos[R], $!pos[C] );
                }
            }
            when KEY_PPAGE | CONTROL_B {
                if $!p_begin <= 0 {
                    self!_beep;
                }
                else {
                    $!row_on_top = $!avail_h * ( $!pos[R] div $!avail_h - 1 );
                    $!pos[R] -= $!avail_h;
                    $!p_begin = $!row_on_top;
                    $!p_end   = $!p_begin + $!avail_h - 1;
                    self!_wr_screen;
                }
            }
            when KEY_NPAGE | CONTROL_F {
                if $!p_end >= $!rc2idx.end {
                    self!_beep;
                }
                else {
                    $!row_on_top = $!avail_h * ( $!pos[R] div $!avail_h + 1 );
                    $!pos[R] += $!avail_h;
                    if $!pos[R] >= $!rc2idx.end {
                        if $!rc2idx.end == $!row_on_top || ! $!rest || $!pos[C] <= $!rest - 1 {
                            if $!pos[R] != $!rc2idx.end {
                                $!pos[R] = $!rc2idx.end;
                            }
                            if $!rest && $!pos[C] > $!rest - 1 {
                                $!pos[C] = $!rc2idx[$!pos[R]].end;
                            }
                        }
                        else {
                            $!pos[R] = $!rc2idx.end - 1;
                        }
                    }
                    $!p_begin = $!row_on_top;
                    $!p_end   = $!p_begin + $!avail_h - 1;
                    $!p_end   = $!rc2idx.end if $!p_end > $!rc2idx.end;
                    self!_wr_screen;
                }
            }
            when KEY_HOME | CONTROL_A {
                if $!pos[C] == 0 && $!pos[R] == 0 {
                    self!_beep;
                }
                else {
                    $!row_on_top = 0;
                    $!pos[R] = $!row_on_top;
                    $!pos[C] = 0;
                    $!p_begin = $!row_on_top;
                    $!p_end   = $!p_begin + $!avail_h - 1;
                    $!p_end   = $!rc2idx.end if $!p_end > $!rc2idx.end;
                    self!_wr_screen;
                }
            }
            when KEY_END | CONTROL_E {
                if %!o<order> == 1 && $!rest {
                    if $!pos[R] == $!rc2idx.end - 1 && $!pos[C] == $!rc2idx[$!pos[R]].end {
                        self!_beep;
                    }
                    else {
                        $!row_on_top = $!rc2idx.elems - ( $!rc2idx.elems % $!avail_h || $!avail_h );
                        $!pos[R] = $!rc2idx.end - 1;
                        $!pos[C] = $!rc2idx[$!pos[R]].end;
                        if $!row_on_top == $!rc2idx.end {
                            $!row_on_top = $!row_on_top - $!avail_h;
                            $!p_begin = $!row_on_top;
                            $!p_end   = $!p_begin + $!avail_h - 1;
                        }
                        else {
                            $!p_begin = $!row_on_top;
                            $!p_end   = $!rc2idx.end;
                        }
                        self!_wr_screen;
                    }
                }
                else {
                    if $!pos[R] == $!rc2idx.end && $!pos[C] == $!rc2idx[$!pos[R]].end {
                        self!_beep;
                    }
                    else {
                        $!row_on_top = $!rc2idx.elems - ( $!rc2idx.elems % $!avail_h || $!avail_h );
                        $!pos[R] = $!rc2idx.end;
                        $!pos[C] = $!rc2idx[$!pos[R]].end;
                        $!p_begin = $!row_on_top;
                        $!p_end   = $!rc2idx.end;
                        self!_wr_screen;
                    }
                }
            }
            when KEY_q | CONTROL_D {
                self!_end_term();
                return;
            }
            when KEY_RETURN | KEY_ENTER { #
                self!_end_term();
                if ! $!multiselect.defined {
                    return;
                }
                elsif $!multiselect == 0 {
                    my Int $i = $!rc2idx[$!pos[R]][$!pos[C]];
                    return %!o<index> || %!o<ll> ?? $i !! @!orig_list[$i];
                }
                else {
                    $!marked[$!pos[R]][$!pos[C]] = 1;
                    return %!o<index> || %!o<ll> ?? self!_marked_to_idx.List !! @!orig_list[self!_marked_to_idx()];
                }
            }
            when KEY_SPACE {
                if $!multiselect {
                    my Int $locked = 0;
                    if %!o<no_spacebar> {
                        for %!o<no_spacebar>.list -> $no_spacebar {
                            if $!rc2idx[$!pos[R]][$!pos[C]] == $no_spacebar {
                                ++$locked;
                                last;
                            }
                        }
                    }
                    if $locked {
                        self!_beep;
                    }
                    else {
                        if ! $!marked[$!pos[R]][$!pos[C]] {
                            $!marked[$!pos[R]][$!pos[C]] = 1;
                        }
                        else {
                            $!marked[$!pos[R]][$!pos[C]] = 0;
                        }
                        self!_wr_cell( $!pos[R], $!pos[C] );
                    }
                }
            }
            when CONTROL_SPACE {
                if $!multiselect {
                    if $!pos[R] == 0 {
                        for 0 .. $!rc2idx.end -> $i {
                            for 0 .. $!rc2idx[$i].end -> $j {
                                $!marked[$i][$j] = $!marked[$i][$j] ?? 0 !! 1;
                            }
                        }
                    }
                    else {
                        for $!p_begin .. $!p_end -> $i {
                            for 0 .. $!rc2idx[$i].end -> $j {
                                $!marked[$i][$j] = $!marked[$i][$j] ?? 0 !! 1;
                            }
                        }
                    }
                    if %!o<no_spacebar> {
                        self!_idx_to_marked( %!o<no_spacebar>, 0 );
                    }
                    self!_wr_screen;
                }
                else {
                    self!_beep;
                }
            }
            when KEY_MOUSE {
                my Term::Choose::NCurses::MEVENT $event .= new;
                if getmouse( $event ) == OK {
                    if $event.bstate == BUTTON1_CLICKED | BUTTON1_PRESSED {
                        my $ret = self!_curr_pos_to_mouse_xy( $event.x, $event.y );
                        if $ret {
                            ungetch( KEY_RETURN );
                        }
                    }
                    #elsif $event.bstate == BUTTON3_CLICKED | BUTTON3_PRESSED {
                    ##
                    elsif $event.bstate == 16384 | 8192 | 4096 | 2048 {
                        if $event.bstate == 4096 && $pressed {
                            $pressed = 0;
                            next GET_KEY;
                        }
                        if $event.bstate == 8192 {
                            $pressed = 1;
                        }
                    ##
                        my $ret = self!_curr_pos_to_mouse_xy( $event.x, $event.y );
                        if $ret {
                            ungetch( KEY_SPACE );
                        }
                    }
                    #elsif $event.bstate == BUTTON4_PRESSED {
                    #    ungetch( KEY_PPAGE );
                    #}
                    #elsif $event.bstate == BUTTON5_PRESSED {
                    #    ungetch( KEY_NPAGE );
                    #}
                }
                next GET_KEY;
            }
            default {
                self!_beep;
            }
        }
        nc_refresh();
    }
}


method !_curr_pos_to_mouse_xy ( Int $abs_mouse_x, Int $abs_mouse_y ) {
    my Int $abs_y_of_top_row = $!nr_prompt_lines;
    if $abs_mouse_y < $abs_y_of_top_row {
        return;
    }
    my Int $mouse_row = $abs_mouse_y - $abs_y_of_top_row;
    my Int $mouse_col = $abs_mouse_x;
    if $mouse_row > $!rc2idx.end {
        return;
    }
    my Int $pad = $!rc2idx.end == 0 ?? %!o<pad_one_row> !! %!o<pad>;
    my Int $row = $mouse_row + $!row_on_top;
    my Int $matched_col;
    my Int $end_last_col = 0;
    COL: for 0 .. $!rc2idx[$row].end -> $col {
        my Int $end_this_col;
        if $!rc2idx.end == 0 {
            $end_this_col = $end_last_col + print_columns( @!list[$!rc2idx[$row][$col]] ) + $pad;
        }
        else { #
            $end_this_col = $end_last_col + $!col_w + $pad;
        }
        if $col == 0 {
            $end_this_col -= $pad div 2;
        }
        if $col == $!rc2idx[$row].end && $end_this_col > $!avail_w {
            $end_this_col = $!avail_w;
        }
        if $end_last_col < $mouse_col && $end_this_col >= $mouse_col {
            $matched_col = $col;
            last COL;
        }
        $end_last_col = $end_this_col;
    }
    if ! $matched_col.defined {
        return;
    }
    if $row != $!pos[R] || $matched_col != $!pos[C] {
        my Array $tmp = $!pos; #
        $!pos = [ $row, $matched_col ];
        self!_wr_cell( $tmp[0], $tmp[1] );
        self!_wr_cell( $!pos[R], $!pos[C] );
    }
    return 1;
}


method !_beep {
    beep() if %!o<beep>;
}


method !_prepare_prompt {
    if %!o<prompt> eq '' {
        $!nr_prompt_lines = 0;
        return;
    }
    my $init   = %!o<lf>[0] // 0;
    my $subseq = %!o<lf>[1] // 0;
    $!prompt_copy = line_fold( %!o<prompt>, $!avail_w, ' ' x $init, ' ' x $subseq );
    $!prompt_copy ~= "\n";
    my $matches = $!prompt_copy.subst-mutate( / \n /, "\n\r", :g ); #
    $!nr_prompt_lines = $matches.elems;
}


method !_set_default_cell {
    my $tmp_pos = [ 0, 0 ];
    ROW: for 0 .. $!rc2idx.end -> $i {
        COL: for 0 .. $!rc2idx[$i].end -> $j {
            if %!o<default> == $!rc2idx[$i][$j] {
                $tmp_pos = [ $i, $j ];
                last ROW;
            }
        }
    }
    $!row_on_top = $!avail_h * ( $tmp_pos[R] div $!avail_h );
    $!p_begin = $!row_on_top;
    $!p_end   = $!p_begin + $!avail_h - 1;
    $!p_end   = $!rc2idx.end if $!p_end > $!rc2idx.end;
    $!pos = $tmp_pos;
}


method !_wr_first_screen {
    $!term_w = getmaxx( $!win );
    $!term_h = getmaxy( $!win );

    ( $!avail_w, $!avail_h ) = ( $!term_w, $!term_h );
    if %!o<max_width> && $!avail_w > %!o<max_width> {
        $!avail_w = %!o<max_width>;
    }
    if $!avail_w < 2 {
        die "Terminal width to small.";
    }

    self!_prepare_new_copy_of_list;

    self!_prepare_prompt;
    $!avail_h -= $!nr_prompt_lines;

    $!pp_row = %!o<page> ?? 1 !! 0;

    my $keep = %!o<keep> + $!pp_row;
    if $!avail_h < $keep {
        $!avail_h = $!term_h > $keep ?? $keep !! $!term_h;
    }

    if %!o<max_height> && %!o<max_height> < $!avail_h {
        $!avail_h = %!o<max_height>;
    }

    $!layout = %!o<layout>;
    self!_index_to_rowcol;

    if %!o<page> {
        self!_set_page_nr_print_fmt;
    }

    $!p_begin    = 0;
    $!p_end      = $!avail_h - 1;
    $!p_end      = $!rc2idx.end if $!p_end > $!rc2idx.end;
    $!row_on_top = 0;
    $!pos        = [ 0, 0 ];
    $!marked     = [];

    if $!multiselect && %!o<mark> {
        self!_idx_to_marked( %!o<mark>, 1 );
    }

    if %!o<default>.defined && %!o<default> <= @!list.end {
        self!_set_default_cell;
    }

    if %!o<prompt> ne '' {
        mvaddstr( 0, 0, $!prompt_copy );
    }

    self!_wr_screen;
    nc_refresh();
}

method !_set_page_nr_print_fmt {
    if $!rc2idx.end / $!avail_h > 1 {
        $!avail_h -= $!pp_row;
        my $last_p_nr = $!rc2idx.end div $!avail_h + 1;
        my $p_nr_w = $last_p_nr.chars;
        $!pp_line_fmt = '--- Page %0' ~ $p_nr_w ~ 'd/' ~ $last_p_nr ~ ' ---';
        if sprintf( $!pp_line_fmt, $last_p_nr ).chars > $!avail_w {
            $!pp_line_fmt = '%0' ~ $p_nr_w ~ 'd/' ~ $last_p_nr;
            if sprintf( $!pp_line_fmt, $last_p_nr ).chars > $!avail_w {
                $p_nr_w = $!avail_w if $p_nr_w > $!avail_w;
                $!pp_line_fmt = '%0' ~ $p_nr_w ~ '.' ~ $p_nr_w ~ 's';
            }
        }
    }
    else {
        $!pp_row = 0;
    }
}

method !_wr_screen {
    move( $!nr_prompt_lines, 0 );
    clrtobot();
    if $!pp_row {
        my Str $pp_line = sprintf $!pp_line_fmt, $!row_on_top div $!avail_h + 1;
        mvaddstr(
            $!avail_h + $!nr_prompt_lines,
            0,
            $pp_line
        );
     }
    for $!p_begin .. $!p_end -> $row {
        for 0 .. $!rc2idx[$row].end -> $col {
            self!_wr_cell( $row, $col );
        }
    }
    self!_wr_cell( $!pos[R], $!pos[C] );
}

method !_wr_cell ( Int $row, Int $col ) {
    my Bool $is_current_pos = $row == $!pos[R] && $col == $!pos[C];
    my Int $idx = $!rc2idx[$row][$col];
    if $!rc2idx.end == 0 && $!rc2idx[0].end > 0 {
        my Int $lngth = 0;
        if $col > 0 {
            for ^$col -> $cl {
                my Int $i = $!rc2idx[$row][$cl];
                $lngth += print_columns( @!list[$i] );
                $lngth += %!o<pad_one_row>;
            }
        }
        attron( A_BOLD +| A_UNDERLINE ) if $!marked[$row][$col];
        attron( A_REVERSE )             if $is_current_pos;
        mvaddstr( 
            $row - $!row_on_top + $!nr_prompt_lines,
            $lngth,
            @!list[$idx]
        );
    }
    else {
        attron( A_BOLD +| A_UNDERLINE ) if $!marked[$row][$col];
        attron( A_REVERSE )             if $is_current_pos;
        mvaddstr( 
            $row - $!row_on_top + $!nr_prompt_lines,
            ( $!col_w + %!o<pad> ) * $col,
            self!_pad_str_to_colwidth: $idx
        );
    }
    attroff( A_BOLD +| A_UNDERLINE ) if $!marked[$row][$col];
    attroff( A_REVERSE )             if $is_current_pos;
}


method !_pad_str_to_colwidth ( Int $idx ) {
    my Int $str_w = @!length[$idx];
    if $str_w < $!col_w {
        if %!o<justify> == 0 {
            return @!list[$idx] ~ " " x ( $!col_w - $str_w );
        }
        elsif %!o<justify> == 1 {
            return " " x ( $!col_w - $str_w ) ~ @!list[$idx];
        }
        elsif %!o<justify> == 2 {
            my Int $fill = $!col_w - $str_w;
            my Int $half_fill = $fill div 2;
            return " " x $half_fill ~ @!list[$idx] ~ " " x ( $fill - $half_fill );
        }
    }
    else {
        return @!list[$idx];
    }
}


method !_index_to_rowcol {
    $!rc2idx = [];
    if $!col_w + %!o<pad> >= $!avail_w {
        $!layout = 2;
    }
    my Str $all_in_first_row;
    if $!layout == 0|1 {
        for 0 .. @!list.end -> $idx {
            $all_in_first_row ~= @!list[$idx];
            $all_in_first_row ~= ' ' x %!o<pad_one_row> if $idx < @!list.end;
            if print_columns( $all_in_first_row ) > $!avail_w {
                $all_in_first_row = '';
                last;
            }
        }
    }
    if $all_in_first_row {
        $!rc2idx[0] = [ 0 .. @!list.end ];
    }
    elsif $!layout == 2 {
        for 0 .. @!list.end -> $idx {
            $!rc2idx[$idx][0] = $idx;
        }
    }
    else {
        my Int $col_with_pad_w = $!col_w + %!o<pad>;
        my Int $tmp_avail_w = $!avail_w + %!o<pad>;
        # auto_format
        if $!layout == 1 {
            my Int $tmc = @!list.elems div $!avail_h;
            $tmc++ if @!list.elems % $!avail_h;
            $tmc *= $col_with_pad_w;
            if $tmc < $tmp_avail_w {
                $tmc += ( ( $tmp_avail_w - $tmc ) / 1.5 ).Int;
                $tmp_avail_w = $tmc;
            }
        }
        # order
        my Int $cols_per_row = $tmp_avail_w div $col_with_pad_w || 1;
        $!rest = @!list.elems % $cols_per_row; #
        if %!o<order> == 1 {
            my Int $nr_of_rows = ( @!list.elems - 1 + $cols_per_row ) div $cols_per_row;
            my Array @rearranged_idx;
            my Int $begin = 0;
            my Int $end = $nr_of_rows - 1;
            for ^$cols_per_row -> $col {
                if $!rest && $col >= $!rest {
                    --$end;
                }
                @rearranged_idx[$col] = [ $begin .. $end ];
                $begin = $end + 1;
                $end = $begin + $nr_of_rows - 1;
            }
            for ^$nr_of_rows -> $row {
                my Int @temp_idx;
                for ^$cols_per_row -> $col {
                    if $row == $nr_of_rows - 1 && $!rest && $col >= $!rest {
                        next;
                    }
                    @temp_idx.push( @rearranged_idx[$col][$row] );
                }
                $!rc2idx.push( @temp_idx );
            }
        }
        else {
            my Int $begin = 0;
            my Int $end = $cols_per_row - 1;
            $end = @!list.end if $end > @!list.end;
            $!rc2idx.push( [ $begin .. $end ] );
            while $end < @!list.end {
                $begin += $cols_per_row;
                $end   += $cols_per_row;
                $end    = @!list.end if $end > @!list.end;
                $!rc2idx.push( [ $begin .. $end ] );
            }
        }
    }
}


method !_idx_to_marked ( Array $indexes, Int $boolean ) {
    if $!layout == 2 {
        for $indexes.list -> $idx {
            $!marked[$idx][0] = $boolean;
        }
        return;
    }
    my ( Int $row, Int $col );
    my Int $cols_per_row = $!rc2idx[0].elems;
    if %!o<order> == 0 {
        for $indexes.list -> $idx {
            $row = $idx div $cols_per_row;
            $col = $idx % $cols_per_row;
            $!marked[$row][$col] = $boolean;
        }
    }
    elsif %!o<order> == 1 {
        my Int $rows_per_col = $!rc2idx.elems;
        my Int $end_last_full_col = $rows_per_col * ( $!rest || $cols_per_row );
        for $indexes.list -> $idx {
            next if $idx > @!list.end; ###
            if $idx <= $end_last_full_col {
                $row = $idx % $rows_per_col;
                $col = $idx div $rows_per_col;
            }
            else {
                my Int $rows_per_col_short = $rows_per_col - 1;
                $row = ( $idx - $end_last_full_col ) % $rows_per_col_short;
                $col = ( $idx - $!rest ) div $rows_per_col_short;
            }
            $!marked[$row][$col] = $boolean;
        }
    }
}

method !_marked_to_idx {
    my Int @idx;
    if %!o<order> == 1 {
        for 0 .. $!rc2idx[0].end -> $col {
            for 0 .. $!rc2idx.end -> $row {
                @idx.push( $!rc2idx[$row][$col] ) if $!marked[$row][$col];
            }
        }
    }
    else {
        for 0 .. $!rc2idx.end -> $row {
            for 0 .. $!rc2idx[$row].end -> $col {
                @idx.push( $!rc2idx[$row][$col] ) if $!marked[$row][$col];
            }
        }
    }
    return @idx;
}



=begin pod

=head1 NAME

Term::Choose - Choose items from a list interactively.

=head1 VERSION

Version 0.105

=head1 SYNOPSIS

    use Term::Choose;

    my @array = <one two three four five>;


    # Functional interface:
 
    my $choice = choose( @array, { layout => 1 } );

    say $choice;


    # OO interface:
 
    my $tc = Term::Choose.new();

    $choice = $tc.choose( @array, { layout => 1 } );

    say $choice;

=head1 DESCRIPTION

Choose interactively from a list of items.

For C<choose>, C<choose_multi> and C<pause> the first argument (Array) holds the list of the available choices.

With the optional second argument (Hash) it can be passed the different options. See L<#OPTIONS>.

The return values are described in L<#Routines>

=head1 USAGE

To browse through the available list-elements use the keys described below.

If the items of the list don't fit on the screen, the user can scroll to the next (previous) page(s).

If the window size is changed, after a keystroke the screen is rewritten.

How to choose the items is described for each method/function separately in L<Routines>.

=head2 Keys

=item the C<Arrow> keys (or C<h,j,k,l>) to move up and down or to move to the right and to the left,

=item the C<Tab> key (or C<Ctrl-I>) to move forward, the C<BackSpace> key (or C<Ctrl-H> or C<Shift-Tab>) to move
backward,

=item the C<PageUp> key (or C<Ctrl-B>) to go back one page, the C<PageDown> key (or C<Ctrl-F>) to go forward one page,

=item the C<Home> key (or C<Ctrl-A>) to jump to the beginning of the list, the C<End> key (or C<Ctrl-E>) to jump to the
end of the list.

For the usage of C<SpaceBar>, C<Ctrl-SpaceBar>, C<Return> and the C<q>-key see L<#choose>, L<#choose_multi> and
L<#pause>.

With I<mouse> enabled (and if supported by the terminal) use the the left mouse key instead the C<Return> key and
the right mouse key instead of the C<SpaceBar> key. Instead of C<PageUp> and C<PageDown> it can be used the mouse wheel.
- Mouse wheel not yet suppoerted! 

=head1 Routines

=head2 choose

C<choose> allows the user to choose one item from a list: the highlighted item is returned when C<Return>
is pressed.

C<choose> returns nothing if the C<q> key or C<Ctrl-D> is pressed.

=head2 choose_multi

The user can choose many items.

To choose more than one item mark an item with the C<SpaceBar>. C<choose_multi> then returns the list of the marked
items including the highlighted item.

C<Ctrl-SpaceBar> (or C<Ctrl-@>) inverts the choices: marked items are unmarked and unmarked items are marked. If the
cursor is on the first row, C<Ctrl-SpaceBar> inverts the choices for the whole list else C<Ctrl-SpaceBar> inverts the
choices for the current page.

C<choose_multi> returns nothing if the C<q> key or C<Ctrl-D> is pressed.

=head2 pause

Nothing can be chosen, nothing is returned but the user can move around and read the output until closed with C<Return>,
C<q> or C<Ctrl-D>.

=head1 OUTPUT

For the output on the screen the array elements are modified.

All the modifications are made on a copy of the original array so C<choose> and C<choose_multi> return the chosen
elements as they were passed without modifications.

Modifications:

=item If an element is not defined, the value from the option I<undef> is assigned to the element.

=item If an element holds an empty string, the value from the option I<empty> is assigned to the element.

=item White-spaces in elements are replaced with simple spaces.

=begin code

    $element =~ s:g/\s/ /;

=end code

=item Characters which match the Unicode character property C<Other> are removed.

=begin code

    $element =~ s:g/\p{C}//;

=end code

=item This mapping is made before the "C<substr>" because it may change the print width of the elements.

=begin code

    $element = $element.gist;

=end code

=item If the length of an element is greater than the width of the screen the element is cut.

=begin code

    $element.=substr( 0, $allowed_length - 3 ) ~ '...';*

=end code

C<*> C<Term::Choose> uses its own function to cut strings which calculates width in print columns.

=head1 OPTIONS

Options which expect a number as their value expect integers.

=head2 beep

0 - off (default)

1 - on

=head2 default

With the option I<default> it can be selected an element, which will be highlighted as the default instead of the first
element.

I<default> expects a zero indexed value, so e.g. to highlight the third element the value would be I<2>.

If the passed value is greater than the index of the last array element, the first element is highlighted.

Allowed values: 0 or greater

(default: undefined)

=head2 empty

Sets the string displayed on the screen instead an empty string.

default: "E<lt>emptyE<gt>"

=head2 index

0 - off (default)

1 - return the indices of the chosen elements instead of the chosen elements.

This option has no meaning for C<pause>.

=head2 justify

0 - elements ordered in columns are left-justified (default)

1 - elements ordered in columns are right-justified

2 - elements ordered in columns are centered

=head2 keep

I<keep> prevents that all the terminal rows are used by the prompt lines.

Setting I<keep> ensures that at least I<keep> terminal rows are available for printing "list"-rows.

If the terminal height is less than I<keep>, I<keep> is set to the terminal height.

Allowed values: 1 or greater

(default: 5)

=head2 layout

From broad to narrow: 0 > 1 > 2

=item 0 - layout off

=begin code

    .-------------------.   .-------------------.   .-------------------.   .-------------------.
    | .. .. .. .. .. .. |   | .. .. .. .. .. .. |   | .. .. .. .. .. .. |   | .. .. .. .. .. .. |
    |                   |   | .. .. .. .. .. .. |   | .. .. .. .. .. .. |   | .. .. .. .. .. .. |
    |                   |   |                   |   | .. .. .. ..       |   | .. .. .. .. .. .. |
    |                   |   |                   |   |                   |   | .. .. .. .. .. .. |
    |                   |   |                   |   |                   |   | .. .. .. .. .. .. |
    |                   |   |                   |   |                   |   | .. .. .. .. .. .. |
    '-------------------'   '--- ---------------'   '-------------------'   '-------------------'

=end code

=item 1 - (default)

=begin code

    .-------------------.   .-------------------.   .-------------------.   .-------------------.
    | .. .. .. .. .. .. |   | .. .. .. ..       |   | .. .. .. .. ..    |   | .. .. .. .. .. .. |
    |                   |   | .. .. .. ..       |   | .. .. .. .. ..    |   | .. .. .. .. .. .. |
    |                   |   | .. ..             |   | .. .. .. .. ..    |   | .. .. .. .. .. .. |
    |                   |   |                   |   | .. .. .. .. ..    |   | .. .. .. .. .. .. |
    |                   |   |                   |   | .. .. ..          |   | .. .. .. .. .. .. |
    |                   |   |                   |   |                   |   | .. .. .. .. .. .. |
    '-------------------'   '-------------------'   '-------------------'   '-------------------'

=end code

=item 2 - all in a single column

=begin code

    .-------------------.   .-------------------.   .-------------------.   .-------------------.
    | ..                |   | ..                |   | ..                |   | ..                |
    | ..                |   | ..                |   | ..                |   | ..                |
    | ..                |   | ..                |   | ..                |   | ..                |
    |                   |   | ..                |   | ..                |   | ..                |
    |                   |   |                   |   | ..                |   | ..                |
    |                   |   |                   |   |                   |   | ..                |
    '-------------------'   '-------------------'   '-------------------'   '-------------------'

=end code

=head2 lf

If I<prompt> lines are folded, the option I<lf> allows to insert spaces at beginning of the folded lines.

The option I<lf> expects a array with one or two elements:

- the first element (C<INITIAL_TAB>) sets the number of spaces inserted at beginning of paragraphs

- a second element (C<SUBSEQUENT_TAB>) sets the number of spaces inserted at the beginning of all broken lines apart
from the beginning of paragraphs

Allowed values for the two elements are: 0 or greater.

(default: undefined)

=head2 mark

This is a C<choose_multi>-only option.

I<mark> expects as its value an array. The elements of the array are list indexes. C<choose> preselects the
list-elements correlating to these indexes.

(default: undefined)

=head2 max_height

If defined sets the maximal number of rows used for printing list items.

If the available height is less than I<max_height>, I<max_height> is set to the available height.

Height in this context means number of print rows.

I<max_height> overwrites I<keep> if I<max_height> is set to a value less than I<keep>.

Allowed values: 1 or greater

(default: undefined)

=head2 max_width

If defined, sets the maximal output width to I<max_width> if the terminal width is greater than I<max_width>.

To prevent the "auto-format" to use a width less than I<max_width> set I<layout> to C<0>.

Width refers here to the number of print columns.

Allowed values: 2 or greater

(default: undefined)

=head2 mouse

0 - no mouse (default)

1 - mouse enabled

=head2 no_spacebar

This is a C<choose_multi>-only option.

I<no_spacebar> expects as its value an array. The elements of the array are indexes of choices which should not be
markable with the C<SpaceBar> or with the right mouse key. If an element is preselected with the option I<mark> and also
marked as not selectable with the option I<no_spacebar>, the user can not remove the preselection of this element.

(default: undefined)

=head2 order

If the output has more than one row and more than one column:

0 - elements are ordered horizontally

1 - elements are ordered vertically (default)

=head2 pad

Sets the number of whitespaces between columns. (default: 2)

Allowed values: 0 or greater

=head2 pad_one_row

Sets the number of whitespaces between elements if we have only one row. (default: value of the option I<pad>)

Allowed values: 0 or greater

=head2 page

0 - off

1 - print the page number on the bottom of the screen if there is more then one page. (default)

=head2 prompt

If I<prompt> is undefined, a default prompt-string will be shown.

If the I<prompt> value is an empty string (""), no prompt-line will be shown.

default: I<multiselect> == C<0> ??  C<Close with ENTER> !! C<Your choice:>. 

=head2 undef

Sets the string displayed on the screen instead an undefined element.

default: "E<lt>undefE<gt>"

=head1 REQUIREMENTS

=head2 Monospaced font

It is required a terminal that uses a monospaced font which supports the printed characters.

=head2 libncurses

See I<Installation> and I<Environment variables> in L<NCurses|https://github.com/azawawi/perl6-ncurses>.

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 CREDITS

Based on the C<choose> function from the L<Term::Clui|https://metacpan.org/pod/Term::Clui> module.

Thanks to the people from L<Perl-Community.de|http://www.perl-community.de>, from
L<stackoverflow|http://stackoverflow.com> and from L<#perl6 on irc.freenode.net|irc://irc.freenode.net/#perl6> for the
help.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2016 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
