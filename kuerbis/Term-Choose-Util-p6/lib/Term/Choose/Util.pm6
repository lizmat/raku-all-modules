use v6;
unit class Term::Choose::Util;

my $VERSION = '0.006';

use Term::Choose;
use Term::Choose::NCurses :all;
use Term::Choose::LineFold :all;



sub _ncurses_win {
    my int32 constant LC_ALL = 6; # From locale.h
    setlocale(LC_ALL, "");
    my Term::Choose::NCurses::WINDOW $win = initscr();
    return $win;
}


sub choose_dirs ( %opt? ) is export( :MANDATORY ) {
    my %o = _prepare_opt_choose_path( %opt );
    my @chosen_dirs;
    my IO::Path $dir = %o<dir>;
    my IO::Path $previous = $dir;
    my @pre = ( Any, %o<confirm>, %o<add_dir>, %o<up> );
    my Int $default_idx = %o<enchanted> ?? @pre.end !! 0;
    my $tc = Term::Choose.new(
        { undef => %o<back>, mouse => %o<mouse>, justify => %o<justify>, layout => %o<layout>, order => %o<order> },
        _ncurses_win()
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
                    return [];
                }
                $dir = $dir.dirname.IO;
                next;
            }
        }
        my Int $len_key;
        my Str $prompt;
        $prompt ~= %o<prompt> ~ "\n" if %o<prompt>;
        my Str $current = 'Current';
        my Str $new     = 'New';
        if %o<current>.defined {
            $len_key = $current.chars > $new.chars ?? $current.chars !! $new.chars;
            $prompt ~= sprintf "%*s: %s\n",   $len_key, 'Current', %o<current>.map( { "\"$_\"" } ).join( ', ' );
            $prompt ~= sprintf "%*s: %s\n\n", $len_key, 'New',    @chosen_dirs.map( { "\"$_\"" } ).join( ', ' );
        }
        else {
            $len_key = $new.chars;
            $prompt ~= sprintf "%*s: %s\n\n", $len_key, 'New', @chosen_dirs.map( { "\"$_\"" } ).join( ', ' );
        }
        my Str $key_cwd = 'pwd: ';
        $prompt  = line_fold( $prompt,              term_width(), '', ' ' x $len_key       );
        $prompt ~= line_fold( $key_cwd ~ $previous, term_width(), '', ' ' x $key_cwd.chars );
        $prompt ~= "\n";
        # Choose
        my $choice = $tc.choose(
            [ |@pre, |@dirs.sort ],
            { prompt => $prompt, default => $default_idx }
        );
        if ! $choice.defined {
            if ! @chosen_dirs.elems {
                endwin();
                return [];
            }
            @chosen_dirs = [];
            next;
        }
        $default_idx = %o<enchanted>  ?? @pre.end !! 0;
        if $choice eq %o<confirm> {
            endwin();
            return @chosen_dirs;
        }
        elsif $choice eq %o<add_dir> {
            @chosen_dirs.push( $previous );
            $dir = $dir.dirname.IO;
            $default_idx = 0 if $previous eq $dir;
            $previous = $dir;
            next;
        }
        $dir = $choice eq %o<up> ?? $dir.dirname.IO !! $choice.IO;
        $default_idx = 0 if $previous eq $dir;
        $previous = $dir;
    }
}


sub _prepare_opt_choose_path ( %opt ) {
    my IO::Path $dir = %opt<dir>.defined ?? %opt<dir>.IO !! $*HOME;
    if ! $dir.d && $dir ne $*HOME {
         my Str $prompt = "Could not find the directory \"$dir\". Falling back to the home directory.";
         pause( [ 'Press ENTER to continue' ], { prompt => $prompt } );
         $dir = $*HOME;
    }
    die "Could not find the home directory \"$dir\"" if ! $dir.d;
    my %defaults = (
        show_hidden  => 1,
        mouse        => 0,
        layout       => 1,
        order        => 1,
        justify      => 0,
        enchanted    => 1,
        confirm      => ' = ',
        add_dir      => ' . ',
        up           => ' .. ',
        file         => ' >F ',
        back         => ' < ',
        #dir         => Str,
        #current      => Any,
        #prompt       => Any,
    );
    #for my %opt ( keys %%opt ) {
    #    die "%opt: invalid option!" if ! exists %defaults->{%opt};
    #}
    my %o;
    %o<dir> = $dir;
    for %defaults.keys -> $key {
        %o{$key} = %opt{$key} // %defaults{$key};
    }
    return %o;
}


