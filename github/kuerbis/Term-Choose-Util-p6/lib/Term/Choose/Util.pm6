use v6;
unit class Term::Choose::Util:ver<1.0.4>;

use NCurses;
use Term::Choose              :choose, :choose-multi, :pause;
use Term::Choose::LineFold    :to-printwidth, :line-fold, :print-columns;
use Term::Choose::NCursesAdd;


has WINDOW $.win;
has Bool   $!reset_win;

has %!o;

subset Int_0_to_2 of Int where * == 0|1|2;
subset Int_0_or_1 of Int where * == 0|1;

has Int_0_or_1 $.index          = 0;
has Int_0_or_1 $.in-place       = 1;
has Int_0_or_1 $.mouse          = 0;
has Int_0_or_1 $.order          = 1;
has Int_0_or_1 $.show-hidden    = 1;
has Int_0_to_2 $.enchanted      = 1;
has Int_0_to_2 $.justify        = 0;
has Int_0_to_2 $.layout         = 1;
has UInt       $.current-number;
has Str        $.current-dir    = '';
has Str        $.current-file   = '';
has Str        $.dir            = $*HOME.Str;
has Str        $.name           = '';
has Str        $.prefix;
has Str        $.prompt;
has Str        $.thsd-sep       = ',';
has List       $.current-dirs   = [];
has List       $.current-list   = [];

has Term::Choose $!tc;


method !_init_term {
    if ! $!win {
        $!reset_win = True;
        my int32 constant LC_ALL = 6;
        setlocale( LC_ALL, "" );
        $!win = initscr();
    }
    $!tc = Term::Choose.new( :win( $!win ), :mouse( %!o<mouse> ) );
}

method !_end_term {
    return if ! $!reset_win;
    endwin();
}


sub _array_gist ( @array ) { @array.map( { '"' ~ .Str ~ '"' } ).join( ', ' ) ~ ']' }
sub _string_gist ( $str ) { '"' ~ $str.Str ~ '"' }


sub choose-dirs ( *%opt ) is export( :DEFAULT, :choose-dirs ) { Term::Choose::Util.new().choose-dirs( |%opt ) }

method choose-dirs (
        Int_0_or_1 :$mouse          = $!mouse,
        Int_0_or_1 :$order          = $!order,
        Int_0_or_1 :$show-hidden    = $!show-hidden,
        Int_0_to_2 :$enchanted      = $!enchanted,
        Int_0_to_2 :$justify        = $!justify,
        Int_0_to_2 :$layout         = $!layout,
        Str        :$dir            = $!dir,
        Str        :$prompt         = $!prompt,
        List       :$current-dirs   = $!current-dirs,
    ) {
    CATCH {
        endwin();
    }
    %!o = :$mouse, :$order, :$show-hidden, :$enchanted, :$justify, :$layout, :$dir, :$prompt, :$current-dirs;
    my @chosen_dirs;
    my IO::Path $tmp_dir = %!o<dir>.IO;
    my IO::Path $previous = $tmp_dir;
    my $back    = ' < ';
    my $confirm = ' = ';
    my $add_dir = ' . ';
    my $up      = ' .. ';
    my @pre = ( Any, $confirm, $add_dir, $up );
    my Int $default_idx = %!o<enchanted> ?? @pre.end !! 0;
    self!_init_term();

    loop {
        my IO::Path @dirs;
        try {
            if %!o<show-hidden> {
                @dirs = $tmp_dir.dir.grep: { .d };
            }
            else {
                @dirs = $tmp_dir.dir.grep: { .d && .basename !~~ / ^ \. / };
            }
            CATCH { #
                my $prompt = $tmp_dir.gist ~ ":\n" ~ $_;
                pause( [ 'Press ENTER to continue.' ], prompt => $prompt );
                if $tmp_dir.absolute eq '/' {
                    self!_end_term();
                    return Empty;
                }
                $tmp_dir = $tmp_dir.dirname.IO;
                next;
            }
        }
        my Str $prompt;
        my Str $key_curr = 'Current [';
        my Str $key_new  =     'New [';
        my Int $len_key = $key_new.chars;;
        if %!o<current-dirs>.elems {
            $len_key = max $len_key, $key_curr.chars;
            $prompt ~= sprintf "%*s%s\n", $len_key, $key_curr, _array_gist( %!o<current-dirs> );
        }
        $prompt ~= sprintf "%*s%s\n", $len_key, $key_new, _array_gist( @chosen_dirs );
        my Str $key_cwd = '=> ';
        $prompt  = line-fold( $prompt,              getmaxx( $!win ), '', ' ' x $len_key       ).join: "\n";
        $prompt ~= "\n";
        $prompt ~= line-fold( $key_cwd ~ $previous, getmaxx( $!win ), '', ' ' x $key_cwd.chars ).join: "\n";
        $prompt ~= "\n";
        $prompt ~= "\n" ~ %!o<prompt> if %!o<prompt>.defined;
        # Choose
        my $choice = $!tc.choose( [ |@pre, |@dirs.sort ], :prompt( $prompt ), :default( $default_idx ), :undef( $back ),
                                    :justify( %!o<justify> ), :layout( %!o<layout> ), :order( %!o<order> ) );
        if ! $choice.defined {
            if ! @chosen_dirs.elems {
                self!_end_term();
                return Empty;
            }
            @chosen_dirs = Empty;
            next;
        }
        $default_idx = %!o<enchanted> ?? @pre.end !! 0;
        if $choice eq $confirm {
            self!_end_term();
            return @chosen_dirs;
        }
        elsif $choice eq $add_dir {
            @chosen_dirs.push: $previous;
            $tmp_dir = $tmp_dir.dirname.IO;
            $default_idx = 0 if $previous eq $tmp_dir;
            $previous = $tmp_dir;
            next;
        }
        $tmp_dir = $choice eq $up ?? $tmp_dir.dirname.IO !! $choice.IO;
        $default_idx = 0 if $previous eq $tmp_dir;
        $previous = $tmp_dir;
    }
}


