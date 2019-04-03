use v6;
unit class Term::Form:ver<1.2.0>;

use Term::termios;

use Term::Choose::ReadKey :read-key;
use Term::Choose::LineFold :to-printwidth, :line-fold, :print-columns;
use Term::Choose::Screen :ALL;

has %!o;
has %!i;

has @!pre;
has @!list;

has Int $!idx;
has Int $!start_idx;
has Int $!end_idx;

has Int $!avail_w;
has Int $!avail_h;
has Int $!val_w;

has Str $!sep;
has Str $!sep_ro;
has Int $!sep_w;

has Int @!len_keys;
has Int $!key_w;

has Str @!header_lines;
has Int $!nr_header_lines;

has Int $!page;
has Int $!pages;

has $!saved_termios;

subset Int_0_to_2 of Int where * == 0|1|2;
subset Int_0_or_1 of Int where * == 0|1;


has Int_0_or_1 $.show-context = 0;
has Int_0_or_1 $.hide-cursor  = 1;
has Int_0_to_2 $.clear-screen = 0;
has Int_0_to_2 $.auto-up      = 0;
has Int_0_to_2 $.no-echo      = 0;
has Str:D      $.back         = '   Back';
has Str:D      $.confirm      = 'Confirm';
has Str:D      $.default      = '';
has Str:D      $.info         = '';
has Str:D      $.prompt       = '';
has List       $.read-only    = [];


multi readline ( Str $prompt, Str $default ) is export( :DEFAULT, :readline ) { Term::Form.new().readline( $prompt, $default ) }
multi readline ( Str $prompt, *%opt )        is export( :DEFAULT, :readline ) { Term::Form.new().readline( $prompt, |%opt ) }

multi method readline ( Str $prompt, Str $default ) { self!_readline( $prompt, |{ default => $default } ) }
multi method readline ( Str $prompt, *%opt )        { self!_readline( $prompt, |%opt ) }

method !_beep {
    beep();
}

sub _sanitized_string ( $str is copy ) {
    if $str.defined {
        $str ~~ s:g/ \t /\ /; ## subst
        $str ~~ s:g/ \v+ /\ \ /;
        $str ~~ s:g/ <:Cc+:Noncharacter_Code_Point+:Cs> //; # /
    }
    else {
        $str = '';
    }
    return $str;
}


method !_calculate_threshold ( $m ) {
    $m<th_l> = 0;
    $m<th_r> = 0;
    my ( $tmp_w, $count ) = ( 0, 0 );
    for $m<p_str>.list {
        $tmp_w += $_[1];
        ++$count;
        if $tmp_w > %!i<th> {
            $m<th_l> = $count;
            last;
        }
    }
    ( $tmp_w, $count ) = ( 0, 0 );
    for $m<p_str>.reverse {
        $tmp_w += $_[1];
        ++$count;
        if $tmp_w > %!i<th> {
            $m<th_r> = $count;
            last;
        }
    }
}


method !_before_readline ( $opt, $m ) {
    my @info;
    if %!o<info>.chars {
        @info = line-fold( %!o<info>, %!i<term_w> );
    }
    if %!o<show-context> {
        my @before_lines;
        if $m<diff> {
            my $line = '';
            my $line_w = 0;
            for ( 0 .. $m<diff> - 1 ).reverse -> $i {
                if $line_w + $m<str>[$i][1] > %!i<term_w> {
                    @before_lines.unshift: $line;
                    $line   = $m<str>[$i][0];
                    $line_w = $m<str>[$i][1];
                    next;
                }
                $line   = $m<str>[$i][0] ~ $line;
                $line_w = $m<str>[$i][1] + $line_w;
            }
            my $total_first_line_w = %!i<max_key_w> + $line_w;
            if $total_first_line_w <= %!i<term_w> {
                my $empty_w = %!i<term_w> - $total_first_line_w;
                unshift @before_lines, %!i<prompt> ~ ( ' ' x $empty_w ) ~ $line;
            }
            else {
                my $empty_w = %!i<term_w> - $line_w;
                @before_lines.unshift: ( ' ' x $empty_w ) ~ $line;
                @before_lines.unshift: %!i<prompt>;
            }
            %!i<keys>[0] = '';
        }
        else {
            if ( $m<str_w> + %!i<max_key_w> ) <= %!i<term_w> {
                %!i<keys>[0] = %!i<prompt>;
            }
            else {
                %!i<keys>[0] = '';
                @before_lines.unshift: %!i<prompt>;
            }
        }
        %!i<pre_text> = ( |@info, |@before_lines ).join: "\n";
    }
    else {
        %!i<keys>[0] = %!i<prompt>;
        %!i<pre_text> = @info.join: "\n";
    }
    %!i<pre_text_row_count> = 0 + %!i<pre_text>.comb: "\n";
    if %!i<pre_text>.chars {
        ++%!i<pre_text_row_count>;
    }
}


