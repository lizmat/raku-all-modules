use v6;
module Compress::Zlib;

need Compress::Zlib::Raw;
use NativeCall;

our sub compress(Blob $data, Int $level = 6 --> Buf) is export {
    if $level < -1 || $level > 9 {
        die "compression level must be between -1 and 9";
    }

    my $outlen = CArray[long].new();
    $outlen[0] = Compress::Zlib::Raw::compressBound($data.bytes);
    my $outdata = buf8.new;
    $outdata[$outlen[0] - 1] = 1;

    Compress::Zlib::Raw::compress2($outdata, $outlen, $data, $data.bytes, $level);

    my $len = $outlen[0];
    return $outdata.subbuf(0, $len);
}

our sub uncompress(Blob $data --> Buf) is export {
    my $bufsize = $data.bytes;
    my $outdata = buf8.new();
    my $outlen = CArray[long].new();
    my $ret = Compress::Zlib::Raw::Z_BUF_ERROR;
    while $ret == Compress::Zlib::Raw::Z_BUF_ERROR {
        $bufsize = $bufsize * 2;
        $outdata[$bufsize - 1] = 1;
        $outlen[0] = $bufsize;

        $ret = Compress::Zlib::Raw::uncompress($outdata, $outlen, $data, $data.bytes);
        if $ret == Compress::Zlib::Raw::Z_DATA_ERROR {
            die "uncompress data error";
        }
    }

    my $len = $outlen[0];
    return $outdata.subbuf(0, $len);
}

class Compress::Zlib::Stream {
    has $!z-stream;
    has $!gz-header;

    has $!has-header;
    has $!deflate-init = False;
    has $!inflate-init = False;

    has $.finished = False;
    has $.bytes-left = 0;

    has $!window-bits;

    has $!zlib-finished = False;

    method new(:$zlib, :$deflate, :$gzip) {
        my $window-bits = 15;
        $window-bits = -15 if $deflate;
        $window-bits = 15 + 16 if $gzip;
        self.bless(:$window-bits);
    }
    submethod BUILD(:$!window-bits) { }

    method inflate($data) {
        die "Cannot inflate and deflate with the same object!" if $!deflate-init;
        die "Stream end reached!" if $.finished;

        unless $!inflate-init {
            $!z-stream = Compress::Zlib::Raw::z_stream.new;
        }

        $!z-stream.set-input($data);

        my $out = buf8.new;

        loop {
            my $output-buf = buf8.new;
            $output-buf[1023] = 1;
            $!z-stream.set-output($output-buf);

            unless $!inflate-init {
                $!inflate-init = True;
                Compress::Zlib::Raw::inflateInit2($!z-stream, $!window-bits);
            }

            my $ret = Compress::Zlib::Raw::inflate($!z-stream, Compress::Zlib::Raw::Z_SYNC_FLUSH);

            unless $ret == Compress::Zlib::Raw::Z_OK|Compress::Zlib::Raw::Z_STREAM_END {
                fail "Cannot inflate stream: $!z-stream.msg()";
            }

            $out ~= $output-buf.subbuf(0, 1024 - $!z-stream.avail-out);

            if $ret == Compress::Zlib::Raw::Z_STREAM_END {
                $!bytes-left = $!z-stream.avail-in;
                self.finish;
            }

            if $ret == Compress::Zlib::Raw::Z_STREAM_END || ($!z-stream.avail-out && !($!z-stream.avail-in)) {
                return $out;
            }
        }
    }

