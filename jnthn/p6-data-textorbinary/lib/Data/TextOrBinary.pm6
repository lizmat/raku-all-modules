my constant PRINTABLE_TABLE = do {
    my int @table;
    @table[flat ords("\t\b\o33\o14"), 32..126, 128..255] = 1 xx *;
    @table
}

multi is-text(Blob $content, Int(Cool) :$test-bytes = 4096) is export {
    my int $limit = $content.elems min $test-bytes;
    my int $printable;
    my int $unprintable;
    loop (my int $i = 0; $i < $limit; $i++) {
        my int $check = $content[$i];
        if $check == 0 {
            # NULL byte, so binary.
            return False;
        }
        elsif $check == 13 {
            # \r not followed by \n hints binary
            if $content[$i + 1] != 10 {
                return False;
            }
            else {
                $i++;
            }
        }
        elsif $check == 10 {
            # Ignore lone \n
        }
        elsif PRINTABLE_TABLE[$check] {
            $printable++;
        }
        else {
            $unprintable++;
        }
    }
    return ($printable +> 7) >= $unprintable;
}

multi is-text(IO::Path $path, Int(Cool) :$test-bytes = 4096) is export {
    my $fh = $path.open(:r, :bin);
    LEAVE $fh.close;
    return is-text($fh.read($test-bytes), :$test-bytes);
}
