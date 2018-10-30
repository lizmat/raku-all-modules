use v6;

=begin pod

=head1 NAME

NativeHelpers::Array - helper subroutines for native arrays

=head1 DESCRIPTION

This provides a number of exported subroutines that may be useful for
working with native L<CArray>s.  The subroutines aren't particularly
complicated but it saves having to have the same code in multiple modules.

=head1 SUBROUTINES

=head2 sub copy-to-carray

    sub copy-to-carray(@items, Mu $type) returns CArray is export

Copy the array to the new CArray typed as per C<$type>. If the supplied type
is not a valid native type there will be an exception.  If the elements of the
array are out of range for the type then the values in the CArray may be 
truncated.

=head2 sub copy-to-array

    sub copy-to-array(CArray $carray, Int $items) returns Array is export

Copy the supplied CArray of the given length to a new Array.

=head2 sub copy-buf-to-carray

    sub copy-buf-to-carray(Buf $buf) returns CArray[uint8] is export

Copy the elements of the supplied L<Buf> to a L<CArray[uint8]>.

=head2 sub copy-carray-to-buf(

    sub copy-carray-to-buf(CArray $array, Int $no-elems) returns Buf is export

Copy the L<CArray[uint8]> of the specified number of elements to a L<Buf>

=end pod


module NativeHelpers::Array {

    use NativeCall;

    sub copy-to-carray(@items, Mu $type) returns CArray is export {
        my $array = CArray[$type].new;
        $array[$_] = @items[$_] for ^@items.elems;
        $array;
    }

    sub copy-to-array(CArray $carray, Int $items) returns Array is export {
        my @array;
        @array[$_] = $carray[$_] for ^$items;
        @array;
    }

    sub copy-buf-to-carray(Buf $buf) returns CArray[uint8] is export {
        my $carray = CArray[uint8].new;
        $carray[$_] = $buf[$_] for ^$buf.elems;
        $carray;
    }

    sub copy-carray-to-buf(CArray $array, Int $no-elems) returns Buf is export {
        my $buf = Buf.new;
        $buf[$_] = $array[$_] for ^$no-elems;
        $buf;
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