    method deflate($data) {
        die "Cannot inflate and deflate with the same object!" if $!inflate-init;
        die ".finish was called!" if $.finished;

        unless $!deflate-init {
            $!z-stream = Compress::Zlib::Raw::z_stream.new;
        }

        $!z-stream.set-input($data);

        my $out = buf8.new;

        loop {
            my $output-buf = buf8.new;
            $output-buf[1023] = 1;
            $!z-stream.set-output($output-buf);

            unless $!deflate-init {
                $!deflate-init = True;
                Compress::Zlib::Raw::deflateInit2($!z-stream,
                                                  6,
                                                  Compress::Zlib::Raw::Z_DEFLATED,
                                                  $!window-bits,
                                                  8,
                                                  Compress::Zlib::Raw::Z_DEFAULT_STRATEGY);
            }

            # XXX At some point, we should support Z_NO_FLUSH, as we can get
            # slightly better compression ratios that way
            my $ret = Compress::Zlib::Raw::deflate($!z-stream, Compress::Zlib::Raw::Z_SYNC_FLUSH);

            unless $ret == Compress::Zlib::Raw::Z_OK {
                fail "Cannot deflate stream: $!z-stream.msg()";
            }

            $out ~= $output-buf.subbuf(0, 1024 - $!z-stream.avail-out);

            if $!z-stream.avail-out && !($!z-stream.avail-in) {
                return $out;
            }
        }
    }

    method flush(:$finish) {
        if $!inflate-init {
            return Buf.new();
        } elsif $!deflate-init {
            if $finish && !$!finished {
                my $out = buf8.new;
                loop {
                    my $output-buf = buf8.new;
                    $output-buf[1023] = 1;
                    $!z-stream.set-output($output-buf);

                    my $ret = Compress::Zlib::Raw::deflate($!z-stream, Compress::Zlib::Raw::Z_FINISH);

                    unless $ret == Compress::Zlib::Raw::Z_OK|Compress::Zlib::Raw::Z_STREAM_END {
                        fail "Cannot deflate stream: $!z-stream.msg()";
                    }

                    $out ~= $output-buf.subbuf(0, 1024 - $!z-stream.avail-out);

                    if $ret == Compress::Zlib::Raw::Z_STREAM_END {
                        $!finished = True;
                    }

                    if $ret == Compress::Zlib::Raw::Z_STREAM_END || $!z-stream.avail-out {
                        return $out;
                    }
                }
            } else {
                return Buf.new();
            }
        }
    }

    method finish() {
        if $!zlib-finished {
            return;
        }
        $!zlib-finished = True;
        my $flushed = self.flush(:finish);
        if $!inflate-init {
            Compress::Zlib::Raw::inflateEnd($!z-stream);
            $!finished = True;
        } elsif $!deflate-init {
            Compress::Zlib::Raw::deflateEnd($!z-stream);
            $!finished = True;
        }
        return $flushed;
    }
}

class Compress::Zlib::Wrap {
    has $.handle;
    has $!compressor;
    has $!decompressor;
    has Buf $!read-buffer = Buf.new;

    method new($handle, :$zlib, :$deflate, :$gzip){
        self.bless(:$handle, :$zlib, :$deflate, :$gzip);
    }

    submethod BUILD(:$!handle, :$zlib, :$deflate, :$gzip) {
        $!compressor = Compress::Zlib::Stream.new(:$zlib, :$gzip, :$deflate);
        $!decompressor = Compress::Zlib::Stream.new(:$zlib, :$gzip, :$deflate);
    }

    method send(Str $stuff) {
        self.write($stuff.encode);
    }

    method get() {
        my $chunksize = 128;

        my $nl = "\n";
        $nl = $.handle.nl if $.handle.can('nl');
        loop {
            my $bufstr;

            # If decoding fails, assume it is caused by our buffer ending in the middle of a multibyte character
            # so chop a byte off the end and try again
            my $len = $!read-buffer.elems;
            my $cut = 0;
            while !($bufstr ~~ Str) {
                $bufstr = try $!read-buffer.subbuf(0,$len-$cut).decode;
                $cut++;
            }
            ##

            my $i = $bufstr.index($nl);
            if $i.defined {
                my $ret = $bufstr.substr(0,$i+$nl.chars);
                $!read-buffer = $!read-buffer.subbuf($ret.encode.bytes);
                return $ret;
            }

            if $!decompressor.finished || self.eof {
                return Str unless $!read-buffer.elems;
                my $ret = $!read-buffer.decode;
                $!read-buffer = Buf.new;
                return $ret;
            }

            my $c = $.handle.read($chunksize);
            fail "Unable to read from handle" unless $c;
            $!read-buffer ~= $!decompressor.inflate($c);
        }
    }