sub choose_a_dir ( %opt? --> IO::Path ) is export( :MANDATORY ) {
    return _choose_a_path( %opt, 0 );
}

sub choose_a_file ( %opt? --> IO::Path ) is export( :MANDATORY ) {
    return _choose_a_path( %opt, 1 );
}

sub _choose_a_path ( %opt, Int $is_a_file --> IO::Path ) {
    my %o = _prepare_opt_choose_path( %opt );
    my @pre;
    @pre[0] = Any;
    @pre[1] = $is_a_file ?? %o<file> !! %o<confirm>;
    @pre[2] = %o<up>;
    my Int $default_idx   = %o<enchanted>  ?? 2 !! 0;
    my Str $curr          = %o<current> // Str;
    my IO::Path $dir      = %o<dir>;
    my IO::Path $previous = $dir;
    my $tc = Term::Choose.new(
        { undef => %o<back>, mouse => %o<mouse>, justify => %o<justify>, layout => %o<layout>, order => %o<order> },
        _ncurses_win()
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
                    return [];
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
        elsif $choice eq %o<confirm> {
            endwin();
            return $previous;
        }
        elsif $choice eq %o<file> {
            my IO::Path $file = _a_file( %o, $dir, $tc ) // IO::Path;
            next if ! $file.defined; ###
            endwin();
            return $file;
        }
        if $choice eq %o<up> {
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
    my Str $sep     = %opt<thsd_sep>                    // ',';
    my Str $current = insert_sep( %opt<current>, $sep ) // Str;
    my Str $name    = %opt<name>                        // '';
    my Int $mouse   = %opt<mouse>                       // 0;
    #-------------------------------------------#
    my Int $longest = $digits + ( $sep eq '' ?? 0 !! ( $digits - 1 ) div 3 );
    my Str $tab     = '  -  ';
    my Str $confirm = 'CONFIRM';
    my Str $back    = 'BACK';
    my Str @ranges;

    if $longest * 2 + $tab.chars <= term_width() {
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
    $name = ' ' ~ $name if $name;
    my $fmt_cur = "Current{$name}: %{$longest}s\n";
    my $fmt_new = "    New{$name}: %{$longest}s\n";
    my $tc = Term::Choose.new(
        { mouse => %opt<mouse> },
        _ncurses_win()
    );

    NUMBER: loop {
        my Str $new_number = $result // $undef;
        my Str $prompt;
        if $current.defined {
            if print_columns( sprintf $fmt_cur, 1 ) <= term_width() {
                $prompt  = sprintf $fmt_cur, $current;
                $prompt ~= sprintf $fmt_new, $new_number;
            }
            else {
                $prompt  = sprintf "%{$longest}s\n", $current;
                $prompt ~= sprintf "%{$longest}s\n", $new_number;
            }
        }
        else {
            $prompt = sprintf $fmt_new, $new_number;
            if print_columns( $prompt ) > term_width() {
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
    my Int $index   = %opt<index>   // 0;
    my Int $mouse   = %opt<mouse>   // 0;
    my Int $layout  = %opt<layout>  // 2;
    my Int $order   = %opt<order>   // 1;
    my Str $prefix  = %opt<prefix>  // ( $layout == 2 ?? '- ' !! '' );
    my Int $justify = %opt<justify> // 0;
    my Str $prompt  = %opt<prompt>  // 'Choose:';
    my     @current = %opt<current> // [];
    #--------------------------------------#
    my Str $confirm = 'CONFIRM';
    my Str $back    = 'BACK';
    if $prefix.chars {
        $confirm = ( ' ' x $prefix.chars ) ~ $confirm;
        $back    = ( ' ' x $prefix.chars ) ~ $back;
    }
    my Str $key_cur = 'Current > ';
    my Str $key_new = '    New > ';
    my Int $len_key = $key_cur.chars > $key_new.chars ?? $key_cur.chars !! $key_new.chars;
    my @new_idx;
    my @new_val;
    my @pre = ( Any, $confirm );
    my $tc = Term::Choose.new(
        { layout => $layout, mouse => $mouse, justify => $justify, order => $order,
          no_spacebar => [ 0 .. @pre.end ], undef => $back, lf => [ 0, $len_key ] },
        _ncurses_win()
    );

    loop {
        my Str $lines = '';
        $lines ~= $key_cur ~ @current.join( ', ' ).map( { "\"$_\"" } ) ~ "\n"   if @current.elems;
        $lines ~= $key_new ~ @new_val.join( ', ' ).map( { "\"$_\"" } ) ~ "\n\n";
        $lines ~= $prompt;
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
                return [];
            }
        }
        if @idx[0] == 1 {
            @idx.shift;
            @new_val.append( @available[@idx >>->> @pre.elems] ); # map
            @new_idx.append( @idx >>->> @pre.elems );
            endwin();
            return $index ?? @new_idx !! @new_val;
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
    my Str $prompt   = %opt<prompt>   // 'Choose:';
    my Int $in_place = %opt<in_place> // 1;
    my Int $mouse    = %opt<mouse>    // 0;
    #-------------------------------------#
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
    my $no_change = %opt<in_place> ?? 0 !! {};
    my $count = 0;
    my $tc = Term::Choose.new(
        { prompt => $prompt, layout => 2, justify => 0, 
          mouse => $mouse, undef => $back },
        _ncurses_win()
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
                    if $in_place {
                        %setup{$key} = %new_setup{$key};
                    }
                    $change++;
                }
            }
            endwin();
            return $no_change if ! $change;
            return 1          if $in_place;
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
    my $new = $<sign> // '';
    $new   ~= $<int>.flip.comb( / . ** 1..3 / ).join( $sep ).flip;
    $new   ~= $<rest> // '';
    return $new;
}

sub print_hash ( %hash, %opt? ) is export( :all ) {
    my Int $left_margin  = %opt<left_margin>  // 1;
    my Int $right_margin = %opt<right_margin> // 2;
    my Str @keys         = %opt<keys>         // %hash.keys.sort;
    my Int $key_w        = %opt<len_key>      // @keys.map( { print_columns $_ } ).max;
    my Int $maxcols      = %opt<maxcols>      // Int;
    my Int $mouse        = %opt<mouse>        // 0;
    my Str $preface      = %opt<preface>      // Str;
    my Str $prompt       = %opt<prompt>       // ( $preface.defined  ?? '' !! 'Close with ENTER' );
    #-----------------------------------------------------------------#
    if ! $maxcols || $maxcols > term_width() {
        $maxcols = term_width() - $right_margin; #
    }
    $key_w += $left_margin;
    my Str $sep   = ' : ';
    my Int $sep_w = $sep.chars;
    if $key_w + $sep_w > $maxcols div 3 * 2 {
        $key_w = $maxcols div 3 * 2 - $sep_w;
    }
    my Str @vals;
    if $preface.defined {
        @vals.append( line_fold( $preface, $maxcols, '', '' ).lines );
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
    pause(
        @vals,
        { prompt => $prompt, layout => 2, justify => 0, mouse => $mouse, empty => ' ' }
    );
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

Version 0.006

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

Set the starting point directory. Defaults to the home directory or the current working directory if the home directory
cannot be found.

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

Values: [0],1,2.

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

Different to C<choose_a_dir>:

"C< . >" adds the current directory to the list of chosen directories.

To return the chosen list of directories select the "confirm"-menu-entry "C< = >".

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

The current value. If set, two prompt lines are displayed - one for the current number and one for the new number.

=item1 name

Sets the name of the number seen in the prompt line.

Default: empty string ("");

=item1 mouse

See the option I<mouse> in L<Term::Choose|https://github.com/kuerbis/Term-Choose-p6>

Values: [0],1,2.

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

Values: [0],1,2.

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
