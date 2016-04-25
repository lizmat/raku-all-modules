use v6;
unit class Term::Choose::Util;

my $VERSION = '0.011';

use Term::Choose;
use Term::Choose::NCurses :all;
use Term::Choose::LineFold :all;



sub _ncurses_win {
    my int32 constant LC_ALL = 6; # From locale.h
    setlocale(LC_ALL, "");
    my Term::Choose::NCurses::WINDOW $win = initscr();
    return $win;
}


sub _prepare_options ( %opt, %valid, %defaults ) {
    for %opt.kv -> $key, $value {
        when %valid{$key}:!exists {
            die "'$key' is not a valid option name";
        }
        when ! $value.defined {
            next;
        }
        when %valid{$key} eq 'Array' {
            die "$key => not an ARRAY reference." if ! $value.isa( Array );
        }
        when %valid{$key} eq 'Str' {
            die "$key => not a string." if ! $value.isa( Str );
        }
        when $value !~~ / ^ <{%valid{$key}}> $ / {
            die "$key => '$value' is not a valid value.";
        }
    }
    my %o;
    for %valid.keys -> $key {
        %o{$key} = %opt{$key} // %defaults{$key};
    }
    return %o;
}


sub _path_valid_opt ( %added_opt? ) {
    my %valid_options = (
        mouse       => '<[ 0 1 ]>',
        order       => '<[ 0 1 ]>',
        show_hidden => '<[ 0 1 ]>',
        enchanted   => '<[ 0 1 2 ]>',
        justify     => '<[ 0 1 2 ]>',
        layout      => '<[ 0 1 2 ]>',
        dir         => 'Str',
        %added_opt,
    );
    return %valid_options;
};


sub _path_defaults ( %added_defaults? ) {
    my %defaults = (
        mouse       => 0,
        order       => 1,
        show_hidden => 1,
        enchanted   => 1,
        justify     => 0,
        layout      => 1,
        dir         => $*HOME,
        %added_defaults,
    );
    return %defaults;
};

sub _my_array_gist ( @array ) {
    return @array.map( { '"' ~ .gist ~ '"' } ).join( ' ' ) ~ ']';
}


sub choose_dirs ( %opt? ) is export( :MANDATORY ) {
    my %o = _prepare_options( 
        %opt,
        _path_valid_opt( { current => 'Array' } ),
        _path_defaults(  { current => [] } )
    );
    my @chosen_dirs;
    my IO::Path $dir = %o<dir>.IO;
    my IO::Path $previous = $dir;
    my $back    = ' < ';
    my $confirm = ' = ';
    my $add_dir = ' . ';
    my $up      = ' .. ';
    my @pre = ( Any, $confirm, $add_dir, $up );
    my Int $default_idx = %o<enchanted> ?? @pre.end !! 0;
    my $win = _ncurses_win();
    my $tc = Term::Choose.new(
        { undef => $back, mouse => %o<mouse>, justify => %o<justify>, layout => %o<layout>, order => %o<order> },
        $win
    );

    loop {
        my IO::Path @dirs;
        try {
            if %o<show_hidden> {
                @dirs = $dir.dir.grep( { .d } );
            }
            else {
                @dirs = $dir.dir.grep( { .d && .basename !~~ / ^ \. / } );
            }
            CATCH { #
                my $prompt = $dir.gist ~ ":\n" ~ $_;
                pause( [ 'Press ENTER to continue.' ], { prompt => $prompt } );
                if $dir.Str eq '/' {
                    endwin();
                    return Empty;
                }
                $dir = $dir.dirname.IO;
                next;
            }
        }
        my Int $len_key;
        my Str $prompt;
        $prompt ~= %o<prompt> ~ "\n" if %o<prompt>;
        my Str $key_curr = 'Current [';
        my Str $key_new  =     'New [';
        if %o<current>.defined {
            $len_key = max $key_curr.chars, $key_new.chars;
            $prompt ~= sprintf "%*s%s\n",   $len_key, $key_curr, _my_array_gist( %o<current> );
            $prompt ~= sprintf "%*s%s\n\n", $len_key, $key_new,  _my_array_gist( [ @chosen_dirs.map( { $_.Str } ) ] );
        }
        else {
            $len_key = $key_new.chars;
            $prompt ~= sprintf "%*s %s\n\n", $len_key, $key_new, _my_array_gist( [ @chosen_dirs.map( { $_.Str } ) ] );
        }
        my Str $key_cwd = 'pwd: ';
        $prompt  = line_fold( $prompt,              getmaxx( $win ), '', ' ' x $len_key       );
        $prompt ~= line_fold( $key_cwd ~ $previous, getmaxx( $win ), '', ' ' x $key_cwd.chars );
        $prompt ~= "\n";
        # Choose
        my $choice = $tc.choose(
            [ |@pre, |@dirs.sort ],
            { prompt => $prompt, default => $default_idx }
        );
        if ! $choice.defined {
            if ! @chosen_dirs.elems {
                endwin();
                return Empty;
            }
            @chosen_dirs = Empty;
            next;
        }
        $default_idx = %o<enchanted> ?? @pre.end !! 0;
        if $choice eq $confirm {
            endwin();
            return @chosen_dirs;
        }
        elsif $choice eq $add_dir {
            @chosen_dirs.push( $previous );
            $dir = $dir.dirname.IO;
            $default_idx = 0 if $previous eq $dir;
            $previous = $dir;
            next;
        }
        $dir = $choice eq $up ?? $dir.dirname.IO !! $choice.IO;
        $default_idx = 0 if $previous eq $dir;
        $previous = $dir;
    }
}