method !_after_readline ( %!o, $m ) {
    my $count_chars_after = $m<str>.elems - ( $m<p_str>.elems + $m<diff> );
    if  ! %!o<show-context> || ! $count_chars_after { # ||
        %!i<post_text> = '';
        %!i<post_text_row_count> = 0;
        return;
    }
    my @after;
    my $line_s = '';
    my $line_w = 0;
    for ( $m<str>.elems - $count_chars_after ) .. $m<str>.end -> $i {
        if $line_w + $m<str>[$i][1] > %!i<term_w> {
            @after.push: $line_s;
            $line_s = $m<str>[$i][0];
            $line_w = $m<str>[$i][1];
            next;
        }
        $line_s = $line_s ~ $m<str>[$i][0];
        $line_w = $line_w + $m<str>[$i][1];
    }
    if $line_w {
        @after.push: $line_s;
    }
    %!i<post_text> = @after.join: "\n";
    if %!i<post_text>.chars {
        %!i<post_text_row_count> = 0 + %!i<post_text>.comb: "\n";
        ++%!i<post_text_row_count>;
    }
}


method !_init_term {
    $!saved_termios := Term::termios.new(fd => 1).getattr;
    my $termios := Term::termios.new(fd => 1).getattr;
    $termios.unset_iflags(<BRKINT ICRNL ISTRIP IXON>);
    $termios.set_oflags(<ONLCR>);
    $termios.set_cflags(<CS8>);
    $termios.unset_lflags(<ECHO ICANON IEXTEN> ); # ISIG
    $termios.setattr(:DRAIN);
    if %!o<clear-screen> {
        if %!o<clear-screen> == 2 {
            save-screen;
        }
        clear;
    }
    else {
        clr-to-bot;
    }
}


method !_reset_term( $up ) {
    $!saved_termios.setattr(:DRAIN);
    if %!o<clear-screen> == 2 {
        restore-screen;
    }
    else {
        up( $up ) if $up;
        print "\r";
        clr-to-bot();
    }
}


method !_init_readline ( %!o, $term_w, $prompt ) {
    %!i<term_w> = $term_w;
    %!i<seps>[0] = ''; # in __readline
    %!i<curr_row> = 0; # in __readlline and __string_and_pos
    %!i<prompt> = _sanitized_string( $prompt );
    %!i<max_key_w> = print-columns( %!i<prompt> );
    if %!i<max_key_w> > $term_w / 3 {
        %!i<max_key_w> = $term_w div 3;
        %!i<prompt> = self!_unicode_trim( %!i<prompt>, %!i<max_key_w> );
    }
    if %!o<show-context> {
        %!i<arrow_left>  = '';
        %!i<arrow_right> = '';
        %!i<arrow_w> = 0;
        %!i<avail_w> = $term_w;
    }
    else {
        %!i<arrow_left>  = '<';
        %!i<arrow_right> = '>';
        %!i<arrow_w> = 1;
        %!i<avail_w> = $term_w - ( %!i<max_key_w> + %!i<arrow_w> );
        # arrow_w: see comment in _prepare_width
    }
    %!i<th> = %!i<avail_w> div 5;
    %!i<th> = 40 if %!i<th> > 40;
    my $list = [ [ %!i<prompt>, %!o<default> ], ];
    my $m = self!_string_and_pos( $list );
    return $m;
}


method !_readline ( $prompt = ': ',
        Int_0_to_2 :$no-echo      = $!no-echo,
        Int_0_to_2 :$clear-screen = $!clear-screen,
        Int_0_or_1 :$show-context = $!show-context,
        Str:D      :$info         = $!info,
        Str:D      :$default      = $!default,
    ) {
    #CATCH {
    #}
    %!o = :$no-echo, :$default, :$no-echo, :$clear-screen, :$show-context, :$info;
    #%!o<read-only> = ();
    self!_init_term();
    my $term_w = ( get-term-size )[0];
    my $m = self!_init_readline( %!o, $term_w, $prompt );
    my $big_step = 10;
    my $up_before = 0;

    CHAR: loop {
        if %!i<beep> {
            self!_beep();
            %!i<beep> = 0;
        }
        my $tmp_term_w = ( get-term-size )[0];
        if $tmp_term_w != $term_w {
            $term_w = $tmp_term_w;
            $m = self!_init_readline( %!o, $term_w, $prompt );
        }
        if $up_before {
            up( $up_before );
        }
        print "\r";
        clr-to-bot();
        self!_before_readline( %!o, $m );
        $up_before = %!i<pre_text_row_count>;
        if %!i<pre_text>.chars {
            print %!i<pre_text>, "\n";
        }
        self!_after_readline( %!o, $m );
        if %!i<post_text>.chars {
            print "\n" ~ %!i<post_text>;
            up( %!i<post_text_row_count> );
        }
        self!_print_readline( %!o, $m );
        my $char = read-key( 0 );
        if ! $char.defined {
            self!_reset_term();
            note "EOT: $!";
            return;
        }
        # reset '$m<avail_w>' to default:
        $m<avail_w> = %!i<avail_w>;
        self!_calculate_threshold( $m );
        given $char {
            when 'CursorUp' {
                for 1 .. $big_step {
                    last if $m<pos> == 0;
                    self!_left( $m )
                }
            }
            when 'CursorDown' {
                for 1 .. $big_step {
                    last if $m<pos> == $m<str>.elems;
                    self!_right( $m )
                }
            }
            when '^U'                 { self!_ctrl_u( $m ) }
            when '^K'                 { self!_ctrl_k( $m ) }
            when 'CursorRight' | '^F' { self!_right(  $m ) }
            when 'CursorLeft'  | '^B' { self!_left(   $m ) }
            when 'CursorEnd'   | '^E' { self!_end(    $m ) }
            when 'CursorHome'  | '^A' { self!_home(   $m ) }
            when 'Backspace'   | '^H' { self!_bspace( $m ) }
            when 'Delete'      | '^D' { self!_delete( $m ) }
            when '^X' {
                #print "\n"; #
                self!_reset_term( %!i<pre_text_row_count> ); # + 1
                return;
            }
            when '^M' { # Enter
                #print "\n"; #
                self!_reset_term( %!i<pre_text_row_count> ); # + 1
                return $m<str>.map({ $_[0] }).join: '';
            }
            when 'PageUp' | 'PageDown' | 'Insert' | 'BackTab' {
                %!i<beep> = 1;
            }
            when /^\^.$/ {
                %!i<beep> = 1;
            }
            default {
                self!_add_char( $m, $char );
            }
        }
    }
}


