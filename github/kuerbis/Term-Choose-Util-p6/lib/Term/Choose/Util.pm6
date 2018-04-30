use v6;
unit class Term::Choose::Util:ver<1.1.0>;

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
has Int_0_or_1 $.mouse          = 0;
has Int_0_or_1 $.order          = 1;
has Int_0_or_1 $.show-hidden    = 1;
has Int_0_or_1 $.small-on-top   = 0;
has Int_0_or_1 $.remove-chosen  = 0;
has Int_0_or_1 $.fmt-chosen     = 0;
has Int_0_to_2 $.enchanted      = 1;
has Int_0_to_2 $.justify        = 0;
has Int_0_to_2 $.layout         = 1;
has List       $.mark           = [];
has Str        $.dir            = $*HOME.Str;
has Str        $.name;
has Str        $.prefix;
has Str        $.info           = '';
has Str        $.prompt         = '';
has Str        $.thsd-sep       = ',';
has Str        $.back           = 'BACK';
has Str        $.confirm        = 'CONFIRM';
has Str        $.add-dir        = ' ++ ';
has Str        $.up             = ' .. ';
has Str        $.choose-file    = ' >F ';

has Term::Choose $!tc;


method !_init_term {
    if ! $!win {
        $!reset_win = True;
        my int32 constant LC_ALL = 6;
        setlocale( LC_ALL, "" );
        $!win = initscr();
    }
    $!tc = Term::Choose.new( :win( $!win ) );
}

method !_end_term {
    return if ! $!reset_win;
    endwin();
}


sub _string_gist ( $_ ) { S:g/' '/\ / }


sub choose-dirs ( *%opt ) is export( :DEFAULT, :choose-dirs ) { Term::Choose::Util.new().choose-dirs( |%opt ) }

