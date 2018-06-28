use v6;

unit class Term::Choose:ver<1.3.0>;

use NCurses;
use Term::Choose::NCursesAdd;
use Term::Choose::LineFold :to-printwidth, :line-fold, :print-columns;

constant R  = 0;
constant C  = 1;

constant CONTROL_SPACE   = 0x00;
constant CONTROL_A       = 0x01;
constant CONTROL_B       = 0x02;
constant CONTROL_D       = 0x04;
constant CONTROL_E       = 0x05;
constant CONTROL_F       = 0x06;
constant CONTROL_H       = 0x08;
constant KEY_TAB         = 0x09;
constant LINE_FEED       = 0x0a;
constant CARRIAGE_RETURN = 0x0d;
constant KEY_SPACE       = 0x20;
constant KEY_h           = 0x68;
constant KEY_j           = 0x6a;
constant KEY_k           = 0x6b;
constant KEY_l           = 0x6c;
constant KEY_q           = 0x71;


has WINDOW $.win;
has Bool   $!reset_win;

subset Positive_Int     of Int where * > 0;
subset Int_2_or_greater of Int where * > 1;
subset Int_0_to_2       of Int where * == 0|1|2;
subset Int_0_or_1       of Int where * == 0|1;

has Int_0_or_1       $.beep                 = 0;
has Int_0_or_1       $.index                = 0;
has Int_0_or_1       $.mouse                = 0;
has Int_0_or_1       $.order                = 1;
has Int_0_or_1       $.page                 = 1;
has Int_0_to_2       $.include-highlighted  = 0;
has Int_0_to_2       $.justify              = 0;
has Int_0_to_2       $.layout               = 1;
has Positive_Int     $.keep                 = 5;
has Positive_Int     $.ll;
has Positive_Int     $.max-height;
has Int_2_or_greater $.max-width;
has UInt             $.default              = 0;
has UInt             $.pad                  = 2;
has List             $.lf;
has List             $.mark;
has List             $.meta-items;
has List             $.no-spacebar;
has Str              $.info                 = '';
has Str              $.prompt;
has Str              $.empty                = '<empty>';
has Str              $.undef                = '<undef>';

has @!orig_list;
has @!list;
has %!o;

has Int   $!term_w;
has Int   $!term_h;
has Int   $!avail_w;
has Int   $!avail_h;
has Int   $!col_w;
has Int   @!w_list;
has Int   $!curr_layout;
has Int   $!rest;
has Int   $!print_pp_row;
has Str   $!pp_row_fmt;
has Str   @!prompt_lines;
has Int   $!row_top;
has Int   $!row_bottom;
has Array $!rc2idx;
has Array $!p;
has Array $!marked;
has Bool  $!ext_mouse;


method num-threads {
    return %*ENV<TC_NUM_THREADS> if %*ENV<TC_NUM_THREADS>;
    # return Kernel.cpu-cores;      # Perl 6.d
    my $proc = run( 'nproc', :out );
    return $proc.out.get.Int || 2;
}


method !_prepare_new_copy_of_list {
    if %!o<ll> {
        @!list = @!orig_list;
        if %!o<ll> > $!avail_w {
            for @!list {
                $_ = to-printwidth( $_, $!avail_w, True ).[0];
            }
            $!col_w = $!avail_w;
        }
        else {
            $!col_w = %!o<ll>;
        }
        @!w_list = $!col_w xx @!list.elems;
    }
    else {
        @!list = ();
        my Int $threads = self.num-threads;
        while $threads > @!orig_list.elems {
            last if $threads < 2;
            $threads = $threads div 2;
        }
        my $size = @!orig_list.elems div $threads;
        my @portions = ( ^$threads ).map: { [ $size * $_, $size * ( $_ + 1 ) ] };
        @portions[*-1][1] = @!orig_list.elems;
        my @promise;
        for @portions -> $range {
            my @cache;
            @promise.push: start {
                do for $range[0] ..^ $range[1] -> $i {
                    if ! @!orig_list[$i].defined {
                        my ( $str, $len ) := to-printwidth(
                            %!o<undef>.subst( / \s /, ' ', :g ).subst( / <:C> /, '',  :g ),
                            $!avail_w,
                            True,
                            @cache
                        );
                        $i, $str, $len;
                    }
                    elsif @!orig_list[$i] eq '' {
                        my ( $str, $len ) := to-printwidth(
                            %!o<empty>.subst( / \s /, ' ', :g ).subst( / <:C> /, '',  :g ),
                            $!avail_w,
                            True,
                            @cache
                        );
                        $i, $str, $len;
                    }
                    else {
                        my ( $str, $len ) := to-printwidth(
                            @!orig_list[$i].subst( / \s /, ' ', :g ).subst( / <:C> /, '',  :g ),
                            $!avail_w,        #                        #
                            True,
                            @cache
                        );
                        $i, $str, $len;
                    }
                }
            };
        }
        @!w_list = ();
        for await @promise -> @portion {
            for @portion {
                @!list[.[0]] := .[1];
                @!w_list[.[0]] := .[2];
            }
        }
        $!col_w = @!w_list.max;
    }
}


