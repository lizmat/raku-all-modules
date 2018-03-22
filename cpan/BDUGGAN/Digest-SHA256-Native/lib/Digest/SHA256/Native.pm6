unit module Digest::SHA256::Fast;

use NativeCall;

constant SHA256 = %?RESOURCES<libraries/sha256>;

sub compute_sha256(Blob, size_t, CArray[uint8]) is native( SHA256 ) { * }

multi sub sha256-hex(Str $in) is export {
    sha256-hex($in.encode);
}

multi sub sha256-hex(Blob $in) is export {
    my size_t $len = $in.elems;

    my CArray[uint8] $hash .= new;
    $hash[127] = 0;

    compute_sha256($in,$len,$hash);

    my $str = $hash.list».chr.join.lc;

    return $str.substr(0,64);
}

sub sha256($in) is export {
    Blob.new( sha256-hex($in).comb(2).map({ :16($_) }))
}
