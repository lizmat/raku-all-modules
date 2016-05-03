use v6;
unit class Term::TablePrint;

my $VERSION = '0.011';

use Term::Choose;
use Term::Choose::NCurses :all;
use Term::Choose::LineFold :all;
use Term::Choose::Util :all;


has %.o_global; #
has %!o;

has Term::Choose::NCurses::WINDOW $!g_win;
has List $!a_ref;
has Int  @!cols_w;
has Int  @!heads_w;
has Int  @!new_cols_w;

has Int  @!not_a_number;
has Str  $!binary_str = 'BNRY';

has Int $!show_progress;
has Str $!computing = 'Computing:';
has Int $!total;
has Int $!bar_w;
has Str $!progressbar_fmt;


method new ( %o_global? ) {
    _validate_options( %o_global );
    _set_defaults( %o_global );
    self.bless( :%o_global );
}

submethod DESTROY () { #
    endwin();
}

sub _set_defaults ( %opt ) {
    %opt<add_header>     //= 0;
    %opt<binary_filter>  //= 0;
    %opt<choose_columns> //= 0;
    %opt<keep_header>    //= 1;
    %opt<max_rows>       //= 50000;
    %opt<min_col_width>  //= 30;
    %opt<mouse>          //= 0;
    %opt<progress_bar>   //= 1000;
    %opt<prompt>         //= '';
    %opt<tab_width>      //= 2;
    %opt<table_expand>   //= 1;
    %opt<undef>          //= '';
    %opt<no_col> = 'col'; #
}

sub _valid_options {
    return {
        max_rows        => '<[ 0 .. 9 ]>+',
        min_col_width   => '<[ 0 .. 9 ]>+',
        progress_bar    => '<[ 0 .. 9 ]>+',
        tab_width       => '<[ 0 .. 9 ]>+',
        add_header      => '<[ 0 1 ]>',
        binary_filter   => '<[ 0 1 ]>',
        keep_header     => '<[ 0 1 ]>',
        choose_columns  => '<[ 0 1 2 ]>',
        table_expand    => '<[ 0 1 2 ]>',
        mouse           => '<[ 0 1 ]>',
        prompt          => 'Str',
        undef           => 'Str',
        #no_col         => 'Str', #
    };
}

sub _validate_options ( %opt ) {
    my $valid = _valid_options();
    for %opt.kv -> $key, $value {
        when $valid{$key}:!exists { #
            die "'$key' is not a valid option name";
        }
        when ! $value.defined {
            next;
        }
        when $valid{$key} eq 'Str' {
            die "$key => not a string." if ! $value.isa: Str;
        }
        when $value !~~ / ^ <{$valid{$key}}> $ / { #
            die "$key => '$value' is not a valid value.";
        }
    }
}

method !_choose_cols_with_order ( @avail_cols ) {
    my Str $init_prompt = 'Columns: ';
    my Int $subseq_tab = $init_prompt.chars;
    my Str $ok = '-ok-';
    my Str @pre = ( $ok );
    my @col_idxs;
    my $tc = Term::Choose.new(
        { lf => [ 0, $subseq_tab ], no_spacebar => [ 0 .. @pre.end ], mouse => %!o<mouse> },
        $!g_win
    );
 
    loop {
        my Str @chosen_cols = @col_idxs.list ?? @avail_cols[@col_idxs] !! '*';
        my Str $prompt = $init_prompt ~ @chosen_cols.join: ', ';
        my Str @choices = |@pre, |@avail_cols;
        # Choose
        my Int @idx = $tc.choose_multi(
            @choices,
            { prompt => $prompt, index => 1 }
        );
        if ! @idx[0].defined || ! @choices[@idx[0]].defined { ##
            if @col_idxs.elems {
                @col_idxs = [];
                next;
            }
            else {
                return;
            }
        }
        elsif @choices[@idx[0]] eq $ok {
            @idx.shift;
            @col_idxs.append: @idx >>->> @pre.elems;
            return @col_idxs;
        }
        else {
            @col_idxs.append: @idx >>->> @pre.elems;
        }
    }
}

