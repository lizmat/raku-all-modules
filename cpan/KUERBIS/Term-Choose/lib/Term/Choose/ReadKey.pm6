use v6;
unit module Term::Choose::ReadKey;


my Int $abs_cursor_Y;


sub read-key( Int $mouse ) is export( :read-key ) {
    my $buf = Buf.new;
    my $c1;
    while ! try $c1 = $buf.decode {
        # Terminal::Print::RawInput
        my $b = $*IN.read(1) or return;
        $buf.push: $b;
    }
    if $c1 eq "\e" {
        my $c2 = $*IN.read(1).decode;
        if ! $c2.defined { return 'Escape'; } #
        elsif $c2 eq 'A' { return 'CursorUp'; }
        elsif $c2 eq 'B' { return 'CursorDown'; }
        elsif $c2 eq 'C' { return 'CursorRight'; }
        elsif $c2 eq 'D' { return 'CursorLeft'; }
        elsif $c2 eq 'H' { return 'CursorHome'; }
        elsif $c2 eq 'O' {
            my $c3 = $*IN.read(1).decode;
            if    $c3 eq 'A' { return 'CursorUp'; }
            elsif $c3 eq 'B' { return 'CursorDown'; }
            elsif $c3 eq 'C' { return 'CursorRight'; }
            elsif $c3 eq 'D' { return 'CursorLeft'; }
            elsif $c3 eq 'F' { return 'CursorEnd'; }
            elsif $c3 eq 'H' { return 'CursorHome'; }
            elsif $c3 eq 'Z' { return 'BackTab'; }
            else {
                return;
            }
        }
        elsif $c2 eq '[' {
            my $c3 = $*IN.read(1).decode;
            if    $c3 eq 'A' { return 'CursorUp'; }
            elsif $c3 eq 'B' { return 'CursorDown'; }
            elsif $c3 eq 'C' { return 'CursorRight'; }
            elsif $c3 eq 'D' { return 'CursorLeft'; }
            elsif $c3 eq 'F' { return 'CursorEnd'; }
            elsif $c3 eq 'H' { return 'CursorHome'; }
            elsif $c3 eq 'Z' { return 'BackTab'; }
            elsif $c3 ~~ / ^ <[0..9]> $ / {
                my $c4 = $*IN.read(1).decode;
                if $c4 eq '~' {
                    if    $c3 eq '2' { return 'Insert'; }
                    elsif $c3 eq '3' { return 'Delete'; }
                    elsif $c3 eq '5' { return 'PageUp'; }
                    elsif $c3 eq '6' { return 'PageDown'; }
                    else {
                        return;
                    }
                }
                elsif $c4 ~~ / ^ <[;0..9]> $ / { # response to "\e[6n"
                    my $abs_curs_y = $c3;
                    my $ry = $c4;
                    while $ry ~~ / ^ <[0..9]> $ / {
                        $abs_curs_y ~= $ry;
                        $ry = $*IN.read(1).decode;
                    }
                    if $ry ne ';' {
                        return;
                    }
                    my $abs_curs_x = '';
                    my $rx = $*IN.read(1).decode;
                    while $rx ~~ / ^ <[0..9]> $ / {
                        $abs_curs_x ~= $rx;
                        $rx = $*IN.read(1).decode;
                    }
                    if $rx eq 'R' {
                        #$!abs_cursor_x = $abs_curs_x; # unused
                        $abs_cursor_Y = $abs_curs_y.Int;
                    }
                    return;
                }
                else {
                    return;
                }
            }
            # http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
            #elsif $c3 eq 'M' && $mouse {
            #    my $event_type = $*IN.read(1).decode - 32;
            #    my $x          = $*IN.read(1).decode - 32;
            #    my $y          = $*IN.read(1).decode - 32;
            #    my $button = _mouse_event_to_button( $event_type );
            #    if ! $button.defined {
            #        return;
            #    }
            #    return [ $abs_cursor_Y, $button, $x.Int, $y.Int ];
            #}
            elsif $c3 eq '<' && $mouse {  # SGR 1006
                my $event_type = '';
                my $m1;
                while ( $m1 = $*IN.read(1).decode ) ~~ / ^ <[0..9]> $ / {
                    $event_type ~= $m1;
                }
                if $m1 ne ';' {
                    return;
                }
                my $x = '';
                my $m2;
                while ( $m2 = $*IN.read(1).decode ) ~~ / ^ <[0..9]> $ / {
                    $x ~= $m2;
                }
                if $m2 ne ';' {
                    return;
                }
                my $y = '';
                my $m3;
                while ( $m3 = $*IN.read(1).decode ) ~~ / ^ <[0..9]> $ / {
                    $y ~= $m3;
                }
                if $m3 !~~ / ^ <[mM]> $ / {
                    return;
                }
                my $button_released = $m3 eq 'm' ?? 1 !! 0;
                if $button_released {
                    return;
                }
                my $button = _mouse_event_to_button( $event_type );
                if ! $button.defined {
                    return;
                }
                return [ $abs_cursor_Y, $button, $x.Int, $y.Int ];
            }
            else {
                return;
            }
        }
        else {
            return;
        }
    }
    else {
        if $c1.ord == 127 {
            return 'Backspace';
        }
        elsif $c1.ord < 32 {
            return '^' ~ ( $c1.ord + 64 ).chr;
        }
        else {
            return $c1;
        }
    }
};


sub _mouse_event_to_button( $event_type ) {
    my $button_drag = ( $event_type +& 0x20 ) +> 5;
    if $button_drag {
        return;
    }
    my $button;
    my $low_2_bits = $event_type +& 0x03;
    if $low_2_bits == 3 {
        $button = 0;
    }
    else {
        if $event_type +& 0x40 {
            $button = $low_2_bits + 4; # 4,5
        }
        else {
            $button = $low_2_bits + 1; # 1,2,3
        }
    }
    return $button;
}