sub choose       ( @list, *%opt ) is export( :DEFAULT, :choose )       { Term::Choose.new().choose(       @list, |%opt ) }
sub choose-multi ( @list, *%opt ) is export( :DEFAULT, :choose-multi ) { Term::Choose.new().choose-multi( @list, |%opt ) }
sub pause        ( @list, *%opt ) is export( :DEFAULT, :pause )        { Term::Choose.new().pause(        @list, |%opt ) }

method choose       ( @list, *%opt ) { self!_choose( 0,   @list, |%opt ) }
method choose-multi ( @list, *%opt ) { self!_choose( 1,   @list, |%opt ) }
method pause        ( @list, *%opt ) { self!_choose( Int, @list, |%opt ) }



method !_init_term {
    if ! $!win {
        $!reset_win = True;
        my int32 constant LC_ALL = 6;
        setlocale( LC_ALL, "" );
        $!win = initscr();
    }
    noecho();
    cbreak();
    keypad( $!win, True );
    timeout( 500 );
    if %!o<mouse> {
        my $mm = mousemask( ALL_MOUSE_EVENTS +| REPORT_MOUSE_POSITION, 0 );
        if $mm != 259913695 {
            mousemask( EMM_ALL_MOUSE_EVENTS +| EMM_REPORT_MOUSE_POSITION, 0 );
            $!ext_mouse = True;
        }
        my $mi = mouseinterval( 5 );
    }
    curs_set( 0 );
}


method !_end_term {
    return if ! $!reset_win;
    endwin();
}


