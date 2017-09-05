#!/usr/bin/env perl6

unit module Net::ZMQ::Common;
use NativeCall;
use v6;


role CArray-CStruct[Mu:U \T where .REPR eq 'CStruct']
      does Positional[T]
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

    method as-pointer {
        nativecast(Pointer[T], $!bytes);
    }
}


sub positive(Numeric $x) is export  {!$x.defined or $x > 0 }
sub unsigned(Numeric $x) is export  {!$x.defined or $x >= 0 }
sub c-unsigned($x) is export  {!$x.defined or Int($x) >= 0 }

sub sub-or-true( $x )    is export  {!$x.defined
#                                      || ($x === True)
                                      || ($x.WHAT === Bool )
                                      || ($x.WHAT === Sub )
                                    }