method !_choose_cols_simple ( @avail_cols ) {
    my $tc = Term::Choose.new(
        { mouse => %!o<mouse> },
        $!g_win
    );
    my Str $all = '-*-';
    my Str @pre = ( $all );
    my @choices = |@pre, |@avail_cols;
    my Int @idx = $tc.choose_multi(
        @choices,
        { prompt => 'Choose: ', no_spacebar => [ 0 .. @pre.end ], index => 1 }
    );
    if ! @idx[0].defined { ##
        return;
    }
    if @choices[@idx[0]] eq $all {
        return [];
    }
    return @idx >>->> @pre.elems;
}


sub print_table ( @table, %opt? ) is export {
    return Term::TablePrint.new().print_table( @table, %opt );
}

method print_table ( @table, %!o? ) {
    if ! @table.elems {
        pause( [ 'Close with ENTER' ], { prompt => "'print_table': Empty table!" } );
        return;
    }
    _validate_options( %!o );
    for %!o_global.kv -> $key, $value {
        %!o{$key} //= $value;
    }
    if %!o<add_header> {
        @table.unshift: [ ( 1 .. @table[0].elems ).map: { $_ ~ '_' ~ %!o<no_col> } ];
    }

    my int32 constant LC_ALL = 6;
    setlocale( LC_ALL, "" );
    $!g_win = initscr();

    my Int @col_idxs;
    if %!o<choose_columns> {
        @col_idxs = self!_choose_cols_simple(     @table[0] ) if %!o<choose_columns> == 1;
        @col_idxs = self!_choose_cols_with_order( @table[0] ) if %!o<choose_columns> == 2;
        if @col_idxs.elems && ! @col_idxs[0].defined {##
            endwin();
            return;
        }
    }
    my Int $last_row_idx = %!o<max_rows> && %!o<max_rows> < @table.elems ?? %!o<max_rows> !! @table.end;
    if @col_idxs.elems {
        $!a_ref = [ ( 0 .. $last_row_idx ).map: { [ @table[$_][@col_idxs] ] } ];
    }
    else {
        if $last_row_idx == @table.end {
            $!a_ref = @table;
        }
        else {
            $!a_ref = @table[0..$last_row_idx];
        }
    }
    if %!o<progress_bar> {
        $!show_progress = ( $!a_ref.elems * $!a_ref[0].elems / %!o<progress_bar> ).Int;
        if $!show_progress >= 1 {
            curs_set( 0 );
            $!progressbar_fmt = $!computing ~ ' [%s%s]';
            $!total = $!a_ref.elems;
        }
    }

    self!_calc_col_width();
    self!_inner_print_tbl();
    endwin();
}