sub choose_a_dir ( %opt? --> IO::Path ) is export( :MANDATORY ) {
    return _choose_a_path( %opt, 0 );
}

sub choose_a_file ( %opt? --> IO::Path ) is export( :MANDATORY ) {
    return _choose_a_path( %opt, 1 );
}

sub _choose_a_path ( %opt, Int $is_a_file --> IO::Path ) {
    my %o = _prepare_options( 
        %opt, 
        _path_valid_opt( $is_a_file ?? {} !! { current => 'Str' } ),
        _path_defaults(  $is_a_file ?? {} !! { current => '' } ),
    );
    my $back        = ' < ';
    my $confirm     = ' = ';
    my $up          = ' .. ';
    my $select_file = ' >F ';
    my @pre;
    @pre[0] = Any;
    @pre[1] = $is_a_file ?? $select_file !! $confirm;
    @pre[2] = $up;
    my Int $default_idx = %o<enchanted>  ?? 2 !! 0;
    my Str $curr        = %o<current> // Str;
    my IO::Path $dir      = %o<dir>.IO;
    my IO::Path $previous = $dir;
    my $win = _ncurses_win();
    my $tc = Term::Choose.new(
        { undef => $back, mouse => %o<mouse>, justify => %o<justify>, layout => %o<layout>, order => %o<order> },
        $win
    );

    loop {
        my IO::Path @dirs;
        try {
            if %o<show_hidden> {
                @dirs = $dir.dir.grep( { .d } );
            }
            else {
                @dirs = $dir.dir.grep( { .d && .basename !~~ / ^ \. / } );
            }
            CATCH { #
                my $prompt = $dir.gist ~ ":\n" ~ $_;
                pause( [ 'Press ENTER to continue.' ], { prompt => $prompt } );
                if $dir.Str eq '/' {
                    endwin();
                    return Empty;
                }
                $dir = $dir.dirname.IO;
                next;
            }
        }
        my Str $prompt = %o<prompt> ?? %o<prompt> ~ "\n" !! '';
        if $is_a_file || ! $curr {
            $prompt ~= 'Dir: ' ~ $dir;
        }
        else {
            $prompt  = sprintf "%11s: \"%s\"\n", 'Current dir', $curr;
            $prompt ~= sprintf "%11s: \"%s\"\n\n",   'New dir', $dir;
        }
        # Choose
        my $choice = $tc.choose(
            [ |@pre, |@dirs.sort ],
            { prompt => $prompt, default => $default_idx }
        );
        if ! $choice.defined {
            endwin();
            return;
        }
        elsif $choice eq $confirm {
            endwin();
            return $previous;
        }
        elsif $choice eq $select_file {
            my IO::Path $file = _a_file( %o, $dir, $tc ) // IO::Path;
            next if ! $file.defined; ###
            endwin();
            return $file;
        }
        if $choice eq $up {
            $dir = $dir.dirname.IO;
        }
        else {
            $dir = $choice;
        }
        if ( $previous eq $dir ) {
            $default_idx = 0;
        }
        else {
            $default_idx = %o<enchanted>  ?? 2 !! 0;
        }
        $previous = $dir;
    }
}

