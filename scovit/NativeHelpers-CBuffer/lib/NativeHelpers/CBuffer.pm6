use v6.c;
unit module NativeHelpers::CBuffer:ver<0.0.2>:auth<Vittore F Scolari (vittore.scolari@gmail.com)>;

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

   method size(--> Int) {
       my Pointer[size_t] $size_loc = nqp::box_i(nqp::unbox_i(nqp::decont(self)) - nativesizeof(size_t), Pointer[size_t]);
       $size_loc.deref;
   }
   
   method type() {
       my Pointer[size_t] $type_loc = nqp::box_i(nqp::unbox_i(nqp::decont(self)) - 2 * nativesizeof(size_t), Pointer[size_t]);
       $types[$type_loc.deref];
   }

   multi method new(Int $size, :$init, :$type where { $type ∈ $types } = uint8) {
       my Pointer $type_loc = calloc($size * nativesizeof($type) + 2 * nativesizeof(size_t), 1) or
           die "Failed to allocate (out of memory)";

       my Pointer $size_loc = Pointer.new(+$type_loc + nativesizeof(size_t));
       my Pointer $data_loc = Pointer.new(+$size_loc + nativesizeof(size_t));

       if (defined($init)) {
           given $init {
               when Str {
                   strncpy($data_loc, $_, $size * nativesizeof($type));
               }
               when Blob {
                   memcpy_A($data_loc, $_, .bytes min ($size * nativesizeof($type)) );
               }
               default {
                   die 'Expected Blob or Str initialization for CBuffer';
               }
           }
       }

       memcpy_A($type_loc, Blob[size_t].new(code($type)), nativesizeof(size_t));
       memcpy_A($size_loc, Blob[size_t].new($size),       nativesizeof(size_t));
       nativecast(CBuffer, $data_loc);
   }

   multi method new(Blob $init) {
       self.new($init.bytes, :init($init));
   }

   multi method new(Str $init) {
       self.new(($init ~ "\x0").encode('ascii'));
   }

   multi method new() {
       die "No default constructor for 'CBuffer', please specify the size to be allocated";
   }

   method Blob(--> Blob) {
       my $t = self.type;
       my Blob[$t] $b = Blob[$t].new(0 xx self.size);
       memcpy_B($b, self, self.size * nativesizeof(self.type));
       $b;
   }

   method Pointer(--> Pointer) { nativecast(Pointer[self.type], self) }

   method Str(--> Str) {
       do with self.Blob { .substr(0, .index("\0")) given .decode("ascii") };
   }

   method gist(--> Str) { self.Str; }

   method free() {
       if (defined self) {
           my Pointer $type_loc = nqp::box_i(nqp::unbox_i(nqp::decont(self)) - 2 * nativesizeof(size_t), Pointer);
           free($type_loc);
       }
   }
}
