use v6;

unit class IO::Blob is IO::Handle;

constant EMPTY = "".encode;
constant LF = "\n".encode;
constant TAB = "\t".encode;
constant SPACE = " ".encode;

has Int $!pos = 0;
has Int $!ins = 1;
has Blob $.data is rw;
has Bool $!is_closed = False;
has Str $.nl is rw = "\n";

method new(Blob $data = Buf.new) {
    return self.bless(:$data);
}

method open(Blob $data = Buf.new) {
    return self.new($data);
}

method get(IO::Blob:D:) {
    if self.eof {
        return EMPTY;
    }

    unless (defined $.nl) {
        return self.slurp-rest(bin => True);
    }

    my $i = $!pos;
    my $len = $.data.elems;

    loop (; $i < $len; $i++) {
        if ($.data.subbuf($i, 1) eq LF) {
            $!ins++;
            last;
        }
    }

    my $line;
    if ($i < $len) {
        $line = $.data.subbuf($!pos, $i - $!pos + 1);
        $!pos = $i + 1;
    } else {
        $line = $.data.subbuf($!pos, $i - $!pos);
        $!pos = $len;
    }

    return $line;
}

method getc(IO::Blob:D:) {
    if self.eof {
        return EMPTY;
    }

    my $char = $.data.subbuf($!pos++, 1);

    # TODO other separator
    if ($char eq LF) {
        $!ins++;
    }

    return $char;
}

method lines(IO::Blob:D: $limit = Inf) {
    my $line;
    my @lines;
    loop (my $i = 0; $i < $limit; $i++) {
        my $line = self.get;
        if (!$line.Bool) {
            last;
        }
        @lines.push($line)
    }
    return @lines;
}

method word(IO::Blob:D:) {
    if self.eof {
        return EMPTY;
    }

    # TODO other separator
    my $i = $!pos;
    my $len = $.data.elems;
    loop (; $i < $len; $i++) {
        my $char = $.data.subbuf($i, 1);
        if ($char eq TAB || $char eq SPACE) {
            last;
        } elsif ($char eq LF) {
            $!ins++;
            last;
        }
    }

    my $buf;
    if ($i < $len) {
        $buf = $.data.subbuf($!pos, $i - $!pos + 1);
        $!pos = $i + 1;
    } else {
        $buf = $.data.subbuf($!pos, $i - $!pos);
        $!pos = $len;
    }
    return $buf;
}

method words(IO::Blob:D: $count = Inf) {
    my $word;
    my @words;
    loop (my $i = 0; $i < $count; $i++) {
        my $word = self.word;
        if (!$word.Bool) {
            last;
        }
        @words.push($word)
    }
    return @words;
}

method print(IO::Blob:D: *@text) returns Bool {
    for (@text) -> $text {
        self.write(($text ~ $.nl).encode)
    }

    return True;
}

method read(IO::Blob:D: Int(Cool:D) $bytes) {
    if self.eof {
        return EMPTY;
    }

    my $read = $.data.subbuf($!pos, $bytes);
    $!pos += $read.elems;

    # TODO ins

    return $read;
}

method write(IO::Blob:D: Blob:D $buf) {
    my $data = $.data ~ $buf;
    $!pos = $data.elems;
    $.data = $data;

    # TODO ins

    return True;
}

method seek(IO::Blob:D: int $offset, int $whence) {
    my $eofpos = $.data.elems;

    # Seek:
    given $whence {
        when 0 { $!pos = $offset } # SEEK_SET
        when 1 { $!pos += $offset } # SEEK_CUR
        when 2 { $!pos = $eofpos + $offset } #SEEK_END
        default { die "bad seek whence ($whence)" }
    }

    # Fixup
    if ($!pos < 0) { $!pos = 0 }
    if ($!pos > $eofpos) { $!pos = $eofpos }

    return True;
}

method tell(IO::Blob:D:) returns Int {
    return $!pos;
}

method ins(IO::Blob:D:) returns Int {
    return $!ins;
}

proto method slurp-rest(|) { * }

multi method slurp-rest(IO::Blob:D: :$bin!) returns Buf {
    my $buf := Buf.new();

    if self.eof {
        return $buf;
    }

    my $read = $.data.subbuf($!pos);
    $!pos += $.data.elems;

    #TODO ins

    return $buf ~ $read;
}

multi method slurp-rest(IO::Blob:D: :$enc) returns Str {
    if self.eof {
        return "";
    }

    my $read = $.data.subbuf($!pos).decode($enc);
    $!pos = $.data.elems;

    #TODO ins

    return $read;
}