sub _a_file ( %o, IO::Path $dir, $tc --> IO::Path ) {
    my IO::Path @files;
    try {
        if %o<show_hidden> {
            @files = $dir.dir.grep( { .IO.f } );
        }
        else {
            @files = $dir.dir.grep( { .f && .basename !~~ / ^ \. / } );
        }
        CATCH { #
            my $prompt = $dir.gist ~ ":\n" ~ $_;
            pause( [ 'Press ENTER to continue.' ], { prompt => $prompt } );
            return;
        }
    }
    if ! @files.elems {
        my $prompt =  $dir.Str ~ ": no files.";
        pause( [ 'Press ENTER' ], { prompt => $prompt } );
        return;
    }
    my Str $prompt = sprintf 'Files in %s:', $dir;
    # Choose
    my $choice = $tc.choose(
        [ Any, |@files.sort ],
        { prompt => $prompt }
    );
    return if ! $choice.defined;
    return $*SPEC.catfile( $dir, $choice ).IO;
}


sub choose_a_number ( Int $digits, %opt? ) is export( :MANDATORY ) {
    my %o = _prepare_options(
        %opt,
        {   mouse    => '<[ 0 1 ]>',
            current  => '<[ 0 .. 9 ]>+',
            name     => 'Str',
            thsd_sep => 'Str',
        },
        {   mouse    => 0,
            current  => Int,
            name     => '',
            thsd_sep => ',',
        }
    );
    my Str $sep = %o<thsd_sep>;
    my Int $longest = $digits + ( $sep eq '' ?? 0 !! ( $digits - 1 ) div 3 );
    my Str $tab     = '  -  ';
    my Str $confirm = 'CONFIRM';
    my Str $back    = 'BACK';
    my Str @ranges;
    my $win = _ncurses_win();

    if $longest * 2 + $tab.chars <= getmaxx( $win ) {
        @ranges = ( sprintf " %*s%s%*s", $longest, '0', $tab, $longest, '9' );
        for 1 .. $digits - 1 -> $zeros { #
            my Str $begin = insert_sep( '1' ~ '0' x $zeros, $sep );
            my Str $end   = insert_sep( '9' ~ '0' x $zeros, $sep );
            @ranges.unshift( sprintf " %*s%s%*s", $longest, $begin, $tab, $longest, $end );
        }
        $confirm = sprintf "%-*s", $longest * 2 + $tab.chars, $confirm;
        $back    = sprintf "%-*s", $longest * 2 + $tab.chars, $back;
    }
    else {
        @ranges = ( sprintf "%*s", $longest, '0' );
        for 1 .. $digits - 1 -> $zeros { #
            my Str $begin = insert_sep( '1' ~ '0' x $zeros, $sep );
            @ranges.unshift( sprintf "%*s", $longest, $begin );
        }
    }

    my Int %numbers;
    my Str $result;
    my Str $undef = '--';
    my $name = %o<name> ?? ' ' ~ %o<name> !! '';
    my $fmt_cur = "Current{$name}: %{$longest}s\n";
    my $fmt_new = "    New{$name}: %{$longest}s\n";
    my $tc = Term::Choose.new(
        { mouse => %o<mouse> },
        $win
    );

    NUMBER: loop {
        my Str $new_number = $result // $undef;
        my Str $prompt;
        if %o<current>.defined {
            if print_columns( sprintf $fmt_cur, 1 ) <= getmaxx( $win ) {
                $prompt  = sprintf $fmt_cur, insert_sep( %o<current>, $sep );
                $prompt ~= sprintf $fmt_new, $new_number;
            }
            else {
                $prompt  = sprintf "%{$longest}s\n", insert_sep( %o<current>, $sep );
                $prompt ~= sprintf "%{$longest}s\n", $new_number;
            }
        }
        else {
            $prompt = sprintf $fmt_new, $new_number;
            if print_columns( $prompt ) > getmaxx( $win ) {
                $prompt = $new_number;
            }
        }
        my @pre = ( Any, $confirm );
        # Choose
        my $range = $tc.choose(
            [ |@pre, |@ranges ],
            { prompt => $prompt, layout => 2, justify => 1, undef => $back }
        );
        if ! $range.defined {
            if $result.defined {
                $result = Str;
                next NUMBER;
            }
            else {
                endwin();
                return;
            }
        }
        elsif $range eq $confirm {
            endwin();
            if ! $result.defined {
                return;
            }
            $result.=subst( / $sep /, '', :g ) if $sep ne '';
            return $result.Int;
        }
        my Str $begin = ( $range.split( / \s+ '-' \s+ / ) )[0];
        my Int $zeros;
        if $sep.chars {
            $zeros = $begin.trim-leading.subst( / $sep /, '', :g ).chars - 1;
        }
        else {
            $zeros = $begin.trim-leading.chars - 1;
        }
        my @choices   = $zeros ?? ( 1 .. 9 ).map( { $_ ~ '0' x $zeros } ) !! 0 .. 9;
        my Str $reset = 'reset';
        my Str $back_short = '<<';
        # Choose
        my $num = $tc.choose(
            [ Any, |@choices, $reset ],
            { prompt => $prompt, layout => 1, justify => 2, order => 0, undef => $back_short }
        );
        if ! $num.defined {
            next;
        }
        elsif $num eq $reset {
            %numbers{$zeros}:delete;
        }
        else {
            if $sep ne '' {
                $num.=subst( / $sep /, '', :g );
            }
            %numbers{$zeros} = $num.Int;
        }
        my Int $num_combined = [+] %numbers.values;
        $result = insert_sep( $num_combined, $sep ).Str;
    }
}


