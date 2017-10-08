use v6;

unit class Test::Base::Actions;

use Test::Base::Block;

method TOP($/) {
    $/.make: $/<block>».made;
}

method block($/) {
    my %pairs = $/<data>».made;
    $/.make: Test::Base::Block.new(
        ~$/<title>, %pairs
    );
}

method data:sym<single>($/) {
    $/.make: ~$/<key> => ~$/<value>
}

method data:sym<multi>($/) {
    $/.make: ~$/<key> => ~$/<value>
}

