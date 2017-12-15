unit module LIVR::Utils;

our sub is-no-value($value --> Bool:D) is export {
    return False if $value ~~ Array;
    return False if $value ~~ Hash;
    return !$value.defined || $value eq '' 
}

our sub looks-like-number($value --> Bool:D) is export {
    return $value ~~ /^\-?\d<[\d.]>*$/ 
        && $value.comb.grep(* eq '.').elems <= 1;
}
