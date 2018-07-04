use v6.c;
unit module NativeHelpers::CBuffer:ver<0.0.3>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

use nqp;
use NativeCall;

class CBuffer is repr('CPointer') is export { 
   my $types = (uint8, int8, uint16, int16, uint32, int32, uint64, int64, size_t, long, ulong, longlong, ulonglong);
   sub code(::T --> size_t) { my size_t $ret = ($types.grep: T, :k).iterator.pull-one; $ret };

   sub calloc(size_t $count, size_t $size --> Pointer) is native { }
   sub strncpy(Pointer $dst, Str $src, size_t $len --> CBuffer) is native { }
   sub memcpy_A(Pointer $dest, Blob:D $src, size_t $size --> Pointer) is native is symbol('memcpy') { }
   sub memcpy_B(Blob:D $dest, CBuffer $src, size_t $size --> Pointer) is native is symbol('memcpy') { }
   sub free(Pointer $what) is native { }

   method elems(--> Int:D) {
       my Pointer[size_t] $size_loc = nqp::box_i(nqp::unbox_i(nqp::decont(self)) - nativesizeof(size_t), Pointer[size_t]);
       $size_loc.deref;
   }

   method type() {
       my Pointer[size_t] $type_loc = nqp::box_i(nqp::unbox_i(nqp::decont(self)) - 2 * nativesizeof(size_t), Pointer[size_t]);
       $types[$type_loc.deref];
   }

   method bytes(--> Int:D) {
       self.elems * nativesizeof(self.type);
   }

   multi method new(Int $size, :$with, :$of-type where { $of-type ∈ $types } = uint8) {
       my Pointer $type_loc = calloc($size * nativesizeof($of-type) + 2 * nativesizeof(size_t), 1) or
           die "Failed to allocate (out of memory)";

       my Pointer $size_loc = Pointer.new(+$type_loc + nativesizeof(size_t));
       my Pointer $data_loc = Pointer.new(+$size_loc + nativesizeof(size_t));

       if (defined($with)) {
           given $with {
               when Str {
                   strncpy($data_loc, $_, $size * nativesizeof($of-type));
               }
               when Blob {
                   memcpy_A($data_loc, $_, .bytes min ($size * nativesizeof($of-type)) );
               }
               default {
                   die 'Expected Blob or Str initialization for CBuffer';
               }
           }
       }

       memcpy_A($type_loc, Blob[size_t].new(code($of-type)), nativesizeof(size_t));
       memcpy_A($size_loc, Blob[size_t].new($size),     nativesizeof(size_t));
       nativecast(CBuffer, $data_loc);
   }

   multi method new(Blob:D $init) {
       self.new($init.elems, :with($init), :of-type($init.of));
   }

   multi method new(Str:D $init) {
       self.new(($init ~ "\x0").encode('ascii'));
   }

   multi method new() {
       die "No default constructor for 'CBuffer', please specify the size to be allocated";
   }

   method Blob(--> Blob:D) {
       my $t = self.type;
       my Blob[$t] $b = Blob[$t].new(0 xx self.elems);
       memcpy_B($b, self, self.bytes);
       $b;
   }

   method Pointer(--> Pointer) { nativecast(Pointer[self.type], self) }

   method Str(--> Str:D) {
       do with self.Blob { .substr(0, .index("\0")) given .decode("ascii") };
   }

   method gist(--> Str:D) { self.Str; }

   method free() {
       if (defined self) {
           my Pointer $type_loc = nqp::box_i(nqp::unbox_i(nqp::decont(self)) - 2 * nativesizeof(size_t), Pointer);
           free($type_loc);
       }
   }
}
