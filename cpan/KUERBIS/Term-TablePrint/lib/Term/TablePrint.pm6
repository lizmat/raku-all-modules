use v6;
unit class Term::TablePrint:ver<1.4.2>;

use Term::Choose           :choose, :choose-multi, :pause;
use Term::Choose::LineFold :to-printwidth, :line-fold, :print-columns;
use Term::Choose::Screen   :ALL;
use Term::Choose::Util     :insert-sep, :unicode-sprintf;

has %!o;

subset Int_0_to_2 of Int where * == 0|1|2;
subset Int_0_or_1 of Int where * == 0|1;

has UInt       $.max-rows          = 50_000;
has UInt       $.min-col-width     = 30;
has UInt       $.progress-bar      = 5_000;
has UInt       $.tab-width         = 2;
has Int_0_or_1 $.choose-columns    = 0;
has Int_0_or_1 $.grid              = 1;
has Int_0_or_1 $.keep-header       = 1;
has Int_0_or_1 $.mouse             = 0;
has Int_0_or_1 $.squash-spaces     = 0;
has Int_0_or_1 $.save-screen       = 0;     # documentation
has Int_0_to_2 $.table-expand      = 1;
has Str        $.decimal-separator = '.';
has Str        $.prompt            = '';
has Str        $.undef             = '';

has     @!orig_table;
has Int @!w_heads;
has     @!w_cols;
has     @!w_int;
has     @!w_fract;
has Int @!avail_w_cols;
has Int @!rows_idx;
has Int @!chosen_cols_idx;
has     @!portions;

has Int  $!tab_w;
has Str  $!info_row;
has Str  $!thsd_sep = ',';
has Hash $!p_bar;

has Term::Choose $!tc;


method !_init_term {
    hide-cursor();
    if %!o<save-screen> {
        save-screen;
    }
    clear;
    $!tc = Term::Choose.new( :mouse( %!o<mouse> ), :0hide-cursor );
}


method !_end_term {
    if %!o<save-screen> {
        restore-screen;
    }
    show-cursor();
}


sub print-table ( @orig_table, *%opt ) is export( :DEFAULT, :print-table ) {
    return Term::TablePrint.new().print-table( @orig_table, |%opt );
}


method print-table (
        @!orig_table,
        UInt       :$max-rows          = $!max-rows,
        UInt       :$min-col-width     = $!min-col-width,
        UInt       :$progress-bar      = $!progress-bar,
        UInt       :$tab-width         = $!tab-width,
        Int_0_or_1 :$choose-columns    = $!choose-columns,
        Int_0_or_1 :$grid              = $!grid,
        Int_0_or_1 :$keep-header       = $!keep-header,
        Int_0_or_1 :$mouse             = $!mouse,
        Int_0_or_1 :$squash-spaces     = $!squash-spaces,
        Int_0_or_1 :$save-screen       = $!save-screen, # documentation  # alternate-screen
        Int_0_to_2 :$table-expand      = $!table-expand,
        Str        :$decimal-separator = $!decimal-separator,
        Str        :$prompt            = $!prompt,
        Str        :$undef             = $!undef,
    ) {
    %!o = :$max-rows, :$min-col-width, :$progress-bar, :$tab-width, :$choose-columns, :$grid, :$keep-header,
          :$mouse, :$squash-spaces, :$table-expand, :$decimal-separator, :$prompt, :$undef, :$save-screen;
    self!_init_term();
    if ! @!orig_table.elems {
        $!tc.pause( ( 'Close with ENTER', ), :prompt( '"print-table": Empty table!' ) );
        self!_end_term;
        return;
    }
    if print-columns( %!o<decimal-separator> ) != 1 {
        %!o<decimal-separator> = '.';
    }
    if %!o<decimal-separator> ne '.' {
        $!thsd_sep = '_';
    }
    $!tab_w = %!o<tab-width>;
    if %!o<grid> && %!o<tab-width> %% 2 {
        $!tab_w++;
    }
    my Int $table_row_count = @!orig_table.elems - 1; # first row is header row
    if %!o<max-rows> && $table_row_count >= %!o<max-rows> {
        $!info_row = sprintf( 'Reached the row LIMIT %s', insert-sep( %!o<max-rows>, $!thsd_sep ) );
        if $table_row_count > %!o<max-rows> {
            $!info_row ~= sprintf( '  (total %s)', insert-sep( $table_row_count, $!thsd_sep ) );
        }
        @!rows_idx = 0 .. %!o<max-rows>; # -1 for index and +1 for header row
    }
    else {
        @!rows_idx = 0 .. @!orig_table.end;
    }
    if %!o<choose-columns> {
        @!chosen_cols_idx = self!_choose_columns( @!orig_table[0] );
        if @!chosen_cols_idx.elems && ! @!chosen_cols_idx[0].defined {
            self!_end_term();
            return;
        }
    }
    if ! @!chosen_cols_idx.elems {
       @!chosen_cols_idx = 0 .. @!orig_table[0].end;
    }
    self!_init_progress_bar();
    self!_split_work_for_threads();
    self!_recursive_code();
    self!_end_term();
    return;
}