method !_choose ( Int $multiselect, @!orig_list,
        Int_0_or_1       :$beep                 = $!beep,

        Int_0_or_1       :$index                = $!index,
        Int_0_or_1       :$mouse                = $!mouse,
        Int_0_or_1       :$order                = $!order,
        Int_0_or_1       :$page                 = $!page,
        Int_0_to_2       :$include-highlighted  = $!include-highlighted,
        Int_0_to_2       :$justify              = $!justify,
        Int_0_to_2       :$layout               = $!layout,
        Positive_Int     :$keep                 = $!keep,
        Positive_Int     :$ll                   = $!ll,
        Positive_Int     :$max-height           = $!max-height,
        Int_2_or_greater :$max-width            = $!max-width,
        UInt             :$default              = $!default,
        UInt             :$pad                  = $!pad,
        List             :$lf                   = $!lf,
        List             :$mark                 = $!mark,
        List             :$meta-items           = $!meta-items,
        List             :$no-spacebar          = $!no-spacebar,
        Str              :$info                 = $!info,
        Str              :$prompt               = $!prompt,
        Str              :$empty                = $!empty,
        Str              :$undef                = $!undef,
    ) {
    if ! @!orig_list.elems {
        return;
    }
    CATCH {
        endwin();
    }
    %!o = :$beep, :$include-highlighted, :$index, :$mouse, :$order, :$page, :$justify, :$layout, :$keep, :$ll, :$max-height,
          :$max-width, :$default, :$pad, :$lf, :$mark, :$meta-items, :$no-spacebar, :$info, :$prompt, :$empty, :$undef;
    if ! %!o<prompt>.defined {
        %!o<prompt> = $multiselect.defined ?? 'Your choice' !! 'Continue with ENTER';
    }
    self!_init_term();
    self!_wr_first_screen( $multiselect );
    my Int $pressed;

    GET_KEY: loop {
        my $key = getch();
        my Int $new_term_w = getmaxx( $!win );
        my Int $new_term_h = getmaxy( $!win );
        if $new_term_w != $!term_w || $new_term_h != $!term_h {
            if %!o<ll> {
                return -1;
            }
            %!o<default> = $!rc2idx[ $!p[R] ][ $!p[C] ]; #
            if $!marked.elems {
                %!o<mark> = self!_marked_rc2idx();
            }
            self!_wr_first_screen( $multiselect );
            next GET_KEY;
        }
        next GET_KEY if $key == ERR;
        if %*ENV<TC_RESET_AUTO_UP>:exists {
            if $key == none( LINE_FEED, CARRIAGE_RETURN) && $key < 361 {
                %*ENV<TC_RESET_AUTO_UP> = 1;
            }
        }

        # $!rc2idx holds the new list (AoA) formatted in "_list_index2rowcol" appropriate to the chosen layout.
        # $!rc2idx does not hold the values directly but the respective list indexes from the original list.
        # If the original list would be ( 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' ) and the new formatted list should be
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
                    self!_beep();
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
                        self!_wr_screen();
                    }
                }
            }
            when KEY_UP | KEY_k {
                if $!p[R] == 0 {
                    self!_beep();
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
                        self!_wr_screen();
                    }
                }
            }
            when KEY_TAB {
                if $!p[R] == $!rc2idx.end && $!p[C] == $!rc2idx[ $!p[R] ].end {
                    self!_beep();
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
                            self!_wr_screen();
                        }
                    }
                }
            }
            when KEY_BACKSPACE | CONTROL_H | KEY_BTAB {
                if $!p[C] == 0 && $!p[R] == 0 {
                    self!_beep();
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
                            $!row_top    = $!row_top - $!avail_h; #
                            $!row_top    = 0 if $!row_top < 0;
                            self!_wr_screen();
                        }
                    }
                }
            }
            when KEY_RIGHT | KEY_l {
                if $!p[C] == $!rc2idx[ $!p[R] ].end {
                    self!_beep();
                }
                else {
                    $!p[C]++;
                    self!_wr_cell( $!p[R], $!p[C] - 1 );
                    self!_wr_cell( $!p[R], $!p[C]     );
                }
            }
            when KEY_LEFT | KEY_h {
                if $!p[C] == 0 {
                    self!_beep();
                }
                else {
                    $!p[C]--;
                    self!_wr_cell( $!p[R], $!p[C] + 1 );
                    self!_wr_cell( $!p[R], $!p[C]     );
                }
            }
            when KEY_PPAGE | CONTROL_B {
                if $!row_top <= 0 {
                    self!_beep();
                }
                else {
                    $!row_top    = $!avail_h * ( $!p[R] div $!avail_h - 1 );
                    $!row_bottom = $!row_top + $!avail_h - 1;
                    $!p[R] -= $!avail_h; # after $!row_top
                    self!_wr_screen();
                }
            }
            when KEY_NPAGE | CONTROL_F {
                if $!row_bottom >= $!rc2idx.end {
                    self!_beep();
                }
                else {
                    $!row_top    = $!avail_h * ( $!p[R] div $!avail_h + 1 );
                    $!row_bottom = $!row_top + $!avail_h - 1;
                    $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
                    $!p[R] += $!avail_h; # after $!row_top
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
                    self!_wr_screen();
                }
            }
            when KEY_HOME | CONTROL_A {
                if $!p[C] == 0 && $!p[R] == 0 {
                    self!_beep();
                }
                else {
                    $!p[R] = 0;
                    $!p[C] = 0;
                    $!row_top    = 0;
                    $!row_bottom = $!row_top + $!avail_h - 1;
                    $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
                    self!_wr_screen();
                }
            }
            when KEY_END | CONTROL_E {
                if %!o<order> == 1 && $!rest {
                    if $!p[R] == $!rc2idx.end - 1 && $!p[C] == $!rc2idx[ $!p[R] ].end {
                        self!_beep();
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
                        self!_wr_screen();
                    }
                }
                else {
                    if $!p[R] == $!rc2idx.end && $!p[C] == $!rc2idx[ $!p[R] ].end {
                        self!_beep();
                    }
                    else {
                        $!p[R] = $!rc2idx.end;
                        $!p[C] = $!rc2idx[ $!p[R] ].end;
                        $!row_top    = $!rc2idx.elems - ( $!rc2idx.elems % $!avail_h || $!avail_h );
                        $!row_bottom = $!rc2idx.end;
                        self!_wr_screen();
                    }
                }
            }
            when KEY_q | CONTROL_D {
                self!_end_term();
                return;
            }
            when LINE_FEED | CARRIAGE_RETURN { # KEY_ENTER
                self!_end_term();
                if ! $multiselect.defined {
                    return;
                }
                elsif $multiselect == 0 {
                    my Int $i = $!rc2idx[ $!p[R] ][ $!p[C] ];
                    return %!o<index> || %!o<ll> ?? $i !! @!orig_list[$i];
                }
                else {
                    if %!o<include-highlighted> == 1 {
                        $!marked[ $!p[R] ][ $!p[C] ] = True;
                    }
                    elsif %!o<include-highlighted> == 2 && ! self!_marked_rc2idx().elems {
                        $!marked[ $!p[R] ][ $!p[C] ] = True;
                    }
                    elsif %!o<meta-items>.defined {
                        for %!o<meta-items>.list -> $meta_item {
                            if $meta_item == $!rc2idx[ $!p[R] ][ $!p[C] ] {
                                $!marked[ $!p[R] ][ $!p[C] ] = True;
                                last;
                            }
                        }
                    }
                    my $indexes = self!_marked_rc2idx();
                    return %!o<index> || %!o<ll> ?? $indexes.list !! @!orig_list[$indexes.list];
                }
            }
            when KEY_SPACE {
                if $multiselect {
                    my Int $locked = 0;
                    OUTER_FOR:
                    for 'meta-items', 'no-spacebar' -> $key {
                        if %!o{$key} {
                            for |%!o{$key} -> $index {
                                if $!rc2idx[ $!p[R] ][ $!p[C] ] == $index {
                                    ++$locked;
                                    last OUTER_FOR;
                                }
                            }
                        }
                    }
                    if $locked {
                        self!_beep();
                    }
                    else {
                        $!marked[ $!p[R] ][ $!p[C] ] = ! $!marked[ $!p[R] ][ $!p[C] ];
                        self!_wr_cell( $!p[R], $!p[C] );
                    }
                }
            }
            when CONTROL_SPACE {
                if $multiselect {
                    for ^$!rc2idx -> $row {
                        for ^$!rc2idx[$row] -> $col {
                            $!marked[$row][$col] = ! $!marked[$row][$col];
                        }
                    }
                    if %!o<no-spacebar> {
                        self!_marked_idx2rc( $no-spacebar, False );
                    }
                    self!_wr_screen();
                }
                else {
                    self!_beep();
                }
            }
            when KEY_MOUSE {
                my NCurses::MEVENT $event .= new;
                if getmouse( $event ) == OK {
                    if $!ext_mouse {
                        if $event.bstate == EMM_BUTTON1_CLICKED | EMM_BUTTON1_PRESSED {
                            my $ret = self!_mouse_xy2pos( $event.x, $event.y );
                            if $ret {
                                ungetch( LINE_FEED ); #
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
                                ungetch( LINE_FEED ); #
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
                self!_beep();
            }
        }
        nc_refresh();
    }
}


method !_mouse_xy2pos ( Int $abs_mouse_x, Int $abs_mouse_y ) {
    my Int $abs_y_of_top_row = @!prompt_lines.elems;
    if $abs_mouse_y < $abs_y_of_top_row {
        return;
    }
    my Int $mouse_row = $abs_mouse_y - $abs_y_of_top_row;
    my Int $mouse_col = $abs_mouse_x;
    if $mouse_row > $!rc2idx.end {
        return;
    }
    my Int $row = $mouse_row + $!row_top;
    my Int $matched_col;
    my Int $end_prev_col = 0;
    COL: for ^$!rc2idx[$row] -> $col {
        my Int $end_this_col = $end_prev_col
                             + ( $!rc2idx.end == 0 ?? print-columns( @!list[$!rc2idx[0][$col]] ) !! $!col_w )
                             + %!o<pad>;
        if $col == 0 {
            $end_this_col -= %!o<pad> div 2;
        }
        if $col == $!rc2idx[$row].end && $end_this_col > $!avail_w {
            $end_this_col = $!avail_w;
        }
        if $end_prev_col < $mouse_col && $end_this_col >= $mouse_col {
            $matched_col = $col;
            last COL;
        }
        $end_prev_col = $end_this_col;
    }
    if ! $matched_col.defined {
        return;
    }
    if $row != $!p[R] || $matched_col != $!p[C] {
        my Array $not_p = $!p;
        $!p = [ $row, $matched_col ];
        self!_wr_cell( $not_p[0], $not_p[1] );
        self!_wr_cell( $!p[R]   , $!p[C]    );
    }
    return 1;
}


method !_beep {
    beep() if %!o<beep>;
}


method !_prepare_prompt {
    my @tmp;
    @tmp.push: %!o<info>   if %!o<info>.chars;   # documentation  %*ENV<TC_RESET_AUTO_UP>;
    @tmp.push: %!o<prompt> if %!o<prompt>.chars;
    if ! @tmp.elems {
        @!prompt_lines = ();
        return;
    }
    my Int $init   = %!o<lf>[0] // 0;
    my Int $subseq = %!o<lf>[1] // 0;
    @!prompt_lines = line-fold( @tmp.join( "\n" ), $!avail_w, ' ' x $init, ' ' x $subseq );
    my Int $keep = %!o<keep> + $!print_pp_row;
    $keep = $!term_h if $keep > $!term_h;
    if @!prompt_lines.elems + $keep > $!avail_h {
        @!prompt_lines.splice( 0, @!prompt_lines.elems + $keep - $!avail_h );
    }
    if @!prompt_lines.elems {
        $!avail_h -= @!prompt_lines.elems;
    }
}


method !_pos_to_default {
    ROW: for ^$!rc2idx -> $row {
        COL: for ^$!rc2idx[$row] -> $col {
            if %!o<default> == $!rc2idx[$row][$col] {
                $!p = [ $row, $col ];
                last ROW;
            }
        }
    }
    $!row_top    = $!avail_h * ( $!p[R] div $!avail_h );
    $!row_bottom = $!row_top + $!avail_h - 1;
    $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
}


method !_wr_first_screen ( Int $multiselect ) {
    $!term_w = getmaxx( $!win );
    $!term_h = getmaxy( $!win );
    ( $!avail_w, $!avail_h ) = ( $!term_w, $!term_h );
    if %!o<max-width> && $!avail_w > %!o<max-width> {
        $!avail_w = %!o<max-width>;
    }
    if $!avail_w < 2 {
        die "Terminal width to small!";
    }
    $!print_pp_row = %!o<page>;
    self!_prepare_new_copy_of_list();
    self!_prepare_prompt();
    if %!o<max-height> && %!o<max-height> < $!avail_h {
        $!avail_h = %!o<max-height>;
    }
    $!curr_layout = %!o<layout>;
    self!_list_index2rowcol();
    if %!o<page> {
        self!_set_pp_print_fmt;
    }
    $!row_top    = 0;
    $!row_bottom = $!avail_h - 1;
    $!row_bottom = $!rc2idx.end if $!row_bottom > $!rc2idx.end;
    $!p = [ 0, 0 ];
    $!marked = [];
    if %!o<mark> && $multiselect {
        self!_marked_idx2rc( %!o<mark>, True ); #
    }
    if %!o<default>.defined && %!o<default> <= @!list.end {
        self!_pos_to_default();
    }
    clear();
    for ^@!prompt_lines -> $row { # if
        mvaddstr( $row, 0, @!prompt_lines[$row] );
    }
    self!_wr_screen();
    nc_refresh();
}

method !_set_pp_print_fmt {
    if $!rc2idx.end / $!avail_h > 1 {
        $!avail_h -= $!print_pp_row;
        my $total_pp = $!rc2idx.end div $!avail_h + 1;
        my $pp_w = $total_pp.chars;
        $!pp_row_fmt = "--- Page \%0{$pp_w}d/{$total_pp} ---";
        if sprintf( $!pp_row_fmt, $total_pp ).chars > $!avail_w {
            $!pp_row_fmt = "\%0{$pp_w}d/{$total_pp}";
            if sprintf( $!pp_row_fmt, $total_pp ).chars > $!avail_w {
                $pp_w = $!avail_w if $pp_w > $!avail_w;
                $!pp_row_fmt = "\%0{$pp_w}.{$pp_w}s";
            }
        }
    }
    else {
        $!print_pp_row = 0;
    }
}

method !_wr_screen {
    move( @!prompt_lines.elems, 0 );
    clrtobot();
    if $!print_pp_row {
        my Str $pp_row = sprintf $!pp_row_fmt, $!row_top div $!avail_h + 1;
        mvaddstr(
            $!avail_h + @!prompt_lines.elems,
            0,
            $pp_row
        );
     }
    for $!row_top .. $!row_bottom -> $row {
        for ^$!rc2idx[$row] -> $col {
            self!_wr_cell( $row, $col );
        }
    }
    self!_wr_cell( $!p[R], $!p[C] );
}

method !_wr_cell ( Int $row, Int $col ) {
    my Bool $is_current_pos = $row == $!p[R] && $col == $!p[C];
    my Int $i = $!rc2idx[$row][$col];
    if $!rc2idx.end == 0 && $!rc2idx[0].end > 0 {
        my Int $lngth = 0;
        if $col > 0 {
            for ^$col -> $c { #
                $lngth += print-columns( @!list[ $!rc2idx[$row][$c] ] );
                $lngth += %!o<pad>;
            }
        }
        attron( A_BOLD +| A_UNDERLINE ) if $!marked[$row][$col];
        attron( A_REVERSE )             if $is_current_pos;
        mvaddstr(
            $row - $!row_top + @!prompt_lines.elems,
            $lngth,
            @!list[$i]
        );
    }
    else {
        attron( A_BOLD +| A_UNDERLINE ) if $!marked[$row][$col];
        attron( A_REVERSE )             if $is_current_pos;
        mvaddstr(
            $row - $!row_top + @!prompt_lines.elems,
            ( $!col_w + %!o<pad> ) * $col,
            self!_pad_str_to_colwidth( $i )
        );
    }
    attroff( A_BOLD +| A_UNDERLINE ) if $!marked[$row][$col];
    attroff( A_REVERSE )             if $is_current_pos;
}


method !_pad_str_to_colwidth ( Int $i ) {
    my Int $str_w = @!w_list[$i];
    if $str_w < $!col_w {
        if %!o<justify> == 0 {
            return @!list[$i] ~ " " x ( $!col_w - $str_w );
        }
        elsif %!o<justify> == 1 {
            return " " x ( $!col_w - $str_w ) ~ @!list[$i];
        }
        elsif %!o<justify> == 2 {
            my Int $fill = $!col_w - $str_w;
            my Int $half_fill = $fill div 2;
            return " " x $half_fill ~ @!list[$i] ~ " " x ( $fill - $half_fill );
        }
    }
    else {
        return @!list[$i] ~ "";
    }
}


method !_list_index2rowcol {
    $!rc2idx = [];
    if $!col_w + %!o<pad> >= $!avail_w {
        $!curr_layout = 2;
    }
    my Str $all_in_first_row = '';
    if $!curr_layout == 0|1 {
        for ^@!list -> $i {
            $all_in_first_row ~= @!list[$i];
            $all_in_first_row ~= ' ' x %!o<pad> if $i < @!list.end;
            if print-columns( $all_in_first_row ) > $!avail_w {
                $all_in_first_row = '';
                last;
            }
        }
    }
    if $all_in_first_row {
        $!rc2idx[0] = [ ^@!list ];
    }
    elsif $!curr_layout == 2 {
        for ^@!list -> $i {
            $!rc2idx[$i][0] = $i;
        }
    }
    else {
        my Int $col_with_pad_w = $!col_w + %!o<pad>;
        my Int $tmp_avail_w = $!avail_w + %!o<pad>;
        # auto_format
        if $!curr_layout == 1 {
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
            my Int $nr_of_rows = ( @!list.elems - 1 + $cols_per_row ) div $cols_per_row; #
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
                $end = @!list.end if $end > @!list.end;
                $!rc2idx.push( [ $begin .. $end ] );
            }
        }
    }
}


