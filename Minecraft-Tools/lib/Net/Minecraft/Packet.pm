unit class Net::Minecraft::Packet:auth<github:flussence>:ver<0.0.1>;
#= This is a giant kludge. Please don't look at it. Ever.

#| Turns a list of objects into a Blob sendable over IO::Socket.write
multi method encode(*@objects --> Blob) {
    serialize(.bytes) ~ $_ given [~] @objects.map(&serialize);
}

#| Reads a response from the network pipe, handling length prefix automatically.
method recv-payload(IO::Socket::INET $socket --> Blob) {
    my $first-packet = $socket.recv(:bin) or die 'No response from server';
    my $length = unserialize(Int, $first-packet);
    my Buf $data = $first-packet.subbuf($length.bytes);
    $data ~= $socket.recv(:bin) while $data.bytes < $length;
    return $data;
}


our proto serialize(| --> Blob) { * }

#| Pre-encoded blobs are passed through as-is
multi serialize(Blob $_ --> Blob) { $_ }

#| Strings are encoded as UTF-8 and prefixed with varint string length
multi serialize(Str $_ --> Blob) {
    serialize(.codes) ~ .encode('utf8');
}

#| See below
multi serialize(Int $_ where int8.Range --> Blob) {
    Blob.new($_);
}

#| int32 are encoded as Protocol Buffers varints (basically UTF8-LE)
multi serialize(Int $_ where int32.Range --> Blob) {
    # Who'd have thought getting the bits out of an int32 would be this hard?
    $_ += uint32.Range.max when .sign == -1;

    Blob.new: ( (0, 128 xx 4).flat Z+ .polymod(128 xx *).reverse ).reverse
}


#| Deserialize a piece of data from the start of Blob. The returned thing will
#| have a .bytes method so you can skip to the next part of the input.
our proto unserialize($, Blob) { * }

#| Decoding a VarInt is surprisingly simpler than encoding one.
multi unserialize(Int:U, Blob $input --> Int) {
    # A varint must never use more than 5 bytes, no matter the input length
    my $bytes = 1 + ($input.subbuf(^5).first(* < 0x80):k);
    :128[ $input.subbuf(0, $bytes).reverse »+&» 0x7F ]
        but role { method bytes { $bytes } };
}

#| Extract a UTF-8 string
multi unserialize(Str:U, Blob $input --> Str) {
    my $utf8len = unserialize(Int, $input);
    $input.subbuf($utf8len.bytes, $utf8len).decode('UTF-8')
        but role { method bytes { $utf8len } };
}
