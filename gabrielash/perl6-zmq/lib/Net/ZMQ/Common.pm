#!/usr/bin/env perl6

unit module Net::ZMQ::Common;
use NativeCall;
use v6;

role CArray-CStruct[Mu:U \T where .REPR eq 'CStruct']
      does Positional[T]
      does Iterable
      is export {
  my $doc = q:to/END/;
  see
  https://stackoverflow.com/questions/43544931/passing-an-array-of-structures-to-a-perl-6-nativecall-function

  END
  #:

    has $.bytes;
    has $.elems;

    method new(UInt $n) {
        self.bless(bytes => buf8.allocate($n * nativesizeof T), elems => $n);
    }

    method AT-POS(UInt $i where ^$!elems) {
        nativecast(T, Pointer.new(nativecast(Pointer, $!bytes) + $i * nativesizeof T));
    }

    method iterator( --> Iterator:D) {
      return
        class :: does Iterator {
            has $.index is rw = 0;
            has $.sz;
            has $.array is required;
            method TWEAK { $!sz = $!array.elems }
            method pull-one {
                $.sz > $.index ?? $.array.AT-POS($.index++) !! IterationEnd;
            }
          }.new(array => self)
    }
    method as-pointer {
        nativecast(Pointer[T], $!bytes);
    }
}


sub positive(Numeric $x) is export  {!$x.defined or $x > 0 }
sub unsigned(Numeric $x) is export  {!$x.defined or $x >= 0 }
sub uint-bool($x) is export  {!$x.defined or Int($x) >= 0 }
sub sub( $x )    is export  {!$x.defined
#                                      || ($x === True)
#                                      || ($x.WHAT === Bool )
                                      || ($x.WHAT === Sub )
                                    }