method !_marked_idx2rc ( List $indexes, Bool $yesno ) {
    if $!curr_layout == 2 {
        for $indexes.list -> $i {
            next if $i > @!list.end;
            $!marked[$i][0] = $yesno;
        }
        return;
    }
    my ( Int $row, Int $col );
    my Int $cols_per_row = $!rc2idx[0].elems;
    if %!o<order> == 0 {
        for $indexes.list -> $i {
            next if $i > @!list.end;
            $row = $i div $cols_per_row;
            $col = $i % $cols_per_row;
            $!marked[$row][$col] = $yesno;
        }
    }
    elsif %!o<order> == 1 {
        my Int $rows_per_col = $!rc2idx.elems;
        my Int $end_last_full_col = $rows_per_col * ( $!rest || $cols_per_row );
        for $indexes.list -> $i {
            next if $i > @!list.end;
            if $i <= $end_last_full_col {
                $row = $i % $rows_per_col;
                $col = $i div $rows_per_col;
            }
            else {
                my Int $rows_per_short_col = $rows_per_col - 1;
                $row = ( $i - $end_last_full_col ) % $rows_per_short_col;
                $col = ( $i - $!rest ) div $rows_per_short_col;
            }
            $!marked[$row][$col] = $yesno;
        }
    }
}