method !_string_and_pos ( $list ) {
    my $default = $list[%!i<curr_row>][1];
    if ! $default.defined {
        $default = '';
    }
    my $m = {
        avail_w => %!i<avail_w>,
        th_l    => 0,
        th_r    => 0,
        str     => [],
        str_w   => 0,
        pos     => 0,
        p_str   => [],
        p_str_w => 0,
        p_pos   => 0,
        diff    => 0,
    };
    for $default.comb {
        my $char_w = print-columns( $_ );
        $m<str>.push: [ $_, $char_w ];
        $m<str_w> += $char_w;
    }
    $m<pos>  = $m<str>.elems;
    $m<diff> = $m<pos>;
    _unshift_till_avail_w( $m, [ 0 .. $m<str>.end ] );
    return $m;
}


method !_left ( $m ) {
    if $m<pos> {
        $m<pos>--;
        # '<=' and not '==' because th_l could change and fall behind p_pos
        while $m<p_pos> <= $m<th_l> && $m<diff> {
            _unshift_element( $m, $m<pos> - $m<p_pos> );
        }
        if ! $m<diff> { # no '<'
            $m<avail_w> = %!i<avail_w> + %!i<arrow_w>;
            _push_till_avail_w( $m, [ $m<p_str>.end + 1 .. $m<str>.end ] );
        }
        $m<p_pos>--;
    }
    else {
        %!i<beep> = 1;
    }
}


method !_right ( $m ) {
    if $m<pos> < $m<str>.end {
        $m<pos>++;
        # '>=' and not '==' because th_r could change and fall in front of p_pos
        while $m<p_pos> >= $m<p_str>.end - $m<th_r> && $m<p_str>.end + $m<diff> != $m<str>.end {
            _push_element( $m );
        }
        $m<p_pos>++;
    }
    elsif $m<pos> == $m<str>.end {
        #rec w if vw
        $m<pos>++;
        $m<p_pos>++;
        # cursor now behind the string at the end posistion
    }
    else {
        %!i<beep> = 1;
    }
}

method !_bspace ( $m ) {
    if $m<pos> {
        $m<pos>--;
        # '<=' and not '==' because th_l could change and fall behind p_pos
        while $m<p_pos> <= $m<th_l> && $m<diff> {
            _unshift_element( $m, $m<pos> - $m<p_pos> );
        }
        $m<p_pos>--;
        if ! $m<diff> { # no '<'
            $m<avail_w> = %!i<avail_w> + %!i<arrow_w>;
        }
        _remove_pos( $m );
    }
    else {
        %!i<beep> = 1;
    }
}

method !_delete ( $m ) {
    if $m<pos> < $m<str>.elems {
        if ! $m<diff> { # no '<'
            $m<avail_w> = %!i<avail_w> + %!i<arrow_w>;
        }
        _remove_pos( $m );
    }
    else {
        %!i<beep> = 1;
    }
}

method !_ctrl_u ( $m ) {
    if $m<pos> {
        for $m<str>.splice( 0, $m<pos> ) -> $removed {
            $m<str_w> -= $removed[1];
        }
        # diff always 0     # never '<'
        $m<avail_w> = %!i<avail_w> + %!i<arrow_w>;
        _fill_from_begin( $m );
    }
    else {
        %!i<beep> = 1;
    }
}

method !_ctrl_k ( $m ) {
    if $m<pos> < $m<str>.elems {
        for $m<str>.splice( $m<pos>, $m<str>.elems - $m<pos> ) -> $removed {
            $m<str_w> -= $removed[1];
        }
        _fill_from_end( $m );
    }
    else {
        %!i<beep> = 1;
    }
}

method !_home ( $m ) {
    if $m<pos> > 0 {
        # diff always 0     # never '<'
        $m<avail_w> = %!i<avail_w> + %!i<arrow_w>;
        _fill_from_begin( $m );
    }
    else {
        %!i<beep> = 1;
    }
}

method !_end ( $m ) {
    if $m<pos> < $m<str>.elems {
        _fill_from_end( $m );
    }
    else {
        %!i<beep> = 1;
    }
}

method !_add_char ( $m, $char ) {
    my $char_w = print-columns( $char );
    $m<str>.splice( $m<pos>, 0, [ [ $char, $char_w ], ] );
    $m<pos>++;
    $m<p_str>.splice( $m<p_pos>, 0, [ [ $char, $char_w ], ] );
    $m<p_pos>++;
    $m<p_str_w> += $char_w;
    $m<str_w>   += $char_w;
    while $m<p_pos> < $m<p_str>.end {
        if $m<p_str_w> <= $m<avail_w> {
            last;
        }
        my $tmp = $m<p_str>.pop;
        $m<p_str_w> -= $tmp[1];
    }
    while $m<p_str_w> > $m<avail_w> {
        my $tmp = $m<p_str>.shift;
        $m<p_str_w> -= $tmp[1];
        $m<p_pos>--;
        $m<diff>++;
    }
}