sub choose_a_subset ( @available, %opt? ) is export( :MANDATORY ) {
    my %o = _prepare_options(
        %opt,
        {   index     => '<[ 0 1 ]>',
            mouse     => '<[ 0 1 ]>',
            order     => '<[ 0 1 ]>',
            justify   => '<[ 0 1 2 ]>',
            layout    => '<[ 0 1 2 ]>',
            current   => 'Array',
            prefix    => 'Str',
            prompt    => 'Str',
        },
        {   index   => 0,
            mouse   => 0,
            order   => 1,
            justify => 0,
            layout  => 2,
            current => [],
            prefix  => Str,
            prompt  => 'Choose:',
        }
    );
    my Str $prefix  = %o<prefix> // ( %o<layout> == 2 ?? '- ' !! '' );
    my Str $confirm = 'CONFIRM';
    my Str $back    = 'BACK';
    if $prefix.chars {
        $confirm = ( ' ' x $prefix.chars ) ~ $confirm;
        $back    = ( ' ' x $prefix.chars ) ~ $back;
    }
    my Str $key_cur = 'Current [';
    my Str $key_new = '    New [';
    my Int $len_key = max $key_cur.chars, $key_new.chars;
    my @new_idx;
    my @new_val;
    my @pre = ( Any, $confirm );
    my $win = _ncurses_win();
    my $tc = Term::Choose.new(
        { layout => %o<layout>, mouse => %o<mouse>, justify => %o<justify>, order => %o<order>,
          no_spacebar => [ 0 .. @pre.end ], undef => $back, lf => [ 0, $len_key ] },
        $win
    );

    loop {
        my Str $lines = '';
        $lines ~= $key_cur ~ _my_array_gist( %o<current> ) ~ "\n"   if %o<current>;
        $lines ~= $key_new ~ _my_array_gist(    @new_val ) ~ "\n\n";
        $lines ~= %o<prompt>;
        my Str @avail_with_prefix = @available.map( { $prefix ~ $_ } );
        # Choose
        my Int @idx = $tc.choose_multi(
            [ |@pre, |@avail_with_prefix  ],
            { prompt => $lines, index => 1 }
        );
        if ! @idx[0] { #
            if @new_idx.elems {
                @new_idx = Empty;
                @new_val = Empty;
                next;
            }
            else {
                endwin();
                return Empty;
            }
        }
        if @idx[0] == 1 {
            @idx.shift;
            @new_val.append( @available[@idx >>->> @pre.elems] );
            @new_idx.append( @idx >>->> @pre.elems );
            endwin();
            return %o<index> ?? @new_idx !! @new_val;
        }
        @new_val.append( @available[@idx >>->> @pre.elems] );
        @new_idx.append( @idx >>->> @pre.elems );
    }
}