method !_marked_rc2idx {
    my Int @idx;
    if %!o<order> == 1 {
        for ^$!rc2idx[0] -> $col {
            for ^$!rc2idx -> $row {
                @idx.push( $!rc2idx[$row][$col] ) if $!marked[$row][$col];
            }
        }
    }
    else {
        for ^$!rc2idx -> $row {
            for ^$!rc2idx[$row] -> $col {
                @idx.push( $!rc2idx[$row][$col] ) if $!marked[$row][$col];
            }
        }
    }
    return @idx;
}



=begin pod

=head1 NAME

Term::Choose - Choose items from a list interactively.

=head1 SYNOPSIS

    use Term::Choose :choose;

    my @list = <one two three four five>;


    # Functional interface:
 
    my $chosen = choose( @list, :layout(2) );


    # OO interface:
 
    my $tc = Term::Choose.new( :1mouse, :0order ) );

    $chosen = $tc.choose( @list, :1layout, :2default );

=head1 DESCRIPTION

Choose interactively from a list of items.

For C<choose>, C<choose-multi> and C<pause> the first argument holds the list of the available choices.

The different options can be passed as key-values pairs. See L<#OPTIONS> to find the available options.

The return values are described in L<#Routines>

=head1 USAGE

To browse through the available list-elements use the keys described below.

