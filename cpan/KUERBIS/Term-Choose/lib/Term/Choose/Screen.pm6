use v6;
unit module Term::Choose::Screen;


sub      clear is export( :ALL ) { print "\e[H\e[J" }
sub clr-to-bot is export( :ALL ) { print "\e[0J"    }
sub clr-to-eol is export( :ALL ) { print "\e[0K"    }

sub    up ( $steps ) is export( :ALL ) { print "\e[{$steps}A" if $steps }
sub  down ( $steps ) is export( :ALL ) { print "\e[{$steps}B" if $steps }
sub right ( $steps ) is export( :ALL ) { print "\e[{$steps}C" if $steps }
sub  left ( $steps ) is export( :ALL ) { print "\e[{$steps}D" if $steps }

sub    save-screen is export( :ALL ) { print "\e[?1049h" }
sub restore-screen is export( :ALL ) { print "\e[?1049l" }

sub show-cursor is export( :ALL ) { print "\e[?25h" }
sub hide-cursor is export( :ALL ) { print "\e[?25l" }

sub   set-mouse1003 is export( :ALL ) { print "\e[?1003h" }
sub unset-mouse1003 is export( :ALL ) { print "\e[?1003l" }
sub   set-mouse1006 is export( :ALL ) { print "\e[?1006h" }
sub unset-mouse1006 is export( :ALL ) { print "\e[?1006l" }

sub get-cursor-position is export( :ALL ) { print "\e[6n" }


sub num-threads is export( :ALL ) {
    return %*ENV<TC_NUM_THREADS> if %*ENV<TC_NUM_THREADS>;
    # return Kernel.cpu-cores;      # Perl 6.d
    my $proc = run( 'nproc', :out );
    return $proc.out.get.Int || 2;
}


sub get-term-size is export( :get-term-size, :ALL  ) {
    my ( $width, $height );
    my $proc = run 'stty', 'size', :out;
    my $size = $proc.out.get.chomp.Int;
    if $size.defined && $size ~~ / ( \d+ ) \s ( \d+ ) / {
         $width  = $1;
         $height = $0;
    }
    if ! $width {
        my $proc = run 'tput', 'cols', :out;
        $width = $proc.out.get.chomp.Int;
    }
    if ! $height {
        my $proc = run 'tput', 'lines', :out;
        $height = $proc.out.get.chomp.Int;
    }
    die "No terminal width!"  if ! $width.defined;
    die "No terminal heigth!" if ! $height.defined;
    return $width - 1, $height;
}