#`<<< example 'settings_menu':

my @menu = (
    [ 'enable_logging', "- Enable logging", [ 'NO', 'YES' ] ],
    [ 'case_sensitive', "- Case sensitive", [ 'NO', 'YES' ] ],
);

my %config = (
    'enable_logging' => 0,
    'case_sensitive' => 1,
);

my %tmp_config = settings_menu( @menu, %config, { in_place => 0 } );
if %tmp_config {
    for %tmp_config.kv -> $key, $value {
        %config{$key} = $value;
    }
}

my $changed = settings_menu( @menu, %config, { in_place => 1 } );
>>>

sub settings_menu ( @menu, %setup, %opt? ) is export( :all ) {
    my %o = _prepare_options(
        %opt,
        {   in_place => '<[ 0 1 ]>',
            mouse    => '<[ 0 1 ]>',
            prompt   => 'Str',
        },
        {   in_place => 1,
            mouse    => 0,
            prompt   => 'Choose:',
        }
    );
    my Str $confirm = '  CONFIRM';
    my Str $back    = '  BACK';
    my Int $name_w = 0;
    my %new_setup;
    for @menu -> $entry {
        my ( Str $key, Str $name ) = $entry;
        my Int $len = print_columns( $name );
        $name_w = $len if $len > $name_w;
        %setup{$key} //= 0;
        %new_setup{$key} = %setup{$key};
    }
    my $no_change = %o<in_place> ?? 0 !! {};
    my $count = 0;
    my $win = _ncurses_win();
    my $tc = Term::Choose.new(
        { prompt => %o<prompt>, layout => 2, justify => 0, 
          mouse => %o<mouse>, undef => $back },
        $win
    );

    loop {
        my Str @print_keys;
        for @menu -> $entry {
            my ( Str $key, Str $name, $avail_values ) = $entry;
            my @current = $avail_values[%new_setup{$key}];
            @print_keys.push( sprintf "%-*s [%s]", $name_w, $name, @current );
        }
        my @pre = ( Any, $confirm );
        my @choices = |@pre, |@print_keys;
        # Choose
        my Int $idx = $tc.choose( 
            @choices,
            { index => 1 }
        );
        if ! $idx.defined {
            endwin();
            return $no_change;
        }
        my $choice = @choices[$idx];
        if ! $choice.defined {
            endwin();
            return $no_change;
        }
        elsif $choice eq $confirm {
            my Int $change = 0;
            if $count {
                for @menu -> $entry {
                    my Str $key = $entry[0];
                    if %setup{$key} == %new_setup{$key} {
                        next;
                    }
                    if %o<in_place> {
                        %setup{$key} = %new_setup{$key};
                    }
                    $change++;
                }
            }
            endwin();
            return $no_change if ! $change;
            return 1          if %o<in_place>;
            return %new_setup;
        }
        my Str   $key          = @menu[$idx-@pre][0];
        my Array $avail_values = @menu[$idx-@pre][2];
        %new_setup{$key}++;
        %new_setup{$key} = 0 if %new_setup{$key} == $avail_values.elems;
        $count++;
    }
}


sub term_size ( IO::Handle $handle_out = $*IN ) is export( :all ) { #
    my Str $stty = qx[stty -a]; #
    my Int $height = $stty.match( / 'rows '    <( \d+ )>/ ).Int;
    my Int $width  = $stty.match( / 'columns ' <( \d+ )>/ ).Int;
    return $width, $height; # $width - 1
}


sub term_width ( IO::Handle $handle_out = $*IN ) is export( :all ) { #
    return( ( term_size( $handle_out ) )[0] );
}


sub insert_sep ( $num, $sep = ' ' ) is export( :all ) {
    return $num if ! $num.defined;
    return $num if $num ~~ /$sep/;
    my token sign { <[+-]> }
    my token int  { \d+ }
    my token rest { \D \d+ }
    if $num !~~ / ^ <sign>? <int> <rest>? $ / {
        return $num;
    }
    #while $num.=subst( / ^ ( -? \d+ ) ( \d\d\d ) /, "$0$sep$1" ) {};
    my $new = $<sign> // '';
    $new   ~= $<int>.flip.comb( / . ** 1..3 / ).join( $sep ).flip;
    $new   ~= $<rest> // '';
    return $new;
}