method !_recursive_code {
    my $table = []; #
    self!_copy_table( $table );
    self!_calc_col_width( $table );
    my $term_w = self!_calc_avail_col_width( $table );
    my Int $table_w = [+] |@!avail_w_cols, $!tab_w * @!avail_w_cols.end;
    if ! $table_w { #
        return;
    }
    self!_table_row_to_string( $table );
    my Str @header;
    if %!o<prompt> {
        @header.push: %!o<prompt>;
    }
    if %!o<keep-header> {
        @header.push: $table.shift;
        @header.push: self!_header_separator if %!o<grid>;
    }
    else {
        $table.splice( 1, 0, self!_header_separator ) if %!o<grid>;
    }
    if $!info_row {
        if print-columns( $!info_row ) > $table_w {
            $table.push: to-printwidth( $!info_row, $table_w - 3 ) ~ '...';
        }
        else {
            $table.push: $!info_row;
        }
    }
    my Int $old_row = 0;
    my Int $auto_jumped_to_row_0 = 2;
    my Int $row_is_expanded = 0;

    loop {
        if $term_w != ( get-term-size )[0] + 1 {
            $term_w = ( get-term-size )[0] + 1;
            self!_recursive_code();
            return;
        }
        if ( %!o<keep-header> && ! $table.elems ) || ( ! %!o<keep-header> && $table.elems == 1 ) {
            # Choose
            $!tc.pause( ( Any, |$table[0] ), :prompt( 'EMPTY!' ), :0layout, :undef( '<<' ) );
            return;
        }
        %*ENV<TC_RESET_AUTO_UP> = 0;
        # Choose
        my Int $row = $!tc.choose(
            $table,
            :prompt( @header.join: "\n" ), :ll( $table_w ), :default( $old_row ), :1index, :2layout
        );
        if ! $row.defined {
            return;
        }
        if $row < 0 {
            clear();
            self!_init_progress_bar();
            next;   # choose: ll + changed window size: returns -1;
        }
        if ! %!o<table-expand> {
            return if $row == 0;
            next;
        }
        else {
            if $old_row == $row {
                if $row == 0 {
                    if ! %!o<keep-header> {
                        return;
                    }
                    elsif %!o<table-expand> == 1 {
                        return if $row_is_expanded;
                        return if $auto_jumped_to_row_0 == 1;
                    }
                    elsif %!o<table-expand> == 2 {
                        return if $row_is_expanded;
                    }
                    $auto_jumped_to_row_0 = 0;
                }
                elsif %*ENV<TC_RESET_AUTO_UP> == 1 {
                    $auto_jumped_to_row_0 = 0;
                }
                else {
                    $old_row = 0;
                    $auto_jumped_to_row_0 = 1;
                    $row_is_expanded = 0;
                    next;
                }
            }
            $old_row = $row;
            $row_is_expanded = 1;
            if $!info_row && $row == $table.end {
                $!tc.pause( ( 'Close', ), :prompt( $!info_row ) );
                next;
            }
            if %!o<keep-header> {
                $row++;
            }
            else {
                if %!o<grid> {
                    next   if $row == 1;
                    $row-- if $row > 1;
                }
            }
            self!_print_single_table_row( $row );
        }
        %*ENV<TC_RESET_AUTO_UP>:delete;
    }
}