If the items of the list don't fit on the screen, the user can scroll to the next (previous) page(s).

If the window size is changed, the screen is rewritten.

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

With I<mouse> enabled use the the left mouse key instead the C<Return> key and the right mouse key instead of the
C<SpaceBar> key. Instead of C<PageUp> and C<PageDown> it can be used the mouse wheel. The mouse wheel only works, if the
ncurses library supports the extended mouse mode.

=head1 CONSTRUCTOR

The constructor method C<new> can be called with named arguments. For the valid options see L<#OPTIONS>. Setting the
options in C<new> overwrites the default values for the instance.

Additionally to the options mentioned below one can set the option L<win>. The opton L<win> expects as its value a
C<WINDOW> object - the return value of L<NCurses> C<initscr>.

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

C<Ctrl-SpaceBar> (or C<Ctrl-@>) inverts the choices: marked items are unmarked and unmarked items are marked.

C<choose-multi> returns nothing if the C<q> key or C<Ctrl-D> is pressed.

=head2 pause

Nothing can be chosen, nothing is returned but the user can move around and read the output until closed with C<Return>,
C<q> or C<Ctrl-D>.

=head1 OUTPUT

For the output on the screen the elements of the list are copied and then modified. Chosen elements are returned as they
were passed without modifications.

Modifications:

