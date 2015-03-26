P6-Compress-Zlib
================

## Name ##

Compress::Zlib - A (hopefully) nice interface to zlib

## Description ##

Compresses and uncompresses data using zlib.

## Example Usage ##

    use Compress::Zlib;

    my $wrapped = Compress::Zlib::Wrap.new($handle); # can be a socket, filehandle, etc
    my $wrapped = zwrap($handle); # does the same thing as the above line

    $wrapped.send("data");
    my $response = $wrapped.get;

    gzslurp("file.gz"); # reads in a gzipped file
    gzspurt("file.gz", "stuff"); # spits out a gzipped file


    my $compressor = Compress::Zlib::Stream.new;
    loop {
        $socket.write($compressor.deflate($data-chunk));
    }
    $socket.write($compressor.finish);

    my $decompressor = Compress::Zlib::Stream.new;
    while !$decompressor.finished {
        my $data-chunk = $decompressor.inflate($socket.read($size));
    }


    my $compressed = compress($string.encode('utf8'));
    my $original = uncompress($compressed).decode('utf8');

## Handle Wrapper ##

 -  `zwrap($handle, :$gzip, :$zlib, :$deflate --> Compress::Zlib::Wrap)`

    Returns a wrapped handle that will read and write data in the compressed format.

 -  `gzslurp($filename, :$bin)`

 -  `gzspurt($filename, $stuff, :$bin)`

## Stream Class ##

This currently has very few options. Over time, I will add support for custom
compression levels, gzip/raw deflate streams, etc. If you need a specific feature,
open an issue and I will move it to the top of my priority list.

 -  `new(:$gzip, :$zlib, :$deflate --> Compress::Zlib::Stream)`

    Creates a new object that can be used for either compressing or decompressing
    (but not both!).

    Defaults to zlib compression.

 -  `finished( --> Bool)`

    Returns true if the end of the data stream has been reached. In this case,
    you can do nothing more that's useful with this object.

 -  `bytes-left( --> Int)`

    After an `.inflate` object is `.finished`, this will return the number of bytes in the last
    input buffer that were "past the end" of the compressed data stream.

    Usually used when you're interested in any data that comes after the compressed stream.

 -  `inflate(Buf $data --> Buf)`

    Decompresses a chunk of data.

 -  `deflate(Buf $data --> Buf)`

    Compresses a chunk of data.

 -  `flush( --> Buf)`

    Currently just returns an empty Buf, as inflate and deflate are using Z_SYNC_FLUSH.
    To be future-proof, call this any time you need Z_SYNC_FLUSH semantics (sending
    a complete request to a server, for example).

    At some point, will cause zlib to flush some of it's internal data structures
    and possibly return more data.

 -  `finish( --> Buf)`

    Flushes all remaining data from zlib's internal structures, and deallocates
    them.

    Call when you want a Z_STREAM_END to happen when compressing, or if you are
    finished with the object.

## Misc Functions ##

These only handle zlib format data, not gzip or deflate.

 -  `compress(Blob $data, Int $level? --> Buf)`

    Compresses binary $data. $level is the optional compression level (0 <= x <= 9); defaults to 6.

 -  `uncompress(Blob $data --> Buf)`

    Uncompresses previously compressed $data.