method !_print_single_table_row ( Int $row ) {
    my Int $term_w = ( get-term-size )[0] + 1;
    my Int $key_w = @!w_heads.max + 1; #
    if $key_w > $term_w div 100 * 33 {
        $key_w = $term_w div 100 * 33;
    }
    my Str $separator = ' : ';
    my Int $sep_w = $separator.chars;
    my $col_w = $term_w - ( $key_w + $sep_w + 1 ); #
    my @lines = ' Close with ENTER';
    for @!chosen_cols_idx -> $col {
        my $col_name = ( @!orig_table[0][$col] // %!o<undef> );
        if $col_name ~~ Buf {
            $col_name = $col_name.gist;
        }
        $col_name.=subst( / \t /,  ' ', :g );
        $col_name.=subst( / \v+ /,  '  ', :g );
        $col_name.=subst( / <:Cc+:Noncharacter_Code_Point+:Cs> /, '', :g );
        my Str $key = to-printwidth( $col_name, $key_w, False ).[0];
        my $cell = @!orig_table[$row][$col];
        my Str $sep = $separator;
        @lines.push: ' ';
        for line-fold( $cell, $col_w, '', '' ) -> $line {
            @lines.push: sprintf "%*.*s%*s%s", $key_w xx 2, $key, $sep_w, $sep, $line;
            $key = '' if $key;
             $sep = '' if $sep;
        }
    }
    $!tc.pause( @lines, :prompt( '' ), :2layout );
}


method !_copy_table ( $table ) {
    my ( Int $count, Int $step ) = self!_set_progress_bar;       #
    my @promise;
    my $lock = Lock.new();
    for @!portions -> $range {
        @promise.push: start {
            do for $range[0] ..^ $range[1] -> $row {
                if $step {                                       #
                    $lock.protect( {                             #
                        ++$count;                                #
                        if $count %% $step {                     #
                            self!_update_progress_bar( $count ); #
                        }                                        #
                    } );                                         #
                }
                do for @!chosen_cols_idx -> $col {
                    my $str = ( @!orig_table.AT-POS($row).AT-POS($col) // %!o<undef> );  # this is where the copying happens
                    if $str ~~ Buf {
                        $str = $str.gist;
                    }
                    if %!o<squash-spaces> {
                        $str.=subst( / ^ <:Space>+ /, '', :g );
                        $str.=subst( / <:Space>+ $ /, '', :g );
                        $str.=subst( / <:Space>+ /,  ' ', :g );
                    }
                    $str.=subst( / \t /,  ' ', :g );
                    $str.=subst( / \v+ /,  '  ', :g );
                    $str.=subst( / <:Cc+:Noncharacter_Code_Point+:Cs> /, '', :g );
                    $str;
                }
            }
        };
    }
    for await @promise -> @portion {
        for @portion -> @p_rows {
            $table.push: @p_rows;
        }
    }
    if $step {                                                   #
        self!_last_update_progress_bar( $count );                #
    }                                                            #
}


method !_calc_col_width ( $table ) {
    my ( Int $count, Int $step ) = self!_set_progress_bar;       #
    my Int @col_idx = 0 .. $table[0].end; # new indexes
    @!w_heads = ();
    for @col_idx -> $col {
       @!w_heads.BIND-POS( $col, print-columns( $table.AT-POS(0).AT-POS($col) ) );
    }
    my $size = $table[0].elems;
    my @w_cols[$size]  = ( 1 xx $size );
    my @w_int[$size]   = ( 0 xx $size );
    my @w_fract[$size] = ( 0 xx $size );
    @!portions[0][0] = 1; # 0 already done: w_heads
    my $ds = %!o<decimal-separator>;
    my @promise;
    my $lock = Lock.new();
    for @!portions -> $range {
        my @cache;
        @promise.push: start {
            for $range[0] ..^ $range[1] -> $row {
                if $step {                                       #
                    $lock.protect( {                             #
                        ++$count;                                #
                        if $count %% $step {                     #
                            self!_update_progress_bar( $count ); #
                        }                                        #
                    } );                                         #
                }                                                #
                for @col_idx -> $col {
                    if $table.AT-POS($row).AT-POS($col).chars {
                        if $table.AT-POS($row).AT-POS($col) ~~ / ^ ( <[-+]>? <[0..9]>* ) ( $ds <[0..9]>+ )? $ / {
                            if $table.AT-POS($row).AT-POS($col).chars > @w_cols.AT-POS($col) {
                                @w_cols.BIND-POS( $col, $table.AT-POS($row).AT-POS($col).chars );
                            }
                            if $0.defined && $0.chars > @w_int.AT-POS($col) {
                                @w_int.BIND-POS( $col, $0.chars );
                            }
                            if $1.defined && $1.chars > @w_fract.AT-POS($col) {
                                @w_fract.BIND-POS( $col, $1.chars );
                            }
                        }
                        else {
                            my $width = print-columns( $table.AT-POS($row).AT-POS($col), @cache );
                            if $width > @w_cols.AT-POS($col) {
                                @w_cols.BIND-POS( $col, $width );
                            }
                        }
                    }
                }
            }
        };
    }
    await @promise;
    @!portions[0][0] = 0; # reset
    @!w_cols  := @w_cols;
    @!w_int   := @w_int;
    @!w_fract := @w_fract;
    if $step {                                                   #
        self!_last_update_progress_bar( $count );                #
    }                                                            #
}


method !_calc_avail_col_width( $table ) {
    @!avail_w_cols = @!w_cols;
    my $term_w = ( get-term-size )[0] + 1; # + 1 if not win32
    my Int $avail_w = $term_w - $!tab_w * @!avail_w_cols.end;
    my Int $sum = [+] @!avail_w_cols;
    if $sum < $avail_w {
        HEAD: loop {
            my Int $count = 0;
            for ^@!w_heads -> $i {
                if @!w_heads.AT-POS($i) > @!avail_w_cols.AT-POS($i) {
                    ++@!avail_w_cols.AT-POS($i);
                    ++$count;
                    last HEAD if ( $sum + $count ) == $avail_w;
                }
            }
            last HEAD if $count == 0;
            $sum += $count;
        }
    }
    elsif $sum > $avail_w {
        my Int $mininum_w = %!o<min-col-width> || 1;
        if @!w_heads.elems > $avail_w {
            self!_print_term_not_wide_enough_message( $table );
            return;
        }
        my Int @tmp_cols_w = @!avail_w_cols;
        my Int $percent = 0;

        MIN: while $sum > $avail_w {
            ++$percent;
            my Int $count = 0;
            for ^@tmp_cols_w -> $i {
                if $mininum_w >= @tmp_cols_w.AT-POS($i) {
                    next;
                }
                if $mininum_w >= _minus_x_percent( @tmp_cols_w.AT-POS($i), $percent ) {
                    @tmp_cols_w[$i] = $mininum_w;
                }
                else {
                    @tmp_cols_w[$i] = _minus_x_percent( @tmp_cols_w[$i], $percent );
                }
                ++$count;
            }
            $sum = @tmp_cols_w.sum;
            $mininum_w-- if $count == 0;
            #last MIN if $mininum_w == 0;
        }
        my Int $rest = $avail_w - $sum;
        if $rest {

            REST: loop {
                my $count = 0;
                for ^@tmp_cols_w -> $i {
                    if @tmp_cols_w.AT-POS($i) < @!avail_w_cols.AT-POS($i) {
                        @tmp_cols_w.BIND-POS( $i, @tmp_cols_w.AT-POS($i) + 1 );
                        $rest--;
                        $count++;
                        last REST if $rest == 0;
                    }
                }
                last REST if $count == 0;
            }
        }
        @!avail_w_cols = [ @tmp_cols_w ] if @tmp_cols_w.elems;
    }
    return $term_w;
}


method !_table_row_to_string( $table ) {
    my Int @col_idx = 0 .. $table[0].end;
    my Str $tab;
    if %!o<grid> {
        $tab = ( ' ' x $!tab_w div 2 ) ~ '|' ~ ( ' ' x $!tab_w div 2 );
    }
    else {
        $tab = ' ' x $!tab_w;
    }
    my ( Int $count, Int $step ) = self!_set_progress_bar;       #
    my $ds = %!o<decimal-separator>;
    my @promise;
    my $lock = Lock.new();
    for @!portions -> $range {
        my @cache;
        @promise.push: start {
            do for $range[0] ..^ $range[1] -> $row {
                my Str $str = '';
                for @col_idx -> $col {
                    if ! $table.AT-POS($row).AT-POS($col).chars {
                            $str = $str ~ ' ' x @!avail_w_cols.AT-POS($col);
                    }
                    elsif $table.AT-POS($row).AT-POS($col) ~~ / ^ ( <[-+]>? <[0..9]>* ) ( $ds <[0..9]>+ )? $ / {
                        my Str $all = '';
                        if @!w_fract.AT-POS($col) {
                            if $1.defined {
                                if $1.chars > @!w_fract.AT-POS($col) {
                                    $all = $1.substr( 0, @!w_fract.AT-POS($col) );
                                }
                                else {
                                    $all = $1 ~ ( ' ' x ( @!w_fract.AT-POS($col) - $1.chars ) );
                                }
                            }
                            else {
                                $all = ' ' x @!w_fract.AT-POS($col);
                            }
                        }
                        if $0.defined {
                            if @!w_int.AT-POS($col) > $0.chars {
                                $all = ' ' x ( @!w_int.AT-POS($col) - $0.chars ) ~ $0 ~ $all;
                            }
                            else {
                                $all = $0 ~ $all;
                            }
                        }
                        if $all.chars > @!avail_w_cols.AT-POS($col) {
                            $str = $str ~ $all.substr( 0, @!avail_w_cols.AT-POS($col) );
                        }
                        else {
                            $str = $str ~ ' ' x ( @!avail_w_cols.AT-POS($col) - $all.chars ) ~ $all;
                        }
                    }
                    else {
                        $str = $str ~ unicode-sprintf( $table.AT-POS($row).AT-POS($col), @!avail_w_cols.AT-POS($col), 0, @cache );
                    }
                    if $col != @!avail_w_cols.end {
                        $str = $str ~ $tab;
                    }
                }
                if $step {                                       #
                    $lock.protect( {                             #
                        ++$count;                                #
                        if $count %% $step {                     #
                            self!_update_progress_bar( $count ); #
                        }                                        #
                    } );                                         #
                }
                $row, $str;
            }
        };
    }
    for await @promise -> @portion {
        for @portion {
            $table.BIND-POS( .[0], .[1] ); # overwrites $table
        }
    }
    if $step {                                                   #
        self!_last_update_progress_bar( $count );                #
    }                                                            #
}


method !_choose_columns ( @avail_cols ) {
    my Str $init_prompt = 'Columns: ';
    my Str $ok = '-ok-';
    my Str @pre = ( Str, $ok );
    my Int @col_idxs;
    my @cols = @avail_cols.map( { $_ // %!o<undef> } );

    loop {
        my @chosen_cols = @col_idxs.list ?? @cols[@col_idxs] !! '*';
        my Str $prompt = $init_prompt ~ @chosen_cols.join: ', ';
        my @choices = |@pre, |@cols;
        # Choose
        my Int @idx = $!tc.choose-multi( @choices, :prompt( $prompt ), :1index, :lf( 0, $init_prompt.chars ),
                                                   :meta-items( |^@pre ), :undef( '<<' ), :2include-highlighted );
        if ! @idx[0].defined || @idx[0] == 0 {
            if @col_idxs.elems {
                @col_idxs = [];
                next;
            }
            return;
        }
        elsif @choices[@idx[0]].defined && @choices[@idx[0]] eq $ok {
            @idx.shift;
            @col_idxs.append: @idx >>->> @pre.elems;
            return @col_idxs;
        }
        @col_idxs.append: @idx >>->> @pre.elems;
    }
}

method !_split_work_for_threads {
    my Int $threads = num-threads();
    while $threads * 2 > @!rows_idx.elems {
        last if $threads == 1;
        $threads = $threads div 2;
    }
    my $size = @!rows_idx.elems div $threads;
    @!portions = ( ^$threads ).map: { [ $size * $_, $size * ( $_ + 1 ) ] };
    @!portions[@!portions.end][1] = @!rows_idx.elems;
}

method !_init_progress_bar {
    $!p_bar = {};
    my Int $count_cells = @!rows_idx.elems * @!chosen_cols_idx.elems;
    if %!o<progress-bar> && %!o<progress-bar> < $count_cells {
        print 'Computing: ';
        $!p_bar<times> = 3;
        if $count_cells / %!o<progress-bar> > 50 {
            $!p_bar<type> = 'multi';
            $!p_bar<total> = @!rows_idx.elems;
        }
        else {
            $!p_bar<type> = 'single';
            $!p_bar<total> = @!rows_idx.elems * $!p_bar<times>;
        }
    }
}

method !_set_progress_bar {
    if ! $!p_bar<type> {
        return Int, Int;
    }
    my Int $term_w = ( get-term-size )[0] + 1;
    my Int $count;
    if $!p_bar<type> eq 'multi' {
        $!p_bar<fmt> = 'Computing: (' ~ $!p_bar<times>-- ~ ') [%s%s]';
        $count = 0;
    }
    else {
        $!p_bar<fmt> = 'Computing: [%s%s]';
        $count = $!p_bar<so_far> // 0;
    }
    if $term_w < 25 {
        $!p_bar<fmt> = '[%s%s]';
    }
    $!p_bar<bar_w> = $term_w - ( sprintf $!p_bar<fmt>, '', '' ).chars - 1;
    my Int $step = $!p_bar<total> div $!p_bar<bar_w> || 1;
    return $count, $step;
}

method !_update_progress_bar( Int $count ) { # sub
    my $multi = ( $count / ( $!p_bar{'total'} / $!p_bar<bar_w> ) ).ceiling;
    print "\r" ~ sprintf( $!p_bar<fmt>, '=' x $multi, ' ' x $!p_bar<bar_w> - $multi );
}

method !_last_update_progress_bar( $count ) {
    if $!p_bar<times> < 1 ||  $!p_bar<type> eq 'multi' {
        self!_update_progress_bar( $!p_bar<total> );
    }
    else {
        $!p_bar<so_far> = $count;
    }
    print "\r";
}

method !_header_separator { 
    my Str $header_sep = '';
    my Str $tab = ( '-' x $!tab_w div 2 ) ~ '|' ~ ( '-' x $!tab_w div 2 );
    for ^@!avail_w_cols {
        $header_sep ~= '-' x @!avail_w_cols[$_];
        $header_sep ~= $tab if $_ != @!avail_w_cols.end;
    }
    return $header_sep;
}

method !_print_term_not_wide_enough_message ( $table ) {
    my $prompt1 = 'Terminal window is not wide enough to print this table.';
    $!tc.pause( [ 'Press ENTER to show the column names.' ], :prompt( $prompt1 ) );
    my Str $prompt2 = 'Reduce the number of columns".' ~ "\n" ~ 'Close with ENTER.';
    $!tc.pause( $table[0], :prompt( $prompt2 ) );
}

sub _minus_x_percent ( Int $value, Int $percent ) {
    my Int $new = ( $value - ( $value / 100 * $percent ) ).Int;
    return $new > 0 ?? $new !! 1; ##
}







=begin pod

=head1 NAME

Term::TablePrint - Print a table to the terminal and browse it interactively.

=head1 SYNOPSIS

=begin code

    use Term::TablePrint :print-table;


    my @table = ( [ 'id', 'name' ],
                  [    1, 'Ruth' ],
                  [    2, 'John' ],
                  [    3, 'Mark' ],
                  [    4, 'Nena' ], );


    # Functional style:

    print-table( @table );


    # or OO style:

    my $pt = Term::TablePrint.new();

    $pt.print-table( @table, :mouse(1), :choose-columns(1) );

=end code

=head1 DESCRIPTION

C<print-table> shows a table and lets the user interactively browse it. It provides a cursor which highlights the row
on which it is located. The user can scroll through the table with the different cursor keys - see L<#KEYS>.

If the table has more rows than the terminal, the table is divided up on as many pages as needed automatically. If the
cursor reaches the end of a page, the next page is shown automatically until the last page is reached. Also if the
cursor reaches the topmost line, the previous page is shown automatically if it is not already the first one.

If the terminal is too narrow to print the table, the columns are adjusted to the available width automatically.

If the option table-expand is enabled and a row is selected with C<Return>, each column of that row is output in its own
line preceded by the column name. This might be useful if the columns were cut due to the too low terminal width.

The following modifications are made (at a copy of the original data) to the table elements before the output.

Tab characters (C<\t>) are replaces with a space.

Vertical spaces (C<\v>) are squashed to two spaces

Control characters, code points of the surrogate ranges and non-characters are removed.

If the option I<squash-spaces> is enabled leading and trailing spaces are removed from the array elements and spaces are squashed to a single space.

If an element looks like a number it is left-justified, else it is right-justified.

=head1 USAGE

=head2 KEYS

Keys to move around:

=item the C<ArrowDown> key (or the C<j> key) to move down and  the C<ArrowUp> key (or the C<k> key) to move up.

=item the C<PageUp> key (or C<Ctrl-B>) to go back one page, the C<PageDown> key (or C<Ctrl-F>) to go forward one page.

=item the C<Insert> key to go back 10 pages, the C<Delete> key to go forward 10 pages.

=item the C<Home> key (or C<Ctrl-A>) to jump to the first row of the table, the C<End> key (or C<Ctrl-E>) to jump to the last
row of the table.

With I<keep-header> set to C<0> the C<Return> key closes the table if the cursor is on the header row.

If I<keep-header> is enabled (set to C<1> or C<2>) and I<table-expand> is set to C<0>, the C<Return> key closes the table if the cursor is on
the first row.

If I<keep-header> and I<table-expand> are enabled and the cursor is on the first row, pressing C<Return> three times in
succession closes the table. If I<table-expand> is set to C<1> and the cursor is auto-jumped to the first row, it is
required only one C<Return> to close the table.

If the cursor is not on the first row:

=item1 with the option I<table-expand> disabled the cursor jumps to the table head if C<Return> is pressed.

=item1 with the option I<table-expand> enabled each column of the selected row is output in its own line preceded by the
column name if C<Return> is pressed. Another C<Return> closes this output and goes back to the table output. If a row is
selected twice in succession, the pointer jumps to the head of the table or to the first row if I<keep-header> is
enabled.

If the width of the window is changed and the option I<table-expand> is enabled, the user can rewrite the screen by
choosing a row.

If the option I<choose-columns> is enabled, the C<SpaceBar> key (or the right mouse key) can be used to select columns -
see option L</choose-columns>.

=head1 CONSTRUCTOR

The constructor method C<new> can be called with named arguments. For the valid options see L<#OPTIONS>. Setting the
options in C<new> overwrites the default values for the instance.

=head1 ROUTINES

=head2 print-table

C<print-table> prints the table passed with the first argument.

    print-table( @table, *%options );

The first argument is an list of arrays. The first array of these arrays holds the column names. The following arrays
are the table rows where the elements are the field values.

The following arguments set the options (key-values pairs).

=head1 OPTIONS

Defaults may change in future releases.

=head2 prompt

String displayed above the table.

=head2 choose-columns

If I<choose-columns> is set to 1, the user can choose which columns to print. Columns can be added (with the
C<SpaceBar> and the C<Return> key) until the user confirms with the I<-ok-> menu entry.

Default: 0

=head2 decimal-separator

If set, numbers use I<decimal-separator> as the decimal separator instead of the default decimal separator.

Allowed values: a character with a print width of C<1>. If an invalid values is passed, I<decimal-separator> falls back
to the default value.

Default: . (dot)

=head2 keep-header

If I<keep-header> is set to 0, the table header is shown on top of the first page.

=begin code

    .----------------------------.    .----------------------------.    .----------------------------.
    |col1   col2     col3   col3 |    |.....  .......  .....  .....|    |.....  .......  .....  .....|
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |.....  .......  .....  .....|
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    | 1/3                        |    | 2/3                        |    | 3/3                        |
    '----------------------------'    '----------------------------'    '----------------------------'

=end code

If I<keep-header> is set to 1, the table header is shown on top of each page.

=begin code

    .----------------------------.    .----------------------------.    .----------------------------.
    |col1   col2     col3   col3 |    |col1   col2     col3   col4 |    |col1   col2     col3   col4 |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |.....  .......  .....  .....|
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |.....  .......  .....  .....|
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |.....  .......  .....  .....|
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    |.....  .......  .....  .....|    |.....  .......  .....  .....|    |                            |
    | 1/3                        |    | 2/3                        |    | 3/3                        |
    '----------------------------'    '----------------------------'    '----------------------------'

=end code

Default: 1

=head2 grid

If I<grid> is set to 1 lines separate the columns from each other and the header from the body.

=begin code

    .----------------------------.
    |col1 | col2   | col3 | col3 |
    |-----|--------|------|------|
    |.... | ...... | .... | .... |
    |.... | ...... | .... | .... |
    |.... | ...... | .... | .... |
    |.... | ...... | .... | .... |
    |.... | ...... | .... | .... |
    |.... | ...... | .... | .... |
    |.... | ...... | .... | .... |
    |.... | ...... | .... | .... |
    '----------------------------'

=end code

If set to 0 the table is shown with no grid.

=begin code

    .----------------------------.
    |col1  col2     col3   col3  |
    |....  .......  .....  ..... |
    |....  .......  .....  ..... |
    |....  .......  .....  ..... |
    |....  .......  .....  ..... |
    |....  .......  .....  ..... |
    |....  .......  .....  ..... |
    |....  .......  .....  ..... |
    |....  .......  .....  ..... |
    |                            |
    '----------------------------'

=end code

Default: 1

=head2 max-rows

Set the maximum number of used table rows. The used table rows are kept in memory.

To disable the automatic limit set I<max-rows> to 0.

If the number of table rows is equal to or higher than I<max-rows>, the last row of the output says
C<REACHED LIMIT "MAX_ROWS": $limit> or C<=LIMIT= $limit> if the previous doesn't fit in the row.

Default: 50_000

=head2 min-col-width

The columns with a width below or equal I<min-col-width> are only trimmed if it is still required to lower the row width
despite all columns wider than I<min-col-width> have been trimmed to I<min-col-width>.

Default: 30

=head2 mouse

Set the I<mouse> mode (see option C<mouse> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>).

Default: 0

=head2 progress-bar

Set the progress bar threshold. If the number of fields (rows x columns) is higher than the threshold, a progress bar is
shown while preparing the data for the output. Setting the value to C<0> disables the progress bar.

Default: 5_000

=head2 squash-spaces

If I<squash-spaces> is enabled, consecutive spaces are squashed to one space and leading and trailing spaces are removed.

Default: 0

=head2 tab-width

Set the number of spaces between columns. If I<format> is set to C<2> and I<tab-width> is even, the spaces between the
columns are I<tab-width> + 1 print columns.

Default: 2

=head2 table-expand

If the option I<table-expand> is set to C<1> or C<2> and C<Return> is pressed, the selected table row is printed with
each column in its own line. Exception: if I<table-expand> is set to C<1> and the cursor auto-jumped to the first row,
the first row will not be expanded.

=begin code

    .----------------------------.        .----------------------------.
    |col1 | col2   | col3 | col3 |        |                            |
    |-----|--------|------|------|        |col1 : ..........           |
    |.... | ...... | .... | .... |        |                            |
    |.... | ...... | .... | .... |        |col2 : .....................|
   >|.... | ...... | .... | .... |        |       ..........           |
    |.... | ...... | .... | .... |        |                            |
    |.... | ...... | .... | .... |        |col3 : .......              |
    |.... | ...... | .... | .... |        |                            |
    |.... | ...... | .... | .... |        |col4 : .............        |
    |.... | ...... | .... | .... |        |                            |
    '----------------------------'        '----------------------------'

=end code

If I<table-expand> is set to 0, the cursor jumps to the to first row (if not already there) when C<Return> is pressed.

Default: 1

=head2 undef

Set the string that will be shown on the screen instead of an undefined field.

Default: "" (empty string)

=head1 ENVIRONMET VARIABLES

=head2 multithreading

C<Term::TablePrint> uses multithreading when preparing the list for the output; the number of threads to use can be set
with the environment variable C<TC_NUM_THREADS>.

=head1 REQUIREMENTS

=head2 Monospaced font

It is required a terminal that uses a monospaced font which supports the printed characters.

=head1 CREDITS

Thanks to the people from L<Perl-Community.de|http://www.perl-community.de>, from
L<stackoverflow|http://stackoverflow.com> and from L<#perl6 on irc.freenode.net|irc://irc.freenode.net/#perl6> for the
help.

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 LICENSE AND COPYRIGHT

Copyright 2016-2019 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