method eof(IO::Blob:D:) {
    return $!is_closed || $!pos >= $.data.elems;
}

method close(IO::Blob:D:) {
    $.data = Nil;
    $!pos = Nil;
    $!ins = Nil;
    $!is_closed = True;
}

method is-closed(IO::Blob:D:) {
    return $!is_closed;
}

=begin pod

IO::Blob - IO:: interface for reading/writing a Blob

=head1 SYNOPSIS

    use v6;
    use IO::Blob;

    my $data = "foo\nbar\n";
    my IO::Blob $io = IO::Blob.new($data.encode);

=head1 DESCRIPTION

IO:: interface for reading/writing a Blob.
This class inherited from L<IO::Handle>.

The IO::Blob class implements objects which behave just like
IO::Handle objects, except that you may use them
to write to (or read from) Blobs.

This module is inspired by IO::Scalar of perl5.

=head1 METHODS

=head2 new(Blob $data = Buf.new)

Make a instance. This method is equivalent to C<open>.

    my $io = IO::Blob.new("foo\nbar\n".encode);

=head2 open(Blob $data = Buf.new)

Make a instance. This method is equivalent to C<new>.

    my $io = IO::Blob.open("foo\nbar\n".encode);

=head2 get(IO::Blob:D:)

Reads a single line from the Blob.

    my $io = IO::Blob.open("foo\nbar\n".encode);
    $io.get; // => "foo\n"

=head2 getc(IO::Blob:D:)

Read a single character from the Blob.

    my $io = IO::Blob.open("foo\nbar\n".encode);
    $io.getc; // => "f\n"

=head2 lines(IO::Blob:D: $limit = Inf)

Return a lazy list of the Blob's lines read via C<get>, limited to C<$limit> lines.

    my $io = IO::Blob.open("foo\nbar\n".encode);
    for $io.lines -> $line {
        $line; // 1st: "foo\n", 2nd: "bar\n"
    }

=head2 word(IO::Blob:D:)

Read a single word (separated on whitespace) from the Blob.

    my $io = IO::Blob.open("foo bar\tbuz\nqux".encode);
    $io.word; // => "foo "

=head2 words(IO::Blob:D: $count = Inf)

Return a lazy list of the Blob's words (separated on whitespace) read via C<word>, limited to C<$count> words.

    my $io = IO::Blob.open("foo bar\tbuz\nqux".encode);
    for $io.words -> $word {
        $word; // 1st: "foo ", 2nd: "bar\t", 3rd: "buz\n", 4th: "qux"
    }

=head2 print(IO::Blob:D: *@text) returns Bool

Text writing; writes the given C<@text> to the Blob.

=head2 read(IO::Blob:D: Int(Cool:D) $bytes)

Binary reading; reads and returns C<$bytes> bytes from the Blob.

=head2 write(IO::Blob:D: Blob:D $buf)

Binary writing; writes $buf to the Blob.

=head2 seek(IO::Blob:D: int $offset, int $whence)

Move the pointer (that is the position at which any subsequent read or write operations will begin,) to the byte position specified by C<$offset> relative to the location specified by C<$whence> which may be one of:

=item 0

The beginning of the file.

=item 1

The current position in the file.

=item 2

The end of the file.

=head2 tell(IO::Blob:D:) returns Int

Returns the current position of the pointer in bytes.

=head2 ins(IO::Blob:D:) returns Int

Returns the number of lines read from the file.

=head2 slurp-rest(IO::Blob:D: :$bin!) returns Buf

Return the remaining content of the Blob from the current position (which may have been set by previous reads or by seek.) If the adverb C<:bin> is provided a Buf will be returned.

=head2 slurp-rest(IO::Blob:D: :$enc) returns Str

Return the remaining content of the Blob from the current position (which may have been set by previous reads or by seek.) Return will be a Str with the optional encoding C<:enc>.

=head2 eof(IO::Blob:D:)

Returns L<Bool::True> if the read operations have exhausted the content of the Blob;

=head2 close(IO::Blob:D:)

Will close a previously opened Blob.

=head2 is-closed(IO::Blob:D:)

Returns L<Bool::True> if the Blob is closed.

=head2 data(IO::Blob:D:)

Returns the current Blob.

=head1 SEE ALSO

L<IO::Scalar of perl5|https://metacpan.org/pod/IO::Scalar>

=head1 LICENSE

Copyright 2015 moznion <moznion@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=end pod