sub _unshift_element ( $m, $pos ) {
    my $tmp = $m<str>[$pos];
    $m<p_str>.unshift: $tmp;
    $m<p_str_w> += $tmp[1];
    $m<diff>--;
    $m<p_pos>++;
    while $m<p_str_w> > $m<avail_w> {
        my $tmp = $m<p_str>.pop;
        $m<p_str_w> -= $tmp[1];
    }
}

sub _push_element ( $m ) {
    my $tmp = $m<str>[ $m<p_str>.end + $m<diff> + 1 ];
    $m<p_str>.push: $tmp;
    if $tmp[1].defined {
        $m<p_str_w> += $tmp[1];
    }
    while $m<p_str_w> > $m<avail_w> {
        my $tmp = $m<p_str>.shift;
        $m<p_str_w> -= $tmp[1];
        $m<diff>++;
        $m<p_pos>--;
    }
}

sub _unshift_till_avail_w ( $m, $idx ) {
    for $m<str>[$idx.reverse] {
        if $m<p_str_w> + $_[1] > $m<avail_w> {
            last;
        }
        $m<p_str>.unshift: $_;
        $m<p_str_w> += $_[1];
        $m<p_pos>++;  # p_pos stays on the last element of the p_str
        $m<diff>--;   # diff: difference between p_pos and pos; pos is always bigger or equal p_pos
    }
}

sub _push_till_avail_w ( $m, $idx ) {
    for $m<str>[|$idx] {
        if $m<p_str_w> + $_[1] > $m<avail_w> {
            last;
        }
        $m<p_str>.push: $_;
        $m<p_str_w> += $_[1];
    }
}

sub _remove_pos ( $m ) {
    $m<str>.splice( $m<pos>, 1 )[0];
    my $tmp = $m<p_str>.splice( $m<p_pos>, 1 )[0];
    $m<p_str_w> -= $tmp[1];
    $m<str_w>   -= $tmp[1];
    _push_till_avail_w( $m, [ ( $m<p_str>.end + $m<diff> + 1 ) .. $m<str>.end ] );
}

sub _fill_from_end ( $m ) {
    $m<pos>     = $m<str>.elems;
    $m<p_str>   = [];
    $m<p_str_w> = 0;
    $m<diff>    = $m<str>.elems;
    $m<p_pos>   = 0;
    _unshift_till_avail_w( $m, [ 0 .. $m<str>.end ] );
}

sub _fill_from_begin {
    my ( $m ) = @_;
    $m<pos>     = 0;
    $m<p_pos>   = 0;
    $m<diff>    = 0;
    $m<p_str>   = [];
    $m<p_str_w> = 0;
    _push_till_avail_w( $m, [ 0 .. $m<str>.end ] );
}


method !_print_readline ( %!o, $m ) {
    print "\r";
    clr-to-eol();
    my $i = %!i<curr_row>;
    if %!o<no-echo> && %!o<no-echo> == 2 {  # 'no-echo' only in readline
        print "\r" ~ %!i<keys>[$i];         # in readline no separator
        return;
    }
    my $print_str = "\r" ~ %!i<keys>[$i] ~ %!i<seps>[$i];
    # left arrow:
    if $m<diff> {
        $print_str ~= %!i<arrow_left>;
    }
    # input text:
    if %!o<no-echo> {
        $print_str ~= ( '*' x $m<p_str>.elems );
    }
    else {
        $print_str ~= $m<p_str>.map({ $_[0] }).join: '';
    }
    # right arrow:
    if $m<p_str>.elems + $m<diff> != $m<str>.elems {
        $print_str ~= %!i<arrow_right>;
    }
    my $back_to_pos = 0;
    for $m<p_str>[ $m<p_pos> .. $m<p_str>.end ] {
        $back_to_pos += $_[1];
    }
    print $print_str;
    if $back_to_pos {
        left( $back_to_pos );
    }
}


method !_unicode_trim ( $str, $len ) {
    if print-columns( $str ) <= $len {
        return $str;
    }
    else {
        return to-printwidth( $str, $len - 3, False ).[0] ~ '...';
    }
}


method !_length_longest_key ( $list ) {
    my $len = []; #
    my $longest = 0;
    for 0 .. $list.end -> $i {
        $len[$i] = print-columns( $list[$i][0] );
        if $i < %!i<pre>.elems {
            next;
        }
        $longest = $len[$i] if $len[$i] > $longest;
    }
    %!i<max_key_w> = $longest;
    %!i<key_w> = $len;
}


method !_prepare_width ( $term_w ) {
    %!i<term_w> = $term_w;
    if %!i<max_key_w> > $term_w / 3 {
        %!i<max_key_w> = $term_w div 3;
    }
    %!i<avail_w> = $term_w - ( %!i<max_key_w> + %!i<sep>.chars + %!i<arrow_w> );
    # Subtract %!i<arrow_w> for the '<' before the string.
    # In each case where no '<'-prefix is required (diff==0) %!i<arrow_w> is added again.
    # Routines where $m<arrow_w> is added:  _left, _bspace, _home, _ctrl_u, _delete
    # The required space (1) for the cursor (or the '>') behind the string is already subtracted in get-term-size
    %!i<th> = %!i<avail_w> div 5;
    %!i<th> = 40 if %!i<th> > 40;
}


