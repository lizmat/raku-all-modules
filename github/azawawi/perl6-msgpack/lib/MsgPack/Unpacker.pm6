
use v6;

unit class MsgPack::Unpacker;

use NativeCall;
use MsgPack::Native;

constant UNPACKED_BUFFER_SIZE = 2048;

method unpack(Blob $packed) {
    warn "unpack(Blob) is currently experimental....";

    # Copy our Blob bytes to simple buffer
    my $sbuf = msgpack_sbuffer.new;
    msgpack_sbuffer_init($sbuf);
    my $data = CArray[uint8].new($packed);
    msgpack_sbuffer_write($sbuf, $data, $data.elems);

    # Initialize unpacker
    my $result          = msgpack_unpacked.new;
    my $unpacked_buffer = CArray[uint8].new([0 xx UNPACKED_BUFFER_SIZE]);
    my size_t $off      = 0;
    msgpack_unpacked_init($result);

    # Start unpacking
    my $buffer = $sbuf.data;
    my $len    = $sbuf.size;
    my $ret    = msgpack_unpack_next($result, $buffer, $len, $off);
    while $ret == MSGPACK_UNPACK_SUCCESS.value {
        my msgpack_object $obj = $result.data;

        given $obj.type {
            when MSGPACK_OBJECT_NIL              { say "Any"   }
            when MSGPACK_OBJECT_BOOLEAN          { say "Bool" } 
            when MSGPACK_OBJECT_POSITIVE_INTEGER { say "+ive Int" }
            when MSGPACK_OBJECT_NEGATIVE_INTEGER { say "-ive Int" }
            when MSGPACK_OBJECT_FLOAT32          { say "Float 32-bit"}
            when MSGPACK_OBJECT_FLOAT64          { say "Float 64-bit"}
            when MSGPACK_OBJECT_STR              { say "Str" } 
            when MSGPACK_OBJECT_ARRAY {
                say "Array";
                my $array = $obj.via.array;
                say "Size: " ~ $array.size;
                for ^$array.size -> $i {
                    say "i: $i";
                    #say $array.ptr[$i].type;
                    #msgpack_object_array
                }
            } 
            when MSGPACK_OBJECT_MAP              { say "Hash" } 
            when MSGPACK_OBJECT_BIN              { say "Bin" } 
            when MSGPACK_OBJECT_EXT              { say "Extension" } 
            default {
                say "Unknown object type: " ~ $obj.type;
            }
        }
        
        #TODO reconstruct the Perl 6 object
        $ret = msgpack_unpack_next($result, $buffer, $len, $off);
    }

    # Cleanup
    msgpack_sbuffer_destroy($sbuf);
    msgpack_unpacked_destroy($result);
    
    if $ret == MSGPACK_UNPACK_CONTINUE {
        #TODO this should be our success criteria to return the result object
        say "All msgpack_object(s) in the buffer are consumed.";
    } elsif $ret == MSGPACK_UNPACK_PARSE_ERROR {
         #TODO exception
         die "The data in the buf is invalid format.";
    } else {
        say "Return type is $ret";
    }
}
