use v6;
unit class Term::Choose;

my $VERSION = '0.120';

use Term::Choose::NCurses;
use Term::Choose::LineFold :to-printwidth, :line-fold, :print-columns;

constant R  = 0;
constant C  = 1;

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


has @!orig_list;
has @!list;

has %.defaults;
has %!o;

has Term::Choose::NCurses::WINDOW $.win;
has Term::Choose::NCurses::WINDOW $!win_local;

has Int   $!term_w;
has Int   $!term_h;
has Int   $!avail_w;
has Int   $!avail_h;
has Int   $!col_w;
has Int   @!length;
has Int   $!layout;
has Int   $!rest;
has Int   $!print_pp_row;
has Str   $!pp_line_fmt;
has Int   $!nr_prompt_lines;
has Str   $!prompt_copy;
has Int   $!row_top;
has Int   $!row_bottom;
has Array $!rc2idx;
has Array $!p;
has Array $!marked;
has Bool  $!ext_mouse;

method new ( :%defaults, :$win=Term::Choose::NCurses::WINDOW ) {
    _validate_options( %defaults );
    _set_defaults( %defaults );
    self.bless( :%defaults, :$win );
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
    %opt<max-height>    //= Int;
    %opt<max-width>     //= Int;
    %opt<mouse>         //= 0;
    %opt<no-spacebar>   //= Array;
    %opt<order>         //= 1;
    %opt<pad>           //= 2;
    %opt<pad-one-row>   //= %opt<pad>;
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
        max-height      => '<[ 1 .. 9 ]><[ 0 .. 9 ]>*',
        max-width       => '<[ 2 .. 9 ]><[ 0 .. 9 ]>*',
        default         => '<[ 0 .. 9 ]>+',
        pad             => '<[ 0 .. 9 ]>+',
        pad-one-row     => '<[ 0 .. 9 ]>+',
        lf              => 'Array',
        mark            => 'Array',
        no-spacebar     => 'Array',
        empty           => 'Str',
        prompt          => 'Str',
        undef           => 'Str',
    };
};

