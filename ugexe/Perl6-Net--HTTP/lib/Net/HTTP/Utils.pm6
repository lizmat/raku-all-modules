unit module Net::HTTP::Utils;

my $CRLF       = buf8.new(13, 10);
my $CRLF-BYTES = $CRLF.bytes;

# header-case
sub hc(Str:D $str) is export { $ = $str.split("-").map(*.wordcase).join("-") }

role IO::Socket::HTTP {
    has $.closing is rw = False;
    has $.promise = Promise.new;
    has $!lock = Lock.new;

    # Currently assumes these are called in a specific order per request
    method get(Bool :$bin where *.so, Bool :$chomp = True) {
        my $buf = $.recv(1, :bin);
        while (my $byte = $.recv(1, :bin)).DEFINITE {
            $buf ~= $byte;
            last if $buf.subbuf(*-$CRLF-BYTES) eq $CRLF;
        }
        $ = ?$chomp ?? $buf.subbuf(0, $buf.bytes - $CRLF-BYTES) !! $buf;
    }

    method lines(Bool :$bin where *.so) {
        gather while (my $buf = $.get(:bin)).DEFINITE {
            take $buf;
        }
    }

    # Currently only for use on the body due to content-length
    method supply(:$buffer = Inf, Bool :$chunked = False) {
        # to make it easier in the transport itself we will simply
        # ignore $buffer if ?$chunked
        my $bytes-read = 0;
        my $want-size  = (?$chunked ?? :16(self.get(:bin).decode('latin-1')) !! $buffer) || 0;
        $ = Supply.on-demand(-> $supply {
            loop {
                my $buffered-size = 0;
                if $want-size {
                    loop {
                        my $bytes-needed = ($want-size - $buffered-size) || last;
                        if (my $data = $.recv($bytes-needed, :bin)).defined {
                            last unless ?$data;
                            $bytes-read    += $data.bytes;
                            $buffered-size += $data.bytes;
                            $supply.emit($data);
                        }
                        last if $buffered-size == $bytes-needed | 0;
                    }
                }

                if ?$chunked and $.recv($CRLF-BYTES, :bin) -> $chunked-crlf {
                    unless $chunked-crlf eq $CRLF {
                        die "Chunked encoding error: expected separator ords "
                        ~   "'{$CRLF.contents}' not found (got: {$chunked-crlf.contents})";
                    }
                    $bytes-read += $chunked-crlf.bytes;
                    $want-size = :16(self.get(:bin).decode('latin-1'));
                }
                last if $want-size == 0 || $bytes-read >= $buffer || $buffered-size == 0;
            }

            $supply.done();
        });
    }

    method init {
        $!lock.protect({
            if $!promise.status ~~ Kept {
                unless $.closed {
                    $!promise = Promise.new;
                }
            }
            self;
        });
    }

    method release {
        $!promise.keep(True);
    }

    method close {
        $!closing = True;
        $!promise.break(False);
        nextsame;
    }

    method closed {
        return True if $!promise.status ~~ Broken;
        try {
            $.read(0);
            # if the socket is closed it will give a different error for read(0)
            CATCH { when /'Out of range'/ { return False } }
        }
    }
}

