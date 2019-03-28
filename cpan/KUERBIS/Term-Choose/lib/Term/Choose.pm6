use v6;

unit class Term::Choose:ver<1.5.1>;

use Term::termios;

use Term::Choose::ReadKey :read-key;
use Term::Choose::Screen :ALL;
use Term::Choose::LineFold :to-printwidth, :line-fold, :print-columns;


constant R  = 0;
constant C  = 1;

subset Positive_Int     of Int where * > 0;
subset Int_2_or_greater of Int where * > 1;
subset Int_0_to_2       of Int where * == 0|1|2;
subset Int_0_or_1       of Int where * == 0|1;

has Int_0_or_1       $.page                 = 0; # removed 26.03.2019 

has Int_0_or_1       $.beep                 = 0;
has Int_0_or_1       $.index                = 0;
has Int_0_or_1       $.mouse                = 0;
has Int_0_or_1       $.order                = 1;
has Int_0_or_1       $.loop                 = 0; # documentation
has Int_0_or_1       $.hide-cursor          = 1;
has Int_0_to_2       $.clear-screen         = 0; # documentation: 2 -> alternate screen
has Int_0_to_2       $.include-highlighted  = 0;
has Int_0_to_2       $.justify              = 0;
has Int_0_to_2       $.layout               = 1;
has Positive_Int     $.keep                 = 5;
has Positive_Int     $.ll;
has Positive_Int     $.max-height;
has Int_2_or_greater $.max-width;
has UInt             $.default              = 0;
has UInt             $.pad                  = 2;
has List             $.lf; #
has List             $.mark;
has List             $.meta-items;
has List             $.no-spacebar;
has Str              $.info                 = '';
has Str              $.prompt;
has Str              $.empty                = '<empty>';
has Str              $.undef                = '<undef>';

has Int $!i_col;
has Int $!i_row;
has $!saved_termios;

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
has Int   $!page_count;
has Str   $!pp_row_fmt;
has Str   @!prompt_lines;
has Int   $!begin_p;
has Int   $!end_p;
has Array $!rc2idx;
has Array $!p;
has Array $!marked;
has Int   $!page_step;
has Int   $!cursor_row;


method !_init_term {
    $!saved_termios := Term::termios.new(fd => 1).getattr;
    my $termios := Term::termios.new(fd => 1).getattr;
    #$termios.makeraw;
    # like makeraw:
    $termios.unset_iflags(<BRKINT ICRNL ISTRIP IXON>);
    $termios.set_oflags(<ONLCR>);
    $termios.set_cflags(<CS8>);
    $termios.unset_lflags(<ECHO ICANON IEXTEN ISIG>);
    # ISIG: When any of the characters INTR, QUIT, SUSP, or DSUSP are
    #       received, generate the corresponding signal.
    $termios.setattr(:DRAIN);
    if %!o<clear-screen> == 2 {
        save-screen;
    }
    if %!o<hide-cursor> && ! $!loop {
        hide-cursor;
    }
    if %!o<mouse> {
        set-mouse1003;
        set-mouse1006;
    }
}


method !_end_term {
    if %!o<mouse> {
        unset-mouse1003;
        unset-mouse1006;
    }
    $!saved_termios.setattr(:DRAIN);
    if %!o<clear-screen> == 2 {
        restore-screen;
    }
    else {
        print "\r";
        my $up = $!i_row + @!prompt_lines.elems;
        print "\e[{$up}A" if $up;
        clr-to-bot()      if ! $!loop;
    }
    if %!o<hide-cursor> && ! $!loop {
        show-cursor;
    }
}


