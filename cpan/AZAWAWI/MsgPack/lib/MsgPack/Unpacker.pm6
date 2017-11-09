
use v6;

unit class MsgPack::Unpacker;

use NativeCall;
use MsgPack::Native;

my %unpacker-map = %(
    MSGPACK_OBJECT_NIL.value              => &unpack-object-nil,
    MSGPACK_OBJECT_BOOLEAN.value          => &unpack-object-boolean,
    MSGPACK_OBJECT_POSITIVE_INTEGER.value => &unpack-object-positive-integer,
    MSGPACK_OBJECT_NEGATIVE_INTEGER.value => &unpack-object-negative-integer,
    MSGPACK_OBJECT_FLOAT32.value          => &unpack-object-float,
    MSGPACK_OBJECT_FLOAT64.value          => &unpack-object-float,
    MSGPACK_OBJECT_STR.value              => &unpack-object-string,
    MSGPACK_OBJECT_ARRAY.value            => &unpack-object-array,
    MSGPACK_OBJECT_MAP.value              => &unpack-object-map,
    MSGPACK_OBJECT_BIN.value              => &unpack-object-bin,
    MSGPACK_OBJECT_EXT.value              => &unpack-object-extension,
);

method unpack(Blob $packed) {
    # Copy our Blob bytes to simple buffer
    my $sbuf = msgpack_sbuffer.new;
    my $data = CArray[uint8].new($packed);
    msgpack_sbuffer_init($sbuf);
    msgpack_sbuffer_write($sbuf, $data, $data.elems);

    # Initialize unpacker
    my $result          = msgpack_unpacked.new;
    msgpack_unpacked_init($result);

    # Compatibility with older pre-1.0 versions
    my $success = (msgpack_version_major() < 1)
        ?? 1
        !! MSGPACK_UNPACK_SUCCESS.value;

    # Start unpacking
    my size_t $off     = 0;
    my ($buffer, $len) = ($sbuf.data, $sbuf.size);
    my $ret            = msgpack_unpack_next($result, $buffer, $len, $off);
    my $unpacked;
    while $ret == $success {
        my $obj = $result.data;
        if $obj {
            my $unpack-obj = %unpacker-map{$obj.type};
            #TODO add a proper typed exception
            die "Unknown object type: " ~ $obj.type unless $unpack-obj;
            $unpacked       = $unpack-obj($obj);
        }
        $ret = msgpack_unpack_next($result, $buffer, $len, $off);
    }

    # Cleanup
    msgpack_sbuffer_destroy($sbuf);
    msgpack_unpacked_destroy($result);

    #TODO throw a proper typed exception
    die "The data in the buf is invalid format with ret = $ret"
        if $ret != MSGPACK_UNPACK_CONTINUE;

    return $unpacked;
}

sub unpack-object-nil(msgpack_object $obj) {
    return Any;
}

sub unpack-object-boolean(msgpack_object $obj) {
    return $obj.via && $obj.via.boolean == 1 ?? True !! False;
}

sub unpack-object-positive-integer(msgpack_object $obj) {
    return $obj.via ?? $obj.via.u64.Int !! 0;
}

sub unpack-object-negative-integer(msgpack_object $obj) {
    return $obj.via ?? $obj.via.i64.Int !! 0;
}

sub unpack-object-float(msgpack_object $obj) {
    return $obj.via ?? $obj.via.f64.Num !! 0;
}

sub unpack-object-string(msgpack_object $obj) {
    return "" unless $obj.via;
    my $str   = $obj.via.str;
    my $size  = $str.size;
    my $bytes = $str.ptr[^$size];
    return Blob.new($bytes).decode;
}

sub unpack-object-array(msgpack_object $obj) {
    return [] unless $obj.via;
    my $array-obj = $obj.via.array;
    my $o         = nativecast(
        Pointer[Pointer[msgpack_object]],
        $array-obj.ptr
    );
    my $result = [];
    my $array  = $o.deref;
    for ^$array-obj.size {
        my $el = $array[$_];
        $result.append: (%unpacker-map{$el.type})( $el );
    }
    return $result;
}

sub unpack-object-map(msgpack_object $obj) {
    return Hash.new unless $obj.via;
    my $map = $obj.via.map;
    my $o   = nativecast(
        Pointer[Pointer[msgpack_object_kv]],
        $map.ptr
    );
    my $result = %();
    for ^$map.size -> $i {
        my $kv      = $o.deref[$i];
        my $key-obj = $kv.key;
        my $val-obj = $kv.val;
        my ($key, $val);
        $key = (%unpacker-map{$key-obj.type})( $key-obj )
            if $key-obj;
        $val = (%unpacker-map{$val-obj.type})( $val-obj )
            if $val-obj;
        $result{$key} = $val;
    }
    return $result;
}

sub unpack-object-bin(msgpack_object $obj) {
    return Blob.new unless $obj.via;
    my $bin   = $obj.via.bin;
    my $size  = $bin.size;
    my $bytes = $bin.ptr[^$size];
    return Blob.new($bytes);
}

sub unpack-object-extension(msgpack_object $obj) {
    #TODO Add proper extension support (e.g. undefined from JavaScript)
    ...
}
