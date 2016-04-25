use v6;
unit class Algorithm::KdTree::Response is export is repr('CStruct');

use NativeCall;
use LibraryMake;
use NativeHelpers::Array;

my sub library {
    my $so = get-vars('')<SO>;
    return ~%?RESOURCES{"libkdtree$so"};
}

my sub kd_res_free(Algorithm::KdTree::Response) is native(&library) { * }
my sub kd_res_size(Algorithm::KdTree::Response) returns int32 is native(&library) { * }
my sub kd_res_rewind(Algorithm::KdTree::Response) is native(&library) { * }
my sub kd_res_end(Algorithm::KdTree::Response) returns int32 is native(&library) { * }
my sub kd_res_next(Algorithm::KdTree::Response) returns int32 is native(&library) { * }
my sub kd_res_item(Algorithm::KdTree::Response, CArray[num64]) returns Pointer is native(&library) { * }
my sub kd_res_item_data(Algorithm::KdTree::Response) returns Pointer is native(&library) { * }
my CArray[num64] $c-pos;
my int32 $c-dim = 0;
my Pointer $c-data;
my int32 $c-index = 0;

method size() returns Int {
    return kd_res_size(self);
}

method is-end() {
    return (kd_res_end(self) == 0 ?? False !! True);
}

method next() returns Algorithm::KdTree::Response {
    kd_res_next(self);
    return self;
}

method set-dimension(Int $p6-dim) {
    $c-dim = $p6-dim;
    return self;
}

method get-position() {
    my @array <== map { 0e0 } <== [0..^$c-dim];
    $c-pos = copy-to-carray(@array, num64);
    $c-data = kd_res_item(self, $c-pos);
    return copy-to-array($c-pos, $c-dim);
}

submethod DESTROY {
    kd_res_free(self);
}