method !_prepare_new_copy_of_list {
    if %!o<ll> {
        @!list = @!orig_list;
        $!col_w = %!o<ll>;
    }
    else {
        my Int $threads = num-threads();
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
                        my ( $str, $len ) = to-printwidth(
                            %!o<undef>.subst( / \t /,  ' ', :g ).subst( / \v+ /,  '  ', :g ).subst( / <:Cc+:Noncharacter_Code_Point+:Cs> /, '', :g ),
                            $!avail_w,
                            True,
                            @cache
                        );
                        $i, $str, $len;
                    }
                    elsif @!orig_list[$i] eq '' {
                        my ( $str, $len ) = to-printwidth(
                            %!o<empty>.subst( / \t /,  ' ', :g ).subst( / \v+ /,  '  ', :g ).subst( / <:Cc+:Noncharacter_Code_Point+:Cs> /, '', :g ),
                            $!avail_w,
                            True,
                            @cache
                        );
                        $i, $str, $len;
                    }
                    else {
                        my ( $str, $len ) = to-printwidth(
                            @!orig_list[$i].subst( / \t /,  ' ', :g ).subst( / \v+ /,  '  ', :g ).subst( / <:Cc+:Noncharacter_Code_Point+:Cs> /, '', :g ),
                            $!avail_w,
                            True,
                            @cache
                        );
                        $i, $str, $len;
                    }
                }
            };
        }
        @!list = ();
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

method !_beep {
    print "\a" if %!o<beep>;
}


method !_prepare_prompt {
    my @tmp;
    @tmp.push: %!o<info>   if %!o<info>.chars;
    @tmp.push: %!o<prompt> if %!o<prompt>.chars;
    if ! @tmp.elems {
        @!prompt_lines = ();
        return;
    }
    my Int $init   = %!o<lf>[0] // 0;
    my Int $subseq = %!o<lf>[1] // 0;
    @!prompt_lines = line-fold( @tmp.join( "\n" ), $!avail_w, ' ' x $init, ' ' x $subseq );
    my Int $keep = %!o<keep>;
    $keep += 1       if $!rc2idx.elems / $!avail_h > 1; ##
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
    $!begin_p = $!avail_h * ( $!p[R] div $!avail_h );
    $!end_p   = $!begin_p + $!avail_h - 1;
    $!end_p   = $!rc2idx.end if $!end_p > $!rc2idx.end;
}


method !_set_pp_print_fmt {
    if $!rc2idx.elems / $!avail_h > 1 {
        $!avail_h -= 1;
        $!page_count = $!rc2idx.end div $!avail_h + 1;
        my $page_count_w = $!page_count.chars;
        $!pp_row_fmt = "--- Page \%0{$page_count_w}d/{$!page_count} ---";
        if sprintf( $!pp_row_fmt, $!page_count ).chars > $!avail_w {
            $!pp_row_fmt = "\%0{$page_count_w}d/{$!page_count}";
            if sprintf( $!pp_row_fmt, $!page_count ).chars > $!avail_w {
                $page_count_w = $!avail_w if $page_count_w > $!avail_w;
                $!pp_row_fmt = "\%0{$page_count_w}.{$page_count_w}s";
            }
        }
    }
    else {
        $!page_count = 1;
    }
}


method !_pad_str_to_colwidth ( Int $i ) {
    if %!o<ll> { # if set ll, all elements must have the same length
        return @!list[$i];
    }
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
        return @!list[$i];
    }
}


