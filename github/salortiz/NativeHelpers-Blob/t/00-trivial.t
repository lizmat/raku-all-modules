use v6;
use NativeCall;
use Test;

plan 1;

constant is-win = Rakudo::Internals.IS-WIN();
constant HANDLE = uint32;
sub GetProcessHeap(--> HANDLE) is native('kernel32') { * };

our sub MyMalloc(Int $size) {
    sub malloc(size_t --> Pointer) is native { * };
    sub HeapAlloc(HANDLE, uint32, size_t -->Pointer) is native('kernel32') { * }

    if is-win {
        my \h = GetProcessHeap;
        HeapAlloc(h, 0, $size);
    } else {
        malloc($size);
    }
}

our sub MyFree(Pointer $ptr) {
    sub free(Pointer) is native { * };
    sub HeapFree(HANDLE, uint32, Pointer) is native('kernel32') { * }
    if is-win {
        my \h = GetProcessHeap;
        HeapFree(h, 0, $ptr);
    } else {
        free($ptr);
    }
}

our sub FreeTry {
    my $p = MyMalloc(10 * nativesizeof(uint8));
    say "Got $p";
    MyFree($p);
}

lives-ok { FreeTry }, "NC works";