sub print_hash ( %hash, %opt? ) is export( :all ) {
    my $win = _ncurses_win();
    my %o = _prepare_options(
        %opt,
        {   mouse        => '<[ 0 1 ]>',
            len_key      => '<[ 1 .. 9 ]><[ 0 .. 9 ]>*',
            maxcols      => '<[ 1 .. 9 ]><[ 0 .. 9 ]>*',
            left_margin  => '<[ 0 .. 9 ]>+',
            right_margin => '<[ 0 .. 9 ]>+',
            keys         => 'Array',
            preface      => 'Str',
            prompt       => 'Str',
        },
        {   mouse        => 0,
            len_key      => Int,
            maxcols      => getmaxx( $win ),
            left_margin  => 0, #
            right_margin => 0, #
            keys         => Array,
            preface      => Str,
            prompt       => Str,
            
        }
    );
    my Str @keys    = %o<keys>     // %hash.keys.sort;
    my Int $key_w   = %o<len_key>  // @keys.map( { print_columns $_ } ).max;
    my Str $prompt  = %opt<prompt> // ( %o<preface>.defined  ?? '' !! 'Close with ENTER' );
    my Int $maxcols = %o<maxcols>;
    if $maxcols > getmaxx( $win ) {
        $maxcols = getmaxx( $win ) - %o<right_margin>; #
    }
    $key_w += %o<left_margin>;
    my Str $sep   = ' : ';
    my Int $sep_w = $sep.chars;
    if $key_w + $sep_w > $maxcols div 3 * 2 {
        $key_w = $maxcols div 3 * 2 - $sep_w;
    }
    my Str @vals;
    if %o<preface>.defined {
        @vals.append( line_fold( %o<preface>, $maxcols, '', '' ).lines );
    }
    for @keys -> $key {
        if %hash{$key}:!exists {
            next;
        }
        my Str $entry = sprintf "%*.*s%s%s", $key_w xx 2, $key, $sep, %hash{$key}.gist;
        my Str $text = line_fold( $entry, $maxcols, '', ' ' x ( $key_w + $sep_w ) );
        @vals.append( $text.lines );
    }
    #return @vals.join( "\n" ) if return something;
    my $tc = Term::Choose.new(
        {},
        $win
    );
    $tc.pause(
        @vals,
        { prompt => $prompt, layout => 2, justify => 0, mouse => %o<mouse>, empty => ' ' }
    );
    endwin();
}


sub unicode_sprintf ( Str $str, Int $avail_col_w, Int $justify ) is export( :all ) {
    my Int $str_length = print_columns( $str );
    if $str_length > $avail_col_w {
        return cut_to_printwidth( $str, $avail_col_w );
    }
    elsif $str_length < $avail_col_w {
        if $justify == 0 {
            return $str ~ " " x ( $avail_col_w - $str_length );
        }
        elsif $justify == 1 {
            return " " x ( $avail_col_w - $str_length ) ~ $str;
        }
        elsif $justify == 2 {
            my Int $all = $avail_col_w - $str_length;
            my Int $half = $all div 2;
            return " " x $half ~ $str ~ " " x ( $all - $half );
        }
    }
    else {
        return $str;
    }
}



=begin pod

=head1 NAME

Term::Choose::Util - CLI related functions.

=head1 VERSION

Version 0.011

=head1 DESCRIPTION

This module provides some CLI related functions.

=head1 SUBROUTINES

Values in brackets are default values.

=head2 choose_a_dir

=begin code

    $chosen_directory = choose_a_dir( { layout => 1, ... } )

=end code

With C<choose_a_dir> the user can browse through the directory tree (as far as the granted rights permit it) and
choose a directory which is returned.

To move around in the directory tree:

- select a directory and press C<Return> to enter in the selected directory.

- choose the "up"-menu-entry ("C< .. >") to move upwards.

To return the current working-directory as the chosen directory choose "C< = >".

The "back"-menu-entry ("C< E<lt> >") causes C<choose_a_dir> to return nothing.

As an argument it can be passed a hash. With this hash the user can set the different options:

=item1 current

If set, C<choose_a_dir> shows I<current> as the current directory.