method !_mouse_info_to_key ( Int $abs_cursor_Y, Int $button, Int $abs_mouse_X, Int $abs_mouse_Y ) {
    if $button == 4 {
        return 'PageUp';
    }
    elsif $button == 5 {
        return 'PageDown';
    }
    # $abs_cursor_Y, $abs_mouse_X, $abs_mouse_Y, $abs_Y_top_row: base index = 1
    my Int $abs_Y_top_row = $abs_cursor_Y - $!cursor_row;
    if $abs_mouse_Y < $abs_Y_top_row {
        return;
    }
    my Int $mouse_Y = $abs_mouse_Y - $abs_Y_top_row;
    my Int $mouse_X = $abs_mouse_X;
    if $mouse_Y > $!rc2idx.end {
        return;
    }
    my $matched_col;
    my $end_prev_col = 0;
    my $row = $mouse_Y + $!begin_p;

    COL: for ^$!rc2idx[$row] -> $col {
        my Int $end_this_col;
        if $!rc2idx.end == 0 {
            my $idx = $!rc2idx[$row][$col];
            $end_this_col = $end_prev_col + print-columns( @!list[$idx] ) + %!o<pad>;
        }
        else { #
            $end_this_col = $end_prev_col + $!col_w + %!o<pad>;
        }
        if $col == 0 {
            $end_this_col -= %!o<pad> div 2;
        }
        if $col == $!rc2idx[$row].end && $end_this_col > $!avail_w {
            $end_this_col = $!avail_w;
        }
        if $end_prev_col < $mouse_X && $end_this_col >= $mouse_X {
            $matched_col = $col;
            last COL;
        }
        $end_prev_col = $end_this_col;
    }
    if ! $matched_col.defined {
        return;
    }
    if $button == 1 {
        $!p[R] = $row;
        $!p[C] = $matched_col;
        return '^M';
    }
    if $row != $!p[R] || $matched_col != $!p[C] {
        my $tmp_p = $!p;
        $!p = [ $row, $matched_col ];
        self!_wr_cell( $tmp_p[R], $tmp_p[C] );
        self!_wr_cell( $!p[R], $!p[C] );
    }
    if $button == 3 {
        return ' ';
    }
    else {
        return;
    }
}


sub choose       ( @list, *%opt ) is export( :DEFAULT, :choose )       { Term::Choose.new().choose(       @list, |%opt ) }
sub choose-multi ( @list, *%opt ) is export( :DEFAULT, :choose-multi ) { Term::Choose.new().choose-multi( @list, |%opt ) }
sub pause        ( @list, *%opt ) is export( :DEFAULT, :pause )        { Term::Choose.new().pause(        @list, |%opt ) }

method choose       ( @list, *%opt ) { self!_choose( 0,   @list, |%opt ) }
method choose-multi ( @list, *%opt ) { self!_choose( 1,   @list, |%opt ) }
method pause        ( @list, *%opt ) { self!_choose( Int, @list, |%opt ) }