method !_prepare_hight ( $list, $term_w, $term_h ) {
    %!i<avail_h> = $term_h;
    if %!i<pre_text>.chars {
        %!i<pre_text> = line-fold( %!i<pre_text>, $term_w ); # term_w
        %!i<pre_text_row_count> = 0 + %!i<pre_text>.comb: "\n";
        %!i<pre_text_row_count> += 1;
        %!i<avail_h> -= %!i<pre_text_row_count>;
        my $min_avail_h = 5;
        if  $term_h < $min_avail_h {
            $min_avail_h =  $term_h;
        }
        if %!i<avail_h> < $min_avail_h {
            %!i<avail_h> = $min_avail_h;
        }
    }
    else {
        %!i<pre_text_row_count> = 0;
    }
    if @$list > %!i<avail_h> {
        %!i<pages> = $list.elems div ( %!i<avail_h> - 1 );
        if $list.elems % ( %!i<avail_h> - 1 ) {
            %!i<pages>++;
        }
        %!i<avail_h>--;
    }
    else {
        %!i<pages> = 1;
    }
    return;
}


method !_print_current_row ( %!o, $list, $m ) {
    print "\r";
    clr-to-eol();
    if %!i<curr_row> < %!i<pre>.elems {
        print "\e[7m" ~ $list[%!i<curr_row>][0] ~ "\e[0m";
    }
    else {
        self!_print_readline( %!o, $m );
        $list[%!i<curr_row>][1] = $m<str>.map({ $_[0] // '' }).join: '';
    }
}


method !_get_row ( $list, $idx ) {
    if $idx < %!i<pre>.elems {
        return $list[$idx][0];
    }
    if ! %!i<keys>[$idx].defined {
        my $key = $list[$idx][0];
        my $key_w = %!i<key_w>[$idx];
        if $key_w > %!i<max_key_w> {
            %!i<keys>[$idx] = self!_unicode_trim( $key, %!i<max_key_w> );
        }
        elsif $key_w < %!i<max_key_w> {
            %!i<keys>[$idx] = " " x ( %!i<max_key_w> - $key_w ) ~ $key;
        }
        else {
            %!i<keys>[$idx] = $key;
        }
    }
    if ! %!i<seps>[$idx].defined {
        my $sep;
        if $idx == %!i<read-only>.any {
            %!i<seps>[$idx] = %!i<sep_ro>;
        }
        else {
            %!i<seps>[$idx] = %!i<sep>;
        }
    }
    my $val;
    if $list[$idx][1].defined {
        $val = self!_unicode_trim( $list[$idx][1], %!i<avail_w> );
    }
    else {
        $val = '';
    }
    return %!i<keys>[$idx] ~ %!i<seps>[$idx] ~ $val;
}


method !_write_screen ( $list ) {
    my @rows;
    for %!i<begin_row> .. %!i<end_row> -> $idx {
        @rows.push: self!_get_row( $list, $idx );
    }
    print @rows.join: "\n";
    if %!i<pages> > 1 {
        if %!i<avail_h> - ( %!i<end_row> + 1 - %!i<begin_row> ) {
            print "\n" x ( %!i<avail_h> - ( %!i<end_row> - %!i<begin_row> ) - 1 );
        }
        %!i<page> = %!i<end_row> div %!i<avail_h> + 1;
        my $page_number = sprintf '- Page %d/%d -', %!i<page>, %!i<pages>;
        if $page_number.chars > %!i<term_w> {
            $page_number = sprintf( '%d/%d', %!i<page>, %!i<pages> ).substr: 0, %!i<term_w>;
        }
        print "\n", $page_number;
        up( %!i<avail_h> - ( %!i<curr_row> - %!i<begin_row> ) ); #
    }
    else {
        %!i<page> = 1;
        up( %!i<end_row> - %!i<curr_row> );
    }
 }


method !_write_first_screen ( %!o, $list, $curr_row, $auto-up ) {
    %!i<curr_row> = $auto-up == 2 ?? $curr_row !! %!i<pre>.elems;
    %!i<begin_row> = 0;
    %!i<end_row>  = ( %!i<avail_h> - 1 );
    if %!i<end_row> > $list.end {
        %!i<end_row> = $list.end;
    }
    if %!o<clear-screen> {
        clear();
    }
    else {
        print "\r";
        clr-to-bot();
    }
    if %!i<pre_text>.chars {
        print %!i<pre_text>, "\n";
    }
    %!i<seps> = [];
    %!i<keys> = [];
    self!_write_screen( $list );
}


method fill-form ( $orig_list,
        Int_0_or_1 :$hide-cursor   = $!hide-cursor,
        Int_0_to_2 :$auto-up      = $!auto-up,
        Int_0_to_2 :$clear-screen = $!clear-screen,
        Str:D      :$info         = $!info,
        Str:D      :$prompt       = $!prompt,
        Str:D      :$back         = $!back,
        Str:D      :$confirm      = $!confirm,
        List       :$read-only    = $!read-only,
    ) {
    #CATCH {
    #}
    %!o = :$hide-cursor, :$auto-up, :$clear-screen, :$info, :$prompt, :$back, :$confirm, :$read-only; ##
    my @tmp;
    @tmp.push: %!o<info>   if %!o<info>.chars;
    @tmp.push: %!o<prompt> if %!o<prompt>.chars;
    %!i<pre_text> = @tmp.join: "\n";
    %!i<sep>    = ': ';
    %!i<sep_ro> = '| ';
    die if %!i<sep>.chars != %!i<sep_ro>.chars;
    %!i<arrow_left>  = '<';
    %!i<arrow_right> = '>';
    %!i<arrow_w> = 1;
    %!i<pre> = [ [ %!o<confirm>, Any ], ];
    if %!o<back>.chars {
        %!i<pre>.unshift: [ %!o<back>, Any ];
    }
    %!i<read-only> = [];
    if %!o<read-only>.elems {
        %!i<read-only> = [ %!o<read-only>.map: { $_ + %!i<pre>.elems } ];
    }
    my $list = [ |%!i<pre>, |$orig_list.map({ [ _sanitized_string( $_[0] ), $_[1] ] }) ];
    self!_init_term();
    my ( $term_w, $term_h ) = get-term-size();
    self!_length_longest_key( $list );
    self!_prepare_width( $term_w );
    self!_prepare_hight( $list, $term_w, $term_h );
    self!_write_first_screen( %!o, $list, 0, $auto-up );
    my $m = self!_string_and_pos( $list );
    my $k = 0;
    my $hidden_cursor = 0;

    CHAR: loop {
        my $locked = 0;
        if %!i<curr_row> == %!i<read-only>.any {
            $locked = 1;
        }
        if $list[%!i<curr_row>][0] eq %!o<confirm> | %!o<back> {
            if %!o<hide-cursor> {
                hide-cursor();
                $hidden_cursor = 1;
            }
        }
        if %!i<beep> {
            self!_beep();
            %!i<beep> = 0;
        }
        else {
            self!_print_current_row( %!o, $list, $m );
        }
        my $char = read-key( 0 );
        if ! $char.defined {
            self!_reset_term();
            note "EOT: $!";
            return;
        }
        my ( $tmp_term_w, $tmp_term_h ) = get-term-size();
        if $tmp_term_w != $term_w || $tmp_term_h != $term_h && $tmp_term_h < ( $list.elems + 1 ) {
            up( %!i<curr_row> + %!i<pre_text_row_count> );
            ( $term_w, $term_h ) = ( $tmp_term_w, $tmp_term_h );
            self!_length_longest_key( $list );
            self!_prepare_width( $term_w );
            self!_prepare_hight( $list, $term_w, $term_h );
            self!_write_first_screen( %!o, $list, 0, $auto-up );
            $m = self!_string_and_pos( $list );
        }
        # reset '$m<avail_w>' to default:
        $m<avail_w> = %!i<avail_w>;
        self!_calculate_threshold( $m );
        if $hidden_cursor {
            show-cursor();
            $hidden_cursor = 0;
        }

        given $char {
            when 'Backspace' | '^H' {
                $k = 1;
                if $locked {    # read-only
                    %!i<beep> = 1;
                }
                else {
                    self!_bspace( $m );
                }
            }
            when '^U' {
                $k = 1;
                if $locked {
                    %!i<beep> = 1;
                }
                else {
                    self!_ctrl_u( $m );
                }
            }
            when '^K' {
                $k = 1;
                if $locked {
                    %!i<beep> = 1;
                }
                else {
                    self!_ctrl_k( $m );
                }
            }
            when 'Delete' | '^D' {
                $k = 1;
                self!_delete( $m );
            }
            when 'CursorRight' {
                $k = 1;
                self!_right( $m );
            }
            when 'CursorLeft' {
                $k = 1;
                self!_left( $m );
            }
            when 'CursorEnd' | '^E' {
                $k = 1;
                self!_end( $m );
            }
            when 'CursorHome' | '^A' {
                $k = 1;
                self!_home( $m );
            }
            when 'CursorUp' {
                $k = 1;
                if %!i<curr_row> == 0 {
                    %!i<beep> = 1;
                }
                else {
                    %!i<curr_row>--;
                    $m = self!_string_and_pos( $list );
                    if %!i<curr_row> >= %!i<begin_row> {
                        self!_reset_previous_row( $list, %!i<curr_row> + 1 );
                        up( 1 );
                    }
                    else {
                        self!_print_previous_page( $list );
                    }
                }
            }
            when 'CursorDown' {
                $k = 1;
                if %!i<curr_row> == $list.end {
                    %!i<beep> = 1;
                }
                else {
                    %!i<curr_row>++;
                    $m = self!_string_and_pos( $list );
                    if %!i<curr_row> <= %!i<end_row> {
                        self!_reset_previous_row( $list, %!i<curr_row> - 1 );
                        down( 1 );
                    }
                    else {
                        up( %!i<end_row> - %!i<begin_row> );
                        self!_print_next_page( $list );
                    }
                }
            }
            when 'PageUp' | '^B' {
                $k = 1;
                if %!i<page> == 1 {
                    if %!i<curr_row> == 0 {
                        %!i<beep> = 1;
                    }
                    else {
                        self!_reset_previous_row( $list, %!i<curr_row> );
                        up( %!i<curr_row> );
                        %!i<curr_row> = 0;
                        $m = self!_string_and_pos( $list );
                    }
                }
                else {
                    up( %!i<curr_row> - %!i<begin_row> );
                    %!i<curr_row> = %!i<begin_row> - %!i<avail_h>;
                    $m = self!_string_and_pos( $list );
                    self!_print_previous_page( $list );
                }
            }
            when 'PageDown' | '^F' {
                $k = 1;
                if %!i<page> == %!i<pages> {
                    if %!i<curr_row> == $list.end {
                        %!i<beep> = 1;
                    }
                    else {
                        self!_reset_previous_row( $list, %!i<curr_row> );
                        my $rows = %!i<end_row> - %!i<curr_row>;
                        down( $rows );
                        %!i<curr_row> = %!i<end_row>;
                        $m = self!_string_and_pos( $list );
                    }
                }
                else {
                    up( %!i<curr_row> - %!i<begin_row> );
                    %!i<curr_row> = %!i<end_row> + 1;
                    $m = self!_string_and_pos( $list );
                    self!_print_next_page( $list );
                }
            }
            when '^M' { # Enter
                %!i<lock_ENTER> = 0 if $k;                                                       # any previously pressed key other than ENTER removes lock_ENTER
                if $auto-up == 2 && %!o<auto-up> == 1 && ! %!i<lock_ENTER> {                     # a removed lock_ENTER resets "auto-up" from 2 to 1 if the 2 was originally a 1
                    $auto-up = 1;
                }
                if $auto-up == 1 && $list.elems - %!i<pre>.elems == 1 {                          # else auto-up 1 sticks on the last==first data row
                    $auto-up = 2;
                }
                $k = 0;                                                                          # if ENTER set $k to 0
                my $up = %!i<curr_row> - %!i<begin_row>;
                $up += %!i<pre_text_row_count> if %!i<pre_text_row_count>;
                if $list[%!i<curr_row>][0] eq %!o<back> {                                        # if ENTER on   {back/0}: leave and return nothing
                    self!_reset_term( $up );
                    return;
                }
                elsif $list[%!i<curr_row>][0] eq %!o<confirm> {                                  # if ENTER on {confirm/1}: leave and return result
                    $list.splice: 0, %!i<pre>.elems;
                    self!_reset_term( $up );
                    return [ ( 0 .. $list.end ).map({ [ $orig_list[$_][0], $list[$_][1] ] }) ];
                }
                if $auto-up == 2 {                                                               # if ENTER && "auto-up" == 2 && any row: jumps {back/0}
                    up( $up );
                    print "\r";
                    clr-to-bot();
                    self!_write_first_screen( %!o, $list, 0, $auto-up );                         # cursor on <back>
                    $m = self!_string_and_pos( $list );
                }
                elsif %!i<curr_row> == $list.end {                                               # if ENTER && {last row}: jumps to the {first data row/2}
                    up( $up );
                    print "\r";
                    clr-to-bot();
                    self!_write_first_screen( %!o, $list, %!i<pre>.elems, $auto-up );            # cursor on the first data row
                    $m = self!_string_and_pos( $list );
                    %!i<lock_ENTER> = 1;                                                          # set lock_ENTER when jumped automatically from the {last row} to the {first data row/2}
                }
                else {
                    if $auto-up == 1 && %!i<curr_row> == %!i<pre>.elems && %!i<lock_ENTER> {      # if ENTER && "auto-up" == 1 $$ "curr_row" == {first data row/2} && lock_ENTER is true:
                        %!i<beep> = 1;                                                            # set "auto-up" temporary to 2 so a second ENTER moves the cursor to {back/0}
                        $auto-up = 2;
                        next CHAR;
                    }
                    %!i<curr_row>++;
                    $m = self!_string_and_pos( $list );                                           # or go to the next row if not on the last row
                    if %!i<curr_row> <= %!i<end_row> {
                        self!_reset_previous_row( $list, %!i<curr_row> - 1 );
                        down( 1 );
                    }
                    else {
                        up( $up );                                                                # or else to the next page
                        self!_print_next_page( $list );
                    }
                }
            }
            when 'Insert' | 'BackTab' {
                %!i<beep> = 1;
            }
            when /^\^.$/ {
                %!i<beep> = 1;
            }
            default {
                $k = 1;
                if $locked {
                    %!i<beep> = 1;
                }
                else {
                    self!_add_char( $m, $char );
                }
            }
        }
    }
}



method !_reset_previous_row ( $list, $idx ) {
    print "\r";
    clr-to-eol();
    print self!_get_row( $list, $idx );
}


method !_print_next_page ( $list ) {
    %!i<begin_row> = %!i<end_row> + 1;
    %!i<end_row>   = %!i<end_row> + %!i<avail_h>;
    %!i<end_row>   = $list.end if %!i<end_row> > $list.end;
    print "\r";
    clr-to-bot();
    self!_write_screen( $list );
}


method !_print_previous_page ( $list ) {
    %!i<end_row>   = %!i<begin_row> - 1;
    %!i<begin_row> = %!i<begin_row> - %!i<avail_h>;
    %!i<begin_row> = 0 if %!i<begin_row> < 0;
    print "\r";
    clr-to-bot();
    self!_write_screen( $list );
}





=begin pod

=head1 NAME

Term::Form - Read lines from STDIN.

=head1 SYNOPSIS

    use Term::Form :readline, :fill-form;

    my @aoa = (
        [ 'name'           ],
        [ 'year'           ],
        [ 'color', 'green' ],
        [ 'city'           ]
    );


    # Functional interface:

    my $line = readline( 'Prompt: ', default<abc> );

    my @filled_form = fill-form( @aoa, :auto-up( 0 ) );


    # OO interface:

    my $new = Term::Form.new();

    $line = $new.readline( 'Prompt: ', :default<abc> );

    @filled_form = $new.fill-form( @aoa, :auto-up( 0 ) );

=head1 DESCRIPTION

C<readline> reads a line from STDIN. As soon as C<Return> is pressed C<readline> returns the read string without the
newline character - so no C<chomp> is required.

C<fill-form> reads a list of lines from STDIN.

=head2 Keys

C<BackSpace> or C<Ctrl-H>: Delete the character behind the cursor.

C<Delete> or C<Ctrl-D>: Delete  the  character at point.

C<Ctrl-U>: Delete the text backward from the cursor to the beginning of the line.

C<Ctrl-K>: Delete the text from the cursor to the end of the line.

C<Right-Arrow>: Move forward a character.

C<Left-Arrow>: Move back a character.

C<Home> or C<Ctrl-A>: Move to the start of the line.

C<End> or C<Ctrl-E>: Move to the end of the line.

C<Up-Arrow>:

- C<fill-form>: move up one row.

- C<readline> move back 10 characters.

C<Down-Arrow>:

- C<fill-form>: move down one row.

- C<readline>: move forward 10 characters.

Only in C<readline>:

C<Ctrl-X>: C<readline> returns nothing (undef).

Only in C<fill-form>:

C<Page-Up> or C<Ctrl-B>: Move back one page.

C<Page-Down> or C<Ctrl-F>: Move forward one page.

=head1 METHODS

=head2 new

The C<new> method returns a C<Term::Form> object.

    my $new = Term::Form.new();

C<new> can be called with named arguments. For the valid options see L<#OPTIONS>. Setting the options in C<new>
overwrites the default values for the instance.

=head2 readline

C<readline> reads a line from STDIN.

    my $line = $new.readline( $prompt, $default );

or

    my $line = $new.readline( $prompt, :$default, :$no-echo, ... );

The fist argument is the prompt string.

With the following arguments one can set the different options or instead it can be passed the default value (see option
default) as a string.

=item1 clear-screen

0 - off (default)

1 - clear the screen before printing the choices

2 - use the alternate screen (uses the control sequence C<1049>)

default: disabled

=item1 info

Expects as is value a string. If set, the string is printed on top of the output of C<readline>.

=item1 default

Set a initial value of input.

=item no-echo

0 - the input is echoed on the screen

1 - "C<*>" are displayed instead of the characters

2 - no output is shown apart from the prompt string

default: C<0>

=item1 show-context

Display the input that does not fit into the "readline" before or after the "readline".

0 - disable I<show-context>

1 - enable I<show-context>

default: C<0>

=head2 fill-form

C<fill-form> reads a list of lines from STDIN.

    my $new_list = $new.fill-form( @aoa, :1auto-up, ... );

The first argument is an array of arrays. The arrays have 1 or 2 elements: the first element is the key and the optional
second element is the value. The key is used as the prompt string for the "readline", the value is used as the default
value for the "readline" (initial value of input).

The first argument can be followed by the different options:

=item1 clear-screen

0 - off (default)

1 - clear the screen before printing the choices

2 - use the alternate screen (uses the control sequence C<1049>)

default: disabled

=item1 hide-cursor

Hide the cursor (C<0> or C<1>).

default: enabled

=item1 info

Expects as is value a string. If set, the string is printed on top of the output of C<fill-form>.

default: nothing

=item1 prompt

If I<prompt> is set, a main prompt string is shown on top of the output.

default: nothing

=item1 auto-up

With I<auto-up> set to C<0> or C<1> pressing C<ENTER> moves the cursor to the next line (if the cursor is not on the
"back" or "confirm" row). If the last row is reached, the cursor jumps to the first data row if C<ENTER> is pressed.
While with  I<auto-up> set to C<0> the cursor loops through the rows until a key other than C<ENTER> is pressed with
I<auto-up> set to C<1> after one loop an C<ENTER> moves the cursor to the top menu entry ("back") if no other
key than C<ENTER> was pressed.

With I<auto-up> set to C<2> an C<ENTER> moves the cursor to the top menu entry (except the cursor is on the "confirm"
row).

If I<auto-up> is set to C<0> or C<1> the initially cursor position is on the first data row while when set to C<2> the
initially cursor position is on the first menu entry ("back").

default: C<1>

=item1 read-only

Set a form-row to read only.

Expected value: a reference to an array with the indexes of the rows which should be read only.

default: empty array

=item1 confirm

Set the name of the "confirm" menu entry.

default: C<Confirm>

=item1 back

Set the name of the "back" menu entry.

The "back" menu entry can be disabled by setting I<back> to an empty string.

default: C<Back>

To close the form and get the modified list select the "confirm" menu entry. If the "back" menu entry is chosen to close
the form, C<fill-form> returns nothing.

=head1 REQUIREMENTS

See L<Term::Choose#REQUIREMENTS>.

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 CREDITS

Thanks to the people from L<Perl-Community.de|http://www.perl-community.de>, from
L<stackoverflow|http://stackoverflow.com> for the help.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2016-2019 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