=item1 dir

Set the starting point directory. Defaults to the home directory (C<$*HOME>).

=item1 enchanted

If set to 1, the default cursor position is on the "up" menu entry. If the directory name remains the same after an
user input, the default cursor position changes to "back".

If set to 0, the default cursor position is on the "back" menu entry.

Values: 0,[1].

=item1 justify

Elements in columns are left justified if set to 0, right justified if set to 1 and centered if set to 2.

Values: [0],1,2.

=item1 layout

See the option I<layout> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>

Values: 0,[1],2.

=item1 mouse

See the option I<mouse> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>

Values: [0],1.

=item1 order

If set to 1, the items are ordered vertically else they are ordered horizontally.

This option has no meaning if I<layout> is set to 2.

Values: 0,[1].

=item1 show_hidden

If enabled, hidden directories are added to the available directories.

Values: 0,[1].

=head2 choose_a_file

=begin code

    $chosen_file = choose_a_file( { layout => 1, ... } )

=end code

Browse the directory tree like with C<choose_a_dir>. Select "C<E<gt>F>" to get the files of the current directory; than
the chosen file is returned.

The options are passed with a hash. See L<#choose_a_dir> for the different options. C<choose_a_file> has no option
I<current>.

=head2 choose_dirs

=begin code

    @chosen_directories = choose_dirs( { layout => 1, ... } )

=end code

C<choose_dirs> is similar to C<choose_a_dir> but it is possible to return multiple directories.

"C< . >" adds the current directory to the list of chosen directories and "C< = >" returns the chosen list of
directories.

The "back"-menu-entry ( "C< E<lt> >" ) resets the list of chosen directories if any. If the list of chosen directories
is empty, "C< E<lt> >" causes C<choose_dirs> to return nothing.

C<choose_dirs> uses the same option as C<choose_a_dir>. The option I<current> expects as its value an array (directories
shown as the current directories).

=head2 choose_a_number

=begin code

    for ( 1 .. 5 ) {
        $current = $new
        $new = choose_a_number( 5, { current => $current, name => 'Testnumber' }  );
    }

=end code

This function lets you choose/compose a number (unsigned integer) which is returned.

The fist argument - "digits" - is an integer and determines the range of the available numbers. For example setting the
first argument to 6 would offer a range from 0 to 999999.

The optional second argument is a hash with these keys (options):

=item1 current

The current value (integer). If set, two prompt lines are displayed - one for the current number and one for the new number.

=item1 name

Sets the name of the number seen in the prompt line.

Default: empty string ("");

=item1 mouse

See the option I<mouse> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>

Values: [0],1.

=item1 thsd_sep

Sets the thousands separator.

Default: comma (,).

=head2 choose_a_subset

=begin code

    $subset = choose_a_subset( @available_items, { current => @current_subset } )

=end code

C<choose_a_subset> lets you choose a subset from a list.

As a first argument it is required an array which provides the available list.

The optional second argument is a hash. The following options are available:

=item1 current

This option expects as its value the current subset of the available list (array). If set, two prompt lines are
displayed - one for the current subset and one for the new subset. Even if the option I<index> is true the passed
current subset is made of values and not of indexes.

The subset is returned as an array.

=item1 index

If true, the index positions in the available list of the made choices is returned.

=item1 justify

Elements in columns are left justified if set to 0, right justified if set to 1 and centered if set to 2.

Values: [0],1,2.

=item1 layout

See the option I<layout> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>.

Values: 0,1,[2].

=item1 mouse

See the option I<mouse> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>

Values: [0],1.

=item1 order

If set to 1, the items are ordered vertically else they are ordered horizontally.

This option has no meaning if I<layout> is set to 2.

Values: 0,[1].

=item1 prefix

I<prefix> expects as its value a string. This string is put in front of the elements of the available list before
printing. The chosen elements are returned without this I<prefix>.

The default value is "- " if the I<layout> is 2 else the default is the empty string ("").

=item1 prompt

The prompt line before the choices.

Defaults to "Choose:".

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 CREDITS

Thanks to the people from L<Perl-Community.de|http://www.perl-community.de>, from
L<stackoverflow|http://stackoverflow.com> and from L<#perl6 on irc.freenode.net|irc://irc.freenode.net/#perl6> for the
help.

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