method !_choose ( Int $multiselect, @!orig_list,

        Int_0_or_1       :$page                 = $!page, # removed 26.03.2019

        Int_0_or_1       :$beep                 = $!beep,
        Int_0_or_1       :$index                = $!index,
        Int_0_or_1       :$mouse                = $!mouse,
        Int_0_or_1       :$order                = $!order,
        Int_0_or_1       :$hide-cursor          = $!hide-cursor,
        Int_0_to_2       :$clear-screen         = $!clear-screen, # 2
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
    # %!o: make options available in methods
    %!o = :$beep, :$include-highlighted, :$index, :$mouse, :$order, :$clear-screen, :$justify, :$layout, :$keep, :$ll, :$max-height,
          :$max-width, :$default, :$pad, :$lf, :$mark, :$meta-items, :$no-spacebar, :$info, :$prompt, :$empty, :$undef, :$hide-cursor;
    if ! %!o<prompt>.defined {
        %!o<prompt> = $multiselect.defined ?? 'Your choice' !! 'Continue with ENTER';
    }
    self!_init_term();
    self!_wr_first_screen( $multiselect );
    #if %!o<ll> && %!o<ll> > $!avail_w {
    #    return -2; #
    #}
    my $fast_page = 10;
    if $!page_count > 10_000 {
        $fast_page = 20;
    }
    my Array $saved_pos;

    READ_KEY: loop {
        my $c = read-key( %!o<mouse> );
        if $c ~~ Array {
            $c = self!_mouse_info_to_key( |$c );
        }
        next READ_KEY if ! $c.defined;
        next READ_KEY if $c eq '~'; #
        my ( Int $new_term_w, Int $new_term_h ) = get-term-size();
        if $new_term_w != $!term_w || $new_term_h != $!term_h { #
            if %!o<ll> {
                return -1;
            }
            %!o<default> = $!rc2idx[ $!p[R] ][ $!p[C] ];
            if $!marked.elems {
                %!o<mark> = self!_marked_rc2idx();
            }
            self!_end_term();  #
            self!_init_term(); #
            self!_wr_first_screen( $multiselect );
            next READ_KEY;
        }
        $!page_step = 1;
        if $c eq  'Insert' {
            if $!begin_p - $fast_page * $!avail_h >= 0 {
                $!page_step = $fast_page;
            }
            $c = 'PageUp';
        }
        elsif $c eq 'Delete' {
            if $!end_p + $fast_page * $!avail_h <= $!rc2idx.end {
                $!page_step = $fast_page;
            }
            $c = 'PageDown';
        }
        if %*ENV<TC_RESET_AUTO_UP>:exists {   # documentation
            if $c ne '^M' {
                %*ENV<TC_RESET_AUTO_UP> = 1;
            }
        }
        if $saved_pos && $c eq none <PageUp ^B PageDown ^F> {
            $saved_pos = Array;
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

        given $c {
            when 'CursorDown' | 'j' {
                if ! $!rc2idx[ $!p[R]+1 ] || ! $!rc2idx[ $!p[R]+1 ][ $!p[C] ] {
                    self!_beep();
                }
                else {
                    $!p[R]++;
                    self!_wr_cell( $!p[R] - 1, $!p[C] ); #
                    if $!p[R] <= $!end_p {
                        #self!_wr_cell( $!p[R] - 1, $!p[C] );
                        self!_wr_cell( $!p[R]    , $!p[C] );
                    }
                    else {
                        $!begin_p = $!end_p + 1;
                        $!end_p   = $!end_p + $!avail_h;
                        $!end_p   = $!rc2idx.end if $!end_p > $!rc2idx.end;
                        self!_wr_screen();
                    }
                }
            }
            when 'CursorUp' | 'k' {
                if $!p[R] == 0 {
                    self!_beep();
                }
                else {
                    $!p[R]--;
                    self!_wr_cell( $!p[R] + 1, $!p[C] ); #
                    if $!p[R] >= $!begin_p {
                        #self!_wr_cell( $!p[R] + 1, $!p[C] );
                        self!_wr_cell( $!p[R]    , $!p[C] );
                    }
                    else {
                        $!end_p   = $!begin_p - 1;
                        $!begin_p = $!begin_p - $!avail_h;
                        $!begin_p = 0 if $!begin_p < 0;
                        self!_wr_screen();
                    }
                }
            }
            when 'CursorRight' | 'l' {
                if $!p[C] == $!rc2idx[ $!p[R] ].end {
                    self!_beep();
                }
                else {
                    $!p[C]++;
                    self!_wr_cell( $!p[R], $!p[C] - 1 );
                    self!_wr_cell( $!p[R], $!p[C]     );
                }
            }
            when 'CursorLeft' | 'h' {
                if $!p[C] == 0 {
                    self!_beep();
                }
                else {
                    $!p[C]--;
                    self!_wr_cell( $!p[R], $!p[C] + 1 );
                    self!_wr_cell( $!p[R], $!p[C]     );
                }
            }

            when '^I' { # Tab
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
                        self!_wr_cell( $!p[R] - 1, $!rc2idx[ $!p[R]-1 ].end ); #
                        if $!p[R] <= $!end_p {
                            #self!_wr_cell( $!p[R] - 1, $!rc2idx[ $!p[R]-1 ].end );
                            self!_wr_cell( $!p[R]    , $!p[C]                   );
                        }
                        else {
                            $!begin_p = $!end_p + 1;
                            $!end_p   = $!end_p + $!avail_h;
                            $!end_p   = $!rc2idx.end if $!end_p > $!rc2idx.end;
                            self!_wr_screen();
                        }
                    }
                }
            }
            when 'Backspace' | '^H' {
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
                        self!_wr_cell( $!p[R] + 1, 0      ); #
                        if $!p[R] >= $!begin_p {
                            #self!_wr_cell( $!p[R] + 1, 0      );
                            self!_wr_cell( $!p[R]    , $!p[C] );
                        }
                        else {
                            $!end_p   = $!begin_p - 1;
                            $!begin_p = $!begin_p - $!avail_h; #
                            $!begin_p = 0 if $!begin_p < 0;
                            self!_wr_screen();
                        }
                    }
                }
            }
            when 'PageUp' | '^B' {
                if $!begin_p <= 0 {
                    self!_beep();
                }
                else {
                    $!begin_p    = $!avail_h * ( $!p[R] div $!avail_h - $!page_step );
                    $!end_p = $!begin_p + $!avail_h - 1;
                    if $saved_pos {
                        $!p[R] = $saved_pos[R] + $!begin_p;
                        $!p[C] = $saved_pos[C];
                        $saved_pos = Array;
                    }
                    else {
                        $!p[R] -= $!avail_h * $!page_step; # after $!begin_p
                    }
                    self!_wr_screen();
                }
            }
            when 'PageDown' | '^F' {
                if $!end_p >= $!rc2idx.end {
                    self!_beep();
                }
                else {
                    my $backup_row_top = $!begin_p;
                    $!begin_p = $!avail_h * ( $!p[R] div $!avail_h + $!page_step );
                    $!end_p   = $!begin_p + $!avail_h - 1;
                    $!end_p   = $!rc2idx.end if $!end_p > $!rc2idx.end;
                    if $!p[R] + $!avail_h > $!rc2idx.end || $!p[C] > $!rc2idx[$!p[R] + $!avail_h].end {
                        $saved_pos = [ $!p[R] - $backup_row_top, $!p[C] ];
                        $!p[R] = $!rc2idx.end;
                        if $!p[C] > $!rc2idx[$!p[R]].end {
                            $!p[C] = $!rc2idx[$!p[R]].end;
                        }
                    }
                    else {
                        $!p[R] += $!avail_h * $!page_step;
                    }
                    self!_wr_screen();
                }
            }
            when 'CursorHome' | '^A' {
                if $!p[C] == 0 && $!p[R] == 0 {
                    self!_beep();
                }
                else {
                    $!p[R] = 0;
                    $!p[C] = 0;
                    $!begin_p = 0;
                    $!end_p   = $!begin_p + $!avail_h - 1;
                    $!end_p   = $!rc2idx.end if $!end_p > $!rc2idx.end;
                    self!_wr_screen();
                }
            }
            when 'CursorEnd' | '^E' {
                if %!o<order> == 1 && $!rest {
                    if $!p[R] == $!rc2idx.end - 1 && $!p[C] == $!rc2idx[ $!p[R] ].end {
                        self!_beep();
                    }
                    else {
                        $!p[R] = $!rc2idx.end - 1;
                        $!p[C] = $!rc2idx[ $!p[R] ].end;
                        $!begin_p = $!rc2idx.elems - ( $!rc2idx.elems % $!avail_h || $!avail_h );
                        if $!begin_p == $!rc2idx.end {
                            $!begin_p = $!begin_p - $!avail_h;
                            $!end_p   = $!begin_p + $!avail_h - 1;
                        }
                        else {
                            $!end_p = $!rc2idx.end;
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
                        $!begin_p = $!rc2idx.elems - ( $!rc2idx.elems % $!avail_h || $!avail_h );
                        $!end_p   = $!rc2idx.end;
                        self!_wr_screen();
                    }
                }
            }
            when 'q' | '^D' { #  documentation
                self!_end_term();
                return;
            }
            when '^C' {
                self!_end_term();
                "^C".note;
                exit 1;
            }
            when '^M' { # Enter/Return
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
                    if %!o<meta-items>.defined && ! $!marked[ $!p[R] ][ $!p[C] ] {
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
            when ' ' { # Space
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
            when '^@' { # Control Space
                if $multiselect {
                    for ^$!rc2idx -> $row {
                        for ^$!rc2idx[$row] -> $col {
                            $!marked[$row][$col] = ! $!marked[$row][$col];
                        }
                    }
                    if %!o<no-spacebar> {
                        self!_marked_idx2rc( $no-spacebar, False );
                    }
                    if %!o<meta-items> {
                        self!_marked_idx2rc( $meta-items, False );
                    }
                    self!_wr_screen();
                }
                else {
                    self!_beep();
                }
            }
            default {
                self!_beep();
            }
        }
    }
}


method !_wr_first_screen ( Int $multiselect ) {
    ( $!term_w, $!term_h ) = get-term-size();
    ( $!avail_w, $!avail_h ) = ( $!term_w, $!term_h );
    if  %!o<ll>.defined &&  %!o<ll> > $!avail_w {
        $!avail_w += 1;
        # with only one print-column the output doesn't get messed up if an item
        # reaches the right edge of the terminal on a non-MSWin32-OS
    }
    if %!o<max-width> && $!avail_w > %!o<max-width> {
        $!avail_w = %!o<max-width>;
    }
    if $!avail_w < 2 {
        die "Terminal width to small!";
    }
    self!_prepare_new_copy_of_list();
    self!_prepare_prompt();
    if %!o<max-height> && %!o<max-height> < $!avail_h {
        $!avail_h = %!o<max-height>;
    }
    $!curr_layout = %!o<layout>;
    self!_list_index2rowcol();
    self!_set_pp_print_fmt;
    $!begin_p = 0;
    $!end_p   = $!avail_h - 1;
    $!end_p   = $!rc2idx.end if $!end_p > $!rc2idx.end;
    $!p = [ 0, 0 ];
    $!marked = [];
    if %!o<mark> && $multiselect {
        self!_marked_idx2rc( %!o<mark>, True );
    }
    if %!o<default>.defined && %!o<default> <= @!list.end {
        self!_pos_to_default();
    }
    if %!o<clear-screen> || $!page_count > 1 {
        clear;
    }
    else {
        clr-to-bot;
    }
    if @!prompt_lines.elems {
        print @!prompt_lines.join( "\n\r" ) ~ "\n\r";
    }
    $!i_col = 0;
    $!i_row = 0;
    self!_wr_screen();
    if %!o<mouse> {
        get-cursor-position;
    }
    $!cursor_row = $!i_row;
}

method !_wr_screen {
    my @lines;
    if $!rc2idx.elems == 1 {
        my $row = 0;
        @lines = ( 0 .. $!rc2idx[$row].end ).map({
            $!marked[$row][$_]
            ?? "\e[1;4m" ~ @!list[ $!rc2idx[$row][$_] ] ~ "\e[0m"
            !!             @!list[ $!rc2idx[$row][$_] ]
        }).join: ' ' x %!o<pad>;
    }
    else {
        if $!marked.elems {
            for $!begin_p .. $!end_p -> $row {
                @lines.push: ( 0 .. $!rc2idx[$row].end ).map({
                    $!marked[$row][$_]
                    ?? "\e[1;4m" ~ self!_pad_str_to_colwidth( $!rc2idx[$row][$_] ) ~ "\e[0m"
                    !!             self!_pad_str_to_colwidth( $!rc2idx[$row][$_] )
                }).join: ' ' x %!o<pad>;
            }
        }
        else {
            for $!begin_p .. $!end_p -> $row {
                @lines.push: ( 0 .. $!rc2idx[$row].end ).map({
                    self!_pad_str_to_colwidth( $!rc2idx[$row][$_] )
                }).join: ' ' x %!o<pad>;
            }
        }
        if $!end_p == $!rc2idx.end && $!begin_p != 0 {
            if $!rc2idx[$!end_p].end < $!rc2idx[0].end {
                @lines[@lines.end] ~= ' ' x ( $!col_w + %!o<pad> ) * ( $!rc2idx[0].end - $!rc2idx[$!end_p].end );
            }
            if $!end_p - $!begin_p < $!avail_h {
                for ( $!end_p + 1 - $!begin_p ) ..^ $!avail_h {
                    @lines.push: ' ' x $!avail_w;
                }
            }
        }
    }
    if $!page_count > 1 {
        @lines.push: sprintf $!pp_row_fmt, $!begin_p div $!avail_h + 1;
    }
    # 0,0 = first row (below promptlines)
    print self!_goto( 0, 0 ) ~ @lines.join( "\n\r" ) ~ "\r";
    $!i_row += @lines.end;
    $!i_col = 0;
    self!_wr_cell( $!p[R], $!p[C] );
}

method !_wr_cell ( Int $row, Int $col ) {
    my Bool $is_current_pos = $row == $!p[R] && $col == $!p[C];
    my $escape;
    if $is_current_pos && $!marked[$row][$col] {
        $escape := "\e[1;4;7m";
    }
    elsif $is_current_pos {
        $escape := "\e[7m";
    }
    elsif $!marked[$row][$col] {
        $escape := "\e[1;4m";
    }
    my Int $i := $!rc2idx[$row][$col];
    if $!rc2idx.end == 0 {
        my Int $x = 0;
        if $col > 0 {
            for ^$col -> $c {
                $x += print-columns( @!list[ $!rc2idx[$row][$c] ] ) + %!o<pad>;
            }
        }
        if $escape {
            print
                self!_goto( $row - $!begin_p, $x ) ~
                $escape ~ @!list[$i] ~ "\e[0m";
        }
        else {
            print
                self!_goto( $row - $!begin_p, $x ) ~
                @!list[$i];
        }
        $!i_col = $!i_col + print-columns( @!list[$i] );
    }
    else {
        if $escape {
            print
                self!_goto( $row - $!begin_p, ( $!col_w + %!o<pad> ) * $col ) ~
                $escape ~ self!_pad_str_to_colwidth( $i ) ~ "\e[0m";
        }
        else {
            print
                self!_goto( $row - $!begin_p, ( $!col_w + %!o<pad> ) * $col ) ~
                self!_pad_str_to_colwidth( $i );
        }
        $!i_col = $!i_col + $!col_w;
    }
}


method !_goto( $newrow, $newcol ) {
    my $escape = '';
    if $newrow > $!i_row {
        # down
        $escape = $escape ~ "\r\n" x ( $newrow - $!i_row );
        $!i_row = $!i_row + ( $newrow - $!i_row );
        $!i_col = 0;
    }
    elsif $newrow < $!i_row {
        # up
        $escape = $escape ~ "\e[{$!i_row - $newrow}A";
        $!i_row = $!i_row - ( $!i_row - $newrow );
    }
    if $newcol > $!i_col {
        # right
        $escape = $escape ~ "\e[{$newcol - $!i_col}C";
        $!i_col = $!i_col + ( $newcol - $!i_col );
    }
    elsif $newcol < $!i_col {
        # left
        $escape = $escape ~ "\e[{$!i_col - $newcol}D";
        $!i_col = $!i_col - ( $!i_col - $newcol );
    }
    return $escape;
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

If the window size is changed, the screen is rewritten as soon as a key is pressed.

How to choose the items is described in L<#ROUTINES>.

=head2 Keys

=item the C<Arrow> keys (or C<h,j,k,l>) to move up and down or to move to the right and to the left,

=item the C<Tab> key (or C<Ctrl-I>) to move forward, the C<BackSpace> key (or C<Ctrl-H>) to move
backward,

=item the C<PageUp> key (or C<Ctrl-B>) to go back one page, the C<PageDown> key (or C<Ctrl-F>) to go forward one page,

=item the C<Insert> key to go back 10 pages, the C<Delete> key to go forward 10 pages,

=item the C<Home> key (or C<Ctrl-A>) to jump to the beginning of the list, the C<End> key (or C<Ctrl-E>) to jump to the
end of the list.

For the usage of C<SpaceBar>, C<Ctrl-SpaceBar>, C<Return> and the C<q>-key see L<#choose>, L<#choose-multi> and
L<#pause>.

With I<mouse> enabled use the the left mouse key instead the C<Return> key and the right mouse key instead of the
C<SpaceBar> key. Instead of C<PageUp> and C<PageDown> it can be used the mouse wheel. See L<#mouse>

=head1 CONSTRUCTOR

The constructor method C<new> can be called with named arguments. For the valid options see L<#OPTIONS>. Setting the
options in C<new> overwrites the default values for the instance.

=head1 ROUTINES

=head2 choose

C<choose> allows the user to choose one item from a list: the highlighted item is returned when C<Return>
is pressed.

C<choose> returns nothing if the C<Ctrl-D> is pressed.

=head2 choose-multi

The user can choose many items.

To choose an item mark the item with the C<SpaceBar>. When C<Return> is pressed C<choose-multi> then returns the list of
the marked items. If the option I<include-highlighted> is set to C<1>, the highlighted item is also returned.

If C<Return> is pressed with no marked items and L<#include-highlighted> is set to C<2>, the highlighted item is
returned.

C<Ctrl-SpaceBar> (or C<Ctrl-@>) inverts the choices: marked items are unmarked and unmarked items are marked.

C<choose-multi> returns nothing if the C<Ctrl-D> is pressed.

=head2 pause

Nothing can be chosen, nothing is returned but the user can move around and read the output until closed with C<Return>
or C<Ctrl-D>.

=head1 OUTPUT

For the output on the screen the elements of the list are copied and then modified. Chosen elements are returned as they
were passed without modifications.

Modifications:

=item If an element is not defined the value from the option I<undef> is assigned to the element.

=item If an element holds an empty string the value from the option I<empty> is assigned to the element.

=item Tab characters in elements are replaces with a space.

    $element =~ s/\t/ /g;

=item Vertical spaces in elements are squashed to two spaces.

    $element =~ s/\v+/\ \ /g;

=item Code points from the ranges of control, surrogate and noncharacter are removed.

    $element =~ s/[\p{Cc}\p{Noncharacter_Code_Point}\p{Cs}]//g;

=item If the length (print columns) of an element is greater than the width of the screen the element is cut and three
dots are attached.

=head1 OPTIONS

Options which expect a number as their value expect integers.

=head3 beep

0 - off (default)

1 - on

=head3 clear_screen

0 - off (default)

1 - clears the screen before printing the choices

=head3 default

With the option I<default> it can be selected an element, which will be highlighted as the default instead of the first
element.

I<default> expects a zero indexed value, so e.g. to highlight the third element the value would be I<2>.

If the passed value is greater than the index of the last array element, the first element is highlighted.

Allowed values: 0 or greater

(default: 0)

=head3 empty

Sets the string displayed on the screen instead of an empty string.

default: "E<lt>emptyE<gt>"

=head3 hide_cursor

0 - keep the terminals highlighting of the cursor position

1 - hide the terminals highlighting of the cursor position (default)

The control sequence C<25> is used to hide the cursor.

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

To enable the mouse mode the control sequences C<1003> and C<1006> are used.

=head3 order

If the output has more than one row and more than one column:

0 - elements are ordered horizontally

1 - elements are ordered vertically (default)

=head3 pad

Sets the number of whitespaces between columns. (default: 2)

Allowed values: 0 or greater

=head3 prompt

If I<prompt> is undefined, a default prompt-string will be shown.

If the I<prompt> value is an empty string (""), no prompt-line will be shown.

=head3 undef

Sets the string displayed on the screen instead of an undefined element.

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

=head1 REQUIREMENTS

=head2 ANSI escape sequences

ANSI escape sequences are used to move the cursor, to markt and highlight cells and to clear the screen.

Some options use non-ANSI control sequences (I<mouse> and I<hide-cursor>).

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

Copyright (C) 2016-2019 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