sub choose-a-dir ( *%opt --> IO::Path ) is export( :DEFAULT, :choose-a-dir ) { Term::Choose::Util.new().choose-a-dir( |%opt ) }

method choose-a-dir (
        Int_0_or_1 :$mouse          = $!mouse,
        Int_0_or_1 :$order          = $!order,
        Int_0_or_1 :$show-hidden    = $!show-hidden,
        Int_0_to_2 :$enchanted      = $!enchanted,
        Int_0_to_2 :$justify        = $!justify,
        Int_0_to_2 :$layout         = $!layout,
        Str        :$dir            = $!dir,
        Str        :$prompt         = $!prompt,
        Str        :$current-dir    = $!current-dir
    --> IO::Path ) {
    CATCH {
        endwin();
    }
    %!o = :$mouse, :$order, :$show-hidden, :$enchanted, :$justify, :$layout, :$dir, :$prompt, :$current-dir;
    self!_choose_a_path( 0 );
}


sub choose-a-file    ( *%opt --> IO::Path ) is export( :DEFAULT, :choose-a-file ) { Term::Choose::Util.new().choose-a-file( |%opt ) }
method choose-a-file (
        Int_0_or_1 :$mouse          = $!mouse,
        Int_0_or_1 :$order          = $!order,
        Int_0_or_1 :$show-hidden    = $!show-hidden,
        Int_0_to_2 :$enchanted      = $!enchanted,
        Int_0_to_2 :$justify        = $!justify,
        Int_0_to_2 :$layout         = $!layout,
        Str        :$dir            = $!dir,
        Str        :$prompt         = $!prompt,
        Str        :$current-file   = $!current-file
    --> IO::Path ) {
    CATCH {
        endwin();
    }
    %!o = :$mouse, :$order, :$show-hidden, :$enchanted, :$justify, :$layout, :$dir, :$prompt, :$current-file;
    self!_choose_a_path( 1 );
}


