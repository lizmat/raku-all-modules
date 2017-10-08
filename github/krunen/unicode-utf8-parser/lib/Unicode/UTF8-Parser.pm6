unit module Unicode::UTF8-Parser;

sub parse-utf8-bytes(Supply $bytes) is export {
    supply {
        my @bytes;
        my $bytenum;
        
        whenever $bytes -> $byte {
            #note "got byte {$byte.gist}";
            if !($byte +& 0b10000000) {
                # note "got ascii $byte";
                if @bytes {
                    # note "prev bytes were wrong: @bytes";
                    emit($_) for @bytes;
                    @bytes = ();
                    $bytenum = 0;
                }
                emit(chr($byte));
            } elsif $bytenum {
                # note "got following byte $byte";
                push @bytes, $byte;
                if $byte +& 0b11000000 == 0b10000000 {
                    if @bytes == $bytenum {
                        # note "emitting char";
                        emit(utf8_char(@bytes));
                        @bytes = ();
                        $bytenum = 0;
                    }
                } else {
                    # note "got wrong byte $byte";
                    emit($_) for @bytes;
                    @bytes = ();
                    $bytenum = 0;
                }
            } else {
                # note "got first byte $byte";
                push @bytes, $byte;
                $bytenum = utf8_byte_count($byte);
                if !$bytenum {
                    # note "not utf8!";
                    emit($byte);
                    @bytes = ();
                }
            }
        }
    }
}

sub utf8_byte_count($first-byte) {
    return 2 if $first-byte +& 0b11100000 == 0b11000000;
    return 3 if $first-byte +& 0b11110000 == 0b11100000;
    return 4 if $first-byte +& 0b11111000 == 0b11110000;
    return 5 if $first-byte +& 0b11111100 == 0b11111000;
    return 6 if $first-byte +& 0b11111110 == 0b11111100;
}

sub utf8_char(@b) {
    chr(do given +@b {
        when 2 { @b[0] +& 31 +< 6   +  @b[1] +& 63 }
        when 3 { @b[0] +& 15 +< 12  +  @b[1] +& 63 +< 6   +  @b[2] +& 63 }
        when 4 { @b[0] +& 7  +< 18  +  @b[1] +& 63 +< 12  +  @b[2] +& 63 +< 6  +  @b[3] +& 63 }
        when 5 { @b[0] +& 3  +< 24  +  @b[1] +& 63 +< 18  +  @b[2] +& 63 +< 12 +  @b[3] +& 63 +< 6  +  @b[4] +& 63 }
        when 6 { @b[0] +& 1  +< 30  +  @b[1] +& 63 +< 24  +  @b[2] +& 63 +< 18 +  @b[3] +& 63 +< 12 +  @b[4] +& 63 +< 6  +  @b[5] +& 63 }
    })
}