sub _validate_options ( %opt, Int $list_end? ) {
    my $valid = _valid_options(); # %
    for %opt.kv -> $key, $value {
        when $valid{$key}:!exists {
            die "'$key' is not a valid option name";
        }
        when ! $value.defined {
            next;
        }
        when $valid{$key} eq 'Array' {
            die "$key => not an ARRAY reference."     if ! $value.isa( Array );
            die "$key => invalid array element"       if $value.grep( { / <-[0..9]> / } ); # .grep( { $_ !~~ UInt } );
            if $key eq 'lf' {
                die "$key => too many array elemnts." if $value.elems > 2;
            }
            else {
                die "$key => value out of range."     if $list_end.defined && $value.any > $list_end;
            }
        }
        when $valid{$key} eq 'Str' {
             die "$key => {$value.perl} is not a string." if ! $value.isa( Str );
        }
        default {
            when ! $value.isa( Int ) {
                die "$key => {$value.perl} is not an integer.";
            }
            when $value !~~ / ^ <{$valid{$key}}> $ / {
                die "$key => '$value' is not a valid value.";
            }
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
                $_ = to-printwidth( $_, $!avail_w - $dots_w ) ~ $dots;
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
            @!list[$i].=subst( / <:C> /, '',  :g );  # remove invisible control characters and unused code points (Other)
            @!list[$i] = @!list[$i].gist;
            my Int $length = print-columns( @!list[$i] );
            if $length > $!avail_w {
                @!list[$i] = to-printwidth( @!list[$i], $!avail_w - $dots_w ) ~ $dots;
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


sub choose       ( @list, %opt? ) is export( :DEFAULT, :choose )       { return Term::Choose.new().choose(       @list, %opt ) }
sub choose-multi ( @list, %opt? ) is export( :DEFAULT, :choose-multi ) { return Term::Choose.new().choose-multi( @list, %opt ) }
sub pause        ( @list, %opt? ) is export( :DEFAULT, :pause )        { return Term::Choose.new().pause(        @list, %opt ) }

method choose       ( @list, %opt? ) { return self!_choose( @list, %opt, 0   ) }
method choose-multi ( @list, %opt? ) { return self!_choose( @list, %opt, 1   ) }
method pause        ( @list, %opt? ) { return self!_choose( @list, %opt, Int ) }



method !_init_term {
    if $!win {
        $!win_local = $!win;
    }
    else {
        my int32 constant LC_ALL = 6;
        setlocale( LC_ALL, "" );
        $!win_local = initscr; # or die "Failed to initialize ncurses\n";
    }
    noecho();
    cbreak();
    keypad( $!win_local, True );
    if %!o<mouse> {
        if library() ~~ / 'libncursesw.so.' ( \d+ ) / {
            $!ext_mouse = $0 >= 6;
        }
        my Array[int32] $old;
        if $!ext_mouse {
            my $s = mousemask( EMM_ALL_MOUSE_EVENTS +| EMM_REPORT_MOUSE_POSITION, $old );
        }
        else {
            my $s = mousemask( ALL_MOUSE_EVENTS +| REPORT_MOUSE_POSITION, $old );
        }
        my $i = mouseinterval( 5 );
    }
    curs_set( 0 );
}

method !_end_term {
    return if $!win;
    endwin();
}

method !_choose ( @!orig_list, %!o, Int $multiselect ) {
    if ! @!orig_list.elems {
        return;
    }
    _validate_options( %!o, @!orig_list.end );
    for %!defaults.kv -> $key, $value {
        %!o{$key} //= $value;
    }
    if ! %!o<prompt>.defined {
        %!o<prompt> = $multiselect.defined ?? 'Your choice' !! 'Continue with ENTER';
    }
    self!_init_term;
    self!_wr_first_screen;
    my Int $pressed; #

    GET_KEY: loop {
        my $key;
        WAIT: loop {
            $key = getch();
            if $key == ERR {
                sleep 0.01;
                next WAIT;
            }
            last WAIT;
        }
        my Int $new_term_w = getmaxx( $!win_local );
        my Int $new_term_h = getmaxy( $!win_local );
        if $new_term_w != $!term_w || $new_term_h != $!term_h {
            if %!o<ll> {
                return -1;
            }
            %!o<default> = $!rc2idx[ $!p[R] ][ $!p[C] ]; #
            if $!marked.elems {
                %!o<mark> = self!_marked_rc2idx;
            }
            self!_wr_first_screen;
            next GET_KEY;
        }

        # $!rc2idx holds the new list (AoA) formated in "_index2rowcol" appropirate to the chosen layout.
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
                if ! $!rc2idx[ $!p[R]+1 ] || ! $!rc2idx[ $!p[R]+1 ][ $!p[C] ] {
                    self!_beep;
                }
                else {
                    $!p[R]++;
                    if $!p[R] <= $!row_bottom {
                        self!_wr_cell( $!p[R] - 1, $!p[C] );
                        self!_wr_cell( $!p[R]    , $!p[C] );
                    }
                    else {
                        $!row_top    = $!row_bottom + 1;
                        $!row_bottom = $!row_bottom + $!avail_h;
                        $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
                        self!_wr_screen;
                    }
                }
            }
            when KEY_UP | KEY_k {
                if $!p[R] == 0 {
                    self!_beep;
                }
                else {
                    $!p[R]--;
                    if $!p[R] >= $!row_top {
                        self!_wr_cell( $!p[R] + 1, $!p[C] );
                        self!_wr_cell( $!p[R]    , $!p[C] );
                    }
                    else {
                        $!row_bottom = $!row_top - 1;
                        $!row_top    = $!row_top - $!avail_h;
                        $!row_top    = 0 if $!row_top < 0;
                        self!_wr_screen;
                    }
                }
            }
            when KEY_TAB {
                if $!p[R] == $!rc2idx.end && $!p[C] == $!rc2idx[ $!p[R] ].end {
                    self!_beep;
                }
                else {
                    if $!p[C] < $!rc2idx[ $!p[R] ].end {
                        $!p[C]++;
                        self!_wr_cell( $!p[R], $!p[C] - 1 );
                        self!_wr_cell( $!p[R], $!p[C]     );
                    }
                    else {
                        $!p[R]++;
                        $!p[C] = 0;
                        if $!p[R] <= $!row_bottom {
                            self!_wr_cell( $!p[R] - 1, $!rc2idx[ $!p[R]-1 ].end );
                            self!_wr_cell( $!p[R]    , $!p[C]                   );
                        }
                        else {
                            $!row_top    = $!row_bottom + 1;
                            $!row_bottom = $!row_bottom + $!avail_h;
                            $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
                            self!_wr_screen;
                        }
                    }
                }
            }
            when KEY_BACKSPACE | CONTROL_H | KEY_BTAB {
                if $!p[C] == 0 && $!p[R] == 0 {
                    self!_beep;
                }
                else {
                    if $!p[C] > 0 {
                        $!p[C]--;
                        self!_wr_cell( $!p[R], $!p[C] + 1 );
                        self!_wr_cell( $!p[R], $!p[C]     );
                    }
                    else {
                        $!p[R]--;
                        $!p[C] = $!rc2idx[ $!p[R] ].end;
                        if $!p[R] >= $!row_top {
                            self!_wr_cell( $!p[R] + 1, 0      );
                            self!_wr_cell( $!p[R]    , $!p[C] );
                        }
                        else {
                            $!row_bottom = $!row_top - 1;
                            $!row_top    = $!row_top - $!avail_h;
                            $!row_top    = 0 if $!row_top < 0;
                            self!_wr_screen;
                        }
                    }
                }
            }
            when KEY_RIGHT | KEY_l {
                if $!p[C] == $!rc2idx[ $!p[R] ].end {
                    self!_beep;
                }
                else {
                    $!p[C]++;
                    self!_wr_cell( $!p[R], $!p[C] - 1 );
                    self!_wr_cell( $!p[R], $!p[C]     );
                }
            }
            when KEY_LEFT | KEY_h {
                if $!p[C] == 0 {
                    self!_beep;
                }
                else {
                    $!p[C]--;
                    self!_wr_cell( $!p[R], $!p[C] + 1 );
                    self!_wr_cell( $!p[R], $!p[C]     );
                }
            }
            when KEY_PPAGE | CONTROL_B {
                if $!row_top <= 0 {
                    self!_beep;
                }
                else {
                    $!row_top    = $!avail_h * ( $!p[R] div $!avail_h - 1 );
                    $!row_bottom = $!row_top + $!avail_h - 1;
                    $!p[R] -= $!avail_h; # set first $!row_top then $!p[R]
                    self!_wr_screen;
                }
            }
            when KEY_NPAGE | CONTROL_F {
                if $!row_bottom >= $!rc2idx.end {
                    self!_beep;
                }
                else {
                    $!row_top    = $!avail_h * ( $!p[R] div $!avail_h + 1 );
                    $!row_bottom = $!row_top + $!avail_h - 1;
                    $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
                    $!p[R] += $!avail_h; # set first $!row_top then $!p[R]
                    if $!p[R] >= $!rc2idx.end {
                        if $!rc2idx.end == $!row_top || ! $!rest || $!p[C] <= $!rest - 1 {
                            if $!p[R] != $!rc2idx.end {
                                $!p[R] = $!rc2idx.end;
                            }
                            if $!rest && $!p[C] > $!rest - 1 {
                                $!p[C] = $!rc2idx[ $!p[R] ].end;
                            }
                        }
                        else {
                            $!p[R] = $!rc2idx.end - 1;
                        }
                    }
                    self!_wr_screen;
                }
            }
            when KEY_HOME | CONTROL_A {
                if $!p[C] == 0 && $!p[R] == 0 {
                    self!_beep;
                }
                else {
                    $!p[R] = 0;
                    $!p[C] = 0;
                    $!row_top    = 0;
                    $!row_bottom = $!row_top + $!avail_h - 1;
                    $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
                    self!_wr_screen;
                }
            }
            when KEY_END | CONTROL_E {
                if %!o<order> == 1 && $!rest {
                    if $!p[R] == $!rc2idx.end - 1 && $!p[C] == $!rc2idx[ $!p[R] ].end {
                        self!_beep;
                    }
                    else {
                        $!p[R] = $!rc2idx.end - 1;
                        $!p[C] = $!rc2idx[ $!p[R] ].end;
                        $!row_top = $!rc2idx.elems - ( $!rc2idx.elems % $!avail_h || $!avail_h );
                        if $!row_top == $!rc2idx.end {
                            $!row_top    = $!row_top - $!avail_h;
                            $!row_bottom = $!row_top + $!avail_h - 1;
                        }
                        else {
                            $!row_bottom   = $!rc2idx.end;
                        }
                        self!_wr_screen;
                    }
                }
                else {
                    if $!p[R] == $!rc2idx.end && $!p[C] == $!rc2idx[ $!p[R] ].end {
                        self!_beep;
                    }
                    else {
                        $!p[R] = $!rc2idx.end;
                        $!p[C] = $!rc2idx[ $!p[R] ].end;
                        $!row_top    = $!rc2idx.elems - ( $!rc2idx.elems % $!avail_h || $!avail_h );
                        $!row_bottom = $!rc2idx.end;
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
                if ! $multiselect.defined {
                    return;
                }
                elsif $multiselect == 0 {
                    my Int $i = $!rc2idx[ $!p[R] ][ $!p[C] ];
                    return %!o<index> || %!o<ll> ?? $i !! @!orig_list[$i];
                }
                else {
                    $!marked[ $!p[R] ][ $!p[C] ] = True;
                    return %!o<index> || %!o<ll> ?? self!_marked_rc2idx.List !! @!orig_list[self!_marked_rc2idx()];
                }
            }
            when KEY_SPACE {
                if $multiselect {
                    my Int $locked = 0;
                    if %!o<no-spacebar> {
                        for %!o<no-spacebar>.list -> $no-spacebar {
                            if $!rc2idx[ $!p[R] ][ $!p[C] ] == $no-spacebar {
                                ++$locked;
                                last;
                            }
                        }
                    }
                    if $locked {
                        self!_beep;
                    }
                    else {
                        $!marked[ $!p[R] ][ $!p[C] ] = ! $!marked[ $!p[R] ][ $!p[C] ];
                        self!_wr_cell( $!p[R], $!p[C] );
                    }
                }
            }
            when CONTROL_SPACE {
                if $multiselect {
                    if $!p[R] == 0 {
                        for 0 .. $!rc2idx.end -> $i {
                            for 0 .. $!rc2idx[$i].end -> $j {
                                $!marked[$i][$j] = ! $!marked[$i][$j];
                            }
                        }
                    }
                    else {
                        for $!row_top .. $!row_bottom -> $i {
                            for 0 .. $!rc2idx[$i].end -> $j {
                                $!marked[$i][$j] = ! $!marked[$i][$j];
                            }
                        }
                    }
                    if %!o<no-spacebar> {
                        self!_marked_idx2rc( %!o<no-spacebar>, False );
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
                    if $!ext_mouse {
                        if $event.bstate == EMM_BUTTON1_CLICKED | EMM_BUTTON1_PRESSED {
                            my $ret = self!_mouse_xy2pos( $event.x, $event.y );
                            if $ret {
                                ungetch( KEY_RETURN );
                            }
                        }
                        elsif $event.bstate == EMM_BUTTON3_RELEASED | EMM_BUTTON3_PRESSED | EMM_BUTTON3_CLICKED {
                            if $event.bstate == EMM_BUTTON3_RELEASED && $pressed {
                                $pressed = 0;
                                next GET_KEY;
                            }
                            if $event.bstate == EMM_BUTTON3_PRESSED {
                                $pressed = 1;
                            }
                            my $ret = self!_mouse_xy2pos( $event.x, $event.y );
                            if $ret {
                                ungetch( KEY_SPACE );
                            }
                        }
                        elsif $event.bstate == EMM_BUTTON4_PRESSED {
                            ungetch( KEY_PPAGE );
                        }
                        elsif $event.bstate == EMM_BUTTON5_PRESSED {
                            ungetch( KEY_NPAGE );
                        }
                    }
                    else {
                        if $event.bstate == BUTTON1_CLICKED | BUTTON1_PRESSED {
                            my $ret = self!_mouse_xy2pos( $event.x, $event.y );
                            if $ret {
                                ungetch( KEY_RETURN );
                            }
                        }
                        elsif $event.bstate == BUTTON3_RELEASED | BUTTON3_PRESSED | BUTTON3_CLICKED {
                            if $event.bstate == BUTTON3_RELEASED && $pressed {
                                $pressed = 0;
                                next GET_KEY;
                            }
                            if $event.bstate == BUTTON3_PRESSED {
                                $pressed = 1;
                            }
                            my $ret = self!_mouse_xy2pos( $event.x, $event.y );
                            if $ret {
                                ungetch( KEY_SPACE );
                            }
                        }
                    }
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


method !_mouse_xy2pos ( Int $abs_mouse_x, Int $abs_mouse_y ) {
    my Int $abs_y_of_top_row = $!nr_prompt_lines;
    if $abs_mouse_y < $abs_y_of_top_row {
        return;
    }
    my Int $mouse_row = $abs_mouse_y - $abs_y_of_top_row;
    my Int $mouse_col = $abs_mouse_x;
    if $mouse_row > $!rc2idx.end {
        return;
    }
    my Int $pad = $!rc2idx.end == 0 ?? %!o<pad-one-row> !! %!o<pad>;
    my Int $row = $mouse_row + $!row_top;
    my Int $matched_col;
    my Int $end_last_col = 0;
    COL: for 0 .. $!rc2idx[$row].end -> $col {
        my Int $end_this_col;
        if $!rc2idx.end == 0 {
            $end_this_col = $end_last_col + print-columns( @!list[ $!rc2idx[$row][$col] ] ) + $pad;
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
    if $row != $!p[R] || $matched_col != $!p[C] {
        my Array $tmp = $!p; #
        $!p = [ $row, $matched_col ];
        self!_wr_cell( $tmp[0], $tmp[1] );
        self!_wr_cell( $!p[R] , $!p[C]  );
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
    $!prompt_copy = line-fold( %!o<prompt>, $!avail_w, ' ' x $init, ' ' x $subseq );
    $!prompt_copy ~= "\n";
    my $matches = $!prompt_copy.subst-mutate( / \n /, "\n\r", :g ); #
    $!nr_prompt_lines = $matches.elems;
}


method !_set_default_cell {
    my $tmp = [ 0, 0 ];
    ROW: for 0 .. $!rc2idx.end -> $i {
        COL: for 0 .. $!rc2idx[$i].end -> $j {
            if %!o<default> == $!rc2idx[$i][$j] {
                $tmp = [ $i, $j ];
                last ROW;
            }
        }
    }
    $!row_top    = $!avail_h * ( $tmp[R] div $!avail_h );
    $!row_bottom = $!row_top + $!avail_h - 1;
    $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
    $!p = $tmp;
}


method !_wr_first_screen {
    $!term_w = getmaxx( $!win_local );
    $!term_h = getmaxy( $!win_local );
    ( $!avail_w, $!avail_h ) = ( $!term_w, $!term_h );
    if %!o<max-width> && $!avail_w > %!o<max-width> {
        $!avail_w = %!o<max-width>;
    }
    if $!avail_w < 2 {
        die "Terminal width to small.";
    }
    self!_prepare_new_copy_of_list;
    self!_prepare_prompt;
    $!avail_h -= $!nr_prompt_lines;
    $!print_pp_row = %!o<page> ?? 1 !! 0;
    my $keep = %!o<keep> + $!print_pp_row;
    if $!avail_h < $keep {
        $!avail_h = $!term_h > $keep ?? $keep !! $!term_h;
    }
    if %!o<max-height> && %!o<max-height> < $!avail_h {
        $!avail_h = %!o<max-height>;
    }
    $!layout = %!o<layout>;
    self!_index2rowcol;
    if %!o<page> {
        self!_set_pp_print_fmt;
    }
    $!row_top    = 0;
    $!row_bottom = $!avail_h - 1;
    $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
    $!p = [ 0, 0 ];
    $!marked = [];
    if %!o<mark> {
        self!_marked_idx2rc( %!o<mark>, True );
    }
    if %!o<default>.defined && %!o<default> <= @!list.end {
        self!_set_default_cell;
    }
    clear();
    if %!o<prompt> ne '' {
        mvaddstr( 0, 0, $!prompt_copy );
    }
    self!_wr_screen;
    nc_refresh();
}

method !_set_pp_print_fmt {
    if $!rc2idx.end / $!avail_h > 1 {
        $!avail_h -= $!print_pp_row;
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
        $!print_pp_row = 0;
    }
}

method !_wr_screen {
    move( $!nr_prompt_lines, 0 );
    clrtobot();
    if $!print_pp_row {
        my Str $pp_line = sprintf $!pp_line_fmt, $!row_top div $!avail_h + 1;
        mvaddstr(
            $!avail_h + $!nr_prompt_lines,
            0,
            $pp_line
        );
     }
    for $!row_top .. $!row_bottom -> $row {
        for 0 .. $!rc2idx[$row].end -> $col {
            self!_wr_cell( $row, $col );
        }
    }
    self!_wr_cell( $!p[R], $!p[C] );
}

method !_wr_cell ( Int $row, Int $col ) {
    my Bool $is_current_pos = $row == $!p[R] && $col == $!p[C];
    my Int $idx = $!rc2idx[$row][$col];
    if $!rc2idx.end == 0 && $!rc2idx[0].end > 0 {
        my Int $lngth = 0;
        if $col > 0 {
            for ^$col -> $cl {
                my Int $i = $!rc2idx[$row][$cl];
                $lngth += print-columns( @!list[$i] );
                $lngth += %!o<pad-one-row>;
            }
        }
        attron( A_BOLD +| A_UNDERLINE ) if $!marked[$row][$col];
        attron( A_REVERSE )             if $is_current_pos;
        mvaddstr(
            $row - $!row_top + $!nr_prompt_lines,
            $lngth,
            @!list[$idx]
        );
    }
    else {
        attron( A_BOLD +| A_UNDERLINE ) if $!marked[$row][$col];
        attron( A_REVERSE )             if $is_current_pos;
        mvaddstr(
            $row - $!row_top + $!nr_prompt_lines,
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
        return @!list[$idx] ~ "";
    }
}


method !_index2rowcol {
    $!rc2idx = [];
    if $!col_w + %!o<pad> >= $!avail_w {
        $!layout = 2;
    }
    my Str $all_in_first_row;
    if $!layout == 0|1 {
        for 0 .. @!list.end -> $idx {
            $all_in_first_row ~= @!list[$idx];
            $all_in_first_row ~= ' ' x %!o<pad-one-row> if $idx < @!list.end;
            if print-columns( $all_in_first_row ) > $!avail_w {
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


method !_marked_idx2rc ( Array $indexes, Bool $yesno ) {
    if $!layout == 2 {
        for $indexes.list -> $idx {
            $!marked[$idx][0] = $yesno;
        }
        return;
    }
    my ( Int $row, Int $col );
    my Int $cols_per_row = $!rc2idx[0].elems;
    if %!o<order> == 0 {
        for $indexes.list -> $idx {
            $row = $idx div $cols_per_row;
            $col = $idx % $cols_per_row;
            $!marked[$row][$col] = $yesno;
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
            $!marked[$row][$col] = $yesno;
        }
    }
}

method !_marked_rc2idx {
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

Version 0.120

=head1 SYNOPSIS

    use Term::Choose :choose;

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

For C<choose>, C<choose-multi> and C<pause> the first argument (Array) holds the list of the available choices.

With the optional second argument (Hash) it can be passed the different options. See L<#OPTIONS>.

The return values are described in L<#Routines>

=head1 FUNCTIONAL INTERFACE

Importing the subroutines explicitly (C<:name_of_the_subroutine>) might become compulsory (optional for now) with the
next release.

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

For the usage of C<SpaceBar>, C<Ctrl-SpaceBar>, C<Return> and the C<q>-key see L<#choose>, L<#choose-multi> and
L<#pause>.

With I<mouse> enabled (and if supported by the terminal) use the the left mouse key instead the C<Return> key and
the right mouse key instead of the C<SpaceBar> key. Instead of C<PageUp> and C<PageDown> it can be used the mouse wheel
(if supported).

=head1 CONSTRUCTOR

The constructor method C<new> can be called with optional named arguments:

=item defaults

Expects as its value a hash. Sets the defaults for the instance. See L<#OPTIONS>.

=item win

Expects as its value a window object created by ncurses C<initscr>.

If set, C<choose>, C<choose-multi> and C<pause> use this global window instead of creating their own without calling
C<endwin> to restores the terminal before returning.

=head1 ROUTINES

=head2 choose

C<choose> allows the user to choose one item from a list: the highlighted item is returned when C<Return>
is pressed.

C<choose> returns nothing if the C<q> key or C<Ctrl-D> is pressed.

=head2 choose-multi

The user can choose many items.

To choose more than one item mark an item with the C<SpaceBar>. C<choose-multi> then returns the list of the marked
items including the highlighted item.

C<Ctrl-SpaceBar> (or C<Ctrl-@>) inverts the choices: marked items are unmarked and unmarked items are marked. If the
cursor is on the first row, C<Ctrl-SpaceBar> inverts the choices for the whole list else C<Ctrl-SpaceBar> inverts the
choices for the current page.

C<choose-multi> returns nothing if the C<q> key or C<Ctrl-D> is pressed.

=head2 pause

Nothing can be chosen, nothing is returned but the user can move around and read the output until closed with C<Return>,
C<q> or C<Ctrl-D>.

=head1 OUTPUT

For the output on the screen the array elements are modified.

All the modifications are made on a copy of the original array so C<choose> and C<choose-multi> return the chosen
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

This is a C<choose-multi>-only option.

I<mark> expects as its value an array. The elements of the array are list indexes. C<choose> preselects the
list-elements correlating to these indexes.

(default: undefined)

=head2 max-height

If defined sets the maximal number of rows used for printing list items.

If the available height is less than I<max-height>, I<max-height> is set to the available height.

Height in this context means number of print rows.

I<max-height> overwrites I<keep> if I<max-height> is set to a value less than I<keep>.

Allowed values: 1 or greater

(default: undefined)

=head2 max-width

If defined, sets the maximal output width to I<max-width> if the terminal width is greater than I<max-width>.

To prevent the "auto-format" to use a width less than I<max-width> set I<layout> to C<0>.

Width refers here to the number of print columns.

Allowed values: 2 or greater

(default: undefined)

=head2 mouse

0 - no mouse (default)

1 - mouse enabled

=head2 no-spacebar

This is a C<choose-multi>-only option.

I<no-spacebar> expects as its value an array. The elements of the array are indexes of choices which should not be
markable with the C<SpaceBar> or with the right mouse key. If an element is preselected with the option I<mark> and also
marked as not selectable with the option I<no-spacebar>, the user can not remove the preselection of this element.

(default: undefined)

=head2 order

If the output has more than one row and more than one column:

0 - elements are ordered horizontally

1 - elements are ordered vertically (default)

=head2 pad

Sets the number of whitespaces between columns. (default: 2)

Allowed values: 0 or greater

=head2 pad-one-row

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

=head2 libncurses

C<Term::Choose> requires C<libncursesw> to be installed. To overwrite the autodetected ncurses library: specify the
location of the ncurses library by setting the environment variable C<PERL6_NCURSES_LIB>.

If the name of the ncurses library matches C<libncursesw.so.6> C<Term::Choose> expects C<NCURSES_MOUSE_VERSION> E<gt>
C<1>.

=head2 Monospaced font

It is required a terminal that uses a monospaced font which supports the printed characters.

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