method !_choose_a_path ( Int $is_a_file --> IO::Path ) {
    my $back        = ' < ';
    my $confirm     = ' = ';
    my $up          = ' .. ';
    my $select_file = ' >F ';
    my $wildcard    = ' ? ';
    my $curr;
    my @pre = Any;
    if $is_a_file {
        $curr = %!o<current-file> // Str;
        @pre.push: $select_file;
    }
    else {
        $curr = %!o<current-dir> // Str;
        @pre.push: $confirm;
    }
    @pre.push: $up;
    my Int $default_idx = %!o<enchanted>  ?? 2 !! 0;
    my IO::Path $dir      = %!o<dir>.IO;
    my IO::Path $previous = $dir;
    self!_init_term();

    loop {
        my IO::Path @dirs;
        try {
            if %!o<show-hidden> {
                @dirs = $dir.dir.grep( { .d } );
            }
            else {
                @dirs = $dir.dir.grep( { .d && .basename !~~ / ^ \. / } );
            }
            CATCH { #
                my $prompt = $dir.gist ~ ":\n" ~ $_;
                pause( [ 'Press ENTER to continue.' ], prompt => $prompt );
                if $dir.Str eq '/' {
                    self!_end_term();
                    return Empty;
                }
                $dir = $dir.dirname.IO;
                next;
            }
        }
        my Str $prompt;
        if $is_a_file || ! $curr {
            if $curr {
                $prompt ~= sprintf "Current file: %s\n", _string_gist( $curr );
                $prompt ~= sprintf "    New file: %s\n", _string_gist( $previous.add( $wildcard ) );
            }
            else {
                $prompt ~= sprintf "New file: %s\n", _string_gist( $previous.add( $wildcard ) );
            }
        }
        else {
            if $curr {
                $prompt  = sprintf "Current dir: %s\n", _string_gist( $curr );
                $prompt ~= sprintf "    New dir: %s\n", _string_gist( $dir );
            }
            else {
                $prompt ~= sprintf "New dir %s\n", _string_gist( $dir );
            }
        }
        $prompt ~= "\n" ~ %!o<prompt> if %!o<prompt>.defined;
        # Choose
        my $choice = $!tc.choose( [ |@pre, |@dirs.sort ], :prompt( $prompt ), :default( $default_idx ), :undef( $back ),
                                    :justify( %!o<justify> ), :layout( %!o<layout> ), :order( %!o<order> ) );
        if ! $choice.defined {
            self!_end_term();
            return;
        }
        elsif $choice eq $confirm {
            self!_end_term();
            return $previous;
        }
        elsif $choice eq $select_file {
            my IO::Path $file = self!_a_file( $dir, $curr, $back, $confirm, $wildcard ) // IO::Path;
            next if ! $file.defined; ###
            self!_end_term();
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
            $default_idx = %!o<enchanted>  ?? 2 !! 0;
        }
        $previous = $dir;
    }
}