If an element is not defined, the value from the option I<undef> is assigned to the element. If an element holds an
empty string, the value from the option I<empty> is assigned to the element.

White-spaces in elements are replaced with simple spaces: C<$_ =~ s:g/\s/ />. Invalid characers (Unicode character
proterty C<Other>) are removed: C<$_=~ s:g/\p{C}//>.

If the length (print columns) of an element is greater than the width of the screen the element is cut and three dots
are attached.

=head1 OPTIONS

Options which expect a number as their value expect integers.

=head3 beep

0 - off (default)

1 - on

=head3 default

With the option I<default> it can be selected an element, which will be highlighted as the default instead of the first
element.

I<default> expects a zero indexed value, so e.g. to highlight the third element the value would be I<2>.

If the passed value is greater than the index of the last array element, the first element is highlighted.

Allowed values: 0 or greater

(default: undefined)

=head3 empty

Sets the string displayed on the screen instead an empty string.

default: "E<lt>emptyE<gt>"

=head3 info

Expects as its value a string. The string is printed above the prompt string.

=head3 index

0 - off (default)

1 - return the indices of the chosen elements instead of the chosen elements.

This option has no meaning for C<pause>.

=head3 justify

0 - elements ordered in columns are left-justified (default)

1 - elements ordered in columns are right-justified

