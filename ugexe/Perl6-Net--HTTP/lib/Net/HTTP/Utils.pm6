unit module Net::HTTP::Utils;



role IO::Socket::HTTP {
    has $.input-line-separator = "\r\n";
    has $.keep-alive is rw;
    has $.content-length is rw;
    has $.content-read;
    has $.is-chunked is rw;

    my $promise = Promise.new;
    my $vow     = $promise.vow;

    method reset {
        $promise         = Promise.new;
        $vow             = $promise.vow;
        $!content-length = Nil;
        $!content-read   = Nil;
        $!is-chunked     = Nil;
    }
    method result  { $ = await $promise; }
    method promise { $ = $promise }

    # Currently assumes these are called in a specific order
    method get(Bool :$bin where True, :$nl = $!input-line-separator, Bool :$chomp = True) {
        my @sep      = $nl.ords;
        my $sep-size = @sep.elems;
        my @buf;
        while (my $data = self.recv(1, :bin)).defined {
            @buf.append: $data.contents;
            next unless @buf.elems >= $sep-size;
            last if @buf[*-($sep-size)..*] ~~ @sep;
        }

        @buf ?? ?$chomp ?? buf8.new(@buf[0..*-($sep-size+1)]) !! buf8.new(@buf) !! Buf;
    }

    method lines(Bool :$bin where True, :$nl = $!input-line-separator) {
        gather while (my $line = self.get(:bin, :$nl)).defined {
            take $line;
        }
    }


    # Currently only for use on the body due to content-length
    method supply {
        supply {
            my $ils       = $!input-line-separator;
            my @sep       = $ils.ords;
            my $sep-size  = $ils.ords.elems;
            my $want-size = $!is-chunked ?? :16(self.get(:bin).unpack('A*')) !! $!content-length;
            loop {
                last if $want-size == 0;
                my $buffered-size = 0;
                loop {
                    my $bytes-needed = ($want-size - $buffered-size) || last;
                    if $.recv($bytes-needed, :bin) -> \data {
                        my $d = buf8.new(data);
                        $!content-read += $buffered-size += $d.bytes;
                        emit($d);
                    }
                    last if $buffered-size == $want-size;
                }

                if ?$!is-chunked {
                    my @validate = self.recv($sep-size, :bin).contents;
                    die "Chunked encoding error: expected separator ords '{@sep.perl}' not found (got: {@validate.perl}" unless @validate ~~ @sep;
                    $!content-read += $sep-size;
                    $want-size = :16(self.get(:bin).unpack('A*'));
                }
                else {
                    last if $!content-length >= $!content-read;
                }
            }
            self.reset;
            self.close() unless ?$!keep-alive;
            $vow.keep(True);
            done();
        }
    }
}

# header-case
sub hc(Str:D $str) is export {
    $str.split("-")>>.wordcase.join("-")
}
