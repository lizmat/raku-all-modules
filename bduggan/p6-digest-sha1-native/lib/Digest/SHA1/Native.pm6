unit module Digest::SHA1::Fast;

use NativeCall;

constant SHA1 = %?RESOURCES<libraries/sha1>.absolute;

sub compute_sha1(Blob, size_t, CArray[uint8]) is native( SHA1 ) { * }

multi sub sha1-hex(Str $in) is export {
    sha1-hex($in.encode);
}

multi sub sha1-hex(Blob $in) is export {
    my size_t $len = $in.elems;

    my CArray[uint8] $hash .= new;
    $hash[79] = 0;

    compute_sha1($in,$len,$hash);

    my $str = $hash.list».chr.join.lc;

    return $str.substr(0,40);
}

sub sha1($in) is export {
    Blob.new( sha1-hex($in).comb(2).map({ :16($_) }))
}