2 - elements ordered in columns are centered

=head3 keep

I<keep> prevents that all the terminal rows are used by the prompt lines.

Setting I<keep> ensures that at least I<keep> terminal rows are available for printing "list"-rows.

If the terminal height is less than I<keep>, I<keep> is set to the terminal height.

Allowed values: 1 or greater

(default: 5)

=head3 layout

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

=head3 lf

If I<prompt> lines are folded, the option I<lf> allows one to insert spaces at beginning of the folded lines.

The option I<lf> expects a list with one or two elements:

- the first element (C<INITIAL_TAB>) sets the number of spaces inserted at beginning of paragraphs

- a second element (C<SUBSEQUENT_TAB>) sets the number of spaces inserted at the beginning of all broken lines apart
from the beginning of paragraphs

Allowed values for the two elements are: 0 or greater.

(default: undefined)

=head3 max-height

If defined sets the maximal number of rows used for printing list items.

If the available height is less than I<max-height>, I<max-height> is set to the available height.

Height in this context means number of print rows.

I<max-height> overwrites I<keep> if I<max-height> is set to a value less than I<keep>.

Allowed values: 1 or greater

(default: undefined)

=head3 max-width

If defined, sets the maximal output width to I<max-width> if the terminal width is greater than I<max-width>.

To prevent the "auto-format" to use a width less than I<max-width> set I<layout> to C<0>.

Width refers here to the number of print columns.

Allowed values: 2 or greater

(default: undefined)

=head3 mouse

0 - no mouse (default)

1 - mouse enabled

=head3 order

If the output has more than one row and more than one column:

0 - elements are ordered horizontally

1 - elements are ordered vertically (default)

=head3 pad

Sets the number of whitespaces between columns. (default: 2)

Allowed values: 0 or greater

=head3 page

0 - off

1 - print the page number on the bottom of the screen if there is more then one page. (default)

=head3 prompt

If I<prompt> is undefined, a default prompt-string will be shown.

If the I<prompt> value is an empty string (""), no prompt-line will be shown.

=head3 undef

Sets the string displayed on the screen instead an undefined element.

default: "E<lt>undefE<gt>"

=head2 options choose-multi

=head3 include-highlighted

0 - C<choose-multi> returns the items marked with the C<SpaceBar>. (default)

1 - C<choose-multi> returns the items marked with the C<SpaceBar> plus the highlighted item.

2 - C<choose-multi> returns the items marked with the C<SpaceBar>. If no items are marked with the C<SpaceBar>, the
highlighted item is returned.

=head3 mark

I<mark> expects as its value a list of indexes (integers). C<choose-multi> preselects the list-elements correlating to
these indexes.

(default: undefined)

=head3 meta-items

I<meta_items> expects as its value a list of indexes (integers). List-elements correlating to these indexes can not be
marked with the C<SpaceBar> or with the right mouse key but if one of these elements is the highlighted item it is added
to the chosen items when C<Return> is pressed.

Elements greater than the last index of the list are ignored.

(default: undefined)

=head3 no-spacebar

I<no-spacebar> expects as its value an list. The elements of the list are indexes of choices which should not be
markable with the C<SpaceBar> or with the right mouse key. If an element is preselected with the option I<mark> and also
marked as not selectable with the option I<no-spacebar>, the user can not remove the preselection of this element.

(default: undefined)

=head1 ENVIRONMET VARIABLES

=head2 multithreading

C<Term::Choose> uses multithreading when preparing the list for the output; the number of threads to use can be set with
the environment variable C<TC_NUM_THREADS>.

The method C<num-threads> returns the setting used by C<Term::Choose>.

=head2 libncurses

The location of the used ncurses library can be specified by setting the environment variable C<PERL6_NCURSES_LIB>. This
will overwrite the default library location.

=head1 REQUIREMENTS

=head2 libncurses

C<Term::Choose> requires C<libncurses> to be installed. If the list elements contain wide characters it is required
an approprirate ncurses library else wide character will break the output.

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

Copyright (C) 2016-2018 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
