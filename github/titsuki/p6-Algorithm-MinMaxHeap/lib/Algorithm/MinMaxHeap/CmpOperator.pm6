use v6;

unit module Algorithm::MinMaxHeap::CmpOperator;

use Algorithm::MinMaxHeap::Comparable;

multi sub infix:<minmaxheap-cmp>(Mu $lhs, Mu $rhs) is export {
    return $lhs cmp $rhs;
}

multi sub infix:<minmaxheap-cmp>(Algorithm::MinMaxHeap::Comparable $lhs, Algorithm::MinMaxHeap::Comparable $rhs) returns Order:D is export {
    return $lhs.compare-to($rhs);
}