method !_inner_print_tbl {
    my Int $term_w = getmaxx( $!g_win );
    my Bool $term_w_ok = self!_calc_avail_width( $term_w );
    if ! $term_w_ok {
        return;
    }
    my Array $list = self!_cols_to_avail_width();
    my Int   $len  = [+] |@!new_cols_w, %!o<tab_width> * @!new_cols_w.end;
    if %!o<max_rows> && $list.elems - 1 >= %!o<max_rows> {
        my Str $limit = insert_sep( %!o<max_rows>, ' ' );
        my Str $reached_limit = 'REACHED LIMIT "MAX_ROWS": ' ~ $limit;
        if $reached_limit.chars > $len {
            $reached_limit = '=LIMIT= ' ~ $limit;
            $reached_limit.=substr: 0, $len;
        }
        $list.push: unicode_sprintf( $reached_limit, $len, 0 );
    }
    my Int $old_row = 0;
    my Int $auto_jumped_to_first_row = 2;
    my Int $expanded = 0;
    my $tc = Term::Choose.new(
        { ll => $len, layout => 2, mouse => %!o<mouse> },
        $!g_win
    );

    loop {
        if getmaxx( $!g_win ) != $term_w {
            $term_w = getmaxx( $!g_win );
            self!_inner_print_tbl();
            return;
        }
        my Str $header = Str;
        if %!o<keep_header> && $list.elems > 1 {
            $header = $list.shift;
        }
        my Str $prompt = %!o<prompt>;
        if $header.defined {
            $prompt ~= "\n" if $prompt.chars;
            $prompt ~= $header;
        }
        # Choose
        my Int $row = $tc.choose(
            $list,
            { prompt => $prompt, default => $old_row, index => 1 }
        );
        if ! $row.defined {
            return;
        }
        elsif $row == -1 {
            next;
        }
        if $header.defined {
            $list.unshift: $header;
        }
        if ! %!o<table_expand> {
            return if $row == 0;
        }
        else {
            if $old_row == $row {
                if ( $row == 0 ) {
                    if ! %!o<keep_header> {
                        return;
                    }
                    elsif %!o<table_expand> == 1 {
                        return if $expanded;
                        return if $auto_jumped_to_first_row == 1;
                    }
                    elsif %!o<table_expand> == 2 {
                        return if $expanded;
                    }
                    $auto_jumped_to_first_row = 0;
                }
                else {
                    $old_row = 0;
                    $auto_jumped_to_first_row = 1;
                    $expanded = 0;
                    next;
                }
            }
            $old_row = $row;
            if %!o<keep_header> {
                $row++;
            }
            $expanded = 1;
            self!_print_single_row( $row );
        }
    }
}