method !_a_file ( IO::Path $dir, $curr, $back, $confirm, $wildcard --> IO::Path ) {
    my Str $previous;

    loop {
        my Str @files;
        try {
            if %!o<show-hidden> {
                @files = $dir.dir.grep( { .f } ).map: { .basename };
            }
            else {
                @files = $dir.dir.grep( { .f } ).map( { .basename } ).grep: { ! / ^ \. / };
            }
            CATCH { #
                my $prompt = $dir.gist ~ ":\n" ~ $_;
                pause( [ 'Press ENTER to continue.' ], prompt => $prompt );
                return;
            }
        }
        if ! @files.elems {
            my $prompt =  "Dir: $dir\nNo files in this directory.";
            pause( [ $back ], prompt => $prompt );
            return;
        }
        my @pre = ( Any, $confirm );
        my Str $prompt;
        if $curr {
            $prompt ~= sprintf "Current file: %s\n", _string_gist( $dir.add( $curr ) );
            $prompt ~= sprintf "    New file: %s\n", _string_gist( $dir.add( $previous // $wildcard ) );
        }
        else {
            $prompt ~= sprintf "New file: %s\n", _string_gist( $dir.add( $previous // $wildcard ) );
        }
        $prompt ~= "\n" ~ %!o<prompt> if %!o<prompt>.defined;
        # Choose
        my $choice = $!tc.choose( [ |@pre, |@files.sort ], :prompt( $prompt ), :undef( $back ),
                                  :justify( %!o<justify> ), :layout( %!o<layout> ), :order( %!o<order> ) );
        if ! $choice.defined {
            return;
        }
        elsif $choice eq $confirm {
            return if ! $previous.chars;
            return $dir.IO.add: $previous;
        }
        else {
            $previous = $choice;
        }
    }
}


sub choose-a-number ( Int $digits, *%opt ) is export( :DEFAULT, :choose-a-number ) {
    Term::Choose::Util.new().choose-a-number( $digits, |%opt );
}

method choose-a-number ( Int $digits,
        Int_0_or_1 :$mouse          = $!mouse,
        Str        :$prompt         = $!prompt,
        UInt       :$current-number = $!current-number,
        Str        :$name           = $!name,
        Str        :$thsd-sep       = $!thsd-sep
    ) {
    CATCH {
        endwin();
    }
    %!o = :$mouse, :$prompt, :$current-number, :$name, :$thsd-sep;
    my Str $sep = %!o<thsd-sep>;
    my Int $longest = $digits + ( $sep eq '' ?? 0 !! ( $digits - 1 ) div 3 );
    my Str $tab     = '  -  ';
    my Str $confirm = 'CONFIRM';
    my Str $back    = 'BACK';
    my Str @ranges;
    self!_init_term();

    if $longest * 2 + $tab.chars <= getmaxx( $!win ) {
        @ranges = ( sprintf " %*s%s%*s", $longest, '0', $tab, $longest, '9' );
        for 1 .. $digits - 1 -> $zeros { #
            my Str $begin = insert-sep( '1' ~ '0' x $zeros, $sep );
            my Str $end   = insert-sep( '9' ~ '0' x $zeros, $sep );
            @ranges.unshift( sprintf " %*s%s%*s", $longest, $begin, $tab, $longest, $end );
        }
        $confirm = sprintf "%-*s", $longest * 2 + $tab.chars, $confirm;
        $back    = sprintf "%-*s", $longest * 2 + $tab.chars, $back;
    }
    else {
        @ranges = ( sprintf "%*s", $longest, '0' ); #
        for 1 .. $digits - 1 -> $zeros { #
            my Str $begin = insert-sep( '1' ~ '0' x $zeros, $sep );
            @ranges.unshift( sprintf "%*s", $longest, $begin );
        }
    }

    my Int %numbers;
    my Str $result;
    my Str $undef = '--';
    my $tmp_name = %!o<name> ?? ' ' ~ %!o<name> !! '';
    my $fmt_cur = "Current{$tmp_name}: %{$longest}s\n";
    my $fmt_new = "    New{$tmp_name}: %{$longest}s\n";

    NUMBER: loop {
        my Str $new_number = $result // $undef;
        my Str $prompt;
        if %!o<current-number>.defined {
            if print-columns( sprintf $fmt_cur, 1 ) <= getmaxx( $!win ) {
                $prompt  = sprintf $fmt_cur, insert-sep( %!o<current-number>, $sep );
                $prompt ~= sprintf $fmt_new, $new_number;
            }
            else {
                $prompt  = sprintf "%{$longest}s\n", insert-sep( %!o<current-number>, $sep );
                $prompt ~= sprintf "%{$longest}s\n", $new_number;
            }
        }
        else {
            $prompt = sprintf $fmt_new, $new_number;
            if print-columns( $prompt ) > getmaxx( $!win ) {
                $prompt = $new_number;
            }
        }
        $prompt ~= "\n" ~ %!o<prompt> if %!o<prompt>.defined;
        my @pre = ( Any, $confirm );
        # Choose
        my $range = $!tc.choose( [ |@pre, |@ranges ], :prompt( $prompt ), :layout( 2 ), :justify( 1 ), :undef( $back ) );
        if ! $range.defined {
            if $result.defined {
                $result = Str;
                next NUMBER;
            }
            else {
                self!_end_term();
                return;
            }
        }
        elsif $range eq $confirm {
            self!_end_term();
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
        my $num = $!tc.choose( [ Any, |@choices, $reset ], :prompt( $prompt ), :layout( 1 ),
                                                           :justify( 2 ), :order( 0 ), :undef( $back_short ) );
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
        $result = insert-sep( $num_combined, $sep ).Str;
    }
}


sub choose-a-subset ( @list, *%opt ) is export( :DEFAULT, :choose-a-subset ) {
    Term::Choose::Util.new().choose-a-subset( @list, |%opt );
}

method choose-a-subset ( @list,
        Int_0_or_1 :$index          = $!index,
        Int_0_or_1 :$mouse          = $!mouse,
        Int_0_or_1 :$order          = $!order,
        Int_0_to_2 :$justify        = $!justify,
        Int_0_to_2 :$layout         = 2,
        Str        :$prefix         = $!prefix,
        Str        :$prompt         = 'Choose:',
        List       :$current-list   = $!current-list
    ) {
    CATCH {
        endwin();
    }
    %!o = :$mouse, :$order, :$index, :$justify, :$layout, :$prefix, :$prompt, :$current-list;
    my Str $tmp_prefix  = %!o<prefix> // ( %!o<layout> == 2 ?? '- ' !! '' );
    my Str $confirm = 'CONFIRM';
    my Str $back    = 'BACK';
    if %!o<layout> == 2 && $tmp_prefix.chars {
        $confirm = ( ' ' x $tmp_prefix.chars ) ~ $confirm;
        $back    = ( ' ' x $tmp_prefix.chars ) ~ $back;
    }
    my Str $key_cur = 'Current [';
    my Str $key_new = '    New [';
    my Int $len_key = max $key_cur.chars, $key_new.chars;
    my @new_idx;
    my @new_val;
    my @pre = ( Any, $confirm );
    self!_init_term();

    loop {
        my Str $prompt = '';
        if %!o<current-list> {
            $prompt ~= $key_cur ~ _array_gist( %!o<current-list> ) ~ "\n";
            $prompt ~= $key_new ~ _array_gist( @new_val          ) ~ "\n";
        }
        else {
            $prompt ~= $key_new ~ _array_gist( @new_val ) ~ "\n";
        }
        $prompt ~= "\n" ~ %!o<prompt> if %!o<prompt>.defined;
        my Str @list_prefixed = @list.map( { $tmp_prefix ~ $_ } );
        # Choose
        my Int @idx = $!tc.choose-multi( [ |@pre, |@list_prefixed ], :prompt( $prompt ), :no-spacebar( |^@pre ),
                                           :undef( $back ), :lf( 0, $len_key ), :justify( %!o<justify> ), :1index,
                                           :layout( %!o<layout> ), :order( %!o<order> ) );
        if ! @idx[0] { #
            if @new_idx.elems {
                @new_idx = Empty;
                @new_val = Empty;
                next;
            }
            else {
                self!_end_term();
                return Empty;
            }
        }
        if @idx[0] == 1 {
            @idx.shift;
            @new_val.append: @list[@idx >>->> @pre.elems];
            @new_idx.append: @idx >>->> @pre.elems;
            self!_end_term();
            return %!o<index> ?? @new_idx !! @new_val;
        }
        @new_val.append: @list[@idx >>->> @pre.elems]; #
        @new_idx.append: @idx >>->> @pre.elems; #
    }
}


sub settings-menu ( @menu, %setup, *%opt ) is export( :settings-menu ) {
    Term::Choose::Util.new().settings-menu( @menu, %setup, |%opt );
}

method settings-menu ( @menu, %setup,
        Int_0_or_1 :$in-place       = $!in-place,
        Int_0_or_1 :$mouse          = $!mouse,
        Str        :$prompt         = 'Choose:'
    ) {
    CATCH {
        endwin();
    }
    %!o = :$mouse, :$in-place, :$prompt;
    my Str $confirm = '  CONFIRM';
    my Str $back    = '  BACK';
    my Int $name_w = 0;
    my %new_setup;
    for @menu -> ( Str $key, Str $name, $ ) {
        my Int $len = print-columns( $name );
        $name_w = $len if $len > $name_w;
        %setup{$key} //= 0;
        %new_setup{$key} = %setup{$key};
    }
    my $no_change = %!o<in-place> ?? 0 !! {};
    my $count = 0;
    self!_init_term();

    loop {
        my Str @print_keys;
        for @menu -> ( Str $key, Str $name, @values ) {
            @print_keys.push: sprintf "%-*s [%s]", $name_w, $name, @values[%new_setup{$key}];
        }
        my @pre = ( Any, $confirm );
        my @choices = |@pre, |@print_keys;
        # Choose
        my Int $idx = $!tc.choose( @choices, :prompt( %!o<prompt> ), :1index, :2layout, :0justify, :undef( $back ) );
        if ! $idx.defined {
            self!_end_term();
            return $no_change;
        }
        my $choice = @choices[$idx];
        if ! $choice.defined {
            self!_end_term();
            return $no_change;
        }
        elsif $choice eq $confirm {
            my Int $change = 0;
            if $count {
                for @menu -> ( Str $key, $, $ ) {
                    next                            if %setup{$key} == %new_setup{$key};
                    %setup{$key} = %new_setup{$key} if %!o<in-place>;
                    $change++;
                }
            }
            self!_end_term();
            return $no_change if ! $change;
            return 1          if %!o<in-place>;
            return %new_setup;
        }
        my Str $key = @menu[$idx-@pre][0];
        my @values  = @menu[$idx-@pre][2];
        %new_setup{$key}++;
        %new_setup{$key} = 0 if %new_setup{$key} == @values.elems;
        $count++;
    }
}


sub insert-sep ( $num, $sep = ' ' ) is export( :insert-sep ) {
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


sub unicode-sprintf ( Str $str, Int $avail_col_w, Int $justify, @cache? ) is export( :unicode-sprintf ) {
    my Int $str_length = print-columns( $str );
    if $str_length > $avail_col_w {
        return to-printwidth( $str, $avail_col_w, False, @cache ).[0];
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

=head1 DESCRIPTION

This module provides some CLI related functions.

=head1 CONSTRUCTOR

The constructor method C<new> can be called with optional named arguments:

=begin code

    my $new = Term::Choose::Util.new( :mouse(1) )

=end code

Additionally to the different options mentioned below one can pass the option I<win> to the C<new>-method. The option

I<win> expects as its value a WINDOW object - the return value of NCurses initscr. If set, the different methods use

this global window instead of creating their own without calling endwin to restores the terminal before returning.

=head1 ROUTINES

Values in brackets are default values.

Options valid for all routines are

=item1 mouse

Set to C<0> the mouse mode is disabled, set to C<1> the mouse mode is enabled.

Values: [0],1.

=item1 prompt

If set shows an additionally prompt line before the choices.

=head2 choose-a-dir

=begin code

    $chosen_directory = choose-a-dir( :layout(1), ... )

=end code

With C<choose-a-dir> the user can browse through the directory tree (as far as the granted rights permit it) and
choose a directory which is returned.

To move around in the directory tree:

- select a directory and press C<Return> to enter in the selected directory.

- choose the "up"-menu-entry ("C< .. >") to move upwards.

To return the current working-directory as the chosen directory choose "C< = >".

The "back"-menu-entry ("C< E<lt> >") causes C<choose-a-dir> to return nothing.

It can be set the following options:

=item1 current-dir

If set, C<choose-a-dir> shows I<current-dir> as the current directory.

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

=item1 order

If set to 1, the items are ordered vertically else they are ordered horizontally.

This option has no meaning if I<layout> is set to 2.

Values: 0,[1].

=item1 show-hidden

If enabled, hidden directories are added to the available directories.

Values: 0,[1].

=head2 choose-a-file

=begin code

    $chosen_file = choose-a-file( :layout(1), ... )

=end code

Browse the directory tree like with C<choose-a-dir>. Select "C<E<gt>F>" to get the files of the current directory. To
return the chosen file select "C< = >".

See L<#choose-a-dir> for the different options. Instead I<current-dir> C<choose-a-file> has I<current-file>.

=head2 choose-dirs

=begin code

    @chosen_directories = choose-dirs( :layout(1), ... )

=end code

C<choose-dirs> is similar to C<choose-a-dir> but it is possible to return multiple directories.

"C< . >" adds the current directory to the list of chosen directories and "C< = >" returns the chosen list of
directories.

The "back"-menu-entry ( "C< E<lt> >" ) resets the list of chosen directories if any. If the list of chosen directories
is empty, "C< E<lt> >" causes C<choose-dirs> to return nothing.

C<choose-dirs> uses the same option as C<choose-a-dir>. Instead I<current-dir> C<choose_dirs> has I<current-dirs>. 
I<current-dirs> expects as its value a list (directories shown as the current directories).

=head2 choose-a-number

=begin code

    my $current-number = 139;
    for ( 1 .. 3 ) {
        $current-number = choose-a-number( 5, :$current-number, :name<Testnumber> );
    }

=end code

This function lets you choose/compose a number (unsigned integer) which is returned.

The fist argument - "digits" - is an integer and determines the range of the available numbers. For example setting the
first argument to 6 would offer a range from 0 to 999999.

The available options:

=item1 current-number

The current value (integer). If set, two prompt lines are displayed - one for the current number and one for the new number.

=item1 name

Sets the name of the number seen in the prompt line.

Default: empty string ("");

=item1 thsd-sep

Sets the thousands separator.

Default: comma (,).

=head2 choose-a-subset

=begin code

    $subset = choose-a-subset( @available_items, :current-list( @current_subset ) )

=end code

C<choose-a-subset> lets you choose a subset from a list.

The first argument is the list of choices. The following arguments are the options:

=item1 current-list

This option expects as its value the current subset of the available list. If set, two prompt lines are displayed - one
for the current subset and one for the new subset. Even if the option I<index> is true the passed current subset is made
of values and not of indexes.

The subset is returned as an array.

=item1 index

If true, the index positions in the available list of the made choices is returned.

=item1 justify

Elements in columns are left justified if set to 0, right justified if set to 1 and centered if set to 2.

Values: [0],1,2.

=item1 layout

See the option I<layout> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>.

Values: 0,1,[2].

=item1 order

If set to 1, the items are ordered vertically else they are ordered horizontally.

This option has no meaning if I<layout> is set to 2.

Values: 0,[1].

=item1 prefix

I<prefix> expects as its value a string. This string is put in front of the elements of the available list before
printing. The chosen elements are returned without this I<prefix>.

The default value is "- " if the I<layout> is 2 else the default is the empty string ("").

=head2 choose-a-subset

=begin code

    my @menu = (
        ( 'enable_logging', "- Enable logging", ( 'NO', 'YES' )   ),
        ( 'case_sensitive', "- Case sensitive", ( 'NO', 'YES' )   ),
        ( 'attempts',       "- Attempts"      , ( '1', '2', '3' ) )
    );

    my %config = (
        'enable_logging' => 0,
        'case_sensitive' => 1,
        'attempts'       => 2
    );


    my %tmp_config = settings-menu( @menu, %config, in-place => 0 );
    if %tmp_config {
        for %tmp_config.kv -> $key, $value {
            %config{$key} = $value;
        }
    }


    my $changed = settings-menu( @menu, %config, in-place => 1 );
    if $changed {
        say "Settings have been changed.";
    }

=end code

The first argument is a list of lists. Each of the lists have three elements:

    the option name

    the prompt string

    a list of the available values for the option

The second argument is a hash:

    the hash key is the option name

    the hash value (zero based index) sets the current value for the option.

The following arguments can be the different options.

=item1 in-place

If enabled, the configuration hash (second argument) is edited in place.

Values: 0,[1].

=head1 AUTHOR

Matthäus Kiem <cuer2s@gmail.com>

=head1 CREDITS

Thanks to the people from L<Perl-Community.de|http://www.perl-community.de>, from
L<stackoverflow|http://stackoverflow.com> and from L<#perl6 on irc.freenode.net|irc://irc.freenode.net/#perl6> for the
help.

=head1 LICENSE AND COPYRIGHT

Copyright 2016-2018 Matthäus Kiem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
