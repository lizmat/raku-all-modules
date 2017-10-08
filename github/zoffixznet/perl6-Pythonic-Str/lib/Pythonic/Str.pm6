unit module Pythonic::Str;

proto sub postcircumfix:<[ ]> (|) is export {*}
multi sub postcircumfix:<[ ]>(Str:D \SELF, Int:D \i, *%_) is export {
    nextsame if %_;
    SELF.substr(i, 1) || Nil
}
multi sub postcircumfix:<[ ]>(Str:D \SELF, |c) is default is export {
    my $r := CORE::{'&postcircumfix:<[ ]>'}(SELF.comb.cache, |c);
    $r ~~ Failure || $r.flat.first({ $_ ~~ any Failure, none Nil, Str }) !=== Nil
        ?? $r
        !! $r.flat.grep(*.defined).join
}
multi sub postcircumfix:<[ ]>(|c) is export {
    CORE::{'&postcircumfix:<[ ]>'}(|c)
}