    method getc() {
        my $chunksize = 32;

        while !$!read-buffer.elems {
            my $c = $.handle.read($chunksize);
            fail "Unable to read from handle" unless $c;
            $!read-buffer = $!decompressor.inflate($c);
        }

        my $char = $!read-buffer.subbuf(0,1).decode;
        $!read-buffer .= subbuf(1);
        return $char;
    }


    method write(Blob $stuff) {
        $.handle.write($!compressor.deflate($stuff));
    }

    method read($size) {
        while $!read-buffer.elems < $size {
            my $c = $.handle.read($size);
            unless $c.elems {
                my $ret = $!read-buffer;
                $!read-buffer = Buf.new;
                return $ret;
            }
            fail "Unable to read from handle" unless $c;
            $!read-buffer ~= $!decompressor.inflate($c);
        }

        my $ret = $!read-buffer.subbuf(0,$size);
        $!read-buffer .= subbuf($size);
        return $ret;
    }

    multi method print(Str $stuff) {
        self.send($stuff);
    }
    multi method print(*@stuff) {
        self.send($_) for @stuff;
    }

    method close() {
        self.end();
        $!decompressor.finish();
        $.handle.close;
    }

    method end() {
        my $stuff = $!compressor.finish();
        $.handle.write($stuff) if $stuff;
        $!decompressor.finish();
    }

    method eof() {
        return $!decompressor.finished || $.handle.eof;
    }

    method opened() {
        return $.handle.opened;
    }

    method flush() {
        my $buf = $!compressor.flush();
        $.handle.write($buf) if $buf;
        $.handle.flush;
    }

    method lines($limit = Inf) {
        if $limit == Inf {
            gather while nqp::p6definite(my $line = self.get) {
                take $line;
            }
        }
        else {
            my $count = 0;
            gather while ++$count <= $limit && nqp::p6definite(my $line = self.get) {
                take $line;
            }
        }
    }

    multi method say(IO::Handle:D: |) {
        my Mu $args := nqp::p6argvmarray();
        nqp::shift($args);
        self.print: nqp::shift($args).gist while $args;
        self.print: "\n";
    }

    method slurp(:$bin, :enc($encoding)) {
        self.encoding($encoding) if $encoding.defined;

        if $bin {
            my $Buf = buf8.new();
            loop {
                my $current  = self.read(10_000);
                $Buf ~= $current;
                last if $current.bytes == 0;
            }
            self.close;
            $Buf;
        }
        else {
            my $contents = self.lines.join;
            self.close();
            $contents
        }
    }

    proto method spurt(|) { * }
    multi method spurt(Cool $contents) {
        self.send($contents);
        self.close;
    }

    multi method spurt(Blob $contents) {
        self.write($contents);
        self.close;
    }

    method recv($chars = Inf, :$bin = False){
        if $chars == Inf {
            return self.slurp(:$bin);
        } else {
            my $buf = self.read($chars);
            return $buf if $bin;
            return $buf.decode;
        }
    }
}

our sub zwrap($thing, :$zlib, :$deflate, :$gzip) is export {
    return Compress::Zlib::Wrap.new($thing, :$zlib, :$deflate, :$gzip);
}

our sub gzslurp($path, :$bin) is export {
    return zwrap(open($path, :r), :gzip).slurp(:$bin);
}

our sub gzspurt($path, $stuff, :$bin) is export {
    return zwrap(open($path, :w), :gzip).spurt($stuff, :$bin);
}
