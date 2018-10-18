use v6;

use nqp;
use NativeCall;

constant LIB = 'tcc';

constant TCC_OUTPUT_MEMORY = 1;
constant TCC_RELOCATE_AUTO = 1;

class TCC is repr('CPointer')
{
    sub tcc_new() returns TCC is native(LIB) {...}

    sub tcc_set_options(TCC, Str) returns int32 is native(LIB) {...}

    sub tcc_delete(TCC) is native(LIB) {...}

    sub tcc_set_output_type(TCC, int32) returns int32 is native(LIB) {...}

    sub tcc_compile_string(TCC, Str) returns int32 is native(LIB) {...}

    sub tcc_relocate(TCC, int64) returns int32 is native(LIB) {...}

    sub tcc_get_symbol(TCC, Str) returns Pointer is native(LIB) {...}

    method new($compile-options)
    {
        my $self = tcc_new;

        tcc_set_options($self, $compile-options) == -1
            and die "Bad TCC options [$compile-options]";

        tcc_set_output_type($self, TCC_OUTPUT_MEMORY);

        $self
    }

    method compile(Str $code)
    {
        tcc_compile_string(self, $code) == -1
            and die "Failed to compile [$code]";
    }

    method add-symbol(&callback, :$name = &callback.name)
    {
        # Start with basic signature
        my $sig := :(TCC, Str, &cb --> int32);

        # Replace &cb sub-signature with calling signature from callback.
        nqp::bindattr($sig.params[2], Parameter, '$!sub_signature',
                      &callback.signature);

        # Construct the NativeCall subroutine to add the symbol
        my &tcc_add_symbol := sub {};
        &trait_mod:<is>(&tcc_add_symbol, native => LIB);
        &trait_mod:<is>(&tcc_add_symbol, symbol => 'tcc_add_symbol');
        nqp::bindattr(&tcc_add_symbol, Code, '$!signature', $sig);

        # Add the symbol
        tcc_add_symbol(self, $name, &callback);
    }

    method relocate { tcc_relocate(self, TCC_RELOCATE_AUTO) }

    multi method bind(Str $name, Signature $sig)
    {
        nativecast($sig, (tcc_get_symbol(self, $name) // fail "No $name"))
    }

    multi method bind(Str $name, Mu:U $type, &store-func?) is rw
    {
        Proxy.new:
	    FETCH => -> $
	    {
                nativecast($type,
                           (tcc_get_symbol(self, $name) // fail "No $name"))
            },
            STORE => -> $, $new
	    {
	        die "No store function defined for $name" unless &store-func;
	        store-func($new)
            };
    }

    submethod DESTROY() { tcc_delete(self) }
}