method !_print_single_row ( Int $row ) {
    my Int $term_w = getmaxx( $!g_win );
    my Int $key_w = @!heads_w.max + 1; #
    if $key_w > $term_w div 100 * 33 {
        $key_w = $term_w div 100 * 33;
    }
    my Str $separator = ' : ';
    my Int $sep_w = $separator.chars;
    my $col_w = $term_w - ( $key_w + $sep_w + 1 ); #
    my @lines = ' Close with ENTER';
    for 0 .. $!a_ref[$row].end -> $col {
        my Str $key = cut_to_printwidth( # 
            _sanitized_string( $!a_ref[0][$col] // %!o<undef> ),
            $key_w
        );
        my Str $sep = $separator;
        @lines.push: ' ';
        if  $!a_ref[$row][$col].defined && ! $!a_ref[$row][$col].chars {
            @lines.push: sprintf "%*.*s%*s%s", $key_w xx 2, $key, $sep_w, $sep, '';
        }
        else {
            for line_fold( $!a_ref[$row][$col].gist, $col_w, '', '' ).lines -> $line {
                @lines.push: sprintf "%*.*s%*s%s", $key_w xx 2, $key, $sep_w, $sep, $line;
                $key = '' if $key;
                $sep = '' if $sep;
            }
        }
    }
    my $tc = Term::Choose.new(
        {},
        $!g_win
    );
    $tc.pause(
        @lines,
        { prompt => '', layout => 2, mouse => %!o<mouse> }
    );
}


sub _sanitized_string ( $str ) {
    return $str.trim.subst( / \s+ /, ' ', :g ).subst( / <:C> /, '', :g );
}


method !_progressbar_update( Int $c ) {
    my $multi = ( $c / ( $!total / $!bar_w ) ).ceiling;
    #my $ext ~= ' ' ~ ( $multi * ( 100 / $!bar_w ) ).Int ~ "%";
    clear();
    mvaddstr( 0, 0, sprintf $!progressbar_fmt, '=' x $multi, ' ' x $!bar_w - $multi );
    nc_refresh();
}


method !_calc_col_width {
    my Int $step;
    my Int $c = 0;
    if $!show_progress >= 2 {
        $!bar_w = getmaxx( $!g_win ) - ( sprintf $!progressbar_fmt, '', '' ).chars - 1;
        $step = $!total div $!bar_w || 1;    #
    }
    my regex binary_regexp { <[\x00 .. \x08 \x0B .. \x0C \x0E .. \x1F]> }
    my Int $undef_w = print_columns( %!o<undef> );
    @!cols_w = 1 xx $!a_ref[0].elems;
    my Int $normal_row = 0;
    my Int @col_idx = 0 .. $!a_ref[0].end; #

    for $!a_ref.list -> $row {
        for @col_idx -> $i {
            my Int $str_w;
            if ! $row[$i].defined {
                $str_w = $undef_w;
            }
            elsif %!o<binary_filter> && $row[$i].substr( 0, 100 ).match: / <binary_regexp> / { #
                $str_w = $!binary_str.chars;
            }
            else {
                $str_w = print_columns( _sanitized_string( $row[$i] ) );
            }
            if $normal_row {
                if $str_w > @!cols_w[$i] {
                    @!cols_w[$i] = $str_w;
                }
                if $row[$i] !~~ Numeric { # ! looks_like_number
                    ++@!not_a_number[$i];
                }
            }
            else {
                # col name
                @!heads_w[$i] = $str_w;
                if $i == $row.end {
                    $normal_row = 1;
                }
            }
        }
        if $step {
            ++$c;
            self!_progressbar_update( $c ) if $c %% $step;
        }
    }
    self!_progressbar_update( $!total ) if $step && $!total % $step;
}


method !_calc_avail_width ( Int $term_w ) {
    @!new_cols_w  = @!cols_w;
    my Int $avail_w = $term_w - %!o<tab_width> * @!new_cols_w.end;
    my Int $sum = [+] @!new_cols_w;
    if $sum < $avail_w {
        HEAD: loop {
            my Int $c = 0;
            for 0 .. @!heads_w.end -> $i {
                if @!heads_w[$i] > @!new_cols_w[$i] {
                    ++@!new_cols_w[$i];
                    ++$c;
                    last HEAD if ( $sum + $c ) == $avail_w;
                }
            }
            last HEAD if $c == 0;
            $sum += $c;
        }
    }
    elsif $sum > $avail_w {
        my Int $mininum_w = %!o<min_col_width> || 1;
        if @!heads_w.elems > $avail_w {
            my $prompt1 = 'Terminal window is not wide enough to print this table.';
            pause(
                [ 'Press ENTER to show the column names.' ],
                { prompt => $prompt1, mouse => %!o<mouse> }
            );
            my Str $prompt2 = 'Reduce the number of columns".' ~ "\n" ~ 'Close with ENTER.';
            pause(
                $!a_ref[0],
                { prompt => $prompt2, mouse => %!o<mouse> }
            );
            return False;
        }
        my Int @tmp_cols_w = @!new_cols_w;
        my Int $percent = 0;

        MIN: while $sum > $avail_w {
            ++$percent;
            my Int $c = 0;
            for 0 .. @tmp_cols_w.end -> $i {
                if $mininum_w >= @tmp_cols_w[$i] {
                    next;
                }
                if $mininum_w >= _minus_x_percent( @tmp_cols_w[$i], $percent ) {
                    @tmp_cols_w[$i] = $mininum_w;
                }
                else {
                    @tmp_cols_w[$i] = _minus_x_percent( @tmp_cols_w[$i], $percent );
                }
                ++$c;
            }
            $sum = [+] @tmp_cols_w;
            $mininum_w-- if $c == 0;
            #last MIN if $mininum_w == 0;
        }
        my Int $rest = $avail_w - $sum;
        if $rest {

            REST: loop {
                my $c = 0;
                for 0 .. @tmp_cols_w.end -> $i {
                    if @tmp_cols_w[$i] < @!new_cols_w[$i] {
                        @tmp_cols_w[$i]++;
                        $rest--;
                        $c++;
                        last REST if $rest == 0;
                    }
                }
                last REST if $c == 0;
            }
        }
        @!new_cols_w = [ @tmp_cols_w ] if @tmp_cols_w.elems;
    }
    return True;
}

sub _minus_x_percent ( Int $value, Int $percent ) {
    my Int $new = ( $value - ( $value / 100 * $percent ) ).Int;
    return $new > 0 ?? $new !! 1;
}


method !_cols_to_avail_width {
    my Int $step;
    my Int $c = 0;
    if $!show_progress {
        $!bar_w = getmaxx( $!g_win ) - ( sprintf $!progressbar_fmt, '', '' ).chars - 1;
        $step = $!total div $!bar_w || 1;    #
    }
    my Int @col_idx = 0 .. @!new_cols_w.end;
    my Str $tab = ' ' x %!o<tab_width>;
    my Array $list;

    for $!a_ref.list -> $row {
        my Str $str = '';
        for @col_idx -> $i {
            if ! $row[$i].defined {
                $str ~= unicode_sprintf( 
                    %!o<undef>, 
                    @!new_cols_w[$i],
                    @!not_a_number[$i] ?? 0 !! 1 );
            }
            elsif %!o<binary_filter> && $row[$i].substr( 0, 100 ).match: / <binary_regexp> / { #
                $str ~= $!binary_str.substr: 0, @!new_cols_w[$i];
            }
            else {
                $str ~= unicode_sprintf( 
                    _sanitized_string( $row[$i] ),
                    @!new_cols_w[$i],
                    @!not_a_number[$i] ?? 0 !! 1 );
            }
            $str ~= $tab if $i != @!new_cols_w.end;
        }
        $list.push: $str;
        if $step {
            ++$c;
            self!_progressbar_update( $c ) if $c %% $step;
        }
    }
    self!_progressbar_update( $!total ) if $step && $!total % $step;
    return $list;
}




=begin pod

=head1 NAME

Term::TablePrint - Print a table to the terminal and browse it interactively.

=head1 VERSION

Version 0.011

=head1 SYNOPSIS

=begin code

    my @table = ( [ 'id', 'name' ],
                  [    1, 'Ruth' ],
                  [    2, 'John' ],
                  [    3, 'Mark' ],
                  [    4, 'Nena' ], );

    use Term::TablePrint;


    # Functional style:

    print_table( @table );


    # or OO style:

    my $pt = Term::TablePrint->new();

    $pt->print_table( @table );

=end code

=head1 ANNOUNCEMENT

Backwards incompatible changes with the next release (C<-> replaces C<_> in routine and option names).

=head1 DESCRIPTION

C<print_table> shows a table and lets the user interactively browse it. It provides a cursor which highlights the row
on which it is located. The user can scroll through the table with the different cursor keys - see L<#KEYS>.

If the table has more rows than the terminal, the table is divided up on as many pages as needed automatically. If the
cursor reaches the end of a page, the next page is shown automatically until the last page is reached. Also if the
cursor reaches the topmost line, the previous page is shown automatically if it is not already the first one.

If the terminal is too narrow to print the table, the columns are adjusted to the available width automatically.

If the option table_expand is enabled and a row is selected with C<Return>, each column of that row is output in its own
line preceded by the column name. This might be useful if the columns were cut due to the too low terminal width.

The following modifications are made (at a copy of the original data) before the output.

Leading and trailing whitespaces are removed.

Spaces are squashed to a single white-space

=begin code

    s:g/\s+/ /;

=end code

In addition, characters of the Unicode property C<Other> are removed.

=begin code

    s:g/\p{C}//;

=end code

The elements in a column are right-justified if one or more elements of that column do not look like a number, else they
are left-justified.

=head1 USAGE

=head2 KEYS

Keys to move around:

=item the C<ArrowDown> key (or the C<j> key) to move down and  the C<ArrowUp> key (or the C<k> key) to move up.

=item the C<PageUp> key (or C<Ctrl-B>) to go back one page, the C<PageDown> key (or C<Ctrl-F>) to go forward one page.

=item the C<Home> key (or C<Ctrl-A>) to jump to the first row of the table, the C<End> key (or C<Ctrl-E>) to jump to the last
row of the table.

With I<keep_header> disabled the C<Return> key closes the table if the cursor is on the header row.

If I<keep_header> is enabled and I<table_expand> is set to C<0>, the C<Return> key closes the table if the cursor is on
the first row.

If I<keep_header> and I<table_expand> are enabled and the cursor is on the first row, pressing C<Return> three times in
succession closes the table. If I<table_expand> is set to C<1> and the cursor is auto-jumped to the first row, it is
required only one C<Return> to close the table.

If the cursor is not on the first row:

=item1 with the option I<table_expand> disabled the cursor jumps to the table head if C<Return> is pressed.

=item1 with the option I<table_expand> enabled each column of the selected row is output in its own line preceded by the
column name if C<Return> is pressed. Another C<Return> closes this output and goes back to the table output. If a row is
selected twice in succession, the pointer jumps to the head of the table or to the first row if I<keep_header> is
enabled.

If the width of the window is changed and the option I<table_expand> is enabled, the user can rewrite the screen by
choosing a row.

If the option I<choose_columns> is enabled, the C<SpaceBar> key (or the right mouse key) can be used to select columns -
see option L</choose_columns>.

=head1 ROUTINES

=head2 print_table

C<print_table> prints the table passed with the first argument.

    print_table( @table, %options );

The first argument is an array of arrays. The first array of these arrays holds the column names. The following arrays
are the table rows where the elements are the field values.

As a optional second argument it can be passed a hash which holds the options.

=head1 OPTIONS

=head2 prompt

String displayed above the table.

=head2 add_header

If I<add_header> is set to 1, C<print_table> adds a header row - the columns are numbered starting with 1.

Default: 0

=head2 binary_filter

If I<binary_filter> is set to 1, "BNRY" is printed instead of arbitrary binary data.

If the data matches the repexp C</[\x00-\x08\x0B-\x0C\x0E-\x1F]/>, it is considered arbitrary binary data.

Printing arbitrary binary data could break the output.

Default: 0

=head2 choose_columns

If I<choose_columns> is set to 1, the user can choose which columns to print. The columns can be marked with the
C<SpaceBar>. The list of marked columns including the highlighted column are printed as soon as C<Return> is pressed.

If I<choose_columns> is set to 2, it is possible to change the order of the columns. Columns can be added (with
the C<SpaceBar> and the C<Return> key) until the user confirms with the I<-ok-> menu entry.

Default: 0

=head2 keep_header

If I<keep_header> is set to 1, the table header is shown on top of each page.

If I<keep_header> is set to 0, the table header is shown on top of the first page.

Default: 1;

=head2 max_rows

Set the maximum number of used table rows. The used table rows are kept in memory.

To disable the automatic limit set I<max_rows> to 0.

If the number of table rows is equal to or higher than I<max_rows>, the last row of the output says
C<REACHED LIMIT "MAX_ROWS": $limit> or C<=LIMIT= $limit> if the previous doesn't fit in the row.

Default: 50_000

=head2 min_col_width

The columns with a width below or equal I<min_col_width> are only trimmed if it is still required to lower the row width
despite all columns wider than I<min_col_width> have been trimmed to I<min_col_width>.

Default: 30

=head2 mouse

Set the I<mouse> mode (see option C<mouse> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>).

Default: 0

=head2 progress_bar

Set the progress bar threshold. If the number of fields (rows x columns) is higher than the threshold, a progress bar is
shown while preparing the data for the output.

Default: 1_000

=head2 tab_width

Set the number of spaces between columns.

Default: 2

=head2 table_expand

If the option I<table_expand> is set to C<1> or C<2> and C<Return> is pressed, the selected table row is printed with
each column in its own line. Exception: if I<table_expand> is set to C<1> and the cursor auto-jumped to the first row,
the first row will not be expanded.

If I<table_expand> is set to 0, the cursor jumps to the to first row (if not already there) when C<Return> is pressed.

Default: 1

=head2 undef

Set the string that will be shown on the screen instead of an undefined field.

Default: "" (empty string)

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

Copyright 2016 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
