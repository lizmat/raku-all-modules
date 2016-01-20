perl6-Compress-Bzip2  [![Build Status](https://travis-ci.org/Altai-man/perl6-Compress-Bzip2.svg?branch=master)](https://travis-ci.org/Altai-man/perl6-Compress-Bzip2)
====================

Bindings to bzip2 library. Procedural API is as easy as pie: you can compress and decompress your files like this:

```perl6
compress($filename);
decompress($filename);
```

If you want to make a simple "from Buf to Buf" (de)compressing, you should use something like this:

```perl6
my buf8 $result = compressToBlob($data); # Data should be encoded.
# or
my Str $result = decompressToBlob($compressed-data).decode;
```

Also, now we support streaming:

```perl6
my $compressor = Compress::Bzip2::Stream.new;
loop {
     $socket.write($compressor.compress($data-chunk));
}
$socket.write($compressor.finish);

my $dcompressor = Compress::Bzip2::Stream.new;
while !$dcompressor.finished {
      my $data-chunk = $dcompressor.decompress($socked.read($size));
}
```

Your any suggestions, reporting of issues and advices about design of library will be really helpful.

I'm very grateful to authors of perl6 bindings to zlib compression library, since I took their code as example for this work and wrote very similar interface.

TODO
====================

* Docs.