method choose-dirs (
        Int_0_or_1 :$mouse          = $!mouse,
        Int_0_or_1 :$order          = $!order,
        Int_0_or_1 :$show-hidden    = $!show-hidden,
        Int_0_or_1 :$enchanted      = $!enchanted,
        Int_0_to_2 :$justify        = $!justify,
        Int_0_to_2 :$layout         = $!layout,
        Str        :$dir            = $!dir,
        Str        :$info           = $!info,
        Str        :$name           = $!name,
        Str        :$prompt         = ' ',
        Str        :$back           = $!back,
        Str        :$confirm        = $!confirm,
        Str        :$add-dir        = $!add-dir,
        Str        :$up             = $!up,
    ) {
    CATCH {
        endwin();
    }
    my @chosen_dirs;
    my IO::Path $tmp_dir = $dir.IO;
    my IO::Path $previous = $tmp_dir;
    my @pre = ( Any, $confirm, $add-dir, $up );
    my Int $default = $enchanted ?? @pre.end !! 0;
    self!_init_term();

    loop {
        my IO::Path @dirs;
        try {
            if $show-hidden {
                @dirs = $tmp_dir.dir.grep: { .d };
            }
            else {
                @dirs = $tmp_dir.dir.grep: { .d && .basename !~~ / ^ \. / };
            }
            CATCH { #
                my $prompt = $tmp_dir.gist ~ ":\n" ~ $_;
                pause( [ 'Press ENTER to continue.' ], :$prompt );
                if $tmp_dir.absolute eq '/' {
                    self!_end_term();
                    return Empty;
                }
                $tmp_dir = $tmp_dir.dirname.IO;
                next;
            }
        }
        my @tmp;
        @tmp.push: $info if $info.chars;
        @tmp.push: ( $name // 'New: ' ) ~ @chosen_dirs.map: { _string_gist( $_ ) };
        @tmp.push: " ++[$previous]";
        @tmp.push: $prompt if $prompt.chars;
        # Choose
        my $choice = $!tc.choose(
            [ |@pre, |@dirs.sort ],
            :prompt( @tmp.join: "\n" ), :$default, :undef( $back ), :$justify,
            :$layout, :$order, :lf( 0, ($name//'').chars ), :$mouse
        );
        if ! $choice.defined {
            if @chosen_dirs.elems {
                @chosen_dirs.pop;
                next;
            }
            self!_end_term();
            return Empty;
        }
        $default = $enchanted ?? @pre.end !! 0;
        if $choice eq $confirm {
            self!_end_term();
            return @chosen_dirs;
        }
        elsif $choice eq $add-dir {
            @chosen_dirs.push: $previous;
            $tmp_dir = $tmp_dir.dirname.IO;
            $default = 0 if $previous eq $tmp_dir;
            $previous = $tmp_dir;
            next;
        }
        $tmp_dir = $choice eq $up ?? $tmp_dir.dirname.IO !! $choice.IO;
        $default = 0 if $previous eq $tmp_dir;
        $previous = $tmp_dir;
    }
}


sub choose-a-dir ( *%opt --> IO::Path ) is export( :DEFAULT, :choose-a-dir ) { Term::Choose::Util.new().choose-a-dir( |%opt ) }

method choose-a-dir (
        Int_0_or_1 :$mouse          = $!mouse,
        Int_0_or_1 :$order          = $!order,
        Int_0_or_1 :$show-hidden    = $!show-hidden,
        Int_0_or_1 :$enchanted      = $!enchanted,
        Int_0_to_2 :$justify        = $!justify,
        Int_0_to_2 :$layout         = $!layout,
        Str        :$dir            = $!dir,
        Str        :$info           = $!info,
        Str        :$prompt         = $!prompt,
        Str        :$back           = $!back,
        Str        :$confirm        = $!confirm,
        Str        :$up             = $!up,
    --> IO::Path ) {
    CATCH {
        endwin();
    }
    %!o = :$mouse, :$order, :$show-hidden, :$enchanted, :$justify, :$layout, :$dir, :$info, :$prompt, :$back, :$confirm, :$up;
    self!_choose_a_path( 0 );
}


sub choose-a-file    ( *%opt --> IO::Path ) is export( :DEFAULT, :choose-a-file ) { Term::Choose::Util.new().choose-a-file( |%opt ) }
method choose-a-file (
        Int_0_or_1 :$mouse          = $!mouse,
        Int_0_or_1 :$order          = $!order,
        Int_0_or_1 :$show-hidden    = $!show-hidden,
        Int_0_or_1 :$enchanted      = $!enchanted,
        Int_0_to_2 :$justify        = $!justify,
        Int_0_to_2 :$layout         = $!layout,
        Str        :$dir            = $!dir,
        Str        :$info           = $!info,
        Str        :$prompt         = $!prompt,
        Str        :$back           = $!back,
        Str        :$confirm        = $!confirm,
        Str        :$up             = $!up,
        Str        :$choose-file    = $!choose-file,
    --> IO::Path ) {
    CATCH {
        endwin();
    }
    %!o = :$mouse, :$order, :$show-hidden, :$enchanted, :$justify, :$layout, :$dir, :$info, :$prompt, :$back, :$confirm, :$up, :$choose-file;
    self!_choose_a_path( 1 );
}


method !_choose_a_path ( Int $is_a_file --> IO::Path ) {
    my $wildcard = ' ? ';
    my @pre = ( Any, $is_a_file ?? %!o<choose-file> !! %!o<confirm>, %!o<up> );
    my Int $default = %!o<enchanted>  ?? 2 !! 0;
    my IO::Path $dir = %!o<dir>.IO;
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
                pause( [ 'Press ENTER to continue.' ], :$prompt );
                if $dir.Str eq '/' {
                    self!_end_term();
                    return Empty;
                }
                $dir = $dir.dirname.IO;
                next;
            }
        }
        my @tmp;
        if %!o<info>.chars {
            @tmp.push: %!o<info>;
        }
        if $is_a_file {              # New file
            @tmp.push: ( %!o<name> // 'New: ' ) ~ _string_gist( $previous.add: $wildcard );
        }
        else {
            @tmp.push: ( %!o<name> // 'New: ' ) ~ _string_gist( $previous );
        }
        if %!o<prompt>.chars {
            @tmp.push: %!o<prompt>;
        }
        my $choices = [ |@pre, |@dirs.sort ];
        # Choose
        my $idx = $!tc.choose(
            $choices,
            :$default, :undef( %!o<back> ), :prompt( @tmp.join: "\n" ), :1index, :justify( %!o<justify> ),
            :layout( %!o<layout> ), :order( %!o<order> ), :mouse( %!o<mouse> )
        );
        if ! $idx.defined || ! $choices[$idx].defined {
            self!_end_term();
            return;
        }
        if $choices[$idx] eq %!o<confirm> {
            self!_end_term();
            return $previous;
        }
        elsif %!o<choose-file>.defined && $choices[$idx] eq %!o<choose-file> {
            my IO::Path $file = self!_a_file( $dir, $wildcard ) // IO::Path;
            next if ! $file.defined;
            self!_end_term();
            return $file;
        }
        if $choices[$idx] eq %!o<up> {
            $dir = $dir.dirname.IO;
        }
        else {
            $dir = $choices[$idx];
        }
        if ( $previous eq $dir ) {
            $default = 0;
        }
        else {
            $default = %!o<enchanted>  ?? 2 !! 0;
        }
        $previous = $dir;
    }
}

method !_a_file ( IO::Path $dir, $wildcard --> IO::Path ) {
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
                pause( [ 'Press ENTER to continue.' ], :$prompt );
                return;
            }
        }
        if ! @files.elems {
            my $prompt =  "Dir: $dir\nNo files in this directory.";
            pause( [ %!o<back> ], prompt => $prompt );
            return;
        }
        my @pre = ( Any, %!o<confirm> );
        my @tmp;
        @tmp.push: %!o<info> if %!o<info>.chars;
        @tmp.push: ( %!o<name> // 'New: ' ) ~ _string_gist( $dir.add( $previous // $wildcard ) ); # New file
        @tmp.push: %!o<prompt> if %!o<prompt>.chars;
        # Choose
        my $choice = $!tc.choose(
            [ |@pre, |@files.sort ],
            :prompt( @tmp.join: "\n" ), :undef( %!o<back> ), :justify( %!o<justify> ),
            :layout( %!o<layout> ), :order( %!o<order> ), :mouse( %!o<mouse> )
        );
        if ! $choice.defined {
            return;
        }
        elsif $choice eq %!o<confirm> {
            return if ! $previous.defined;
            return $dir.IO.add: $previous;
        }
        else {
            $previous = $choice;
        }
    }
}


sub choose-a-number ( Int $digits = 7, *%opt ) is export( :DEFAULT, :choose-a-number ) {
    Term::Choose::Util.new().choose-a-number( $digits, |%opt );
}

method choose-a-number ( Int $digits = 7,
        Int_0_or_1 :$mouse          = $!mouse,
        Int_0_or_1 :$small-on-top   = $!small-on-top,
        Str        :$info           = $!info,
        Str        :$prompt         = $!prompt,
        Str        :$name           = $!name,
        Str        :$thsd-sep       = $!thsd-sep,
        Str        :$back           = $!back,
        Str        :$confirm        = $!confirm,
    ) {
    CATCH {
        endwin();
    }
    my Str $sep = $thsd-sep;
    my Int $longest = $digits + ( $sep eq '' ?? 0 !! ( $digits - 1 ) div 3 );
    my Str $tab     = '  -  ';
    my Str @ranges;
    my $tmp_confirm;
    my $tmp_back;
    self!_init_term();

    if $longest * 2 + $tab.chars <= getmaxx( $!win ) {
        @ranges = ( sprintf " %*s%s%*s", $longest, '0', $tab, $longest, '9' );
        for 1 .. $digits - 1 -> $zeros { #
            my Str $begin = insert-sep( '1' ~ '0' x $zeros, $sep );
            my Str $end   = insert-sep( '9' ~ '0' x $zeros, $sep );
            @ranges.unshift( sprintf " %*s%s%*s", $longest, $begin, $tab, $longest, $end );
        }
        $tmp_confirm = sprintf "%-*s", $longest * 2 + $tab.chars, $confirm;
        $tmp_back    = sprintf "%-*s", $longest * 2 + $tab.chars, $back;
    }
    else {
        @ranges = ( sprintf "%*s", $longest, '0' ); #
        for 1 .. $digits - 1 -> $zeros { #
            my Str $begin = insert-sep( '1' ~ '0' x $zeros, $sep );
            @ranges.unshift( sprintf "%*s", $longest, $begin );
        }
    }
    my @pre = ( Any, $tmp_confirm );
    my Int %numbers;
    my Str $result;
    my $tmp_name = $name ?? $name !! '> '; #

    NUMBER: loop {
        my Str $new_number = $result // '';
        my @tmp;
        if $info.chars {
            @tmp.push: $info;
        }
        my $row = sprintf(  "{$tmp_name}%*s", $longest, $new_number );
        if ( print-columns( $row ) > getmaxx( $!win ) ) {
            $row = $new_number;
        }
        @tmp.push: $row;
        if $prompt.chars {
            @tmp.push: $prompt;
        }
        # Choose
        my $range = $!tc.choose(
             [ |@pre, |( $small-on-top ?? @ranges.reverse !! @ranges ) ],
            :prompt( @tmp.join: "\n" ), :2layout, :1justify, :undef( $tmp_back ), :$mouse );
        if ! $range.defined {
            if $result.defined {
                $result = Str;
                %numbers = ();
                next NUMBER;
            }
            else {
                self!_end_term();
                return;
            }
        }
        elsif $range eq $tmp_confirm {
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
        my $num = $!tc.choose( 
            [ Any, |@choices, $reset ],
            :prompt( @tmp.join: "\n" ), :1layout, :2justify, :0order, :undef( $back_short ), :$mouse
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
        Int_0_or_1 :$remove-chosen  = $!remove-chosen,
        Int_0_or_1 :$fmt-chosen     = $!fmt-chosen,
        Int_0_to_2 :$justify        = $!justify,
        Int_0_to_2 :$layout         = 2,
        List       :$mark           = $!mark,
        Str        :$prefix         = $!prefix,
        Str        :$info           = $!info,
        Str        :$prompt         = 'Choose:',
        Str        :$name           = $!name,
        Str        :$back           = $!back,
        Str        :$confirm        = $!confirm,

    ) {
    CATCH {
        endwin();
    }
    my Str $tmp_prefix  = $prefix // ( $layout == 2 ?? '- ' !! '' );
    my Str $tmp_name = $name // '> ';
    my Str $tmp_confirm = $confirm;
    my Str $tmp_back    = $back;
    if $layout == 2 && $tmp_prefix.chars {
        $tmp_confirm = ( ' ' x $tmp_prefix.chars ) ~ $tmp_confirm;
        $tmp_back    = ( ' ' x $tmp_prefix.chars ) ~ $tmp_back;
    }
    my List $new_idx = [];
    my List $new_val = [ @list ];
    my @pre = ( Any, $tmp_confirm );
    my List $initially_marked = [ |$mark.map: { $_ + @pre.elems } ];
    my @bu;
    self!_init_term();

    loop {
        my @tmp;
        if $info.chars {
             @tmp.push: $info;
        }
        if $fmt-chosen == 0 {
            @tmp.push: $tmp_name ~ @list[|$new_idx].map({ _string_gist( $_.gist ) }).join: ', ';
        }
        else {
            @tmp.push: $tmp_name if $name.defined;
            @tmp.push: @list[|$new_idx].map({ ( ' ' x $tmp_prefix.chars ) ~ _string_gist( $_.gist ) }). join: "\n" if @list[|$new_idx].elems;
        }
        if $prompt.chars {
            @tmp.push: $prompt;
        }
        my $choices = [ |@pre, |$new_val.map: { $tmp_prefix ~ $_.gist } ];
        # Choose
        my Int @idx = $!tc.choose-multi(
            $choices,
            :prompt( @tmp.join: "\n" ), :no-spacebar( |^@pre ), :undef( $tmp_back ), :lf( 0, $tmp_name.chars ),
            :$justify, :1index, :$layout, :$order, :mark( $initially_marked )
        );
        if $initially_marked.defined {
            $initially_marked = List;
        }
        if ! @idx[0].defined || @idx[0] == 0 {
            if @bu {
                ( $new_val, $new_idx ) = @bu.pop;
                next;
            }
            self!_end_term();
            return;
        }
        @bu.push( [ [ |$new_val ], [ |$new_idx ] ] );
        my $ok;
        if @idx[0] == @pre.first( $tmp_confirm, :k ) {
            $ok = True;
            @idx.shift;
        }
        my @tmp_idx;
        for @idx.reverse {
            my $i = $_ - @pre;
            if $remove-chosen {
                $new_val.splice( $i, 1 );
                for $new_idx.sort -> $u {
                    last if $u > $i;
                    ++$i;
                }
            }
            @tmp_idx.push: $i;
        }
        $new_idx.append: @tmp_idx.reverse;
        if $ok {
            self!_end_term();
            return $index ?? $new_idx !! [ @list[|$new_idx] ];
        }
    }
}


sub settings-menu ( @menu, %setup, *%opt ) is export( :DEFAULT, :settings-menu ) {
    Term::Choose::Util.new().settings-menu( @menu, %setup, |%opt );
}

method settings-menu ( @menu, %setup,
        Int_0_or_1 :$mouse   = $!mouse,
        Str        :$info    = $!info,
        Str        :$prompt  = 'Choose:',
        Str        :$back    = $!back,
        Str        :$confirm = $!confirm,
    ) {
    CATCH {
        endwin();
    }
    my Int $name_w = 0;
    my %new_setup;
    for @menu -> ( Str $key, Str $name, $ ) {
        my Int $len = print-columns( $name );
        $name_w = $len if $len > $name_w;
        %setup{$key} //= 0;
        %new_setup{$key} = %setup{$key};
    }
    self!_init_term();

    loop {
        my @tmp;
        @tmp.push: $info   if $info.chars;
        @tmp.push: $prompt if $prompt.chars;
        my Str @print_keys;
        for @menu -> ( Str $key, Str $name, @values ) {
            @print_keys.push: sprintf "%-*s [%s]", $name_w, $name, @values[%new_setup{$key}];
        }
        my @pre = ( Any, $confirm );
        my $choices = [ |@pre, |@print_keys ];
        # Choose
        my Int $idx = $!tc.choose(
            $choices,
            :prompt( @tmp.join: "\n" ), :1index, :2layout, :0justify, :undef( $back ), :$mouse
        );
        if ! $idx.defined {
            self!_end_term();
            return False; ###
        }
        my $choice = $choices[$idx];
        if ! $choice.defined {
            self!_end_term();
            return False; ###
        }
        elsif $choice eq $confirm {
            my Int $change = 0;
            for @menu -> ( Str $key, $, $ ) {
                next if %setup{$key} == %new_setup{$key};
                %setup{$key} = %new_setup{$key};
                $change++;
            }
            self!_end_term();
            return $change.so; ###
        }
        my Str $key = @menu[$idx-@pre][0];
        my @values  = @menu[$idx-@pre][2];
        %new_setup{$key}++;
        %new_setup{$key} = 0 if %new_setup{$key} == @values.elems;
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

Values: [0], 1.

=item1 info

A string placed on top of of the output.

=item1 prompt

If set shows an additionally prompt line before the choices.

=head2 choose-a-dir

=begin code

    $chosen_directory = choose-a-dir( :layout(1), ... )

=end code

With C<choose-a-dir> the user can browse through the directory tree (as far as the granted rights permit it) and choose
a directory which is returned.

To move around in the directory tree:

- select a directory and press C<Return> to enter in the selected directory.

- choose the "up"-menu-entry ("C< .. >") to move upwards.

To return the current working-directory as the chosen directory choose "C< = >".

The "back"-menu-entry ("C< E<lt> >") causes C<choose-a-dir> to return nothing.

It can be set the following options:

=item1 dir

Set the starting point directory. Defaults to the home directory (C<$*HOME>).

=item1 enchanted

If set to 1, the default cursor position is on the "up" menu entry. If the directory name remains the same after an user
input, the default cursor position changes to "back".

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

See L<#choose-a-dir> for the different options.

=head2 choose-dirs

=begin code

    @chosen_directories = choose-dirs( :layout(1), ... )

=end code

C<choose-dirs> is similar to C<choose-a-dir> but it is possible to return multiple directories.

"C< . >" adds the current directory to the list of chosen directories and "C< = >" returns the chosen list of
directories.

The "back"-menu-entry ( "C< E<lt> >" ) removes the last added directory. If the list of chosen directories is empty,
"C< E<lt> >" causes C<choose-dirs> to return nothing.

C<choose-dirs> uses the same option as C<choose-a-dir>. The option I<prompt> can be used to put empty lines between the
header rows and the menu: an empty string ('') means no newline, a space (' ') one newline, a newline ("\n") two
newlines.

=head2 choose-a-number

=begin code

    my $number = choose-a-number( 5, :name<Testnumber> );

=end code

This function lets you choose/compose a number (unsigned integer) which is returned.

The fist argument - "digits" - is an integer and determines the range of the available numbers. For example setting the
first argument to 6 would offer a range from 0 to 999999. If not set it defaults to C<7>.

The available options:

=item1 name

Sets the name of the number seen in the prompt line.

Default: empty string ("");

=item1 thsd-sep

Sets the thousands separator.

Default: comma (,).

=head2 choose-a-subset

=begin code

    $subset = choose-a-subset( @available_items, :layout( 1 ) )

=end code

C<choose-a-subset> lets you choose a subset from a list.

The first argument is the list of choices. The following arguments are the options:

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

=head2 settings-menu

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

    settings-menu( @menu, %config );

=end code

The first argument is a list of lists. Each of the lists have three elements:

    the option name

    the prompt string

    a list of the available values for the option

The second argument is a hash:

    the hash key is the option name

    the hash value (zero based index) sets the current value for the option.

This hash is edited in place: the changes made by the user are saved as new current values.

The following arguments can be the different options.

When C<settings-menu> is called, it displays for each list entry a row with the prompt string and the current value.
It is possible to scroll through the rows. If a row is selected, the set and displayed value changes to the next. If the
end of the list of the values is reached, it begins from the beginning of the list.

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
